import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart' hide testWidgets;
import 'package:flutter_test/flutter_test.dart' as ft show testWidgets;
import 'package:frontend/app/app.dart';
import 'package:frontend/app/auth_state.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/local/modo_local.dart';
import 'package:frontend/core/theme/modo_tema_provider.dart';
import 'package:frontend/features/sincronizacion/data/models/estado_local.dart';
import 'package:frontend/features/sincronizacion/presentation/providers/estado_local_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ayudas/sin_actualizaciones.dart';

EstadoLocal _estado({
  String? servidor = 'http://192.168.1.10:8000',
  bool? conectado = true,
  int pendientes = 0,
  int conflictos = 0,
  String? error,
}) {
  return EstadoLocal(
    configurado: true,
    servidorUrl: servidor,
    conectado: conectado,
    sincronizando: false,
    pendientes: pendientes,
    conflictos: conflictos,
    ultimaSincronizacion: DateTime.utc(2026, 10, 11, 12),
    ultimoError: error,
    requiereInicioDeSesion: false,
  );
}

Future<void> _abrirApp(
  WidgetTester tester, {
  EstadoLocal? estado,
  List<ConflictoLocal> conflictos = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferencias = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      preferenciasProvider.overrideWithValue(preferencias),
      ...sinActualizaciones,
      if (estado != null) estadoLocalProvider.overrideWith((ref) => Stream.value(estado)),
      conflictosProvider.overrideWith((ref) async => conflictos),
    ],
    child: const BiblioGestApp(),
  ));
  await tester.pumpAndSettle();
}

/// Estas pruebas son del menú de escritorio: `flutter test` corre por defecto como
/// Android, donde el personal tiene un menú móvil distinto.
void testWidgets(String descripcion, Future<void> Function(WidgetTester) prueba) {
  ft.testWidgets(descripcion, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await prueba(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  tearDown(() {
    // El router y el estado de modo son globales: se devuelven a su estado inicial.
    modoLocalNotifier.iniciar(activo: false, requiereConfiguracion: false);
    authStateNotifier.cerrarSesion();
    appRouter.go('/login');
  });

  group('EstadoLocal', () {
    test('lee la respuesta del backend y toma las fechas como UTC', () {
      final estado = EstadoLocal.fromJson({
        'configurado': true,
        'servidor_url': 'http://servidor:8000',
        'conectado': null,
        'sincronizando': false,
        'pendientes': 3,
        'conflictos': 1,
        'ultima_sincronizacion': '2026-10-11T14:36:09.907299',
        'ultimo_error': null,
        'requiere_inicio_de_sesion': false,
      });

      expect(estado.tieneServidor, isTrue);
      expect(estado.conectado, isNull);
      expect(estado.pendientes, 3);
      expect(estado.ultimaSincronizacion!.isUtc, isTrue);
      expect(estado.ultimaSincronizacion!.hour, 14);
    });

    test('un equipo sin servidor trabaja solo', () {
      expect(_estado(servidor: null).tieneServidor, isFalse);
    });
  });

  group('configuración inicial', () {
    testWidgets('un equipo sin configurar solo muestra la configuración', (tester) async {
      modoLocalNotifier.iniciar(activo: true, requiereConfiguracion: true);
      await _abrirApp(tester);

      expect(find.text('Configura este equipo'), findsOneWidget);
      expect(find.text('Usar solo en este equipo'), findsOneWidget);
      expect(find.text('Conectar con un servidor'), findsOneWidget);

      appRouter.go('/materials');
      await tester.pumpAndSettle();
      expect(find.text('Configura este equipo'), findsOneWidget); // no deja salir
    });

    testWidgets('elegir "solo en este equipo" pide los datos del administrador', (tester) async {
      modoLocalNotifier.iniciar(activo: true, requiereConfiguracion: true);
      await _abrirApp(tester);

      await tester.tap(find.text('Usar solo en este equipo'));
      await tester.pumpAndSettle();

      expect(find.text('Administrador de este equipo'), findsOneWidget);
      expect(find.text('Crear administrador'), findsOneWidget);
    });

    testWidgets('elegir un servidor pide su dirección', (tester) async {
      modoLocalNotifier.iniciar(activo: true, requiereConfiguracion: true);
      await _abrirApp(tester);

      await tester.tap(find.text('Conectar con un servidor'));
      await tester.pumpAndSettle();

      expect(find.text('Dirección del servidor'), findsOneWidget);
      expect(find.text('Conectar y descargar datos'), findsOneWidget);
    });

    testWidgets('al terminar la configuración se pasa al inicio de sesión', (tester) async {
      modoLocalNotifier.iniciar(activo: true, requiereConfiguracion: true);
      await _abrirApp(tester);

      modoLocalNotifier.configuracionTerminada();
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Iniciar sesión'), findsOneWidget);
    });
  });

  group('menú del ejecutable', () {
    testWidgets('muestra la sección de sincronización y el indicador de conexión', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      modoLocalNotifier.iniciar(activo: true, requiereConfiguracion: false);

      await _abrirApp(tester, estado: _estado(pendientes: 2));
      authStateNotifier.iniciarSesion('admin');
      await tester.pumpAndSettle();

      expect(find.text('Sincronización'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done_outlined), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // cambios por enviar
    });

    testWidgets('en la web no aparece la sincronización', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _abrirApp(tester);
      authStateNotifier.iniciarSesion('admin');
      await tester.pumpAndSettle();

      expect(find.text('Sincronización'), findsNothing);
      appRouter.go('/sync');
      await tester.pumpAndSettle();
      expect(find.text('Lo que requiere atención en la biblioteca'), findsOneWidget);
    });

    testWidgets('sin conexión, el indicador avisa que los cambios esperan', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      modoLocalNotifier.iniciar(activo: true, requiereConfiguracion: false);

      await _abrirApp(tester, estado: _estado(conectado: false, pendientes: 4));
      authStateNotifier.iniciarSesion('bibliotecario');
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      expect(find.byTooltip('Sin conexión · 4 cambios por enviar'), findsOneWidget);
    });
  });

  group('pantalla de sincronización', () {
    testWidgets('explica que se puede seguir trabajando sin conexión', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      modoLocalNotifier.iniciar(activo: true, requiereConfiguracion: false);

      await _abrirApp(tester, estado: _estado(conectado: false, pendientes: 5));
      authStateNotifier.iniciarSesion('admin');
      appRouter.go('/sync');
      await tester.pumpAndSettle();

      expect(find.text('Sin conexión con el servidor'), findsOneWidget);
      expect(find.textContaining('seguir trabajando'), findsOneWidget);
      expect(find.text('http://192.168.1.10:8000'), findsOneWidget);
      expect(find.text('Sincronizar ahora'), findsOneWidget);
    });

    testWidgets('lista los conflictos con las opciones de resolverlos', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      modoLocalNotifier.iniciar(activo: true, requiereConfiguracion: false);

      await _abrirApp(
        tester,
        estado: _estado(conflictos: 1),
        conflictos: [
          ConflictoLocal(
            id: 'c1',
            creadoEn: DateTime.utc(2026, 10, 11, 10),
            descripcion: 'Prestamo «activo» nuevo · Material «PROY-1» modificado',
            mensaje: 'Material cambio en el servidor mientras trabajabas sin conexion.',
          ),
        ],
      );
      authStateNotifier.iniciarSesion('bibliotecario');
      appRouter.go('/sync');
      await tester.pumpAndSettle();

      expect(find.text('Cambios por revisar'), findsOneWidget);
      expect(find.textContaining('PROY-1'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.text('Descartar mis cambios'), findsOneWidget);
    });

    testWidgets('solo un administrador puede cambiar de servidor', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      modoLocalNotifier.iniciar(activo: true, requiereConfiguracion: false);

      await _abrirApp(tester, estado: _estado());
      authStateNotifier.iniciarSesion('bibliotecario');
      appRouter.go('/sync');
      await tester.pumpAndSettle();
      expect(find.text('Trabajar solo en este equipo'), findsNothing);

      authStateNotifier.cerrarSesion();
      await tester.pumpAndSettle(); // el router lleva al login antes de entrar otra persona
      authStateNotifier.iniciarSesion('admin');
      await tester.pumpAndSettle();
      appRouter.go('/sync');
      await tester.pumpAndSettle();
      expect(find.text('Trabajar solo en este equipo'), findsOneWidget);
    });
  });
}
