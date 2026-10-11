import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../local/modo_local.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.watch(urlApiProvider));
});

class DioClient {
  late final Dio _dio;

  /// Se invoca cuando el servidor rechaza la sesión actual (token vencido o de
  /// un usuario que ya no existe). Quien lo asigna debe volver al inicio de sesión.
  void Function()? alSesionExpirada;

  /// [baseUrl] es la dirección de la API (el backend local o el servidor).
  DioClient(String baseUrl) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(() => alSesionExpirada),
      _LogInterceptor(),
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

  final void Function()? Function() _obtenerAlSesionExpirada;

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
      _obtenerAlSesionExpirada()?.call();
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
