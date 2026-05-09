import 'package:flutter/material.dart';

import '../theme.dart';

class RestTimerChip extends StatelessWidget {
  const RestTimerChip({super.key, required this.isResting});

  final bool isResting;

  @override
  Widget build(BuildContext context) {
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
            color: isResting ? RepFastColors.green : RepFastColors.cyan,
          ),
          const SizedBox(width: 8),
          Text(
            isResting ? 'Rest started' : 'Ready',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isResting ? RepFastColors.green : RepFastColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
