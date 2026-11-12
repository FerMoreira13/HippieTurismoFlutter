import { z } from 'zod';

export const nearbySchema = z.object({
  lat: z.coerce.number().min(-90).max(90),
  lng: z.coerce.number().min(-180).max(180),
  radius: z.coerce.number().min(100).max(50000).default(10000),
});

export const placeNearbySchema = nearbySchema.extend({
  radius: z.coerce.number().min(100).max(100000).default(10000),
});

export function distanceMeters(a, b) {
  const radians = value => value * Math.PI / 180;
  const delta =
    Math.sin(radians(b.lat - a.lat) / 2) ** 2 +
    Math.cos(radians(a.lat)) *
      Math.cos(radians(b.lat)) *
      Math.sin(radians(b.lng - a.lng) / 2) ** 2;
  return 6371000 * 2 * Math.atan2(Math.sqrt(delta), Math.sqrt(Math.max(0, 1 - delta)));
}

export function rankNearby(items, center, radius) {
  return items
    .map(item => ({...item, distance:Math.round(distanceMeters(center, item))}))
    .filter(item => item.distance <= radius)
    .sort((a, b) => a.distance - b.distance)
    .slice(0, 100);
}
