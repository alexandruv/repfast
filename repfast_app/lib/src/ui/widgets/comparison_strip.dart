import 'package:flutter/material.dart';

import '../../domain/calculators.dart';
import '../../domain/comparison.dart';
import '../theme.dart';

class ComparisonStrip extends StatelessWidget {
  const ComparisonStrip({
    super.key,
    required this.result,
    this.formatWeight,
    this.weightUnitLabel,
  });

  final WorkoutComparisonResult result;
  final String Function(double weight)? formatWeight;
  final String? weightUnitLabel;

  @override
  Widget build(BuildContext context) {
    final bestSet = result.bestSet;
    final deltaText = result.previousVolume == 0
        ? 'New'
        : '${result.volumeDeltaPercent >= 0 ? '+' : ''}${result.volumeDeltaPercent.toStringAsFixed(0)}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF08100D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RepFastColors.green.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Today vs last time',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: RepFastColors.green),
              ),
              if (result.isPersonalRecord) const _PersonalRecordBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                deltaText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: RepFastColors.green,
                ),
              ),
              if (bestSet != null)
                Text(
                  'Best ${_displayWeight(bestSet.weight)} x ${bestSet.reps}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.takeaway,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: RepFastColors.text),
          ),
        ],
      ),
    );
  }

  String _displayWeight(double weight) {
    final value =
        formatWeight?.call(weight) ?? RepFastCalculators.displayWeight(weight);
    final unit = weightUnitLabel;
    return unit == null ? value : '$value $unit';
  }
}

class _PersonalRecordBadge extends StatelessWidget {
  const _PersonalRecordBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Personal record',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: RepFastColors.amber),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'PR',
            style: TextStyle(
              color: RepFastColors.amber,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
