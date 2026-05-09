import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repfast_app/src/application/active_workout_controller.dart';
import 'package:repfast_app/src/data/sqlite_workout_repository.dart';
import 'package:repfast_app/src/ui/repfast_app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  Future<ActiveWorkoutController> openController(WidgetTester tester) async {
    final controller = await tester.runAsync(() async {
      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
      );
      final repository = await SqliteWorkoutRepository.openWithDatabase(
        database,
      );
      addTearDown(repository.close);
      final controller = ActiveWorkoutController(repository: repository);
      await controller.load();
      return controller;
    });
    return controller!;
  }

  testWidgets('cockpit renders active lift defaults and comparison', (
    tester,
  ) async {
    final controller = await openController(tester);

    await tester.pumpWidget(RepFastApp(controller: controller));
    await tester.pumpUntilFound(find.text('Bench Press'));

    expect(find.text('RepFast'), findsOneWidget);
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Saved on device'), findsOneWidget);
    expect(find.text('Set 1'), findsOneWidget);
    expect(find.text('225'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('LOG SET'), findsOneWidget);
    expect(find.text('Today vs last time'), findsOneWidget);
    expect(
      find.text('No signup. No signal. Open, lift, log, compare.'),
      findsOneWidget,
    );
  });

  testWidgets('weight and reps controls update values', (tester) async {
    final controller = await openController(tester);

    await tester.pumpWidget(RepFastApp(controller: controller));
    await tester.pumpUntilFound(find.text('Bench Press'));
    await tester.tap(find.bySemanticsLabel('Increase weight'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Increase reps'));
    await tester.pump();

    expect(find.text('230'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('logging a set advances to set 2, rest, and comparison state', (
    tester,
  ) async {
    final controller = await openController(tester);

    await tester.pumpWidget(RepFastApp(controller: controller));
    await tester.pumpUntilFound(find.text('Bench Press'));
    await tester.tap(find.bySemanticsLabel('Increase reps'));
    await tester.pump();
    await tester.ensureVisible(find.text('LOG SET'));
    await tester.tap(find.text('LOG SET'));
    await tester.waitForSetIndex(controller, 2);
    await tester.pumpUntilFound(find.text('Set 2'));

    expect(find.text('Set 2'), findsOneWidget);
    expect(controller.state.isResting, isTrue);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 500));
    await tester.pumpUntilFound(find.text('Rest started'));
    expect(find.text('Rest started'), findsOneWidget);
    expect(find.textContaining('+'), findsWidgets);
    expect(find.text('You added one rep at the same weight.'), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpUntilFound(Finder finder) async {
    for (var pumpCount = 0; pumpCount < 20; pumpCount += 1) {
      await pump(const Duration(milliseconds: 50));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    expect(finder, findsOneWidget);
  }

  Future<void> waitForSetIndex(
    ActiveWorkoutController controller,
    int setIndex,
  ) async {
    await runAsync(() async {
      for (var attempt = 0; attempt < 20; attempt += 1) {
        if (controller.state.setIndex == setIndex) {
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    expect(controller.state.setIndex, setIndex);
  }
}
