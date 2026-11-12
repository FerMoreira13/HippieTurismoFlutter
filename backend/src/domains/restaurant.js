import { z } from 'zod';
import { coordinatesSchema } from './common.js';

export const restaurantSchema = coordinatesSchema.extend({
  name: z.string().trim().min(3).max(120),
  cuisine: z.string().trim().min(2).max(100),
  address: z.string().trim().max(300),
  demo: z.boolean().default(false),
});
