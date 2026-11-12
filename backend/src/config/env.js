import { z } from 'zod';

const envSchema = z.object({
  DATA_MODE: z.enum(['demo', 'firebase']).default('demo'),
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  LOCAL_DATA_FILE: z.string().min(1).optional(),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
  HOST: z.string().trim().min(1).default('127.0.0.1'),
  GOOGLE_PLACES_API_KEY: z.string().trim().optional().default(''),
});

export function loadConfig(environment=process.env) {
  const result=envSchema.safeParse(environment);
  if(!result.success) {
    const details=result.error.issues
      .map(issue => issue.path.join('.') + ': ' + issue.message)
      .join('; ');
    throw new Error('Configuração inválida: ' + details);
  }
  if(result.data.DATA_MODE==='demo' && result.data.NODE_ENV==='production') {
    throw new Error('Modo demo não pode ser publicado em produção.');
  }
  return {
    localDataFile:result.data.NODE_ENV==='test'?null:(result.data.LOCAL_DATA_FILE??'.data/demo.json'),
    mode:result.data.DATA_MODE,
    nodeEnv:result.data.NODE_ENV,
    port:result.data.PORT,
    host:result.data.HOST,
    googlePlacesApiKey:result.data.GOOGLE_PLACES_API_KEY,
  };
}
