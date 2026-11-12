import { z } from 'zod';
import { isoDateSchema } from './common.js';

export const accountSchema = z.object({
  name: z.string().trim().min(2).max(80).optional(),
  email: z.email().transform(value => value.toLowerCase()),
  password: z.string().min(8).max(128),
});

export const userProfileSchema = z.object({
  name: z.string().trim().min(2).max(80),
  email: z.email().transform(value => value.toLowerCase()),
  createdAt: isoDateSchema,
  updatedAt: isoDateSchema,
});
