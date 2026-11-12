import { existsSync, copyFileSync } from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { resolve, dirname } from 'node:path';

const root=resolve(dirname(fileURLToPath(import.meta.url)), '..');
const backend=resolve(root,'backend');
const port=Number(process.env.PORT || 3000);
const healthHost=process.env.HOST === '0.0.0.0' ? '127.0.0.1' : (process.env.HOST || '127.0.0.1');
const serverUrl=`http://${healthHost}:${port}`;
for(const [source,target] of [['backend/.env.example','backend/.env'],['mobile/config.example.json','mobile/config.local.json']]) {
  if(!existsSync(resolve(root,target))) copyFileSync(resolve(root,source),resolve(root,target));
}
if(!existsSync(resolve(backend,'node_modules/express'))) {
  console.error('Instale as dependencias do servidor: na pasta backend, execute npm ci.');
  process.exit(1);
}
async function running(){
  try {
    const r=await fetch(`${serverUrl}/health`,{signal:AbortSignal.timeout(1500)});
    const data=await r.json();
    if(data.status==='ok' && ['demo','firebase'].includes(data.mode)) return true;
    throw new Error(`A porta ${port} esta ocupada por outro servidor.`);
  } catch(error) {
    if(error.message.includes('ocupada')) throw error;
    return false;
  }
}
if(!await running()) {
  console.log(`Iniciando servidor Hippie em ${serverUrl}...`);
  process.chdir(backend);
  await import(pathToFileURL(resolve(backend,'src/server.js')).href);
} else {
  console.log(`Hippie Turismo: servidor existente em ${serverUrl}`);
}
