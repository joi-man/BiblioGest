import 'package:freezed_annotation/freezed_annotation.dart';

part 'material.freezed.dart';
part 'material.g.dart';

/// Tipo de material que administra la biblioteca (libros y equipos).
enum TipoMaterial {
  libro,
  revista,
  dvd,
  cd,
  proyector,
  alargador,
  laptop,
  tablet,
  parlante,
  microfono,
  camara,
  adaptador,
  otro,
}

/// Estado de una unidad de material.
enum EstadoMaterial {
  disponible,
  reservado,
  prestado,
  vencido,
  @JsonValue('fuera_de_servicio')
  fueraDeServicio,
}

/// Condición física de una unidad.
enum CondicionMaterial { nuevo, bueno, regular, malo }

/// Una unidad física del inventario (un libro, un proyector, un alargador...).
@freezed
class MaterialBiblioteca with _$MaterialBiblioteca {
  const MaterialBiblioteca._();

  const factory MaterialBiblioteca({
    required String id,
    required String codigo,
    required String titulo,
    @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
    required TipoMaterial tipoMaterial,
    @JsonKey(unknownEnumValue: EstadoMaterial.disponible)
    required EstadoMaterial estado,
    @JsonKey(name: 'categoria_id') required String categoriaId,

    // Bibliográficos
    String? autor,
    String? isbn,
    String? editorial,
    @JsonKey(name: 'anio_publicacion') int? anioPublicacion,
    @JsonKey(name: 'numero_paginas') int? numeroPaginas,
    String? descripcion,

    // Medios
    String? formato,
    String? duracion,

    // Equipos
    String? marca,
    String? modelo,
    @JsonKey(name: 'numero_serie') String? numeroSerie,
    String? ubicacion,
    String? accesorios,

    // Gestión de la unidad
    @JsonKey(unknownEnumValue: CondicionMaterial.bueno)
    @Default(CondicionMaterial.bueno)
    CondicionMaterial condicion,
    @JsonKey(name: 'valor_referencial') double? valorReferencial,
    @JsonKey(name: 'es_prestable') @Default(true) bool esPrestable,
    @JsonKey(name: 'plazo_prestamo_horas') int? plazoPrestamoHoras,
    @JsonKey(name: 'imagen_url') String? imagenUrl,
    @JsonKey(name: 'fecha_creacion') DateTime? fechaCreacion,
    @JsonKey(name: 'fecha_actualizacion') DateTime? fechaActualizacion,
  }) = _MaterialBiblioteca;

  factory MaterialBiblioteca.fromJson(Map<String, dynamic> json) =>
      _$MaterialBibliotecaFromJson(json);

  /// Libros y revistas: tienen autor, ISBN y editorial.
  bool get esBibliografico =>
      tipoMaterial == TipoMaterial.libro || tipoMaterial == TipoMaterial.revista;

  /// DVD y CD: tienen formato y duración.
  bool get esMedio =>
      tipoMaterial == TipoMaterial.dvd || tipoMaterial == TipoMaterial.cd;

  /// Todo lo que no es bibliográfico ni un medio: proyectores, alargadores, etc.
  bool get esEquipo => !esBibliografico && !esMedio;

  /// Se puede pedir en préstamo ahora mismo.
  bool get sePuedeSolicitar =>
      esPrestable && estado == EstadoMaterial.disponible;
}
