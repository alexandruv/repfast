import 'package:flutter/material.dart';

import '../application/active_workout_controller.dart';
import '../data/sqlite_workout_repository.dart';
import 'screens/active_cockpit_screen.dart';
import 'theme.dart';

class RepFastApp extends StatelessWidget {
  const RepFastApp({
    super.key,
    this.controller,
    this.repositoryLoader = SqliteWorkoutRepository.open,
  });

  final ActiveWorkoutController? controller;
  final Future<SqliteWorkoutRepository> Function() repositoryLoader;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RepFast',
      debugShowCheckedModeBanner: false,
      theme: repFastTheme(),
      home: controller == null
          ? _RepositoryLoadedHome(repositoryLoader: repositoryLoader)
          : ActiveCockpitScreen(controller: controller!),
    );
  }
}

class _RepositoryLoadedHome extends StatefulWidget {
  const _RepositoryLoadedHome({required this.repositoryLoader});

  final Future<SqliteWorkoutRepository> Function() repositoryLoader;

  @override
  State<_RepositoryLoadedHome> createState() => _RepositoryLoadedHomeState();
}

class _RepositoryLoadedHomeState extends State<_RepositoryLoadedHome> {
  late Future<ActiveWorkoutController> _controller;

  @override
  void initState() {
    super.initState();
    _controller = _openController();
  }

  Future<ActiveWorkoutController> _openController() async {
    final repository = await widget.repositoryLoader();
    return ActiveWorkoutController(repository: repository);
  }

  void _retry() {
    setState(() {
      _controller = _openController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ActiveWorkoutController>(
      future: _controller,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ActiveCockpitScreen(controller: snapshot.requireData);
        }
        if (snapshot.hasError) {
          return _ShellMessage(
            title: 'Could not open workout log.',
            detail:
                'Your lifts stay on this device. Retry when storage is ready.',
            action: FilledButton(onPressed: _retry, child: const Text('Retry')),
          );
        }
        return const _ShellMessage(
          title: 'Opening RepFast',
          detail: 'Loading your offline workout log.',
          action: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        );
      },
    );
  }
}

class _ShellMessage extends StatelessWidget {
  const _ShellMessage({
    required this.title,
    required this.detail,
    required this.action,
  });

  final String title;
  final String detail;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                action,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
