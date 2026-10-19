import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/features/authors/data/models/autor.dart';

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

/// Un material del inventario (un libro, un proyector, un alargador...) con sus
/// ejemplares: [cantidadTotal] copias, de las que algunas pueden estar
/// reservadas o prestadas.
@freezed
class MaterialBiblioteca with _$MaterialBiblioteca {
  const MaterialBiblioteca._();

  @JsonSerializable(explicitToJson: true)
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
    /// Resumen en texto de los autores ("A, B"); la lista real está en [autores].
    String? autor,
    @Default(<Autor>[]) List<Autor> autores,
    String? isbn,
    String? editorial,
    @JsonKey(name: 'anio_publicacion') int? anioPublicacion,
    @JsonKey(name: 'numero_paginas') int? numeroPaginas,
    String? descripcion,

    /// Obras de varios tomos: cada tomo es un material con su código y sus ejemplares.
    String? tomo,
    @JsonKey(name: 'total_tomos') int? totalTomos,

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

    // Ejemplares. Una respuesta antigua (o una copia guardada por una versión
    // anterior de la app) no los trae: se asume un solo ejemplar.
    @JsonKey(name: 'cantidad_total') @Default(1) int cantidadTotal,
    @JsonKey(name: 'cantidad_reservada') @Default(0) int cantidadReservada,
    @JsonKey(name: 'cantidad_prestada') @Default(0) int cantidadPrestada,
    @JsonKey(name: 'cantidad_vencida') @Default(0) int cantidadVencida,
    @JsonKey(name: 'cantidad_fuera_servicio')
    @Default(0)
    int cantidadFueraServicio,
    @JsonKey(name: 'cantidad_disponible') int? cantidadDisponible,
    @JsonKey(name: 'imagen_url') String? imagenUrl,
    @JsonKey(name: 'fecha_creacion') DateTime? fechaCreacion,
    @JsonKey(name: 'fecha_actualizacion') DateTime? fechaActualizacion,
  }) = _MaterialBiblioteca;

  factory MaterialBiblioteca.fromJson(Map<String, dynamic> json) =>
      _$MaterialBibliotecaFromJson(json);

  /// Libros y revistas: tienen autor, ISBN y editorial.
  bool get esBibliografico =>
      tipoMaterial == TipoMaterial.libro ||
      tipoMaterial == TipoMaterial.revista;

  /// DVD y CD: tienen formato y duración.
  bool get esMedio =>
      tipoMaterial == TipoMaterial.dvd || tipoMaterial == TipoMaterial.cd;

  /// Todo lo que no es bibliográfico ni un medio: proyectores, alargadores, etc.
  bool get esEquipo => !esBibliografico && !esMedio;

  /// Ejemplares que se pueden reservar o prestar ahora.
  ///
  /// Si el servidor no los informó (respuesta antigua), se deduce del estado.
  int get ejemplaresLibres =>
      cantidadDisponible ??
      (estado == EstadoMaterial.disponible ? cantidadTotal : 0);

  /// Ejemplares reservados, prestados o vencidos: no se pueden quitar del inventario.
  int get ejemplaresEnUso =>
      cantidadReservada + cantidadPrestada + cantidadVencida;

  /// Se puede pedir en préstamo ahora mismo: es prestable y queda algún ejemplar libre.
  bool get sePuedeSolicitar => esPrestable && ejemplaresLibres > 0;
}
