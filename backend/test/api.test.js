import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { createApp } from '../src/app.js';
import { MemoryStore } from '../src/store.js';
import { createDemoAuth } from '../src/auth.js';
import { distanceMeters, rankNearby } from '../src/domain.js';

let server,base,alice,bob;
const store=new MemoryStore(),auth=createDemoAuth();
before(async()=>{
  const app=createApp({store,demoAuth:auth,verify:async token=>token==='test-admin'?{uid:'admin',name:'Admin',admin:true}:auth.verify(token)});
  server=await new Promise(resolve=>{const s=app.listen(0,'127.0.0.1',()=>resolve(s));});
  base=`http://127.0.0.1:${server.address().port}`;
});
after(()=>new Promise(resolve=>server.close(resolve)));
async function call(method,path,body,token){
 const res=await fetch(base+path,{method,headers:{'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:body===undefined?undefined:JSON.stringify(body)});
 const text=await res.text();return {status:res.status,body:text?JSON.parse(text):null};
}
test('GPS: distância em metros e ordenação por raio',()=>{
 assert.equal(distanceMeters({lat:0,lng:0},{lat:0,lng:0}),0);
 assert.ok(Math.abs(distanceMeters({lat:0,lng:0},{lat:0,lng:1})-111195)<10);
 assert.deepEqual(rankNearby([{id:'longe',lat:0,lng:2},{id:'perto',lat:0,lng:0.001}],{lat:0,lng:0},500).map(p=>p.id),['perto']);
});
test('cadastro, login, senha incorreta e ausência de senha no perfil',async()=>{
 const a=await call('POST','/auth/register',{name:'Alice',email:'alice@example.com',password:'senha-forte-123'});
 assert.equal(a.status,201);alice=a.body.token;
 const b=await call('POST','/auth/register',{name:'Bob',email:'bob@example.com',password:'senha-forte-123'});bob=b.body.token;
 assert.equal((await call('POST','/auth/login',{email:'alice@example.com',password:'incorreta'})).status,401);
 assert.equal((await call('POST','/auth/login',{email:'ALICE@example.com',password:'senha-forte-123'})).status,200);
 const me=await call('GET','/me',undefined,alice);assert.equal(me.body.name,'Alice');assert.equal(me.body.password,undefined);assert.equal(me.body.admin,false);
});
test('dados e alterações exigem autenticação',async()=>{
 assert.equal((await call('GET','/places?lat=0&lng=0')).status,401);
 assert.equal((await call('PUT','/favorites/cachoeira-serena',{},'invalido')).status,401);
});
test('proximidade, validação e local inexistente',async()=>{
 const result=await call('GET','/places?lat=-15.5989&lng=-56.0949&radius=500',undefined,alice);
 assert.equal(result.status,200);assert.equal(result.body[0].id,'cachoeira-serena');assert.equal(result.body[0].distance,0);
 assert.ok(result.body.every(p=>p.distance<=500));
 assert.equal((await call('GET','/places?lat=91&lng=0',undefined,alice)).status,400);
 assert.equal((await call('GET','/places?lat=0&lng=0&radius=-1',undefined,alice)).status,400);
 assert.equal((await call('GET','/places?lng=0',undefined,alice)).status,400);
 assert.equal((await call('GET','/places/ausente',undefined,alice)).status,404);
});
test('favoritos são idempotentes e privados por usuário',async()=>{
 for(let i=0;i<2;i++) assert.equal((await call('PUT','/favorites/cachoeira-serena',{},alice)).status,204);
 assert.equal((await call('GET','/favorites',undefined,alice)).body.length,1);
 assert.equal((await call('GET','/favorites',undefined,bob)).body.length,0);
 assert.equal((await call('PUT','/favorites/ausente',{},alice)).status,404);
 await call('DELETE','/favorites/cachoeira-serena',undefined,alice);
 assert.equal((await call('GET','/favorites',undefined,alice)).body.length,0);
});
test('avaliação pertence ao token, valida nota e permite edição sem duplicação',async()=>{
 assert.equal((await call('PUT','/places/cachoeira-serena/review',{rating:6,comment:'Bom local'},alice)).status,400);
 await call('PUT','/places/cachoeira-serena/review',{rating:5,comment:'Bom passeio',userId:'forjado'},alice);
 await call('PUT','/places/cachoeira-serena/review',{rating:3,comment:'Experiência atualizada'},alice);
 await call('PUT','/places/cachoeira-serena/review',{rating:5,comment:'Muito agradável'},bob);
 const detail=(await call('GET','/places/cachoeira-serena',undefined,alice)).body;
 assert.equal(detail.reviewCount,2);assert.equal(detail.rating,4);
 assert.ok(detail.reviews.every(r=>r.userId!=='forjado'));
});
test('admin: nega usuário comum, atualiza local e modera avaliação',async()=>{
 const p={name:'Local de teste',description:'Descrição válida para os testes.',category:'Cultura',lat:0,lng:0,address:'Teste',hours:'9h às 17h',price:0};
 assert.equal((await call('PUT','/admin/places/teste',p,alice)).status,403);
 assert.equal((await call('PUT','/admin/places/teste',p,'test-admin')).status,200);
 assert.equal((await call('PUT','/admin/places/teste',{...p,lat:100},'test-admin')).status,400);
 const uid=(await call('GET','/me',undefined,alice)).body.uid;
 assert.equal((await call('DELETE',`/admin/places/cachoeira-serena/reviews/${uid}`,undefined,'test-admin')).status,204);
 assert.equal((await call('GET','/places/cachoeira-serena',undefined,bob)).body.reviewCount,1);
});
test('restaurantes do catálogo possuem distância e fonte',async()=>{
 const r=await call('GET','/restaurants?lat=-15.5989&lng=-56.0949&radius=3000',undefined,alice);
 assert.equal(r.status,200);assert.equal(r.body.source,'catalog');assert.equal(r.body.items.length,2);assert.ok(r.body.items[0].distance>=0);
});
test('Google Places indisponível mantém catálogo e informa fallback',async()=>{
 const app=createApp({store,verify:auth.verify,placesKey:'test-key',fetchImpl:async()=>{throw new Error('offline');}});
 const temp=await new Promise(resolve=>{const s=app.listen(0,'127.0.0.1',()=>resolve(s));});
 try {
  const response=await fetch(`http://127.0.0.1:${temp.address().port}/restaurants?lat=-15.5989&lng=-56.0949`,{headers:{Authorization:`Bearer ${alice}`}});
  const body=await response.json();assert.equal(body.source,'catalog');assert.ok(body.warning);assert.equal(body.items.length,2);
 } finally {await new Promise(resolve=>temp.close(resolve));}
});
test('logout invalida sessão de demonstração',async()=>{
 assert.equal((await call('POST','/auth/logout',{},bob)).status,204);
 assert.equal((await call('GET','/me',undefined,bob)).status,401);
});

