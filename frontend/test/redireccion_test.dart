import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/auth_state.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/theme/modo_tema_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Arranca la app con las preferencias simuladas.
Future<void> _abrirApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final preferencias = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [preferenciasProvider.overrideWithValue(preferencias)],
    child: const BiblioGestApp(),
  ));
  await tester.pumpAndSettle();
}

/// Ejecuta una prueba simulando que la app corre en [plataforma].
///
/// El valor simulado debe quitarse antes de que termine la prueba (Flutter lo
/// verifica), por eso se restablece en un `finally` dentro del propio test.
Future<void> _enPlataforma(
  TargetPlatform plataforma,
  WidgetTester tester,
  Future<void> Function() prueba,
) async {
  debugDefaultTargetPlatformOverride = plataforma;
  try {
    await _abrirApp(tester);
    await prueba();
  } finally {
    debugDefaultTargetPlatformOverride = null;
    authStateNotifier.cerrarSesion();
    appRouter.go('/login');
  }
}

void main() {
  testWidgets('sin sesion se queda en el login aunque pida otra ruta', (tester) async {
    await _enPlataforma(TargetPlatform.windows, tester, () async {
      appRouter.go('/loans');
      await tester.pumpAndSettle();

      expect(find.text('Iniciar Sesion'), findsOneWidget);
    });
  });

  testWidgets('el personal entra al inicio', (tester) async {
    await _enPlataforma(TargetPlatform.windows, tester, () async {
      authStateNotifier.iniciarSesion('bibliotecario');
      await tester.pumpAndSettle();

      expect(find.text('Lo que requiere atención en la biblioteca'), findsOneWidget);
    });
  });

  testWidgets('el personal no puede entrar a la seccion del estudiante', (tester) async {
    await _enPlataforma(TargetPlatform.windows, tester, () async {
      authStateNotifier.iniciarSesion('admin');
      await tester.pumpAndSettle();

      appRouter.go('/estudiante');
      await tester.pumpAndSettle();

      expect(find.text('Lo que requiere atención en la biblioteca'), findsOneWidget);
    });
  });

  testWidgets('un estudiante en escritorio ve el aviso de usar el movil', (tester) async {
    await _enPlataforma(TargetPlatform.windows, tester, () async {
      authStateNotifier.iniciarSesion('estudiante');
      await tester.pumpAndSettle();

      expect(find.text('Usa la aplicación móvil'), findsOneWidget);
    });
  });

  testWidgets('un estudiante en escritorio no puede pasar a otras pantallas', (tester) async {
    await _enPlataforma(TargetPlatform.windows, tester, () async {
      authStateNotifier.iniciarSesion('estudiante');
      await tester.pumpAndSettle();

      appRouter.go('/materials');
      await tester.pumpAndSettle();

      expect(find.text('Usa la aplicación móvil'), findsOneWidget);
    });
  });

  testWidgets('un estudiante en el movil entra a su catalogo', (tester) async {
    await _enPlataforma(TargetPlatform.android, tester, () async {
      authStateNotifier.iniciarSesion('estudiante');
      await tester.pumpAndSettle();

      expect(find.text('Catálogo'), findsWidgets);
      expect(find.text('Mis solicitudes'), findsOneWidget);
    });
  });
}
