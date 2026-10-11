import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/actualizaciones/actualizaciones_provider.dart';
import 'package:frontend/core/actualizaciones/cliente_actualizaciones.dart';
import 'package:frontend/core/actualizaciones/decision.dart';
import 'package:frontend/core/actualizaciones/instalador_actualizaciones.dart';
import 'package:frontend/core/actualizaciones/manifiesto.dart';
import 'package:frontend/core/actualizaciones/preferencias_actualizacion.dart';
import 'package:frontend/core/actualizaciones/version_app.dart';
import 'package:frontend/core/theme/modo_tema_provider.dart';
import 'package:frontend/core/theme/tema_app.dart';
import 'package:frontend/features/actualizaciones/presentation/widgets/guardia_actualizacion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Instalador implements InstaladorActualizaciones {
  @override
  bool get disponible => false; // el notifier no busca nada: el estado se fija a mano

  @override
  Future<void> limpiarDescargas(String versionActual) async {}

  @override
  Future<String> descargar(Manifiesto manifiesto, {required void Function(double) alProgreso}) async => '';

  @override
  Future<void> instalar(String ruta, {required Future<void> Function() cerrarBackend}) async {}

  @override
  Future<void> salir({required Future<void> Function() cerrarBackend}) async {}
}

class _NotifierFijo extends ActualizacionesNotifier {
  _NotifierFijo(SharedPreferences preferencias, EstadoActualizacion estado)
      : super(
          versionInstalada: VersionApp.parse('0.10.0'),
          cliente: ClienteActualizaciones(dio: Dio(), urlManifiesto: 'https://x.test/l.json', clavePublica: ''),
          instalador: _Instalador(),
          preferencias: PreferenciasActualizacion(preferencias),
          cerrarBackend: () async {},
          habilitado: false,
          clavePublica: '',
        ) {
    this.state = estado;
  }
}

final _nueva = Manifiesto(
  version: VersionApp.parse('0.10.1'),
  minima: VersionApp.parse('0.0.0'),
  url: Uri.parse('https://x.test/i.exe'),
  sha256: 'a' * 64,
  tamano: 50 * 1024 * 1024,
  notas: 'Corrige el cierre de caja.',
);

Future<void> _mostrar(WidgetTester tester, EstadoActualizacion estado) async {
  SharedPreferences.setMockInitialValues({});
  final preferencias = await SharedPreferences.getInstance();
  await tester.binding.setSurfaceSize(const Size(1000, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        preferenciasProvider.overrideWithValue(preferencias),
        versionAppProvider.overrideWithValue('0.10.0'),
        actualizacionesProvider.overrideWith((ref) => _NotifierFijo(preferencias, estado)),
      ],
      child: MaterialApp(
        theme: TemaApp.claro,
        builder: (context, child) => GuardiaActualizacion(child: child!),
        home: const Scaffold(body: Center(child: Text('Contenido de la aplicación'))),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('sin actualización pendiente solo se ve la aplicación', (tester) async {
    await _mostrar(tester, const EstadoActualizacion());

    expect(find.text('Contenido de la aplicación'), findsOneWidget);
    expect(find.text('Hay una nueva versión disponible'), findsNothing);
  });

  testWidgets('una actualización opcional pregunta y deja seguir usando la aplicación', (tester) async {
    await _mostrar(
      tester,
      EstadoActualizacion(
        fase: FaseActualizacion.disponible,
        urgencia: Urgencia.opcional,
        manifiesto: _nueva,
        avisoPendiente: true,
      ),
    );

    expect(find.text('Hay una nueva versión disponible'), findsOneWidget);
    expect(find.textContaining('BiblioGest 0.10.1'), findsOneWidget);
    expect(find.text('Tienes la versión 0.10.0.'), findsOneWidget);
    expect(find.text('Corrige el cierre de caja.'), findsOneWidget);
    expect(find.text('Actualizar ahora'), findsOneWidget);
    expect(find.text('Más tarde'), findsOneWidget);
    expect(find.text('Omitir esta versión'), findsOneWidget);
    expect(find.text('Instalar las próximas actualizaciones automáticamente'), findsOneWidget);
    expect(find.text('Contenido de la aplicación'), findsOneWidget);

    await tester.tap(find.text('Más tarde'));
    await tester.pump();
    expect(find.text('Hay una nueva versión disponible'), findsNothing);
    expect(find.text('Contenido de la aplicación'), findsOneWidget);
  });

  testWidgets('una actualización obligatoria reemplaza la aplicación y no ofrece omitir', (tester) async {
    await _mostrar(
      tester,
      EstadoActualizacion(
        fase: FaseActualizacion.disponible,
        urgencia: Urgencia.obligatoria,
        manifiesto: _nueva,
      ),
    );

    expect(find.text('Actualización obligatoria'), findsOneWidget);
    expect(find.text('Actualizar ahora'), findsOneWidget);
    expect(find.text('Salir'), findsOneWidget);
    expect(find.text('Más tarde'), findsNothing);
    expect(find.text('Omitir esta versión'), findsNothing);
    expect(find.text('Contenido de la aplicación'), findsNothing);
  });

  testWidgets('durante la descarga muestra el avance y bloquea los botones', (tester) async {
    await _mostrar(
      tester,
      EstadoActualizacion(
        fase: FaseActualizacion.descargando,
        urgencia: Urgencia.opcional,
        manifiesto: _nueva,
        avisoPendiente: true,
        progreso: 0.42,
      ),
    );

    expect(find.text('Descargando… 42 %'), findsOneWidget);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Más tarde')).onPressed, isNull);
  });

  testWidgets('si falla la descarga muestra el motivo y permite reintentar', (tester) async {
    await _mostrar(
      tester,
      EstadoActualizacion(
        fase: FaseActualizacion.error,
        urgencia: Urgencia.opcional,
        manifiesto: _nueva,
        avisoPendiente: true,
        mensaje: 'No se pudo descargar la actualización.',
      ),
    );

    expect(find.text('No se pudo descargar la actualización.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
