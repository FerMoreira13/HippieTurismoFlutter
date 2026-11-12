import {test} from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {regionalPlaces} from '../src/regional-catalog.js';
import {LocalDatabase} from '../src/database/local.js';
import {LocalStore, MemoryStore} from '../src/store.js';
import {createApp} from '../src/app.js';

test('catálogo possui atrações reais e fontes, sem fotos fictícias ou gratuidade presumida', () => {
  assert.equal(regionalPlaces.length, 14);
  assert.equal(new Set(regionalPlaces.map(p => p.id)).size, 14);
  assert.ok(regionalPlaces.every(p => !p.demo && p.website.startsWith('https://') && !p.imageAsset));
  assert.equal(regionalPlaces.find(p => p.id === 'complexo-salgadeira').priceKnown, false);
});

test('atualizar banco existente acrescenta atrações sem substituir conta, favorito, relato ou edição administrativa', async () => {
  const dir = mkdtempSync(join(tmpdir(), 'hippie-catalog-'));
  try {
    const db = new LocalDatabase(join(dir, 'demo.json'));
    db.save('accounts', [['viajante@example.com', {uid:'existing'}]]);
    const edited = {...regionalPlaces[0], name:'Nome editado pelo administrador'};
    db.save('documents', [
      ['places/' + edited.id, edited],
      ['users/existing/favorites/' + edited.id, {createdAt:'2026-10-01'}],
      ['places/' + edited.id + '/reviews/existing', {rating:5}],
    ]);
    const store = new LocalStore(db);
    assert.equal((await store.get('places/' + edited.id)).name, edited.name);
    assert.equal((await store.get('places/' + edited.id + '/reviews/existing')).rating, 5);
    assert.ok(await store.get('users/existing/favorites/' + edited.id));
    assert.equal(db.data.accounts[0][1].uid, 'existing');
    assert.ok(await store.get('places/chapada-praca-dom-wunibaldo'));
    const count = db.data.documents.length;
    new LocalStore(new LocalDatabase(db.file));
    assert.equal(new LocalDatabase(db.file).data.documents.length, count);
  } finally { rmSync(dir, {recursive:true, force:true}); }
});

test('busca regional inclui Cuiabá e Chapada sem ampliar o limite de restaurantes', async () => {
  const app = createApp({store:new MemoryStore(), verify:async () => ({uid:'test'})});
  const server = app.listen(0, '127.0.0.1');
  await new Promise(resolve => server.once('listening', resolve));
  try {
    const base = 'http://127.0.0.1:' + server.address().port;
    const options = {headers:{Authorization:'Bearer test'}};
    const query = '?lat=-15.5989&lng=-56.0949&radius=100000';
    const response = await fetch(base + '/places' + query, options);
    assert.equal(response.status, 200);
    const places = await response.json();
    for (const place of regionalPlaces) assert.ok(places.some(p => p.id === place.id), place.id);
    assert.equal((await fetch(base + '/restaurants' + query, options)).status, 400);
    assert.equal((await fetch(base + '/places?lat=0&lng=0&radius=100001', options)).status, 400);
  } finally { await new Promise(resolve => server.close(resolve)); }
});
