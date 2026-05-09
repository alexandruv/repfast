import 'package:flutter/material.dart';

import '../../domain/calculators.dart';
import '../../domain/comparison.dart';
import '../theme.dart';

class ComparisonStrip extends StatelessWidget {
  const ComparisonStrip({super.key, required this.result});

  final WorkoutComparisonResult result;

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
          Row(
            children: [
              Text(
                'Today vs last time',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: RepFastColors.green),
              ),
              const Spacer(),
              if (result.isPersonalRecord)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                deltaText,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: RepFastColors.green,
                ),
              ),
              const SizedBox(width: 16),
              if (bestSet != null)
                Expanded(
                  child: Text(
                    'Best ${RepFastCalculators.displayWeight(bestSet.weight)} x ${bestSet.reps}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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
}
