import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app.dart';

void main() {
  testWidgets('App should render login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BiblioGestApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify login screen is displayed
    expect(find.text('BiblioGest'), findsOneWidget);
    expect(find.text('Iniciar Sesion'), findsOneWidget);
  });
}
