import { loadConfig } from '../src/config/env.js';
import { connectFirebase } from '../src/database/firebase.js';
import { runMigrations } from '../src/database/migrate.js';
import { FirestoreStore } from '../src/store.js';

const config=loadConfig();
if(config.mode!=='firebase') {
  throw new Error('Defina DATA_MODE=firebase para executar migrations persistentes.');
}
const {db}=connectFirebase();
const result=await runMigrations(new FirestoreStore(db));
console.log('Migrations concluídas. Aplicadas: ' + result.applied.length + '; já existentes: ' + result.skipped.length + '.');
