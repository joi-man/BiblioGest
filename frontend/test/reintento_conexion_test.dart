import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/estado_conexion.dart';
import 'package:frontend/core/network/reconector_conexion.dart';
import 'package:frontend/core/network/reintento_interceptor.dart';

/// Servidor falso: cada petición consume el siguiente resultado de la lista
/// (una falla de red o una respuesta). Cuenta cuántas peticiones llegaron.
class _AdaptadorFalso implements HttpClientAdapter {
  _AdaptadorFalso(this.resultados);

  final List<Object> resultados; // DioExceptionType o int (código HTTP)
  int peticiones = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final resultado = resultados[peticiones.clamp(0, resultados.length - 1)];
    peticiones++;
    if (resultado is DioExceptionType) {
      throw DioException(requestOptions: options, type: resultado);
    }
    return ResponseBody.fromString('{}', resultado as int, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

const _red = DioExceptionType.connectionError;

({Dio dio, _AdaptadorFalso servidor, EstadoConexion estado, List<Duration> esperas}) _montar(
  List<Object> resultados, {
  int reintentos = 3,
}) {
  final servidor = _AdaptadorFalso(resultados);
  final estado = EstadoConexion();
  final esperas = <Duration>[];
  final dio = Dio(BaseOptions(baseUrl: 'http://prueba.test'))..httpClientAdapter = servidor;
  dio.interceptors.add(ReintentoInterceptor(
    dio,
    estado,
    esperas: List.generate(reintentos, (i) => Duration(seconds: i + 1)),
    esperar: (d) async => esperas.add(d), // sin esperar de verdad
  ));
  return (dio: dio, servidor: servidor, estado: estado, esperas: esperas);
}

void main() {
  group('ReintentoInterceptor', () {
    test('una lectura que falla por la red se reintenta hasta que responde', () async {
      final t = _montar([_red, _red, 200]);

      final respuesta = await t.dio.get('/api/solicitudes/mias');

      expect(respuesta.statusCode, 200);
      expect(t.servidor.peticiones, 3);
      expect(t.esperas, [const Duration(seconds: 1), const Duration(seconds: 2)]);
      expect(t.estado.fase, FaseConexion.conectado);
    });

    test('mientras reintenta se informa el intento en curso', () async {
      final t = _montar([_red, 200]);
      final intentos = <int>[];
      t.estado.addListener(() {
        if (t.estado.fase == FaseConexion.reconectando) intentos.add(t.estado.intento);
      });

      await t.dio.get('/api/materiales/');

      expect(intentos, [1]);
    });

    test('tras agotar los reintentos devuelve el error y avisa "sin conexión"', () async {
      final t = _montar([_red], reintentos: 3);

      await expectLater(
        t.dio.get('/api/materiales/'),
        throwsA(isA<DioException>()),
      );

      expect(t.servidor.peticiones, 4); // el intento original + 3 reintentos
      expect(t.estado.fase, FaseConexion.sinConexion);
    });

    test('una escritura no se repite si pudo llegar al servidor (tiempo agotado)', () async {
      final t = _montar([DioExceptionType.receiveTimeout, 200]);

      await expectLater(
        t.dio.post('/api/solicitudes/', data: {}),
        throwsA(isA<DioException>()),
      );

      expect(t.servidor.peticiones, 1);
    });

    test('una escritura sí se reintenta si ni siquiera se pudo conectar', () async {
      final t = _montar([_red, 201]);

      final respuesta = await t.dio.post('/api/solicitudes/', data: {});

      expect(respuesta.statusCode, 201);
      expect(t.servidor.peticiones, 2);
    });

    test('un 503 en una lectura (servidor despertando) se reintenta', () async {
      final t = _montar([503, 200]);

      final respuesta = await t.dio.get('/api/materiales/');

      expect(respuesta.statusCode, 200);
      expect(t.servidor.peticiones, 2);
    });

    test('un error normal del servidor (404, 409) no se reintenta ni da aviso de red', () async {
      final t = _montar([409, 200]);

      await expectLater(t.dio.get('/api/materiales/'), throwsA(isA<DioException>()));

      expect(t.servidor.peticiones, 1);
      expect(t.estado.fase, FaseConexion.conectado);
    });

    test('con la marca de "sin reintento" falla de inmediato', () async {
      final t = _montar([_red, 200]);

      await expectLater(
        t.dio.get('/api/materiales/', options: Options(extra: {extraSinReintento: true})),
        throwsA(isA<DioException>()),
      );

      expect(t.servidor.peticiones, 1);
    });
  });

  group('ReconectorConexion', () {
    ({ReconectorConexion reconector, _AdaptadorFalso servidor, EstadoConexion estado, List<int> recuperaciones})
        montar(List<Object> resultados, {int intentos = 3}) {
      final servidor = _AdaptadorFalso(resultados);
      final estado = EstadoConexion();
      final recuperaciones = <int>[];
      final dio = Dio(BaseOptions(baseUrl: 'http://prueba.test'))..httpClientAdapter = servidor;
      final reconector = ReconectorConexion(
        dio: dio,
        estado: estado,
        intentosAntesDeAvisar: intentos,
        alRecuperar: () => recuperaciones.add(1),
      );
      return (reconector: reconector, servidor: servidor, estado: estado, recuperaciones: recuperaciones);
    }

    test('cuenta los intentos fallidos y avisa "sin conexión" al llegar al límite', () async {
      final t = montar([_red], intentos: 3);
      t.estado.reconectando(0, 3);

      await t.reconector.sondear();
      expect(t.estado.fase, FaseConexion.reconectando);
      expect(t.estado.intento, 1);
      await t.reconector.sondear();
      expect(t.estado.fase, FaseConexion.reconectando);
      await t.reconector.sondear();
      expect(t.estado.fase, FaseConexion.sinConexion);
      expect(t.recuperaciones, isEmpty);
    });

    test('al volver la conexión lo marca y avisa para refrescar los datos', () async {
      final t = montar([_red, _red, _red, 200], intentos: 3);
      t.estado.reconectando(0, 3);
      for (var i = 0; i < 3; i++) {
        await t.reconector.sondear();
      }
      expect(t.estado.fase, FaseConexion.sinConexion);

      await t.reconector.sondear();

      expect(t.estado.fase, FaseConexion.conectado);
      expect(t.recuperaciones, hasLength(1));
    });

    test('un aviso de reconexión nuevo no esconde el aviso de "sin conexión"', () {
      final estado = EstadoConexion()..sinConexion();

      estado.reconectando(1, 5);

      expect(estado.fase, FaseConexion.sinConexion);
    });
  });
}
