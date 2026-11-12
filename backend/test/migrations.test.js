import { test } from 'node:test';
import assert from 'node:assert/strict';
import { MemoryStore } from '../src/store.js';
import { places, restaurants } from '../src/fixtures.js';
import { migrationStatus,runMigrations } from '../src/database/migrate.js';

test('migrations iniciais são versionadas e idempotentes',async()=>{
  const store=new MemoryStore({seed:false});
  const logger={info(){}};
  const first=await runMigrations(store,{logger});
  assert.deepEqual(first.applied,['001_initial_schema','002_seed_catalog']);
  assert.equal((await store.get('_meta/schema')).version,1);
  assert.equal((await store.list('places')).length,places.length);
  assert.equal((await store.list('restaurants')).length,restaurants.length);

  const second=await runMigrations(store,{logger});
  assert.deepEqual(second.applied,[]);
  assert.deepEqual(second.skipped,['001_initial_schema','002_seed_catalog']);
  assert.ok((await migrationStatus(store)).every(item=>item.applied));
});
