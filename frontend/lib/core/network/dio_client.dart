import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../local/modo_local.dart';
import '../platform/plataforma.dart';
import 'estado_conexion.dart';
import 'reintento_interceptor.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  // En el móvil, un corte de internet no debe mostrar un error al primer fallo.
  return DioClient(ref.watch(urlApiProvider), reintentar: esDispositivoMovil);
});

class DioClient {
  late final Dio _dio;

  /// Se invoca cuando el servidor rechaza la sesión actual (token vencido o de
  /// un usuario que ya no existe). Quien lo asigna debe volver al inicio de sesión.
  void Function(String? motivo)? alSesionExpirada;

  /// [baseUrl] es la dirección de la API (el backend local o el servidor).
  /// Con [reintentar], las fallas de red se reintentan con esperas crecientes
  /// antes de avisar (ver [ReintentoInterceptor]).
  DioClient(String baseUrl, {bool reintentar = false}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(() => alSesionExpirada),
      _LogInterceptor(),
      if (reintentar) ReintentoInterceptor(_dio, estadoConexion),
    ]);
  }

  Dio get dio => _dio;

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._obtenerAlSesionExpirada);

  final void Function(String? motivo)? Function() _obtenerAlSesionExpirada;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add token from storage if available
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Un 401 con sesión iniciada significa que el token ya no vale. Los de
    // /api/auth son intentos de acceso con credenciales incorrectas.
    final habiaSesion = err.requestOptions.headers['Authorization'] != null;
    final esDeAutenticacion = err.requestOptions.path.startsWith('/api/auth/');
    if (err.response?.statusCode == 401 && habiaSesion && !esDeAutenticacion) {
      final datos = err.response?.data;
      _obtenerAlSesionExpirada()?.call(
        datos is Map && datos['detail'] is String
            ? datos['detail'] as String
            : null,
      );
    }
    handler.next(err);
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('[API] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('[API] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('[API ERROR] ${err.message}');
    handler.next(err);
  }
}
