import { z } from 'zod';
import { coordinatesSchema } from './common.js';

export const placeSchema = coordinatesSchema.extend({
  name: z.string().trim().min(3).max(120),
  description: z.string().trim().min(10).max(5000),
  category: z.enum(['Natureza', 'Cultura', 'História', 'Lazer']),
  address: z.string().trim().max(300),
  hours: z.string().trim().min(1).max(300),
  price: z.number().min(0).max(100000),
  priceKnown: z.boolean().default(true),
  imageAsset: z.string().regex(/^assets\/places\/[a-z0-9-]+\.png$/).optional(),
  contact: z.string().trim().max(200).default(''),
  website: z.union([z.literal(''),z.string().url().max(500).refine(v=>v.startsWith('https://'))]).default(''),
  accessibility: z.string().trim().max(600).default('Informação ainda não verificada.'),
  visitMinutes: z.number().int().min(10).max(720).default(60),
  status: z.enum(['open','temporarily_closed','closed','unverified']).default('unverified'),
  source: z.string().trim().max(300).default(''),
  verifiedAt: z.string().datetime().nullable().default(null),
  demo: z.boolean().default(false),
});
