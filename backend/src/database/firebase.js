import { applicationDefault, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

export function connectFirebase() {
  const app=getApps()[0] ?? initializeApp({credential:applicationDefault()});
  const db=getFirestore(app);
  db.settings({ignoreUndefinedProperties:true});
  return {app,db,auth:getAuth(app)};
}
