import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/tema_app.dart';
import 'package:frontend/features/returns/data/models/fecha_recepcion.dart';
import 'package:frontend/features/returns/presentation/widgets/campo_fecha_recepcion.dart';
import 'package:frontend/features/returns/presentation/widgets/dialogo_devolver.dart';
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
  final entrega = DateTime.utc(2026, 10, 10, 12);

  group('validación de la fecha en que se recibió el material', () {
    test('una fecha pasada, posterior a la entrega, es válida', () {
      final recibido = ahora.subtract(const Duration(hours: 5));
      expect(
        FechaRecepcion.validar(recibido, ahora: ahora, entrega: entrega),
        isNull,
      );
    });

    test('una fecha futura se rechaza', () {
      final mensaje = FechaRecepcion.validar(
        ahora.add(const Duration(hours: 1)),
        ahora: ahora,
        entrega: entrega,
      );
      expect(mensaje, contains('posterior a este momento'));
    });

    test('una fecha anterior a la entrega se rechaza', () {
      final mensaje = FechaRecepcion.validar(
        entrega.subtract(const Duration(hours: 1)),
        ahora: ahora,
        entrega: entrega,
      );
      expect(mensaje, contains('anterior a la entrega'));
    });

    test('más de 30 días atrás se rechaza', () {
      final mensaje = FechaRecepcion.validar(
        ahora.subtract(const Duration(days: 31)),
        ahora: ahora,
      );
      expect(mensaje, contains('más de 30 días'));
    });

    test('los mensajes no exponen detalles técnicos', () {
      final mensaje = FechaRecepcion.validar(
        ahora.add(const Duration(days: 1)),
        ahora: ahora,
      );
      expect(mensaje, isNot(contains('Exception')));
    });
  });

  group('motivo de la fecha', () {
    test('es obligatorio y debe tener al menos 10 caracteres', () {
      expect(FechaRecepcion.validarMotivo(null), isNotNull);
      expect(FechaRecepcion.validarMotivo('   corto  '), isNotNull);
      expect(
        FechaRecepcion.validarMotivo('Lo trajo ayer por la tarde'),
        isNull,
      );
    });
  });

  group('días que se pueden elegir', () {
    test('el último es hoy en Paraguay, no hoy en UTC', () {
      // 01:00 UTC del día 20 todavía es el día 19 en Paraguay.
      expect(
        FechaRecepcion.ultimoDia(ahora: DateTime.utc(2026, 10, 20, 1)),
        DateTime(2026, 10, 19),
      );
    });

    test('el primero es el día de la entrega si es reciente', () {
      expect(
        FechaRecepcion.primerDia(entrega: entrega, ahora: ahora),
        DateTime(2026, 10, 20 - 10),
      );
    });

    test(
      'el primero no pasa de hace 30 días aunque la entrega sea anterior',
      () {
        expect(
          FechaRecepcion.primerDia(
            entrega: DateTime.utc(2026, 8, 1),
            ahora: ahora,
          ),
          DateTime(2026, 9, 20),
        );
      },
    );
  });

  group('CampoFechaRecepcion', () {
    testWidgets('por defecto es "Recibido ahora"', (tester) async {
      await tester.pumpWidget(
        _app(CampoFechaRecepcion(valor: null, onChanged: (_) {})),
      );

      expect(find.text('Recibido ahora'), findsOneWidget);
    });

    testWidgets('con fecha la muestra en hora de Paraguay y permite quitarla', (
      tester,
    ) async {
      DateTime? recibido = DateTime.utc(2026, 10, 19, 21);
      await tester.pumpWidget(
        _app(
          CampoFechaRecepcion(valor: recibido, onChanged: (f) => recibido = f),
        ),
      );

      expect(find.textContaining('19 oct 2026, 18:00'), findsOneWidget);
      expect(find.text('Hora de Paraguay'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      expect(recibido, isNull);
    });
  });

  group('DialogoDevolver', () {
    testWidgets(
      'registrar en el momento no pide fecha ni motivo (un solo paso)',
      (tester) async {
        await tester.pumpWidget(
          _app(DialogoDevolver(prestamo: prestamoDePrueba(estado: 'activo'))),
        );

        expect(find.text('Recibido ahora'), findsOneWidget);
        expect(find.text('Motivo de la fecha *'), findsNothing);
        expect(find.text('Registrar 1 devolución'), findsOneWidget);
      },
    );
  });
}
