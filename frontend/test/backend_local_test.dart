@TestOn('windows')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/local/backend_local.dart';

/// Prueba el arranque del backend empaquetado. Solo corre si se indica dónde está:
///
///     flutter test test/backend_local_test.dart --dart-define=BACKEND_LOCAL_EXE=C:\ruta\bibliogest-backend.exe
const _ruta = String.fromEnvironment('BACKEND_LOCAL_EXE');

void main() {
  test(
    'la aplicación inicia el backend, este responde y se cierra al detenerlo',
    () async {
      final backend = await iniciarBackendLocal();
      expect(backend, isNotNull);

      final cliente = HttpClient();
      try {
        final peticion = await cliente.getUrl(Uri.parse('${backend!.url}/api/local/estado'));
        final respuesta = await peticion.close();
        expect(respuesta.statusCode, 200);
        await respuesta.drain<void>();
      } finally {
        cliente.close(force: true);
        await backend!.detener();
      }
    },
    skip: _ruta.isEmpty ? 'Define BACKEND_LOCAL_EXE para probar el backend real' : null,
  );

  test('sin el ejecutable, la aplicación usa el servidor configurado', () async {
    if (_ruta.isNotEmpty) return; // con la ruta definida aplica la prueba anterior
    expect(await iniciarBackendLocal(), isNull);
  });
}
