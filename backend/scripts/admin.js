import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
const uid=process.argv[2];
if(!uid) throw new Error('Uso: npm run admin -- UID_DO_USUARIO');
initializeApp({credential:applicationDefault()});
const auth=getAuth(),user=await auth.getUser(uid);
await auth.setCustomUserClaims(uid,{...user.customClaims,admin:true});
console.log('Administrador definido. O usuário deve sair e entrar novamente.');
