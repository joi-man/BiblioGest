// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devolucion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DevolucionImpl _$$DevolucionImplFromJson(Map<String, dynamic> json) =>
    _$DevolucionImpl(
      id: json['id'] as String,
      prestamoDetalleId: json['prestamo_detalle_id'] as String,
      fechaDevolucion: DateTime.parse(json['fecha_devolucion'] as String),
      condicion: $enumDecode(
        _$CondicionDevolucionEnumMap,
        json['condicion'],
        unknownValue: CondicionDevolucion.bueno,
      ),
      observaciones: json['observaciones'] as String?,
      diasRetraso: (json['dias_retraso'] as num?)?.toInt() ?? 0,
      multaMonto: (json['multa_monto'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$DevolucionImplToJson(_$DevolucionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prestamo_detalle_id': instance.prestamoDetalleId,
      'fecha_devolucion': instance.fechaDevolucion.toIso8601String(),
      'condicion': _$CondicionDevolucionEnumMap[instance.condicion]!,
      'observaciones': instance.observaciones,
      'dias_retraso': instance.diasRetraso,
      'multa_monto': instance.multaMonto,
    };

const _$CondicionDevolucionEnumMap = {
  CondicionDevolucion.bueno: 'bueno',
  CondicionDevolucion.danoMenor: 'dano_menor',
  CondicionDevolucion.danoMayor: 'dano_mayor',
  CondicionDevolucion.perdido: 'perdido',
};
