import { z } from 'zod';
import { idSchema, isoDateSchema } from './common.js';

export const reviewSchema = z.object({
  visitedOn: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).refine(v=>!Number.isNaN(Date.parse(v)) && new Date(v).toISOString().slice(0,10)===v && v<=new Date().toISOString().slice(0,10), 'Data de visita inválida.').optional(),
  photo: z.string().max(180000).regex(/^data:image\/(jpeg|png);base64,[A-Za-z0-9+/]+={0,2}$/).refine(v=>{
    const b=Buffer.from(v.split(',')[1],'base64');
    return b.subarray(0,3).equals(Buffer.from([255,216,255])) || b.subarray(0,8).equals(Buffer.from([137,80,78,71,13,10,26,10]));
  }, 'Envie uma foto JPEG ou PNG.').optional(),
  rating: z.number().int().min(1).max(5),
  comment: z.string().trim().min(3).max(1000),
});

export const reviewDocumentSchema = reviewSchema.extend({
  userId: idSchema,
  userName: z.string().trim().min(2).max(80),
  updatedAt: isoDateSchema,
});
