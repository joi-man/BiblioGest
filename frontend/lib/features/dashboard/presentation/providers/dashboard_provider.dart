import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/dashboard/data/models/resumen_dashboard.dart';
import 'package:frontend/features/dashboard/data/repositories/dashboard_repository.dart';

/// Métricas del panel de inicio.
final resumenDashboardProvider = FutureProvider<ResumenDashboard?>((ref) async {
  if (ref.watch(tokenSesionProvider) == null) return null;
  return ref.read(dashboardRepositoryProvider).obtenerResumen();
});
