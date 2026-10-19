import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/tema_app.dart';
import 'package:frontend/features/loans/data/models/plazo_retiro.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'package:frontend/features/loans/presentation/widgets/meta_prestamo.dart';
import 'package:frontend/features/student/presentation/widgets/hoja_fecha_retiro.dart';
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

  final ahora = DateTime.utc(2026, 10, 20, 15);

  group('validación de la fecha de retiro', () {
    test('una fecha futura dentro de la semana es válida', () {
      expect(
        PlazoRetiro.validar(ahora.add(const Duration(days: 2)), ahora: ahora),
        isNull,
      );
    });

    test('una fecha pasada se rechaza con un mensaje claro', () {
      final mensaje = PlazoRetiro.validar(
        ahora.subtract(const Duration(minutes: 5)),
        ahora: ahora,
      );
      expect(mensaje, contains('posteriores a este momento'));
      expect(mensaje, isNot(contains('Exception')));
    });

    test('más de 7 días de anticipación se rechaza', () {
      final mensaje = PlazoRetiro.validar(
        ahora.add(const Duration(days: 8)),
        ahora: ahora,
      );
      expect(mensaje, contains('7 días de anticipación'));
    });

    test(
      'la propuesta inicial es mañana a las 9:00 de Paraguay y es válida',
      () {
        final propuesta = PlazoRetiro.propuesta(ahora: ahora);
        // 9:00 en Paraguay (UTC-3) = 12:00 UTC del día siguiente.
        expect(propuesta, DateTime.utc(2026, 10, 21, 12));
        expect(PlazoRetiro.validar(propuesta, ahora: ahora), isNull);
      },
    );
  });

  group('el modelo lee la fecha de retiro que envía el servidor', () {
    test('sin fecha (aplicaciones o solicitudes anteriores) queda en null', () {
      expect(prestamoDePrueba().fechaRetiroSolicitada, isNull);
    });

    test('con fecha la interpreta como UTC', () {
      final json = jsonPrestamo()
        ..['fecha_retiro_solicitada'] = '2026-10-21T12:00:00Z';
      final prestamo = Prestamo.fromJson(json);

      expect(prestamo.fechaRetiroSolicitada, DateTime.utc(2026, 10, 21, 12));
      // y se conserva al copiar y comparar
      expect(
        prestamo.copyWith(observaciones: 'x').fechaRetiroSolicitada,
        prestamo.fechaRetiroSolicitada,
      );
      expect(prestamo, Prestamo.fromJson(json));
      expect(
        prestamo.toJson()['fecha_retiro_solicitada'],
        '2026-10-21T12:00:00.000Z',
      );
    });
  });

  group('lo que ve el personal', () {
    testWidgets('una solicitud pendiente muestra cuándo dice que pasará', (
      tester,
    ) async {
      final prestamo = Prestamo.fromJson(
        jsonPrestamo()..['fecha_retiro_solicitada'] = '2026-10-21T18:00:00Z',
      );
      await tester.pumpWidget(_app(MetaPrestamo(prestamo: prestamo)));

      expect(
        find.textContaining('Retiro previsto: 21 oct 2026, 15:00'),
        findsOneWidget,
      );
    });

    testWidgets('sin fecha propuesta no agrega esa línea', (tester) async {
      await tester.pumpWidget(_app(MetaPrestamo(prestamo: prestamoDePrueba())));

      expect(find.textContaining('Retiro previsto'), findsNothing);
    });
  });

  group('HojaFechaRetiro', () {
    testWidgets('propone una fecha válida y permite confirmarla', (
      tester,
    ) async {
      DateTime? elegido;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: TemaApp.claro,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async => elegido = await pedirFechaRetiro(
                      context,
                      resumen: 'Rayuela y 1 más',
                    ),
                    child: const Text('abrir'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cuándo pasarás a retirarlo?'), findsOneWidget);
      expect(find.text('Rayuela y 1 más'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('Hora de Paraguay'), findsOneWidget);

      await tester.tap(find.text('Confirmar reserva'));
      await tester.pumpAndSettle();

      expect(elegido, isNotNull);
      expect(PlazoRetiro.validar(elegido!), isNull);
    });

    testWidgets('cancelar no devuelve ninguna fecha', (tester) async {
      DateTime? elegido = DateTime(2000);
      await tester.pumpWidget(
        MaterialApp(
          theme: TemaApp.claro,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async => elegido = await pedirFechaRetiro(
                    context,
                    resumen: 'Rayuela',
                  ),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(elegido, isNull);
    });
  });
}
