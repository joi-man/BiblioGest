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
  tipoMaterial: $enumDecode(
    _$TipoMaterialEnumMap,
    json['tipo_material'],
    unknownValue: TipoMaterial.otro,
  ),
  estado: $enumDecode(
    _$EstadoMaterialEnumMap,
    json['estado'],
    unknownValue: EstadoMaterial.disponible,
  ),
  categoriaId: json['categoria_id'] as String,
  autor: json['autor'] as String?,
  autores:
      (json['autores'] as List<dynamic>?)
          ?.map((e) => Autor.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Autor>[],
  isbn: json['isbn'] as String?,
  editorial: json['editorial'] as String?,
  anioPublicacion: (json['anio_publicacion'] as num?)?.toInt(),
  numeroPaginas: (json['numero_paginas'] as num?)?.toInt(),
  descripcion: json['descripcion'] as String?,
  tomo: json['tomo'] as String?,
  totalTomos: (json['total_tomos'] as num?)?.toInt(),
  formato: json['formato'] as String?,
  duracion: json['duracion'] as String?,
  marca: json['marca'] as String?,
  modelo: json['modelo'] as String?,
  numeroSerie: json['numero_serie'] as String?,
  ubicacion: json['ubicacion'] as String?,
  accesorios: json['accesorios'] as String?,
  condicion:
      $enumDecodeNullable(
        _$CondicionMaterialEnumMap,
        json['condicion'],
        unknownValue: CondicionMaterial.bueno,
      ) ??
      CondicionMaterial.bueno,
  valorReferencial: (json['valor_referencial'] as num?)?.toDouble(),
  esPrestable: json['es_prestable'] as bool? ?? true,
  plazoPrestamoHoras: (json['plazo_prestamo_horas'] as num?)?.toInt(),
  cantidadTotal: (json['cantidad_total'] as num?)?.toInt() ?? 1,
  cantidadReservada: (json['cantidad_reservada'] as num?)?.toInt() ?? 0,
  cantidadPrestada: (json['cantidad_prestada'] as num?)?.toInt() ?? 0,
  cantidadVencida: (json['cantidad_vencida'] as num?)?.toInt() ?? 0,
  cantidadFueraServicio:
      (json['cantidad_fuera_servicio'] as num?)?.toInt() ?? 0,
  cantidadDisponible: (json['cantidad_disponible'] as num?)?.toInt(),
  imagenUrl: json['imagen_url'] as String?,
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
  'categoria_id': instance.categoriaId,
  'autor': instance.autor,
  'autores': instance.autores.map((e) => e.toJson()).toList(),
  'isbn': instance.isbn,
  'editorial': instance.editorial,
  'anio_publicacion': instance.anioPublicacion,
  'numero_paginas': instance.numeroPaginas,
  'descripcion': instance.descripcion,
  'tomo': instance.tomo,
  'total_tomos': instance.totalTomos,
  'formato': instance.formato,
  'duracion': instance.duracion,
  'marca': instance.marca,
  'modelo': instance.modelo,
  'numero_serie': instance.numeroSerie,
  'ubicacion': instance.ubicacion,
  'accesorios': instance.accesorios,
  'condicion': _$CondicionMaterialEnumMap[instance.condicion]!,
  'valor_referencial': instance.valorReferencial,
  'es_prestable': instance.esPrestable,
  'plazo_prestamo_horas': instance.plazoPrestamoHoras,
  'cantidad_total': instance.cantidadTotal,
  'cantidad_reservada': instance.cantidadReservada,
  'cantidad_prestada': instance.cantidadPrestada,
  'cantidad_vencida': instance.cantidadVencida,
  'cantidad_fuera_servicio': instance.cantidadFueraServicio,
  'cantidad_disponible': instance.cantidadDisponible,
  'imagen_url': instance.imagenUrl,
  'fecha_creacion': instance.fechaCreacion?.toIso8601String(),
  'fecha_actualizacion': instance.fechaActualizacion?.toIso8601String(),
};

const _$TipoMaterialEnumMap = {
  TipoMaterial.libro: 'libro',
  TipoMaterial.revista: 'revista',
  TipoMaterial.dvd: 'dvd',
  TipoMaterial.cd: 'cd',
  TipoMaterial.proyector: 'proyector',
  TipoMaterial.alargador: 'alargador',
  TipoMaterial.laptop: 'laptop',
  TipoMaterial.tablet: 'tablet',
  TipoMaterial.parlante: 'parlante',
  TipoMaterial.microfono: 'microfono',
  TipoMaterial.camara: 'camara',
  TipoMaterial.adaptador: 'adaptador',
  TipoMaterial.otro: 'otro',
};

const _$EstadoMaterialEnumMap = {
  EstadoMaterial.disponible: 'disponible',
  EstadoMaterial.reservado: 'reservado',
  EstadoMaterial.prestado: 'prestado',
  EstadoMaterial.vencido: 'vencido',
  EstadoMaterial.fueraDeServicio: 'fuera_de_servicio',
};

const _$CondicionMaterialEnumMap = {
  CondicionMaterial.nuevo: 'nuevo',
  CondicionMaterial.bueno: 'bueno',
  CondicionMaterial.regular: 'regular',
  CondicionMaterial.malo: 'malo',
};
