// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AutorImpl _$$AutorImplFromJson(Map<String, dynamic> json) => _$AutorImpl(
  id: json['id'] as String,
  nombre: json['nombre'] as String,
  cantidadMateriales: (json['cantidad_materiales'] as num?)?.toInt() ?? 0,
  fechaCreacion: json['fecha_creacion'] == null
      ? null
      : DateTime.parse(json['fecha_creacion'] as String),
);

Map<String, dynamic> _$$AutorImplToJson(_$AutorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'cantidad_materiales': instance.cantidadMateriales,
      'fecha_creacion': instance.fechaCreacion?.toIso8601String(),
    };
