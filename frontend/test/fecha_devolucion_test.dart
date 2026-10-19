import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/tema_app.dart';
import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/loans/data/models/plazo_devolucion.dart';
import 'package:frontend/features/loans/presentation/widgets/campo_fecha_devolucion.dart';
import 'package:frontend/features/loans/presentation/widgets/tarjeta_prestamo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'ayudas/prestamo_de_prueba.dart';

Widget _app(Widget hijo) => ProviderScope(
  child: MaterialApp(
    theme: TemaApp.claro,
    home: Scaffold(body: SingleChildScrollView(child: hijo)),
  ),
);

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  group('hora de Paraguay', () {
    test(
      'lo que se elige en pantalla se envía como el mismo instante en UTC',
      () {
        // 18:00 en Paraguay (UTC-3) son las 21:00 UTC, sin depender de la zona del equipo.
        final utc = PlazoDevolucion.combinar(DateTime(2026, 10, 20), 18, 0);
        expect(utc, DateTime.utc(2026, 10, 20, 21));
        expect(utc.isUtc, isTrue);
      },
    );

    test('es la operación inversa de enParaguay', () {
      final instante = DateTime.utc(2026, 10, 20, 11, 30);
      final pared = FormatoFecha.enParaguay(instante);
      expect(FormatoFecha.desdeParaguay(pared), instante);
    });

    test(
      'combinar pasa al día siguiente cuando la hora de Paraguay cruza la medianoche UTC',
      () {
        final utc = PlazoDevolucion.combinar(DateTime(2026, 10, 20), 22, 30);
        expect(utc, DateTime.utc(2026, 10, 21, 1, 30));
      },
    );

    test('hoyEnParaguay usa la fecha de Paraguay, no la del equipo', () {
      // 01:00 UTC del día 20 todavía es el día 19 en Paraguay.
      final hoy = PlazoDevolucion.hoyEnParaguay(
        ahora: DateTime.utc(2026, 10, 20, 1),
      );
      expect(hoy, DateTime(2026, 10, 19));
    });
  });

  group('validación de la fecha de devolución', () {
    final ahora = DateTime.utc(2026, 10, 20, 12);

    test('una fecha futura es válida', () {
      expect(
        PlazoDevolucion.validar(
          ahora.add(const Duration(hours: 2)),
          ahora: ahora,
        ),
        isNull,
      );
    });

    test(
      'una fecha pasada o igual a ahora se rechaza con un mensaje claro',
      () {
        for (final limite in [
          ahora,
          ahora.subtract(const Duration(minutes: 1)),
        ]) {
          final mensaje = PlazoDevolucion.validar(limite, ahora: ahora);
          expect(mensaje, contains('posteriores a este momento'));
          expect(mensaje, isNot(contains('Exception')));
        }
      },
    );

    test('más de un año hacia adelante se rechaza', () {
      final lejos = ahora.add(const Duration(days: 366));
      expect(
        PlazoDevolucion.validar(lejos, ahora: ahora),
        contains('más de un año'),
      );
    });
  });

  group('CampoFechaDevolucion', () {
    testWidgets('sin fecha muestra el plazo automático', (tester) async {
      await tester.pumpWidget(
        _app(CampoFechaDevolucion(valor: null, onChanged: (_) {})),
      );

      expect(find.text('Plazo automático según el material'), findsOneWidget);
      expect(find.byTooltip('Volver al plazo automático'), findsNothing);
    });

    testWidgets('con fecha la muestra en hora de Paraguay y permite quitarla', (
      tester,
    ) async {
      DateTime? recibido = DateTime.utc(2026, 10, 20, 21);
      await tester.pumpWidget(
        _app(
          CampoFechaDevolucion(valor: recibido, onChanged: (f) => recibido = f),
        ),
      );

      expect(find.textContaining('20 oct 2026, 18:00'), findsOneWidget);
      expect(find.text('Hora de Paraguay'), findsOneWidget);

      await tester.tap(find.byTooltip('Volver al plazo automático'));
      expect(recibido, isNull);
    });
  });

  group('entrega con fecha elegida', () {
    testWidgets(
      'una solicitud pendiente ofrece elegir la fecha, además de entregar ahora',
      (tester) async {
        await tester.pumpWidget(
          _app(TarjetaPrestamo(prestamo: prestamoDePrueba())),
        );

        expect(find.text('Entregar ahora'), findsOneWidget);
        expect(find.text('Elegir fecha de devolución'), findsOneWidget);
      },
    );

    testWidgets('una reserva aprobada también', (tester) async {
      await tester.pumpWidget(
        _app(TarjetaPrestamo(prestamo: prestamoDePrueba(estado: 'aprobado'))),
      );

      expect(find.text('Marcar como entregado'), findsOneWidget);
      expect(find.text('Elegir fecha de devolución'), findsOneWidget);
    });

    testWidgets('un préstamo ya entregado no la ofrece', (tester) async {
      await tester.pumpWidget(
        _app(TarjetaPrestamo(prestamo: prestamoDePrueba(estado: 'activo'))),
      );

      expect(find.text('Elegir fecha de devolución'), findsNothing);
    });
  });
}
