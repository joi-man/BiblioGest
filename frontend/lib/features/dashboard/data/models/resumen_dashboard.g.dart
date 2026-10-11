// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resumen_dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResumenMaterialesImpl _$$ResumenMaterialesImplFromJson(
  Map<String, dynamic> json,
) => _$ResumenMaterialesImpl(
  total: (json['total'] as num).toInt(),
  disponibles: (json['disponibles'] as num).toInt(),
  reservados: (json['reservados'] as num).toInt(),
  prestados: (json['prestados'] as num).toInt(),
  vencidos: (json['vencidos'] as num).toInt(),
  fueraDeServicio: (json['fuera_de_servicio'] as num).toInt(),
);

Map<String, dynamic> _$$ResumenMaterialesImplToJson(
  _$ResumenMaterialesImpl instance,
) => <String, dynamic>{
  'total': instance.total,
  'disponibles': instance.disponibles,
  'reservados': instance.reservados,
  'prestados': instance.prestados,
  'vencidos': instance.vencidos,
  'fuera_de_servicio': instance.fueraDeServicio,
};

_$ResumenPrestamosImpl _$$ResumenPrestamosImplFromJson(
  Map<String, dynamic> json,
) => _$ResumenPrestamosImpl(
  solicitudesPendientes: (json['solicitudes_pendientes'] as num).toInt(),
  porRetirar: (json['por_retirar'] as num).toInt(),
  activos: (json['activos'] as num).toInt(),
  vencidos: (json['vencidos'] as num).toInt(),
  porVencer24h: (json['por_vencer_24h'] as num).toInt(),
  entregadosHoy: (json['entregados_hoy'] as num).toInt(),
  devueltosHoy: (json['devueltos_hoy'] as num).toInt(),
);

Map<String, dynamic> _$$ResumenPrestamosImplToJson(
  _$ResumenPrestamosImpl instance,
) => <String, dynamic>{
  'solicitudes_pendientes': instance.solicitudesPendientes,
  'por_retirar': instance.porRetirar,
  'activos': instance.activos,
  'vencidos': instance.vencidos,
  'por_vencer_24h': instance.porVencer24h,
  'entregados_hoy': instance.entregadosHoy,
  'devueltos_hoy': instance.devueltosHoy,
};

_$ResumenDashboardImpl _$$ResumenDashboardImplFromJson(
  Map<String, dynamic> json,
) => _$ResumenDashboardImpl(
  materiales: ResumenMateriales.fromJson(
    json['materiales'] as Map<String, dynamic>,
  ),
  prestamos: ResumenPrestamos.fromJson(
    json['prestamos'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$ResumenDashboardImplToJson(
  _$ResumenDashboardImpl instance,
) => <String, dynamic>{
  'materiales': instance.materiales,
  'prestamos': instance.prestamos,
};
