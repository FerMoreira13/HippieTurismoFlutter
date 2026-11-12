import { createApp } from './app.js';
import { buildRuntime } from './application/bootstrap.js';
import { loadConfig } from './config/env.js';

const config=loadConfig();
const runtime=buildRuntime(config);
const app=createApp({...runtime,placesKey:config.googlePlacesApiKey});
const server=app.listen(config.port,config.host,()=>console.log(
  'Hippie Turismo: http://' + config.host + ':' + config.port + ' • ' +
  config.mode + (config.mode==='demo' ? ' • catálogo fictício, contas e alterações salvas localmente' : '')
));
for(const signal of ['SIGINT','SIGTERM']) {
  process.on(signal,()=>server.close(()=>process.exit(0)));
}
