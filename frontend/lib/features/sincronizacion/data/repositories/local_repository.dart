import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/dio_client.dart';
import '../models/estado_local.dart';

final localRepositoryProvider = Provider<LocalRepository>((ref) {
  return LocalRepository(ref.watch(dioClientProvider).dio);
});

/// Acceso a la API propia del ejecutable de escritorio (`/api/local`).
class LocalRepository {
  LocalRepository(this._dio);

  final Dio _dio;

  Future<EstadoLocal> estado() async {
    final respuesta = await _dio.get('/api/local/estado');
    return EstadoLocal.fromJson(respuesta.data);
  }

  /// Crea el administrador de un equipo que trabajará sin servidor.
  Future<EstadoLocal> configurarSoloLocal(Map<String, dynamic> datos) async {
    final respuesta = await _dio.post(
      '/api/local/configurar-solo-local',
      data: datos,
    );
    return EstadoLocal.fromJson(respuesta.data);
  }

  /// Une el equipo a un servidor y descarga sus datos.
  ///
  /// Con [reemplazarDatosLocales] se descartan los datos que ya tuviera el equipo.
  Future<EstadoLocal> conectar({
    required String servidorUrl,
    required String usuario,
    required String contrasena,
    bool reemplazarDatosLocales = false,
  }) async {
    final respuesta = await _dio.post(
      '/api/local/conectar',
      data: {
        'servidor_url': servidorUrl,
        'usuario': usuario,
        'contrasena': contrasena,
        'reemplazar_datos_locales': reemplazarDatosLocales,
      },
      // La primera descarga puede tardar más que una petición normal.
      options: Options(receiveTimeout: const Duration(minutes: 3)),
    );
    return EstadoLocal.fromJson(respuesta.data);
  }

  Future<EstadoLocal> desconectar() async {
    final respuesta = await _dio.post('/api/local/desconectar');
    return EstadoLocal.fromJson(respuesta.data);
  }

  Future<ResumenSincronizacion> sincronizar() async {
    final respuesta = await _dio.post(
      '/api/local/sincronizar',
      options: Options(receiveTimeout: const Duration(minutes: 3)),
    );
    return ResumenSincronizacion.fromJson(respuesta.data);
  }

  Future<List<ConflictoLocal>> conflictos() async {
    final respuesta = await _dio.get('/api/local/conflictos');
    return (respuesta.data as List)
        .map((json) => ConflictoLocal.fromJson(json))
        .toList();
  }

  Future<void> reintentarConflicto(String id) async {
    await _dio.post('/api/local/conflictos/$id/reintentar');
  }

  Future<void> descartarConflicto(String id) async {
    await _dio.post('/api/local/conflictos/$id/descartar');
  }
}
