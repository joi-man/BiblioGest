import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/theme/tema_app.dart';
import 'package:frontend/features/auth/presentation/widgets/dialogo_cambiar_contrasena.dart';

/// Servidor falso: guarda lo que recibe y responde con el código indicado.
class _Servidor implements HttpClientAdapter {
  _Servidor(this.codigo, {this.detalle});

  final int codigo;
  final String? detalle;
  final List<RequestOptions> recibidas = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? s, Future<void>? c) async {
    recibidas.add(options);
    final cuerpo = codigo == 200 ? {'mensaje': 'ok'} : {'detail': detalle};
    return ResponseBody.fromString(
      jsonEncode(cuerpo),
      codigo,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<void> _abrir(WidgetTester tester, _Servidor servidor) async {
  final cliente = DioClient('http://prueba.test');
  cliente.dio.httpClientAdapter = servidor;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [dioClientProvider.overrideWithValue(cliente)],
      child: MaterialApp(
        theme: TemaApp.claro,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => cambiarContrasena(context),
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
}

Future<void> _escribir(WidgetTester tester, {String actual = '', String nueva = '', String repetida = ''}) async {
  final campos = find.byType(TextFormField);
  await tester.enterText(campos.at(0), actual);
  await tester.enterText(campos.at(1), nueva);
  await tester.enterText(campos.at(2), repetida);
}

void main() {
  testWidgets('valida los campos antes de llamar al servidor', (tester) async {
    final servidor = _Servidor(200);
    await _abrir(tester, servidor);

    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar contraseña'));
    await tester.pump();
    expect(find.text('Escribe tu contraseña actual'), findsOneWidget);
    expect(find.text('Debe tener al menos 6 caracteres'), findsOneWidget);

    await _escribir(tester, actual: 'ClaveVieja1', nueva: 'ClaveVieja1', repetida: 'ClaveVieja1');
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar contraseña'));
    await tester.pump();
    expect(find.text('Debe ser distinta de la actual'), findsOneWidget);

    await _escribir(tester, actual: 'ClaveVieja1', nueva: 'ClaveNueva1', repetida: 'otra cosa');
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar contraseña'));
    await tester.pump();
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);

    expect(servidor.recibidas, isEmpty);
  });

  testWidgets('envía las contraseñas y se cierra al lograrlo', (tester) async {
    final servidor = _Servidor(200);
    await _abrir(tester, servidor);

    await _escribir(tester, actual: 'ClaveVieja1', nueva: 'ClaveNueva1', repetida: 'ClaveNueva1');
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar contraseña'));
    await tester.pumpAndSettle();

    expect(servidor.recibidas.single.path, '/api/auth/cambiar-contrasena');
    expect(servidor.recibidas.single.data, {
      'contrasena_actual': 'ClaveVieja1',
      'nueva_contrasena': 'ClaveNueva1',
    });
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Contraseña actualizada'), findsOneWidget);
  });

  testWidgets('si la actual es incorrecta explica el motivo y deja el diálogo abierto', (tester) async {
    final servidor = _Servidor(400, detalle: 'La contrasena actual no es correcta');
    await _abrir(tester, servidor);

    await _escribir(tester, actual: 'mal', nueva: 'ClaveNueva1', repetida: 'ClaveNueva1');
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar contraseña'));
    await tester.pumpAndSettle();

    expect(find.text('La contrasena actual no es correcta'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
