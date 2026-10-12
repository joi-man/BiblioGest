import 'package:dio/dio.dart';

import 'estado_conexion.dart';

/// Marca una petición que no debe reintentarse (por ejemplo, el sondeo de conexión).
const String extraSinReintento = 'sinReintento';

/// Reintenta las peticiones que fallan por la red, con esperas crecientes.
///
/// La aplicación móvil no debe detenerse ni mostrar un error al primer corte de
/// internet: espera, vuelve a intentar y solo después de varios intentos le
/// avisa a la persona (ver [EstadoConexion]).
///
/// Qué se reintenta:
/// - Siempre: no se pudo abrir la conexión (la petición ni siquiera salió).
/// - Solo en lecturas (GET): se agotó el tiempo esperando la respuesta o el
///   servidor respondió 502, 503 o 504 (por ejemplo, mientras despierta).
///   Una escritura que pudo llegar al servidor no se repite, para no duplicarla.
class ReintentoInterceptor extends Interceptor {
  ReintentoInterceptor(
    this._dio,
    this._estado, {
    this.esperas = const [
      Duration(seconds: 2),
      Duration(seconds: 4),
      Duration(seconds: 6),
      Duration(seconds: 10),
      Duration(seconds: 15),
    ],
    Future<void> Function(Duration)? esperar,
  }) : _esperar = esperar ?? Future.delayed;

  final Dio _dio;
  final EstadoConexion _estado;

  /// Espera antes de cada reintento; su longitud es la cantidad de reintentos.
  final List<Duration> esperas;
  final Future<void> Function(Duration) _esperar;

  static const _clave = 'reintentosHechos';

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Cualquier respuesta del servidor demuestra que hay conexión.
    if (response.requestOptions.extra[extraSinReintento] != true) {
      _estado.conectado();
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final opciones = err.requestOptions;
    if (opciones.extra[extraSinReintento] == true || !_esReintentable(err)) {
      handler.next(err);
      return;
    }

    final hechos = (opciones.extra[_clave] as int?) ?? 0;
    if (hechos >= esperas.length) {
      _estado.sinConexion();
      handler.next(err);
      return;
    }

    _estado.reconectando(hechos + 1, esperas.length);
    await _esperar(esperas[hechos]);
    opciones.extra[_clave] = hechos + 1;

    try {
      // El reintento vuelve a pasar por este interceptor: si falla, sigue la cuenta.
      handler.resolve(await _dio.fetch(opciones));
    } on DioException catch (siguiente) {
      handler.next(siguiente);
    }
  }

  bool _esReintentable(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
        return true;
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return _esLectura(error);
      case DioExceptionType.badResponse:
        final codigo = error.response?.statusCode;
        return _esLectura(error) &&
            (codigo == 502 || codigo == 503 || codigo == 504);
      default:
        return false;
    }
  }

  bool _esLectura(DioException error) =>
      error.requestOptions.method.toUpperCase() == 'GET';
}
