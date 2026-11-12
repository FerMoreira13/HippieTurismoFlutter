import { z } from 'zod';

export const idSchema = z.string().regex(/^[a-zA-Z0-9_-]{1,128}$/);
export const isoDateSchema = z.string().datetime({offset:true});
export const coordinatesSchema = z.object({
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
});
