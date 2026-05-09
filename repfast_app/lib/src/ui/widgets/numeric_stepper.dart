import 'package:flutter/material.dart';

import '../theme.dart';

class NumericStepper extends StatelessWidget {
  const NumericStepper({
    super.key,
    required this.label,
    required this.valueText,
    this.unit,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String valueText;
  final String? unit;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RepFastColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RepFastColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: RepFastColors.muted),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        valueText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          unit!,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: RepFastColors.cyan),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StepperButton(
            label: 'Decrease $label',
            symbol: '-',
            onPressed: onDecrease,
          ),
          const SizedBox(width: 8),
          _StepperButton(
            label: 'Increase $label',
            symbol: '+',
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.label,
    required this.symbol,
    required this.onPressed,
  });

  final String label;
  final String symbol;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size(56, 56),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: RepFastColors.surfaceRaised,
          foregroundColor: RepFastColors.text,
        ),
        onPressed: onPressed,
        child: Text(
          symbol,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
