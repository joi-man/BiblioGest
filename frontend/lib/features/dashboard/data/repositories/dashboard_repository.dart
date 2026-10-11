import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/dio_client.dart';
import '../models/resumen_dashboard.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DashboardRepository(dioClient.dio);
});

/// Acceso a las métricas del panel de inicio.
class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<ResumenDashboard> obtenerResumen() async {
    final respuesta = await _dio.get('/api/dashboard/resumen');
    return ResumenDashboard.fromJson(respuesta.data);
  }
}
