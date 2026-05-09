import 'package:flutter_test/flutter_test.dart';
import 'package:repfast_app/src/application/active_workout_controller.dart';
import 'package:repfast_app/src/data/sqlite_workout_repository.dart';
import 'package:repfast_app/src/ui/repfast_app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  testWidgets('RepFast app builds', (tester) async {
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

    await tester.pumpWidget(RepFastApp(controller: controller!));
    for (var pumpCount = 0; pumpCount < 20; pumpCount += 1) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('Bench Press').evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.text('RepFast'), findsOneWidget);
    expect(find.text('Bench Press'), findsOneWidget);
  });
}
