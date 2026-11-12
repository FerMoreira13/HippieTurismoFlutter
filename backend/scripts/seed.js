import { loadConfig } from '../src/config/env.js';
import { connectFirebase } from '../src/database/firebase.js';
import { FirestoreStore } from '../src/store.js';
import { places,restaurants } from '../src/fixtures.js';

const config=loadConfig();
if(config.mode!=='firebase') throw new Error('O modo demo já possui exemplos. Para importar, use DATA_MODE=firebase.');
const {db}=connectFirebase();
const store=new FirestoreStore(db);
for(const [collection,items] of Object.entries({places,restaurants})) {
  for(const item of items) {
    const path=collection + '/' + item.id;
    if(!await store.get(path)) await store.set(path,item);
  }
}
console.log('Exemplos fictícios importados; registros existentes foram preservados.');
