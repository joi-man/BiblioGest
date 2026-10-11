// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prestamo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrestamoImpl _$$PrestamoImplFromJson(
  Map<String, dynamic> json,
) => _$PrestamoImpl(
  id: json['id'] as String,
  estado: $enumDecode(
    _$EstadoPrestamoEnumMap,
    json['estado'],
    unknownValue: EstadoPrestamo.pendiente,
  ),
  usuario: UsuarioResumen.fromJson(json['usuario'] as Map<String, dynamic>),
  detalles: (json['detalles'] as List<dynamic>)
      .map((e) => PrestamoDetalle.fromJson(e as Map<String, dynamic>))
      .toList(),
  fechaSolicitud: DateTime.parse(json['fecha_solicitud'] as String),
  fechaRetiroLimite: json['fecha_retiro_limite'] == null
      ? null
      : DateTime.parse(json['fecha_retiro_limite'] as String),
  fechaPrestamo: json['fecha_prestamo'] == null
      ? null
      : DateTime.parse(json['fecha_prestamo'] as String),
  fechaDevolucionEsperada: json['fecha_devolucion_esperada'] == null
      ? null
      : DateTime.parse(json['fecha_devolucion_esperada'] as String),
  fechaDevolucionReal: json['fecha_devolucion_real'] == null
      ? null
      : DateTime.parse(json['fecha_devolucion_real'] as String),
  aprobadoPor: json['aprobado_por'] == null
      ? null
      : UsuarioResumen.fromJson(json['aprobado_por'] as Map<String, dynamic>),
  entregadoPor: json['entregado_por'] == null
      ? null
      : UsuarioResumen.fromJson(json['entregado_por'] as Map<String, dynamic>),
  observaciones: json['observaciones'] as String?,
  motivoRechazo: json['motivo_rechazo'] as String?,
);

Map<String, dynamic> _$$PrestamoImplToJson(_$PrestamoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'estado': _$EstadoPrestamoEnumMap[instance.estado]!,
      'usuario': instance.usuario,
      'detalles': instance.detalles,
      'fecha_solicitud': instance.fechaSolicitud.toIso8601String(),
      'fecha_retiro_limite': instance.fechaRetiroLimite?.toIso8601String(),
      'fecha_prestamo': instance.fechaPrestamo?.toIso8601String(),
      'fecha_devolucion_esperada': instance.fechaDevolucionEsperada
          ?.toIso8601String(),
      'fecha_devolucion_real': instance.fechaDevolucionReal?.toIso8601String(),
      'aprobado_por': instance.aprobadoPor,
      'entregado_por': instance.entregadoPor,
      'observaciones': instance.observaciones,
      'motivo_rechazo': instance.motivoRechazo,
    };

const _$EstadoPrestamoEnumMap = {
  EstadoPrestamo.pendiente: 'pendiente',
  EstadoPrestamo.aprobado: 'aprobado',
  EstadoPrestamo.rechazado: 'rechazado',
  EstadoPrestamo.cancelado: 'cancelado',
  EstadoPrestamo.activo: 'activo',
  EstadoPrestamo.vencido: 'vencido',
  EstadoPrestamo.devuelto: 'devuelto',
};
