import 'package:freezed_annotation/freezed_annotation.dart';

part 'resumen_dashboard.freezed.dart';
part 'resumen_dashboard.g.dart';

/// Cantidad de unidades por estado.
@freezed
class ResumenMateriales with _$ResumenMateriales {
  const factory ResumenMateriales({
    required int total,
    required int disponibles,
    required int reservados,
    required int prestados,
    required int vencidos,
    @JsonKey(name: 'fuera_de_servicio') required int fueraDeServicio,
  }) = _ResumenMateriales;

  factory ResumenMateriales.fromJson(Map<String, dynamic> json) =>
      _$ResumenMaterialesFromJson(json);
}

/// Situación actual de la operación de préstamos.
@freezed
class ResumenPrestamos with _$ResumenPrestamos {
  const factory ResumenPrestamos({
    @JsonKey(name: 'solicitudes_pendientes') required int solicitudesPendientes,
    @JsonKey(name: 'por_retirar') required int porRetirar,
    required int activos,
    required int vencidos,
    @JsonKey(name: 'por_vencer_24h') required int porVencer24h,
    @JsonKey(name: 'entregados_hoy') required int entregadosHoy,
    @JsonKey(name: 'devueltos_hoy') required int devueltosHoy,
  }) = _ResumenPrestamos;

  factory ResumenPrestamos.fromJson(Map<String, dynamic> json) =>
      _$ResumenPrestamosFromJson(json);
}

@freezed
class ResumenDashboard with _$ResumenDashboard {
  const factory ResumenDashboard({
    required ResumenMateriales materiales,
    required ResumenPrestamos prestamos,
  }) = _ResumenDashboard;

  factory ResumenDashboard.fromJson(Map<String, dynamic> json) =>
      _$ResumenDashboardFromJson(json);
}
