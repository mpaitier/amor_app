// <<===========================================================================>>
// <<========================== TEST WIDGET DE BASE ============================>>
// <<===========================================================================>>

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // <<--- Correction : MyApp remplacé par AmorApp --->
    await tester.pumpWidget(const AmorApp());
  });
}