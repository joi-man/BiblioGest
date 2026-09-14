// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaterialBibliotecaImpl _$$MaterialBibliotecaImplFromJson(
  Map<String, dynamic> json,
) => _$MaterialBibliotecaImpl(
  id: json['id'] as String,
  codigo: json['codigo'] as String,
  titulo: json['titulo'] as String,
  tipoMaterial: $enumDecode(_$TipoMaterialEnumMap, json['tipo_material']),
  estado: $enumDecode(_$EstadoMaterialEnumMap, json['estado']),
  autor: json['autor'] as String?,
  isbn: json['isbn'] as String?,
  editorial: json['editorial'] as String?,
  anioPublicacion: (json['anio_publicacion'] as num?)?.toInt(),
  numeroPaginas: (json['numero_paginas'] as num?)?.toInt(),
  idioma: json['idioma'] as String?,
  edicion: json['edicion'] as String?,
  formato: json['formato'] as String?,
  duracion: json['duracion'] as String?,
  descripcion: json['descripcion'] as String?,
  ubicacion: json['ubicacion'] as String?,
  cantidadDisponible: (json['cantidad_disponible'] as num?)?.toInt(),
  categoriaId: json['categoria_id'] as String?,
  fechaCreacion: json['fecha_creacion'] == null
      ? null
      : DateTime.parse(json['fecha_creacion'] as String),
  fechaActualizacion: json['fecha_actualizacion'] == null
      ? null
      : DateTime.parse(json['fecha_actualizacion'] as String),
);

Map<String, dynamic> _$$MaterialBibliotecaImplToJson(
  _$MaterialBibliotecaImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'codigo': instance.codigo,
  'titulo': instance.titulo,
  'tipo_material': _$TipoMaterialEnumMap[instance.tipoMaterial]!,
  'estado': _$EstadoMaterialEnumMap[instance.estado]!,
  'autor': instance.autor,
  'isbn': instance.isbn,
  'editorial': instance.editorial,
  'anio_publicacion': instance.anioPublicacion,
  'numero_paginas': instance.numeroPaginas,
  'idioma': instance.idioma,
  'edicion': instance.edicion,
  'formato': instance.formato,
  'duracion': instance.duracion,
  'descripcion': instance.descripcion,
  'ubicacion': instance.ubicacion,
  'cantidad_disponible': instance.cantidadDisponible,
  'categoria_id': instance.categoriaId,
  'fecha_creacion': instance.fechaCreacion?.toIso8601String(),
  'fecha_actualizacion': instance.fechaActualizacion?.toIso8601String(),
};

const _$TipoMaterialEnumMap = {
  TipoMaterial.libro: 'libro',
  TipoMaterial.revista: 'revista',
  TipoMaterial.dvd: 'dvd',
  TipoMaterial.cd: 'cd',
  TipoMaterial.proyector: 'proyector',
  TipoMaterial.otro: 'otro',
};

const _$EstadoMaterialEnumMap = {
  EstadoMaterial.disponible: 'disponible',
  EstadoMaterial.prestado: 'prestado',
  EstadoMaterial.vencido: 'vencido',
  EstadoMaterial.fueraDeServicio: 'fuera_de_servicio',
};
