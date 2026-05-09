import 'package:flutter/material.dart';

import '../theme.dart';

class RestTimerChip extends StatelessWidget {
  const RestTimerChip({super.key, required this.isResting, this.remaining});

  final bool isResting;
  final Duration? remaining;

  @override
  Widget build(BuildContext context) {
    if (!isResting) {
      return _buildChip(context, label: 'Ready', isDone: false);
    }

    final value = remaining ?? const Duration(minutes: 1);
    if (value <= Duration.zero) {
      return _buildChip(context, label: 'Rest done', isDone: true);
    }

    final seconds = (value.inMilliseconds / 1000).ceil();
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: seconds, end: 0),
      duration: value,
      builder: (context, secondsLeft, child) {
        final isDone = secondsLeft <= 0;
        return _buildChip(
          context,
          label: isDone ? 'Rest done' : _format(secondsLeft),
          isDone: isDone,
        );
      },
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required bool isDone,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isResting
            ? RepFastColors.green.withValues(alpha: 0.1)
            : RepFastColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isResting ? RepFastColors.green : RepFastColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isResting ? Icons.timer_outlined : Icons.bolt_outlined,
            size: 18,
            color: isResting
                ? isDone
                      ? RepFastColors.amber
                      : RepFastColors.green
                : RepFastColors.cyan,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isResting
                  ? isDone
                        ? RepFastColors.amber
                        : RepFastColors.green
                  : RepFastColors.text,
            ),
          ),
        ],
      ),
    );
  }

  String _format(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return 'Rest $minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
