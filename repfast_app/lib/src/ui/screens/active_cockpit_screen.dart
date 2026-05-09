import 'package:flutter/material.dart';

import '../../application/active_workout_controller.dart';
import '../../domain/calculators.dart';
import '../theme.dart';
import '../widgets/comparison_strip.dart';
import '../widgets/numeric_stepper.dart';
import '../widgets/rest_timer_chip.dart';

class ActiveCockpitScreen extends StatefulWidget {
  const ActiveCockpitScreen({super.key, required this.controller});

  final ActiveWorkoutController controller;

  @override
  State<ActiveCockpitScreen> createState() => _ActiveCockpitScreenState();
}

class _ActiveCockpitScreenState extends State<ActiveCockpitScreen> {
  ActiveWorkoutState? _state;
  Object? _loadError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (_useLoadedState()) {
      return;
    }
    _load();
  }

  bool _useLoadedState() {
    try {
      _state = widget.controller.state;
      _isLoading = false;
      return true;
    } on StateError {
      return false;
    }
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final state = await widget.controller.load();
      if (!mounted) {
        return;
      }
      setState(() {
        _state = state;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  void _changeWeight(double delta) {
    final current = _state;
    if (current == null) {
      return;
    }
    setState(() {
      _state = widget.controller.updateWeight(current.weight + delta);
    });
  }

  void _changeReps(int delta) {
    final current = _state;
    if (current == null) {
      return;
    }
    setState(() {
      _state = widget.controller.updateReps(current.reps + delta);
    });
  }

  Future<void> _logSet() async {
    final current = _state;
    if (current == null || current.isSaving) {
      return;
    }

    final pendingSave = widget.controller.logSet();
    setState(() {
      _state = widget.controller.state;
    });

    final state = await pendingSave;
    if (!mounted) {
      return;
    }
    setState(() {
      _state = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Scaffold(
      body: SafeArea(
        child: _loadError != null
            ? _LoadErrorState(onRetry: _load)
            : _isLoading || state == null
            ? const _LoadingState()
            : _CockpitBody(
                state: state,
                onWeightDown: () =>
                    _changeWeight(-state.exercise.weightIncrement),
                onWeightUp: () => _changeWeight(state.exercise.weightIncrement),
                onRepsDown: () => _changeReps(-state.exercise.repIncrement),
                onRepsUp: () => _changeReps(state.exercise.repIncrement),
                onLogSet: _logSet,
              ),
      ),
    );
  }
}

class _CockpitBody extends StatelessWidget {
  const _CockpitBody({
    required this.state,
    required this.onWeightDown,
    required this.onWeightUp,
    required this.onRepsDown,
    required this.onRepsUp,
    required this.onLogSet,
  });

  final ActiveWorkoutState state;
  final VoidCallback onWeightDown;
  final VoidCallback onWeightUp;
  final VoidCallback onRepsDown;
  final VoidCallback onRepsUp;
  final VoidCallback onLogSet;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isShort = constraints.maxHeight < 720;
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            Row(
              children: [
                const _BrandMark(),
                const Spacer(),
                RestTimerChip(isResting: state.isResting),
              ],
            ),
            SizedBox(height: isShort ? 18 : 28),
            Text(
              state.exercise.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineMedium?.copyWith(fontSize: 34),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _StatusPill(text: 'Set ${state.setIndex}'),
                _StatusPill(
                  text: state.statusLabel,
                  icon: Icons.offline_pin_outlined,
                  color: RepFastColors.green,
                ),
              ],
            ),
            SizedBox(height: isShort ? 18 : 26),
            NumericStepper(
              label: 'weight',
              valueText: RepFastCalculators.displayWeight(state.weight),
              unit: 'lb',
              onDecrease: onWeightDown,
              onIncrease: onWeightUp,
            ),
            const SizedBox(height: 14),
            NumericStepper(
              label: 'reps',
              valueText: state.reps.toString(),
              onDecrease: onRepsDown,
              onIncrease: onRepsUp,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: RepFastColors.cyan,
                  foregroundColor: RepFastColors.background,
                  disabledBackgroundColor: RepFastColors.surfaceRaised,
                  disabledForegroundColor: RepFastColors.muted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: state.isSaving ? null : onLogSet,
                child: Text(
                  state.isSaving ? 'Saving' : 'Log set',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            if (state.saveError != null) ...[
              const SizedBox(height: 12),
              Text(
                state.saveError!,
                style: textTheme.bodyMedium?.copyWith(
                  color: RepFastColors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 18),
            ComparisonStrip(result: state.comparison),
            if (!isShort) ...[
              const SizedBox(height: 18),
              Text(
                'Open, lift, log, compare. No account, no signal, no clipboard between sets.',
                style: textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'RepFast',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: RepFastColors.cyan,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Offline lift log',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: RepFastColors.muted),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    this.icon,
    this.color = RepFastColors.cyan,
  });

  final String text;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RepFastColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RepFastColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: icon == null ? RepFastColors.text : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _LoadErrorState extends StatelessWidget {
  const _LoadErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load workout.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Your log stays on this phone. Retry before your next set.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
