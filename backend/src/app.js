import { randomUUID } from 'node:crypto';
import express from 'express';
import helmet from 'helmet';
import { rateLimit } from 'express-rate-limit';
import { z, ZodError } from 'zod';
import { authenticate } from './auth.js';
import { placeNearbySchema } from './domains/geo.js';
import { favoriteSchema, idSchema, nearbySchema, placeSchema, restaurantSchema, reviewDocumentSchema, reviewSchema, rankNearby, userProfileSchema } from './domain.js';

export function createApp({store, verify, demoAuth=null, placesKey='', fetchImpl=fetch}) {
  const app=express();
  app.disable('x-powered-by');
  app.use(helmet());
  app.use(express.json({limit:'200kb'}));
  app.use(rateLimit({windowMs:60000,limit:120,standardHeaders:'draft-8',legacyHeaders:false,message:{error:'Muitas solicitações. Aguarde um minuto.'}}));
  app.get('/',(_req,res) => res.json({
    status:'online',
    service:'Hippie Turismo API',
    mode:demoAuth?'demo':'firebase',
    health:'/health',
  }));
  app.get('/health',(_req,res) => res.json({status:'ok',mode:demoAuth?'demo':'firebase'}));
  if(demoAuth) {
    const authLimit=rateLimit({windowMs:900000,limit:30,message:{error:'Muitas tentativas. Aguarde 15 minutos.'}});
    app.post('/auth/register',authLimit,(req,res) => res.status(201).json(demoAuth.login(req.body,true)));
    app.post('/auth/recover',authLimit,(req,res)=>res.json(demoAuth.recover(req.body)));
    app.post('/auth/login',authLimit,(req,res) => res.json(demoAuth.login(req.body)));
  }
  app.use(authenticate(verify));
  app.post('/auth/recovery-code',(req,res)=>demoAuth?res.json(demoAuth.recoveryCode(req.user)):res.status(404).json({error:'Use a recuperação por e-mail.'}));
  app.get('/me',async(req,res) => {
    const path='users/' + req.user.uid;
    const existing=await store.get(path);
    const now=new Date().toISOString();
    const profile=userProfileSchema.parse({
      name:req.user.name??'Viajante',
      email:req.user.email,
      createdAt:existing?.createdAt??now,
      updatedAt:now,
    });
    await store.set(path,profile);
    res.json({uid:req.user.uid,...profile,admin:req.user.admin===true});
  });
  app.post('/auth/logout',(req,res) => { demoAuth?.revoke(req.token); res.status(204).end(); });
  app.get('/places',async(req,res) => {
    const query=placeNearbySchema.parse(req.query);
    res.json(await store.nearby('places',query,query.radius));
  });
  const getPlace=async id => {
    const place=await store.get(`places/${idSchema.parse(id)}`);
    if(!place) throw Object.assign(new Error('Local não encontrado.'),{status:404});
    return place;
  };
  app.get('/places/:id',async(req,res) => {
    const place=await getPlace(req.params.id);
    const reviews=await store.list(`places/${place.id}/reviews`);
    res.json({...place,reviews,rating:reviews.length?reviews.reduce((sum,r)=>sum+r.rating,0)/reviews.length:null,reviewCount:reviews.length});
  });
  app.put('/places/:id/review',async(req,res) => {
    const place=await getPlace(req.params.id);
    const review=reviewSchema.parse(req.body);
    const document=reviewDocumentSchema.parse({
      ...review,
      userId:req.user.uid,
      userName:req.user.name??'Viajante',
      updatedAt:new Date().toISOString(),
    });
    await store.set('places/' + place.id + '/reviews/' + req.user.uid,document);
    res.status(204).end();
  });
  app.post('/places/:id/reports',async(req,res)=>{
    const place=await getPlace(req.params.id);
    const data=z.object({reason:z.enum(['closed','incorrect','review']),details:z.string().trim().min(5).max(1000),reviewUserId:idSchema.optional()}).parse(req.body);
    if(data.reason==='review' && (!data.reviewUserId || !await store.get('places/'+place.id+'/reviews/'+data.reviewUserId))) return res.status(400).json({error:'Avaliação não encontrada.'});
    const id=randomUUID();
    await store.set('reports/'+id,{...data,id,placeId:place.id,placeName:place.name,userId:req.user.uid,status:'pending',createdAt:new Date().toISOString()});
    res.status(201).json({id});
  });
  app.get('/favorites',async(req,res) => {
    const refs=await store.list(`users/${req.user.uid}/favorites`);
    res.json((await Promise.all(refs.map(ref=>store.get(`places/${ref.id}`)))).filter(Boolean));
  });
  app.put('/favorites/:id',async(req,res) => {
    const place=await getPlace(req.params.id);
    const favorite=favoriteSchema.parse({createdAt:new Date().toISOString()});
    await store.set('users/' + req.user.uid + '/favorites/' + place.id,favorite);
    res.status(204).end();
  });
  app.delete('/favorites/:id',async(req,res) => {
    await store.delete(`users/${req.user.uid}/favorites/${idSchema.parse(req.params.id)}`);
    res.status(204).end();
  });
  app.get('/restaurants',async(req,res) => {
    const query=nearbySchema.parse(req.query);
    const local=await store.nearby('restaurants',query,query.radius);
    if(!placesKey) return res.json({items:local,source:'catalog',warning:null});
    try {
      const response=await fetchImpl('https://places.googleapis.com/v1/places:searchNearby',{
        method:'POST',signal:AbortSignal.timeout(5000),headers:{'Content-Type':'application/json','X-Goog-Api-Key':placesKey,'X-Goog-FieldMask':'places.id,places.displayName,places.location,places.formattedAddress,places.googleMapsUri,places.attributions'},
        body:JSON.stringify({includedTypes:['restaurant'],maxResultCount:20,languageCode:'pt-BR',locationRestriction:{circle:{center:{latitude:query.lat,longitude:query.lng},radius:query.radius}}}),
      });
      if(!response.ok) throw new Error('Places indisponível');
      const payload=await response.json();
      const items=(payload.places??[]).map(p=>({id:p.id,name:p.displayName?.text??'Restaurante',lat:p.location.latitude,lng:p.location.longitude,address:p.formattedAddress??'',cuisine:'Restaurante',mapsUrl:p.googleMapsUri,attributions:p.attributions??[],demo:false}));
      res.json({items:rankNearby(items,query,query.radius),source:'google',warning:null});
    } catch { res.json({items:local,source:'catalog',warning:'Google Places indisponível. Exibindo o catálogo cadastrado.'}); }
  });
  const admin=(req,res,next) => req.user.admin===true?next():res.status(403).json({error:'Acesso exclusivo de administrador.'});
  app.get('/admin/places',admin,async(_req,res)=>res.json(await store.list('places')));
  app.get('/admin/reports',admin,async(_req,res)=>res.json(await store.list('reports')));
  app.patch('/admin/reports/:id',admin,async(req,res)=>{
    const id=idSchema.parse(req.params.id);
    const report=await store.get('reports/'+id);
    if(!report) return res.status(404).json({error:'Relato não encontrado.'});
    const {status}=z.object({status:z.enum(['resolved','dismissed'])}).parse(req.body);
    await store.set('reports/'+id,{...report,status,resolvedAt:new Date().toISOString(),resolvedBy:req.user.uid});
    res.status(204).end();
  });
  for(const [collection,schema] of [['places',placeSchema],['restaurants',restaurantSchema]]) {
    app.put(`/admin/${collection}/:id`,admin,async(req,res) => {
      const id=idSchema.parse(req.params.id),data=schema.parse(req.body);
      await store.set(`${collection}/${id}`,{...data,id}); res.json({...data,id});
    });
  }
  app.delete('/admin/places/:id/reviews/:userId',admin,async(req,res) => {
    const id=idSchema.parse(req.params.id),uid=idSchema.parse(req.params.userId);
    await store.delete(`places/${id}/reviews/${uid}`); res.status(204).end();
  });
  app.use((_req,res)=>res.status(404).json({error:'Recurso não encontrado.'}));
  app.use((err,_req,res,_next)=> {
    if(err instanceof ZodError) return res.status(400).json({error:'Verifique os dados informados.',details:err.issues.map(x=>({field:x.path.join('.'),message:x.message}))});
    const status=err.status??500;
    if(status>=500) console.error('Falha na API:',err.message);
    res.status(status).json({error:status>=500?'Não foi possível concluir. Tente novamente.':status===400?'Solicitação inválida.':err.message});
  });
  return app;
}
