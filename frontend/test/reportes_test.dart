import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/archivos/formato_exportacion.dart';
import 'package:frontend/core/theme/tema_app.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/reports/data/reporte_repository.dart';
import 'package:frontend/features/reports/presentation/screens/reportes_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Servidor falso de reportes: guarda las peticiones y responde una tabla fija.
class _Servidor implements HttpClientAdapter {
  final List<RequestOptions> recibidas = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? s, Future<void>? c) async {
    recibidas.add(options);
    final tipo = options.path.split('/')[3];
    final cuerpo = {
      'titulo': 'Reporte',
      'descripcion': 'Sin filtros | Total: 1 | Horas en UTC',
      'columnas': tipo == 'vencidos'
          ? ['Persona', 'Documento', 'Dias de atraso']
          : ['Solicitud', 'Persona', 'Estado'],
      'filas': [
        tipo == 'vencidos' ? ['Ana Lopez', 'D-2', '3'] : ['10/10/2026 12:00', 'Luis Perez', 'Activo'],
      ],
      'total': 1,
      'pagina': 1,
      'tamano': 10,
      'total_paginas': 1,
    };
    return ResponseBody.fromString(
      jsonEncode(cuerpo),
      200,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<_Servidor> _abrir(WidgetTester tester) async {
  final servidor = _Servidor();
  final dio = Dio(BaseOptions(baseUrl: 'http://prueba.test'))..httpClientAdapter = servidor;
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenSesionProvider.overrideWithValue('token'),
        reporteRepositoryProvider.overrideWithValue(ReporteRepository(dio)),
      ],
      child: MaterialApp(theme: TemaApp.claro, home: const ReportesScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return servidor;
}

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  test('los filtros se envian como dias y sin valores vacios', () {
    final consulta = ConsultaReporte(
      desde: DateTime(2026, 10, 5),
      hasta: DateTime(2026, 10, 9),
      estado: 'vencido',
      texto: ' ana ',
    );

    expect(consulta.filtros, {
      'desde': '2026-10-05',
      'hasta': '2026-10-09',
      'estado': 'vencido',
      'q': 'ana',
    });
    expect(const ConsultaReporte().filtros, isEmpty);
  });

  test('cambiar un filtro vuelve a la primera pagina y quitar una fecha es posible', () {
    final consulta = ConsultaReporte(desde: DateTime(2026, 10, 5), pagina: 3);

    final sinFecha = consulta.conFiltros(desde: () => null);

    expect(sinFecha.desde, isNull);
    expect(sinFecha.pagina, 1);
    expect(consulta.enPagina(2).pagina, 2);
  });

  testWidgets('muestra las tres pestanas y la tabla del reporte de prestamos', (tester) async {
    final servidor = await _abrir(tester);

    expect(find.text('Préstamos'), findsOneWidget);
    expect(find.text('Vencidos'), findsOneWidget);
    expect(find.text('Devoluciones'), findsOneWidget);
    expect(find.text('Luis Perez'), findsOneWidget);
    expect(find.text('Activo'), findsOneWidget);
    expect(find.textContaining('Total: 1'), findsOneWidget);
    expect(servidor.recibidas.single.path, '/api/reportes/prestamos');
    expect(servidor.recibidas.single.queryParameters, {'pagina': 1, 'tamano': 10});
  });

  testWidgets('la pestana de vencidos pide su propio reporte', (tester) async {
    final servidor = await _abrir(tester);

    await tester.tap(find.text('Vencidos'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Lopez'), findsOneWidget);
    expect(find.text('Dias de atraso'), findsOneWidget);
    expect(servidor.recibidas.last.path, '/api/reportes/vencidos');
  });

  testWidgets('el menu de exportar ofrece CSV, Excel y PDF', (tester) async {
    await _abrir(tester);

    await tester.tap(find.text('Exportar'));
    await tester.pumpAndSettle();

    for (final formato in FormatoExportacion.values) {
      expect(find.text(formato.etiqueta), findsOneWidget);
    }
  });
}
