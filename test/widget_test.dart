import 'package:flutter_test/flutter_test.dart';

import 'package:dev_hup_task_week_1/main.dart';

void main() {
  testWidgets('App starts on login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const InternTaskApp());

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
