import 'dart:math' as math;
import 'models.dart';

double tripDistance(double lat, double lng, Place place) {
  const r = math.pi / 180;
  final a =
      math.pow(math.sin((place.lat - lat) * r / 2), 2) +
      math.cos(lat * r) *
          math.cos(place.lat * r) *
          math.pow(math.sin((place.lng - lng) * r / 2), 2);
  return 6371000 * 2 * math.asin(math.sqrt(a.clamp(0, 1)));
}

int travelMinutes(double distance, String mode) {
  final speed = switch (mode) {
    'driving' => 25.0,
    'transit' => 15.0,
    _ => 4.5,
  };
  return (distance * 1.3 / 1000 / speed * 60).ceil();
}

List<Place> planTrip(
  List<Place> places,
  double lat,
  double lng, {
  double budget = double.infinity,
  int minutes = 100000,
  String mode = 'walking',
}) {
  final remaining = {for (final p in places) p.id: p}.values
      .where((p) => p.status != 'closed' && p.status != 'temporarily_closed')
      .toList();
  final selected = <Place>[];
  var spent = 0.0, used = 0;
  while (remaining.isNotEmpty) {
    remaining.sort((a, b) {
      final order = tripDistance(
        lat,
        lng,
        a,
      ).compareTo(tripDistance(lat, lng, b));
      return order == 0 ? a.id.compareTo(b.id) : order;
    });
    final next = remaining.removeAt(0);
    if (budget.isFinite && !next.priceKnown) continue;
    final duration =
        next.visitMinutes + travelMinutes(tripDistance(lat, lng, next), mode);
    if (spent + next.price > budget || used + duration > minutes) continue;
    selected.add(next);
    spent += next.price;
    used += duration;
    lat = next.lat;
    lng = next.lng;
  }
  return selected;
}
