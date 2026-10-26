import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/theme/modo_tema_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ayudas/sin_actualizaciones.dart';

void main() {
  testWidgets('La app muestra la pantalla de inicio de sesion',
      (WidgetTester tester) async {
    // Preferencias simuladas: la app lee el modo de tema guardado al arrancar.
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferenciasProvider.overrideWithValue(preferencias), ...sinActualizaciones],
        child: const BiblioGestApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('BiblioGest'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Iniciar sesión'), findsOneWidget);
  });

  testWidgets('El modo oscuro se recuerda entre sesiones',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'modo_tema': 'oscuro'});
    final preferencias = await SharedPreferences.getInstance();
    final contenedor = ProviderContainer(
      overrides: [preferenciasProvider.overrideWithValue(preferencias), ...sinActualizaciones],
    );
    addTearDown(contenedor.dispose);

    expect(contenedor.read(modoTemaProvider).name, 'dark');
  });
}
