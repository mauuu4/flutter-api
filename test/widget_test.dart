import 'package:flutter_test/flutter_test.dart';

import 'package:api_pizzas_app/main.dart';

void main() {
  testWidgets('App builds and shows Pizzas tab', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Pizzas'), findsWidgets);
  });
}
