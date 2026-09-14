import 'package:freezed_annotation/freezed_annotation.dart';

part 'material.freezed.dart';
part 'material.g.dart';

enum TipoMaterial {
  @JsonValue('libro')
  libro,
  @JsonValue('revista')
  revista,
  @JsonValue('dvd')
  dvd,
  @JsonValue('cd')
  cd,
  @JsonValue('proyector')
  proyector,
  @JsonValue('otro')
  otro,
}

enum EstadoMaterial {
  @JsonValue('disponible')
  disponible,
  @JsonValue('prestado')
  prestado,
  @JsonValue('vencido')
  vencido,
  @JsonValue('fuera_de_servicio')
  fueraDeServicio,
}

@freezed
class MaterialBiblioteca with _$MaterialBiblioteca {
  const factory MaterialBiblioteca({
    required String id,
    required String codigo,
    required String titulo,
    @JsonKey(name: 'tipo_material') required TipoMaterial tipoMaterial,
    @JsonKey(name: 'estado') required EstadoMaterial estado,
    String? autor,
    String? isbn,
    String? editorial,
    @JsonKey(name: 'anio_publicacion') int? anioPublicacion,
    @JsonKey(name: 'numero_paginas') int? numeroPaginas,
    String? idioma,
    String? edicion,
    String? formato,
    String? duracion,
    String? descripcion,
    String? ubicacion,
    @JsonKey(name: 'cantidad_disponible') int? cantidadDisponible,
    @JsonKey(name: 'categoria_id') String? categoriaId,
    @JsonKey(name: 'fecha_creacion') DateTime? fechaCreacion,
    @JsonKey(name: 'fecha_actualizacion') DateTime? fechaActualizacion,
  }) = _MaterialBiblioteca;

  factory MaterialBiblioteca.fromJson(Map<String, dynamic> json) =>
      _$MaterialBibliotecaFromJson(json);
}
