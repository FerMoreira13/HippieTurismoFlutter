import { z } from 'zod';
import { isoDateSchema } from './common.js';

export const favoriteSchema = z.object({
  createdAt: isoDateSchema,
});
