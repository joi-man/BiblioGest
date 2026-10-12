import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/features/loans/data/models/devolucion.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';

final devolucionRepositoryProvider = Provider<DevolucionRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DevolucionRepository(dioClient.dio);
});

/// Un item del préstamo que se entrega de vuelta, con la condición en que llega.
class ItemADevolver {
  const ItemADevolver({
    required this.detalleId,
    required this.condicion,
    this.observaciones,
  });

  final String detalleId;
  final CondicionDevolucion condicion;
  final String? observaciones;

  Map<String, dynamic> toJson() => {
    'prestamo_detalle_id': detalleId,
    'condicion': condicion.valor,
    if (observaciones != null && observaciones!.isNotEmpty)
      'observaciones': observaciones,
  };
}

/// Acceso a la API de devoluciones. El token lo agrega el cliente HTTP.
class DevolucionRepository {
  DevolucionRepository(this._dio);

  final Dio _dio;

  /// Préstamos con material en manos de los usuarios, los más urgentes primero.
  Future<List<Prestamo>> listarPendientes({String? texto}) async {
    final respuesta = await _dio.get(
      '/api/devoluciones/pendientes',
      queryParameters: {
        if (texto != null && texto.trim().isNotEmpty) 'q': texto.trim(),
      },
    );
    return (respuesta.data as List).map((j) => Prestamo.fromJson(j)).toList();
  }

  /// Registra la devolución de uno o varios items de un préstamo.
  Future<Prestamo> registrar(
    String prestamoId,
    List<ItemADevolver> items,
  ) async {
    final respuesta = await _dio.post(
      '/api/devoluciones/$prestamoId',
      data: {'items': items.map((i) => i.toJson()).toList()},
    );
    return Prestamo.fromJson(respuesta.data);
  }
}
