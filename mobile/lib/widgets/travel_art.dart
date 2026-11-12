import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app_theme.dart';

class HippieWordmark extends StatelessWidget {
  final bool light;
  const HippieWordmark({super.key, this.light = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: light
              ? Colors.white.withValues(alpha: .14)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.explore_rounded,
          size: 21,
          color: light ? AppColors.secondary : Colors.white,
        ),
      ),
      const SizedBox(width: 10),
      Text(
        'hippie',
        style: TextStyle(
          fontSize: 24,
          height: 1,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.25,
          color: light ? Colors.white : AppColors.ink,
        ),
      ),
    ],
  );
}

class LocationHeroCard extends StatelessWidget {
  final bool active;
  final bool busy;
  final String location;
  final int radiusKm;
  final VoidCallback? onPressed;
  const LocationHeroCard({
    super.key,
    required this.active,
    required this.busy,
    required this.location,
    required this.radiusKm,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryDark,
          AppColors.primary,
          AppColors.primaryLight,
        ],
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(
          color: Color(0x334e2639),
          blurRadius: 26,
          offset: Offset(0, 13),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          Positioned(
            right: -26,
            top: -38,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .09),
                  width: 25,
                ),
              ),
            ),
          ),
          Positioned(
            right: 26,
            bottom: -42,
            child: Transform.rotate(
              angle: -.32,
              child: Container(
                width: 95,
                height: 125,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.near_me_rounded,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 11),
                    const Text(
                      'PERTO DE VOCÊ',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 1.25,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  active
                      ? 'Seu próximo achado\nestá logo adiante.'
                      : 'Descubra o que existe\nao seu redor.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      color: Colors.white60,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '$location • $radiusKm km',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.primaryDark,
                    elevation: 0,
                  ),
                  onPressed: onPressed,
                  icon: Icon(
                    active ? Icons.refresh_rounded : Icons.my_location_rounded,
                    size: 19,
                  ),
                  label: Text(
                    busy
                        ? 'Localizando…'
                        : active
                        ? 'Atualizar localização'
                        : 'Usar minha localização',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class DiscoveryArtwork extends StatelessWidget {
  final String category;
  final double height;
  final bool showLabel;
  final String? imageAsset;
  const DiscoveryArtwork({
    super.key,
    required this.category,
    this.height = 160,
    this.showLabel = false,
    this.imageAsset,
  });
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageAsset == null)
            CustomPaint(
              painter: _LandscapePainter(accent: categoryColor(category)),
            )
          else
            Image.asset(
              imageAsset!,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, _, _) => CustomPaint(
                painter: _LandscapePainter(accent: categoryColor(category)),
              ),
            ),
          if (imageAsset != null)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x59000000)],
                ),
              ),
            ),
          Positioned(
            right: 18,
            top: 18,
            child: Container(
              width: height > 100 ? 54 : 40,
              height: height > 100 ? 54 : 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .88),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 18,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: Icon(
                categoryIcon(category),
                color: categoryColor(category),
                size: height > 100 ? 28 : 21,
              ),
            ),
          ),
          if (showLabel)
            Positioned(
              left: 20,
              bottom: 17,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _LandscapePainter extends CustomPainter {
  final Color accent;
  const _LandscapePainter({required this.accent});
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xfff7d5b5), Color(0xfff8ead8), Color(0xffdceadf)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);
    canvas.drawCircle(
      Offset(size.width * .2, size.height * .27),
      size.height * .17,
      Paint()..color = const Color(0xffffbd68).withValues(alpha: .9),
    );
    final far = Path()
      ..moveTo(0, size.height * .63)
      ..quadraticBezierTo(
        size.width * .19,
        size.height * .32,
        size.width * .42,
        size.height * .65,
      )
      ..quadraticBezierTo(
        size.width * .7,
        size.height * .28,
        size.width,
        size.height * .6,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(far, Paint()..color = accent.withValues(alpha: .5));
    final near = Path()
      ..moveTo(0, size.height * .7)
      ..quadraticBezierTo(
        size.width * .3,
        size.height * .52,
        size.width * .53,
        size.height * .77,
      )
      ..quadraticBezierTo(
        size.width * .79,
        size.height * .5,
        size.width,
        size.height * .68,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(near, Paint()..color = AppColors.primary);
    final trail = Path()
      ..moveTo(size.width * .42, size.height)
      ..cubicTo(
        size.width * .43,
        size.height * .86,
        size.width * .57,
        size.height * .84,
        size.width * .56,
        size.height * .69,
      );
    canvas.drawPath(
      trail,
      Paint()
        ..color = AppColors.primarySoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(5, size.width * .025)
        ..strokeCap = StrokeCap.round,
    );
    for (final x in [.08, .16, .73, .84, .92]) {
      final top = size.height * (.58 + (x * .08));
      final paint = Paint()..color = AppColors.primaryDark;
      canvas.drawRect(
        Rect.fromLTWH(size.width * x - 1.5, top + 8, 3, size.height - top),
        paint,
      );
      canvas.drawCircle(Offset(size.width * x, top), 8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) =>
      oldDelegate.accent != accent;
}

Color categoryColor(String category) => switch (category) {
  'Natureza' => const Color(0xff3d8060),
  'Cultura' => AppColors.accent,
  'História' => const Color(0xff7b658f),
  _ => const Color(0xff327b8c),
};
IconData categoryIcon(String category) => switch (category) {
  'Natureza' => Icons.park_rounded,
  'Cultura' => Icons.palette_rounded,
  'História' => Icons.account_balance_rounded,
  _ => Icons.landscape_rounded,
};
