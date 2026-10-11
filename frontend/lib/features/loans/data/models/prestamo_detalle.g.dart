// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prestamo_detalle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrestamoDetalleImpl _$$PrestamoDetalleImplFromJson(
  Map<String, dynamic> json,
) => _$PrestamoDetalleImpl(
  id: json['id'] as String,
  material: MaterialResumen.fromJson(json['material'] as Map<String, dynamic>),
  fechaDevolucionEsperada: json['fecha_devolucion_esperada'] == null
      ? null
      : DateTime.parse(json['fecha_devolucion_esperada'] as String),
  devuelto: json['devuelto'] as bool? ?? false,
  devolucion: json['devolucion'] == null
      ? null
      : Devolucion.fromJson(json['devolucion'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$PrestamoDetalleImplToJson(
  _$PrestamoDetalleImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'material': instance.material,
  'fecha_devolucion_esperada': instance.fechaDevolucionEsperada
      ?.toIso8601String(),
  'devuelto': instance.devuelto,
  'devolucion': instance.devolucion,
};
