import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/formulas/units.dart';
import '../core/models/exercise.dart';
import '../core/models/strength_result.dart';
import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import 'exercise_glyph.dart';
import 'tier_gauge.dart';

/// Fixed logical width the card is laid out at. The preview scales this down to
/// fit the sheet, but capture always happens at this width × the pixel ratio so
/// the exported image is a consistent, high resolution regardless of device.
const double _cardWidth = 360;

/// A polished, self-contained snapshot of a strength result, designed to be
/// rendered to a PNG and shared. Pure Flutter widgets only (the tier gauge is a
/// [CustomPaint]) so it paints synchronously and captures cleanly.
class ShareResultCard extends StatelessWidget {
  const ShareResultCard({
    super.key,
    required this.result,
    required this.exercise,
    required this.unit,
  });

  final StrengthResult result;
  final Exercise exercise;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final tierColor = Color(result.tier.colorValue);
    final isReps = result.oneRmKg == null;

    return Container(
      width: _cardWidth,
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF161D2B), Color(0xFF0B0E14)],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _brand(),
          const SizedBox(height: 26),
          // Gauge with a soft tier-coloured glow behind it.
          SizedBox(
            height: 210,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: tierColor.withValues(alpha: 0.35),
                        blurRadius: 70,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
                TierGauge(
                  percentile: result.percentile,
                  tier: result.tier,
                  centerValue: '${result.percentile.round()}%',
                  centerLabel: result.tier.label,
                  size: 200,
                  animate: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExerciseGlyph(exercise: exercise, size: 36, radius: 11, padding: 8),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  exerciseName(context, exercise),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            trp(context, 'stronger_than', {'n': result.percentile.round()}),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          if (isReps)
            _StatPill(
              label: tr(context, 'reps'),
              value: '${result.repCount}',
              color: tierColor,
            )
          else
            Row(
              children: [
                Expanded(
                  child: _StatPill(
                    label: tr(context, 'est_1rm'),
                    value: _weight(result.oneRmKg!),
                    color: tierColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatPill(
                    label: tr(context, 'bw_ratio'),
                    value: '${result.bodyweightRatio!.toStringAsFixed(2)}×',
                    color: tierColor,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          Container(height: 1, color: AppColors.stroke),
          const SizedBox(height: 14),
          Text(
            tr(context, 'app_tagline'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _brand() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.fitness_center_rounded,
              color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        const Text(
          'METAL STRENGTH',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  String _weight(double kg) {
    final v = Units.prettyRound(Units.fromKg(kg, unit), unit);
    final text =
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return '$text ${unit.symbol}';
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

/// Bottom sheet that previews [ShareResultCard] and shares it as a PNG.
class ShareResultSheet extends StatefulWidget {
  const ShareResultSheet({
    super.key,
    required this.result,
    required this.exercise,
    required this.unit,
  });

  final StrengthResult result;
  final Exercise exercise;
  final WeightUnit unit;

  static Future<void> show(
    BuildContext context, {
    required StrengthResult result,
    required Exercise exercise,
    required WeightUnit unit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ShareResultSheet(
        result: result,
        exercise: exercise,
        unit: unit,
      ),
    );
  }

  @override
  State<ShareResultSheet> createState() => _ShareResultSheetState();
}

class _ShareResultSheetState extends State<ShareResultSheet> {
  final _cardKey = GlobalKey();
  bool _busy = false;

  Future<void> _share(String caption, String failMessage) async {
    if (_busy) return;
    setState(() => _busy = true);

    // Origin rect for the iPad/macOS popover; harmless elsewhere.
    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    try {
      // Make sure the boundary has painted before snapshotting it.
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _cardKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/metal_strength_${widget.exercise.id}.png');
      await file.writeAsBytes(bytes, flush: true);

      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: caption,
        sharePositionOrigin: origin,
      ));
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failMessage)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final caption = trp(context, 'share_caption', {
      'tier': tierLabel(context, widget.result.tier),
      'exercise': exerciseName(context, widget.exercise),
      'n': widget.result.percentile.round(),
    });
    final failMessage = tr(context, 'share_failed');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.stroke,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 18),
            Flexible(
              child: FittedBox(
                fit: BoxFit.contain,
                child: RepaintBoundary(
                  key: _cardKey,
                  child: ShareResultCard(
                    result: widget.result,
                    exercise: widget.exercise,
                    unit: widget.unit,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : () => _share(caption, failMessage),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.ios_share_rounded, size: 20),
                label: Text(
                  tr(context, 'share'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
