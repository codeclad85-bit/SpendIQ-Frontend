import 'package:flutter_test/flutter_test.dart';
import 'package:spend_iq/main.dart';

void main() {
  testWidgets('SpendIQ app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SpendIQApp());
    await tester.pump();

    expect(find.byType(SpendIQApp), findsOneWidget);
  });
}
