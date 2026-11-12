/// Mantém o cálculo independente de GPS e plugins, para testar a regra de alertas.
class NearbyPolicy {
  final Duration cooldown;
  final double radius;
  const NearbyPolicy({
    this.cooldown = const Duration(hours: 6),
    this.radius = 500,
  });
  bool shouldNotify({
    required double distance,
    required DateTime now,
    DateTime? last,
  }) =>
      distance.isFinite &&
      distance >= 0 &&
      distance <= radius &&
      (last == null || now.difference(last) >= cooldown);
}
