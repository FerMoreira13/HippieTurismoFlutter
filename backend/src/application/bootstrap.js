import { createDemoAuth } from '../auth.js';
import { connectFirebase } from '../database/firebase.js';
import { FirestoreStore, MemoryStore, LocalStore } from '../store.js';

import { LocalDatabase } from '../database/local.js';

export function buildRuntime(config) {
  if(config.mode==='firebase') {
    const {db,auth}=connectFirebase();
    return {
      store:new FirestoreStore(db),
      verify:token => auth.verifyIdToken(token,true),
      demoAuth:null,
    };
  }
  const database=config.localDataFile?new LocalDatabase(config.localDataFile):null;
  const demoAuth=createDemoAuth(database);
  return {
    store:database?new LocalStore(database):new MemoryStore(),
    verify:demoAuth.verify,
    demoAuth,
  };
}
