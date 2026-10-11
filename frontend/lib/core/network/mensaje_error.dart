import 'package:dio/dio.dart';

/// Convierte cualquier error en un texto que se pueda mostrar a la persona.
///
/// Si el backend explicó el problema (`detail`), se usa ese texto; si no,
/// se da un mensaje genérico según el tipo de falla.
String mensajeDeError(Object error) {
  if (error is! DioException) return 'Ocurrió un error inesperado';

  final datos = error.response?.data;
  if (datos is Map && datos['detail'] is String) {
    return datos['detail'] as String;
  }

  switch (error.response?.statusCode) {
    case 401:
      return 'Tu sesión expiró. Inicia sesión de nuevo';
    case 403:
      return 'No tienes permiso para hacer esto';
    case 404:
      return 'No se encontró lo que buscabas';
    case 422:
      return 'Revisa los datos ingresados';
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.connectionError:
      return 'No se pudo conectar con el servidor';
    default:
      return 'Ocurrió un error inesperado';
  }
}
