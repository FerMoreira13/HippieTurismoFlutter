export const migration001 = {
  id:'001_initial_schema',
  description:'Registra coleções, subcoleções e versão inicial dos domínios.',
  async up({store,now}) {
    await store.set('_meta/schema',{
      version:1,
      database:'firestore',
      collections:{
        users:['name','email','createdAt','updatedAt'],
        places:['name','description','category','address','hours','price','lat','lng','geohash','imageAsset','demo'],
        restaurants:['name','cuisine','address','lat','lng','geohash','demo'],
      },
      subcollections:{
        'users/{uid}/favorites':['createdAt'],
        'places/{placeId}/reviews':['rating','comment','userId','userName','updatedAt'],
      },
      updatedAt:now,
    });
  },
};
