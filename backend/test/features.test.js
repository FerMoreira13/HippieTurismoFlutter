import {test} from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,readFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {LocalDatabase} from '../src/database/local.js';
import {LocalStore} from '../src/store.js';
import {createDemoAuth} from '../src/auth.js';
import {createApp} from '../src/app.js';

test('contas, favoritos e avaliações sobrevivem ao reinício; recuperação revoga sessões e usa código uma vez',async()=>{
  const file=join(mkdtempSync(join(tmpdir(),'hippie-persist-')),'db.json');
  let db=new LocalDatabase(file),store=new LocalStore(db),auth=createDemoAuth(db);
  const credentials={name:'Viajante',email:'viajante@example.com',password:'senha-local-123'};
  const first=auth.login(credentials,true);
  await store.set('users/'+first.user.uid+'/favorites/cachoeira-serena',{createdAt:new Date().toISOString()});
  await store.set('places/cachoeira-serena/reviews/'+first.user.uid,{rating:4,comment:'Ótimo passeio'});
  const serialized=readFileSync(file,'utf8');
  assert.ok(!serialized.includes(credentials.password));assert.ok(!serialized.includes(first.recoveryCode));
  db=new LocalDatabase(file);store=new LocalStore(db);auth=createDemoAuth(db);
  const login=auth.login(credentials);
  assert.equal(login.user.uid,first.user.uid);
  assert.equal((await store.list('users/'+login.user.uid+'/favorites')).length,1);
  assert.equal((await store.list('places/cachoeira-serena/reviews'))[0].rating,4);
  const recovered=auth.recover({...credentials,password:'nova-senha-123',recoveryCode:first.recoveryCode});
  await assert.rejects(()=>auth.verify(login.token));
  assert.throws(()=>auth.login(credentials));
  assert.throws(()=>auth.recover({...credentials,recoveryCode:first.recoveryCode}));
  auth=createDemoAuth(new LocalDatabase(file));
  assert.equal(auth.login({...credentials,password:'nova-senha-123'}).user.uid,first.user.uid);
  assert.equal(recovered.recoveryCode.length,32);
});

test('relatos, fotos, dados confiáveis e painel exigem autorização',async()=>{
  const db=new LocalDatabase(join(mkdtempSync(join(tmpdir(),'hippie-api-')),'db.json'));
  const store=new LocalStore(db),auth=createDemoAuth(db);
  const account=auth.login({name:'Viajante',email:'visitante@example.com',password:'senha-local-123'},true);
  const app=createApp({store,demoAuth:auth,verify:async token=>token==='admin-test'?{uid:'admin',name:'Admin',admin:true}:auth.verify(token)});
  const server=await new Promise(resolve=>{const s=app.listen(0,'127.0.0.1',()=>resolve(s));});
  const base='http://127.0.0.1:'+server.address().port;
  const call=async(method,path,body,token=account.token)=>{
    const response=await fetch(base+path,{method,headers:{'Content-Type':'application/json',Authorization:'Bearer '+token},body:body?JSON.stringify(body):undefined});
    const text=await response.text();return {status:response.status,data:text?JSON.parse(text):null};
  };
  try {
    assert.equal((await call('GET','/admin/places')).status,403);
    assert.equal((await call('GET','/admin/reports')).status,403);
    const report=await call('POST','/places/cachoeira-serena/reports',{reason:'closed',details:'O portão estava fechado na visita.'});
    assert.equal(report.status,201);
    assert.equal((await call('PATCH','/admin/reports/'+report.data.id,{status:'resolved'})).status,403);
    assert.equal((await call('GET','/admin/reports',null,'admin-test')).data.length,1);
    assert.equal((await call('PATCH','/admin/reports/'+report.data.id,{status:'resolved'},'admin-test')).status,204);
    assert.equal((await call('POST','/places/inexistente/reports',{reason:'closed',details:'Teste de local inexistente'})).status,404);
    assert.equal((await call('PUT','/places/cachoeira-serena/review',{rating:5,comment:'Boa visita',photo:'data:text/html;base64,PHNjcmlwdD4='})).status,400);
    assert.equal((await call('PUT','/places/cachoeira-serena/review',{rating:5,comment:'Boa visita',visitedOn:'2999-01-01'})).status,400);
    const photo='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y9Zl1sAAAAASUVORK5CYII=';
    assert.equal((await call('PUT','/places/cachoeira-serena/review',{rating:5,comment:'Boa visita',visitedOn:'2026-01-01',photo})).status,204);
    const detail=(await call('GET','/places/cachoeira-serena')).data;
    assert.equal(detail.reviews[0].photo,photo);
    const update={...detail,accessibility:'Rampa na entrada.',contact:'Contato de teste',status:'temporarily_closed',source:'Catálogo demonstrativo',verifiedAt:new Date().toISOString(),visitMinutes:90};
    assert.equal((await call('PUT','/admin/places/cachoeira-serena',update,'admin-test')).status,200);
    assert.equal((await call('GET','/places/cachoeira-serena')).data.accessibility,'Rampa na entrada.');
    assert.equal((await call('DELETE','/admin/places/cachoeira-serena/reviews/'+account.user.uid,null,'admin-test')).status,204);
    assert.equal((await call('GET','/places/cachoeira-serena')).data.reviews.length,0);
  }finally {await new Promise(resolve=>server.close(resolve));}
});
