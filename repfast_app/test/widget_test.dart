import 'package:flutter_test/flutter_test.dart';
import 'package:repfast_app/main.dart';

void main() {
  testWidgets('RepFast app builds', (tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Hello World!'), findsOneWidget);
  });
}
