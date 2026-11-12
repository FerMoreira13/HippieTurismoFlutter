import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');

function readJson(path) {
  return JSON.parse(readFileSync(resolve(root, path), 'utf8'));
}

function readEnv(path) {
  return Object.fromEntries(
    readFileSync(resolve(root, path), 'utf8')
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter((line) => line && !line.startsWith('#'))
      .map((line) => {
        const separator = line.indexOf('=');
        return [line.slice(0, separator), line.slice(separator + 1)];
      }),
  );
}

const environments = [
  {
    name: 'desenvolvimento',
    backend: readEnv('backend/.env.development'),
    mobile: readJson('mobile/config.development.json'),
    nodeEnv: 'development',
    port: '3000',
    appEnv: 'development',
  },
  {
    name: 'testes',
    backend: readEnv('backend/.env.test'),
    mobile: readJson('mobile/config.test.json'),
    nodeEnv: 'test',
    port: '3001',
    appEnv: 'test',
  },
];

for (const environment of environments) {
  const expectedApi = `http://10.0.2.2:${environment.port}`;
  if (
    environment.backend.NODE_ENV !== environment.nodeEnv ||
    environment.backend.DATA_MODE !== 'demo' ||
    environment.backend.PORT !== environment.port ||
    environment.mobile.APP_ENV !== environment.appEnv ||
    environment.mobile.DEMO_MODE !== 'true' ||
    environment.mobile.API_URL !== expectedApi
  ) {
    throw new Error(`Configuração inválida no ambiente de ${environment.name}.`);
  }
}

const productionBackend = readEnv('backend/.env.production.example');
const productionMobile = readJson('mobile/config.production.example.json');
if (
  productionBackend.NODE_ENV !== 'production' ||
  productionBackend.DATA_MODE !== 'firebase' ||
  productionMobile.APP_ENV !== 'production' ||
  productionMobile.DEMO_MODE !== 'false' ||
  !productionMobile.API_URL.startsWith('https://')
) {
  throw new Error('Configuração de exemplo de produção inválida.');
}

console.log('Ambientes de desenvolvimento, testes e produção validados.');
