import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/tema_app.dart';
import 'package:frontend/features/loans/presentation/widgets/tarjeta_prestamo.dart';
import 'package:frontend/features/returns/presentation/widgets/dialogo_devolver.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'ayudas/prestamo_de_prueba.dart';

/// Monta [hijo] con el tema real de la app y Riverpod.
Widget _app(Widget hijo, {ThemeData? tema}) {
  return ProviderScope(
    child: MaterialApp(
      theme: tema ?? TemaApp.claro,
      home: Scaffold(body: SingleChildScrollView(child: hijo)),
    ),
  );
}

void main() {
  // La app real lo hace en main(); las pruebas deben hacerlo por su cuenta.
  setUpAll(() => initializeDateFormatting('es'));

  group('TarjetaPrestamo muestra las acciones según el estado', () {
    testWidgets('pendiente: rechazar, aprobar y entregar ahora', (tester) async {
      await tester.pumpWidget(_app(TarjetaPrestamo(prestamo: prestamoDePrueba())));

      expect(find.text('Ana Lopez'), findsOneWidget);
      expect(find.text('Proyector Epson'), findsOneWidget);
      expect(find.text('Rechazar'), findsOneWidget);
      expect(find.text('Aprobar'), findsOneWidget);
      expect(find.text('Entregar ahora'), findsOneWidget);
    });

    testWidgets('aprobado: marcar como entregado o cancelar la reserva', (tester) async {
      await tester.pumpWidget(
          _app(TarjetaPrestamo(prestamo: prestamoDePrueba(estado: 'aprobado'))));

      expect(find.text('Marcar como entregado'), findsOneWidget);
      expect(find.text('Cancelar reserva'), findsOneWidget);
      expect(find.text('Aprobar'), findsNothing);
    });

    testWidgets('activo: lleva a la pantalla de devoluciones', (tester) async {
      await tester.pumpWidget(
          _app(TarjetaPrestamo(prestamo: prestamoDePrueba(estado: 'activo'))));

      expect(find.text('Ir a devolución'), findsOneWidget);
    });

    testWidgets('historial: sin botones', (tester) async {
      await tester.pumpWidget(_app(TarjetaPrestamo(
        prestamo: prestamoDePrueba(estado: 'devuelto'),
        mostrarBotones: false,
      )));

      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('en modo oscuro también se dibuja sin errores', (tester) async {
      await tester.pumpWidget(_app(
        TarjetaPrestamo(prestamo: prestamoDePrueba()),
        tema: TemaApp.oscuro,
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('Pendiente'), findsOneWidget);
    });
  });

  group('DialogoDevolver', () {
    final dosItems = [
      jsonDetalle(id: 'a', titulo: 'Proyector', codigo: 'P-1'),
      jsonDetalle(id: 'b', titulo: 'Alargador', codigo: 'A-1'),
    ];

    /// Abre el diálogo como lo haría la app: desde un botón, con showDialog.
    Future<void> abrirDialogo(WidgetTester tester) async {
      final prestamo = prestamoDePrueba(estado: 'activo', detalles: dosItems);
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: TemaApp.claro,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => DialogoDevolver(prestamo: prestamo),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('todos los items vienen marcados para devolver de un clic', (tester) async {
      await abrirDialogo(tester);

      expect(find.text('Registrar 2 devoluciones'), findsOneWidget);
    });

    testWidgets('desmarcar un item permite una devolucion parcial', (tester) async {
      await abrirDialogo(tester);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      expect(find.text('Registrar 1 devolución'), findsOneWidget);
    });

    testWidgets('sin items marcados no se puede registrar', (tester) async {
      await abrirDialogo(tester);

      await tester.tap(find.byType(Checkbox).at(0));
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();

      final boton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(boton.onPressed, isNull);
    });
  });
}
