import { geohashForLocation, geohashQueryBounds } from 'geofire-common';
import { rankNearby } from './domain.js';
import { places, restaurants } from './fixtures.js';

export class MemoryStore {
  constructor({seed=true}={}) {
    this.data = new Map();
    if(seed) {
      for (const [type, items] of Object.entries({places,restaurants})) {
        for (const item of items) this.data.set(type + '/' + item.id, structuredClone(item));
      }
    }
  }
  async get(path) { return structuredClone(this.data.get(path) ?? null); }
  async set(path, value) { this.data.set(path, structuredClone(value)); }
  async delete(path) { this.data.delete(path); }
  async list(path) {
    return [...this.data].filter(([key]) => key.startsWith(`${path}/`) && key.split('/').length === path.split('/').length+1)
      .map(([key,value]) => ({...structuredClone(value),id:key.split('/').at(-1)}));
  }
  async nearby(type, center, radius) { return rankNearby(await this.list(type),center,radius); }
}

export class LocalStore extends MemoryStore {
  constructor(database) {
    super(); this.database=database;
    if(database.data.documents.length) this.data=new Map(database.data.documents);
    // Add new catalog entries without overwriting accounts, reviews or admin edits.
    for (const item of places) {
      const path = 'places/' + item.id;
      if (!this.data.has(path)) this.data.set(path, structuredClone(item));
    }
    this.database.save('documents',[...this.data]);
  }
  async set(path,value) {
    const next=new Map(this.data); next.set(path,structuredClone(value));
    this.database.save('documents',[...next]); this.data=next;
  }
  async delete(path) {
    const next=new Map(this.data); next.delete(path);
    this.database.save('documents',[...next]); this.data=next;
  }
}

export class FirestoreStore {
  constructor(db) { this.db = db; }
  async get(path) { const doc=await this.db.doc(path).get(); return doc.exists ? {...doc.data(),id:doc.id} : null; }
  async set(path, value) {
    const data={...value};
    if (typeof data.lat==='number') data.geohash=geohashForLocation([data.lat,data.lng]);
    await this.db.doc(path).set(data);
  }
  async delete(path) { await this.db.doc(path).delete(); }
  async list(path) { return (await this.db.collection(path).limit(500).get()).docs.map(doc => ({...doc.data(),id:doc.id})); }
  async nearby(type, center, radius) {
    const bounds=geohashQueryBounds([center.lat,center.lng],radius);
    const snapshots=await Promise.all(bounds.map(([start,end]) => this.db.collection(type).orderBy('geohash').startAt(start).endAt(end).limit(500).get()));
    const unique=new Map();
    for (const snapshot of snapshots) for(const doc of snapshot.docs) unique.set(doc.id,{...doc.data(),id:doc.id});
    return rankNearby([...unique.values()],center,radius);
  }
}
