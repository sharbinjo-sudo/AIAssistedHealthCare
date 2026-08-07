import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';

void main() {
  testWidgets('navigates from splash to login', (tester) async {
    await tester.pumpWidget(HealGuiApp());

    expect(find.text('Heal Gui AI'), findsOneWidget);
    expect(find.text('AI Powered Smart Healthcare'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
