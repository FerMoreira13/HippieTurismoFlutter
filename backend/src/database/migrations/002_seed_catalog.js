import { places,restaurants } from '../../fixtures.js';

export const migration002 = {
  id:'002_seed_catalog',
  description:'Inclui o catálogo demonstrativo sem substituir documentos existentes.',
  async up({store}) {
    for(const [collection,items] of Object.entries({places,restaurants})) {
      for(const item of items) {
        const path=collection + '/' + item.id;
        if(await store.get(path)) continue;
        const {id,...data}=item;
        await store.set(path,data);
      }
    }
  },
};
