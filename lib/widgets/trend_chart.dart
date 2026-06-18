import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// One plotted sample: a value at a moment in time.
class TrendPoint {
  const TrendPoint(this.at, this.value);
  final DateTime at;
  final double value;
}

/// A dependency-free line chart used for progress trends. Points are spaced
/// evenly along the x-axis (by index) so a handful of samples still reads
/// clearly; the y-axis auto-scales unless [minY]/[maxY] are given.
///
/// A single point renders as a centred dot; an empty list renders nothing.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.points,
    this.color = AppColors.accent,
    this.height = 160,
    this.minY,
    this.maxY,
    this.showArea = true,
  });

  final List<TrendPoint> points;
  final Color color;
  final double height;
  final double? minY;
  final double? maxY;
  final bool showArea;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(
          points: points,
          color: color,
          minY: minY,
          maxY: maxY,
          showArea: showArea,
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.color,
    required this.minY,
    required this.maxY,
    required this.showArea,
  });

  final List<TrendPoint> points;
  final Color color;
  final double? minY;
  final double? maxY;
  final bool showArea;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const padTop = 10.0;
    const padBottom = 10.0;
    const padX = 6.0;
    final chartW = size.width - padX * 2;
    final chartH = size.height - padTop - padBottom;

    final values = points.map((p) => p.value).toList();
    var lo = minY ?? values.reduce((a, b) => a < b ? a : b);
    var hi = maxY ?? values.reduce((a, b) => a > b ? a : b);
    if (hi <= lo) {
      // Flat series — open a small window so the line sits mid-chart.
      hi = lo + (lo.abs() < 1 ? 1 : lo.abs() * 0.1);
      lo = lo - (lo.abs() < 1 ? 1 : lo.abs() * 0.1);
    } else {
      final pad = (hi - lo) * 0.12;
      lo -= pad;
      hi += pad;
    }

    double xFor(int i) => points.length == 1
        ? size.width / 2
        : padX + chartW * (i / (points.length - 1));
    double yFor(double v) =>
        padTop + chartH * (1 - ((v - lo) / (hi - lo)).clamp(0.0, 1.0));

    // Baseline.
    final base = Paint()
      ..color = AppColors.stroke
      ..strokeWidth = 1;
    canvas.drawLine(Offset(padX, size.height - padBottom),
        Offset(size.width - padX, size.height - padBottom), base);

    if (points.length == 1) {
      _dot(canvas, Offset(xFor(0), yFor(values.first)), color, filled: true);
      return;
    }

    final linePath = Path();
    for (var i = 0; i < points.length; i++) {
      final o = Offset(xFor(i), yFor(values[i]));
      if (i == 0) {
        linePath.moveTo(o.dx, o.dy);
      } else {
        linePath.lineTo(o.dx, o.dy);
      }
    }

    if (showArea) {
      final areaPath = Path.from(linePath)
        ..lineTo(xFor(points.length - 1), size.height - padBottom)
        ..lineTo(xFor(0), size.height - padBottom)
        ..close();
      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size);
      canvas.drawPath(areaPath, areaPaint);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < points.length; i++) {
      _dot(canvas, Offset(xFor(i), yFor(values[i])), color,
          filled: i == points.length - 1);
    }
  }

  void _dot(Canvas canvas, Offset o, Color c, {required bool filled}) {
    canvas.drawCircle(o, filled ? 4.5 : 3.0, Paint()..color = AppColors.background);
    canvas.drawCircle(
      o,
      filled ? 4.5 : 3.0,
      Paint()
        ..color = c
        ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.points != points ||
      old.color != color ||
      old.minY != minY ||
      old.maxY != maxY;
}

/// A compact inline sparkline (no area, no baseline) for list rows.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    this.color = AppColors.accent,
    this.width = 64,
    this.height = 28,
  });

  final List<double> values;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final base = DateTime(2000);
    final points = [
      for (var i = 0; i < values.length; i++)
        TrendPoint(base.add(Duration(days: i)), values[i]),
    ];
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _TrendPainter(
          points: points,
          color: color,
          minY: null,
          maxY: null,
          showArea: false,
        ),
      ),
    );
  }
}
