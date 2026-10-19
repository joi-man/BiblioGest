// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_resumen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaterialResumenImpl _$$MaterialResumenImplFromJson(
  Map<String, dynamic> json,
) => _$MaterialResumenImpl(
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
  ubicacion: json['ubicacion'] as String?,
  tomo: json['tomo'] as String?,
  totalTomos: (json['total_tomos'] as num?)?.toInt(),
);

Map<String, dynamic> _$$MaterialResumenImplToJson(
  _$MaterialResumenImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'codigo': instance.codigo,
  'titulo': instance.titulo,
  'tipo_material': _$TipoMaterialEnumMap[instance.tipoMaterial]!,
  'estado': _$EstadoMaterialEnumMap[instance.estado]!,
  'ubicacion': instance.ubicacion,
  'tomo': instance.tomo,
  'total_tomos': instance.totalTomos,
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
