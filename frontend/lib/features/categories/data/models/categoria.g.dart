// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categoria.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoriaImpl _$$CategoriaImplFromJson(Map<String, dynamic> json) =>
    _$CategoriaImpl(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      plazoPrestamoHoras: (json['plazo_prestamo_horas'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CategoriaImplToJson(_$CategoriaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'descripcion': instance.descripcion,
      'plazo_prestamo_horas': instance.plazoPrestamoHoras,
    };
