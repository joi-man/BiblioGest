import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/dio_client.dart';
import '../models/prestamo.dart';

final prestamoRepositoryProvider = Provider<PrestamoRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PrestamoRepository(dioClient.dio);
});

/// Acceso a la API de solicitudes y préstamos. El token lo agrega el cliente HTTP.
///
/// Reúne las operaciones del personal (`/api/prestamos`) y las del propio
/// usuario (`/api/solicitudes`), porque ambas trabajan con el mismo [Prestamo].
class PrestamoRepository {
  PrestamoRepository(this._dio);

  final Dio _dio;

  // ---------------------------------------------------------------------
  // Personal de la biblioteca
  // ---------------------------------------------------------------------

  /// Lista préstamos del personal con filtros opcionales.
  Future<List<Prestamo>> listar({
    List<EstadoPrestamo> estados = const [],
    String? texto,
    bool masAntiguosPrimero = false,
  }) async {
    final respuesta = await _dio.get(
      '/api/prestamos/',
      queryParameters: {
        if (estados.isNotEmpty) 'estado': estados.map((e) => e.valor).toList(),
        if (texto != null && texto.trim().isNotEmpty) 'q': texto.trim(),
        if (masAntiguosPrimero) 'mas_antiguos_primero': true,
      },
    );
    return _aPrestamos(respuesta.data);
  }

  /// Registra un préstamo en el mostrador, ya entregado.
  Future<Prestamo> crearDirecto({
    required String usuarioId,
    required List<String> materialIds,
    String? observaciones,
    DateTime? fechaDevolucionEsperada,
    bool omitirValidacionesUsuario = false,
  }) async {
    final respuesta = await _dio.post(
      '/api/prestamos/directo',
      data: {
        'usuario_id': usuarioId,
        'material_ids': materialIds,
        if (observaciones != null && observaciones.isNotEmpty)
          'observaciones': observaciones,
        if (fechaDevolucionEsperada != null)
          'fecha_devolucion_esperada': fechaDevolucionEsperada
              .toUtc()
              .toIso8601String(),
        'omitir_validaciones_usuario': omitirValidacionesUsuario,
      },
    );
    return Prestamo.fromJson(respuesta.data);
  }

  Future<Prestamo> aprobar(String id) async {
    final respuesta = await _dio.post('/api/prestamos/$id/aprobar');
    return Prestamo.fromJson(respuesta.data);
  }

  Future<Prestamo> rechazar(String id, String motivo) async {
    final respuesta = await _dio.post(
      '/api/prestamos/$id/rechazar',
      data: {'motivo': motivo},
    );
    return Prestamo.fromJson(respuesta.data);
  }

  /// Entrega los materiales. Sobre una solicitud pendiente la aprueba y entrega.
  Future<Prestamo> entregar(
    String id, {
    DateTime? fechaDevolucionEsperada,
  }) async {
    final respuesta = await _dio.post(
      '/api/prestamos/$id/entregar',
      data: {
        if (fechaDevolucionEsperada != null)
          'fecha_devolucion_esperada': fechaDevolucionEsperada
              .toUtc()
              .toIso8601String(),
      },
    );
    return Prestamo.fromJson(respuesta.data);
  }

  Future<Prestamo> cancelar(String id) async {
    final respuesta = await _dio.post('/api/prestamos/$id/cancelar');
    return Prestamo.fromJson(respuesta.data);
  }

  /// Cancela una reserva aprobada y presta el material a otra persona.
  /// Devuelve el préstamo nuevo, ya entregado.
  Future<Prestamo> ceder(
    String id, {
    required String usuarioId,
    required String motivo,
    DateTime? fechaDevolucionEsperada,
    bool omitirValidacionesUsuario = false,
  }) async {
    final respuesta = await _dio.post(
      '/api/prestamos/$id/ceder',
      data: {
        'usuario_id': usuarioId,
        'motivo': motivo,
        if (fechaDevolucionEsperada != null)
          'fecha_devolucion_esperada': fechaDevolucionEsperada
              .toUtc()
              .toIso8601String(),
        'omitir_validaciones_usuario': omitirValidacionesUsuario,
      },
    );
    return Prestamo.fromJson(respuesta.data);
  }

  // ---------------------------------------------------------------------
  // Usuario sobre sus propias solicitudes (app móvil del estudiante)
  // ---------------------------------------------------------------------

  /// Pide en préstamo o reserva los materiales. [fechaRetiro] es cuándo la persona
  /// dice que pasará a retirarlos.
  Future<Prestamo> solicitar(
    List<String> materialIds, {
    String? observaciones,
    DateTime? fechaRetiro,
  }) async {
    final respuesta = await _dio.post(
      '/api/solicitudes/',
      data: {
        'material_ids': materialIds,
        if (observaciones != null && observaciones.isNotEmpty)
          'observaciones': observaciones,
        if (fechaRetiro != null)
          'fecha_retiro_solicitada': fechaRetiro.toUtc().toIso8601String(),
      },
    );
    return Prestamo.fromJson(respuesta.data);
  }

  Future<List<Prestamo>> listarMias() async {
    final respuesta = await _dio.get('/api/solicitudes/mias');
    return _aPrestamos(respuesta.data);
  }

  Future<Prestamo> cancelarPropia(String id) async {
    final respuesta = await _dio.post('/api/solicitudes/$id/cancelar');
    return Prestamo.fromJson(respuesta.data);
  }

  List<Prestamo> _aPrestamos(dynamic datos) {
    return (datos as List).map((json) => Prestamo.fromJson(json)).toList();
  }
}
