import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/dio_client.dart';

/// Servidor falso que responde siempre con el [codigo] indicado.
class _AdaptadorFalso implements HttpClientAdapter {
  _AdaptadorFalso(this.codigo);

  final int codigo;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    return ResponseBody.fromString('{"detail":"x"}', codigo, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

DioClient _cliente(int codigo, {required void Function() alExpirar}) {
  final cliente = DioClient('http://servidor')
    ..alSesionExpirada = alExpirar;
  cliente.dio.httpClientAdapter = _AdaptadorFalso(codigo);
  return cliente;
}

Future<void> _pedir(DioClient cliente, String ruta) async {
  try {
    await cliente.dio.get(ruta);
  } on DioException {
    // El error es lo esperado; interesa lo que hizo el cliente al recibirlo.
  }
}

void main() {
  test('un 401 con sesión iniciada avisa que la sesión terminó', () async {
    var avisos = 0;
    final cliente = _cliente(401, alExpirar: () => avisos++)..setToken('token');

    await _pedir(cliente, '/api/materiales/');

    expect(avisos, 1);
  });

  test('un 401 al iniciar sesión (clave incorrecta) no cierra nada', () async {
    var avisos = 0;
    final cliente = _cliente(401, alExpirar: () => avisos++)..setToken('token');

    await _pedir(cliente, '/api/auth/login');

    expect(avisos, 0);
  });

  test('un 401 sin sesión no avisa', () async {
    var avisos = 0;
    final cliente = _cliente(401, alExpirar: () => avisos++);

    await _pedir(cliente, '/api/materiales/');

    expect(avisos, 0);
  });

  test('otros errores no cierran la sesión', () async {
    var avisos = 0;
    final cliente = _cliente(500, alExpirar: () => avisos++)..setToken('token');

    await _pedir(cliente, '/api/materiales/');

    expect(avisos, 0);
  });
}
