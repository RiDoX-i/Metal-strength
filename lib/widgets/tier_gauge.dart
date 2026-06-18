import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/formulas/tiers.dart';
import '../theme/app_colors.dart';

/// An animated radial gauge: the sweep fills to [percentile] and is coloured by
/// [tier]. The centre shows the headline value + label.
class TierGauge extends StatelessWidget {
  const TierGauge({
    super.key,
    required this.percentile,
    required this.tier,
    required this.centerValue,
    required this.centerLabel,
    this.size = 240,
    this.animate = true,
  });

  /// 0..100.
  final double percentile;
  final StrengthTier tier;
  final String centerValue;
  final String centerLabel;
  final double size;

  /// When false the sweep is drawn fully on the first frame (no fill-up
  /// animation) — used when rendering the gauge into a shareable image, where
  /// a mid-animation capture would show a partially filled arc.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final color = Color(tier.colorValue);
    final target = (percentile / 100).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animate ? 0 : target, end: target),
      duration: Duration(milliseconds: animate ? 1100 : 0),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _GaugePainter(progress: value, color: color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerValue,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: size * 0.20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    centerLabel.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: size * 0.058,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.progress, required this.color});

  final double progress; // 0..1
  final Color color;

  // 270° arc, starting bottom-left, leaving a gap at the bottom.
  static const double _start = math.pi * 0.75;
  static const double _sweep = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 14;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..color = AppColors.surfaceAlt;
    canvas.drawArc(rect, _start, _sweep, false, track);

    if (progress > 0) {
      final fill = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: _start,
          endAngle: _start + _sweep,
          colors: [color.withValues(alpha: 0.55), color],
        ).createShader(rect);
      canvas.drawArc(rect, _start, _sweep * progress, false, fill);

      // Glowing tip.
      final tipAngle = _start + _sweep * progress;
      final tip = Offset(
        center.dx + radius * math.cos(tipAngle),
        center.dy + radius * math.sin(tipAngle),
      );
      canvas.drawCircle(
        tip,
        7,
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(tip, 5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.color != color;
}
