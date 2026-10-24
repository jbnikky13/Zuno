import 'package:flutter_test/flutter_test.dart';
import 'package:zuno/main.dart';

void main() {
  testWidgets('Zuno shows offline and international messaging routes', (tester) async {
    await tester.pumpWidget(const ZunoApp());

    expect(find.text('zuno'), findsOneWidget);
    expect(find.text('Nearby mode'), findsOneWidget);
    expect(find.text('Zuno Anywhere'), findsOneWidget);
    expect(find.textContaining('Early UI prototype'), findsOneWidget);
  });

  testWidgets('bottom navigation opens nearby and share screens', (tester) async {
    await tester.pumpWidget(const ZunoApp());

    await tester.tap(find.text('Nearby').last);
    await tester.pumpAndSettle();
    expect(find.text('Nearby discovery is not connected yet'), findsOneWidget);

    await tester.tap(find.text('Share').last);
    await tester.pumpAndSettle();
    expect(find.text('File transfer is coming next'), findsOneWidget);
  });
}
