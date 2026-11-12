import { migration001 } from './migrations/001_initial_schema.js';
import { migration002 } from './migrations/002_seed_catalog.js';

export const migrations=[migration001,migration002];

export async function migrationStatus(store) {
  const status=[];
  for(const migration of migrations) {
    status.push({
      id:migration.id,
      description:migration.description,
      applied:Boolean(await store.get('_migrations/' + migration.id)),
    });
  }
  return status;
}

export async function runMigrations(store,{logger=console}={}) {
  const applied=[];
  const skipped=[];
  for(const migration of migrations) {
    const path='_migrations/' + migration.id;
    if(await store.get(path)) {
      skipped.push(migration.id);
      logger.info('Migration já aplicada: ' + migration.id);
      continue;
    }
    const now=new Date().toISOString();
    await migration.up({store,now});
    await store.set(path,{description:migration.description,appliedAt:now});
    applied.push(migration.id);
    logger.info('Migration aplicada: ' + migration.id);
  }
  return {applied,skipped};
}
