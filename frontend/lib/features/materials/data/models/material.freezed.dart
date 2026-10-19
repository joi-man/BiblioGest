// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'material.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MaterialBiblioteca _$MaterialBibliotecaFromJson(Map<String, dynamic> json) {
  return _MaterialBiblioteca.fromJson(json);
}

/// @nodoc
mixin _$MaterialBiblioteca {
  String get id => throw _privateConstructorUsedError;
  String get codigo => throw _privateConstructorUsedError;
  String get titulo => throw _privateConstructorUsedError;
  @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
  TipoMaterial get tipoMaterial => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: EstadoMaterial.disponible)
  EstadoMaterial get estado => throw _privateConstructorUsedError;
  @JsonKey(name: 'categoria_id')
  String get categoriaId => throw _privateConstructorUsedError; // Bibliográficos
  /// Resumen en texto de los autores ("A, B"); la lista real está en [autores].
  String? get autor => throw _privateConstructorUsedError;
  List<Autor> get autores => throw _privateConstructorUsedError;
  String? get isbn => throw _privateConstructorUsedError;
  String? get editorial => throw _privateConstructorUsedError;
  @JsonKey(name: 'anio_publicacion')
  int? get anioPublicacion => throw _privateConstructorUsedError;
  @JsonKey(name: 'numero_paginas')
  int? get numeroPaginas => throw _privateConstructorUsedError;
  String? get descripcion => throw _privateConstructorUsedError;

  /// Obras de varios tomos: cada tomo es un material con su código y sus ejemplares.
  String? get tomo => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_tomos')
  int? get totalTomos => throw _privateConstructorUsedError; // Medios
  String? get formato => throw _privateConstructorUsedError;
  String? get duracion => throw _privateConstructorUsedError; // Equipos
  String? get marca => throw _privateConstructorUsedError;
  String? get modelo => throw _privateConstructorUsedError;
  @JsonKey(name: 'numero_serie')
  String? get numeroSerie => throw _privateConstructorUsedError;
  String? get ubicacion => throw _privateConstructorUsedError;
  String? get accesorios =>
      throw _privateConstructorUsedError; // Gestión de la unidad
  @JsonKey(unknownEnumValue: CondicionMaterial.bueno)
  CondicionMaterial get condicion => throw _privateConstructorUsedError;
  @JsonKey(name: 'valor_referencial')
  double? get valorReferencial => throw _privateConstructorUsedError;
  @JsonKey(name: 'es_prestable')
  bool get esPrestable => throw _privateConstructorUsedError;
  @JsonKey(name: 'plazo_prestamo_horas')
  int? get plazoPrestamoHoras => throw _privateConstructorUsedError; // Ejemplares. Una respuesta antigua (o una copia guardada por una versión
  // anterior de la app) no los trae: se asume un solo ejemplar.
  @JsonKey(name: 'cantidad_total')
  int get cantidadTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'cantidad_reservada')
  int get cantidadReservada => throw _privateConstructorUsedError;
  @JsonKey(name: 'cantidad_prestada')
  int get cantidadPrestada => throw _privateConstructorUsedError;
  @JsonKey(name: 'cantidad_vencida')
  int get cantidadVencida => throw _privateConstructorUsedError;
  @JsonKey(name: 'cantidad_fuera_servicio')
  int get cantidadFueraServicio => throw _privateConstructorUsedError;
  @JsonKey(name: 'cantidad_disponible')
  int? get cantidadDisponible => throw _privateConstructorUsedError;
  @JsonKey(name: 'imagen_url')
  String? get imagenUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_creacion')
  DateTime? get fechaCreacion => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_actualizacion')
  DateTime? get fechaActualizacion => throw _privateConstructorUsedError;

  /// Serializes this MaterialBiblioteca to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MaterialBiblioteca
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaterialBibliotecaCopyWith<MaterialBiblioteca> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaterialBibliotecaCopyWith<$Res> {
  factory $MaterialBibliotecaCopyWith(
    MaterialBiblioteca value,
    $Res Function(MaterialBiblioteca) then,
  ) = _$MaterialBibliotecaCopyWithImpl<$Res, MaterialBiblioteca>;
  @useResult
  $Res call({
    String id,
    String codigo,
    String titulo,
    @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
    TipoMaterial tipoMaterial,
    @JsonKey(unknownEnumValue: EstadoMaterial.disponible) EstadoMaterial estado,
    @JsonKey(name: 'categoria_id') String categoriaId,
    String? autor,
    List<Autor> autores,
    String? isbn,
    String? editorial,
    @JsonKey(name: 'anio_publicacion') int? anioPublicacion,
    @JsonKey(name: 'numero_paginas') int? numeroPaginas,
    String? descripcion,
    String? tomo,
    @JsonKey(name: 'total_tomos') int? totalTomos,
    String? formato,
    String? duracion,
    String? marca,
    String? modelo,
    @JsonKey(name: 'numero_serie') String? numeroSerie,
    String? ubicacion,
    String? accesorios,
    @JsonKey(unknownEnumValue: CondicionMaterial.bueno)
    CondicionMaterial condicion,
    @JsonKey(name: 'valor_referencial') double? valorReferencial,
    @JsonKey(name: 'es_prestable') bool esPrestable,
    @JsonKey(name: 'plazo_prestamo_horas') int? plazoPrestamoHoras,
    @JsonKey(name: 'cantidad_total') int cantidadTotal,
    @JsonKey(name: 'cantidad_reservada') int cantidadReservada,
    @JsonKey(name: 'cantidad_prestada') int cantidadPrestada,
    @JsonKey(name: 'cantidad_vencida') int cantidadVencida,
    @JsonKey(name: 'cantidad_fuera_servicio') int cantidadFueraServicio,
    @JsonKey(name: 'cantidad_disponible') int? cantidadDisponible,
    @JsonKey(name: 'imagen_url') String? imagenUrl,
    @JsonKey(name: 'fecha_creacion') DateTime? fechaCreacion,
    @JsonKey(name: 'fecha_actualizacion') DateTime? fechaActualizacion,
  });
}

/// @nodoc
class _$MaterialBibliotecaCopyWithImpl<$Res, $Val extends MaterialBiblioteca>
    implements $MaterialBibliotecaCopyWith<$Res> {
  _$MaterialBibliotecaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MaterialBiblioteca
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? titulo = null,
    Object? tipoMaterial = null,
    Object? estado = null,
    Object? categoriaId = null,
    Object? autor = freezed,
    Object? autores = null,
    Object? isbn = freezed,
    Object? editorial = freezed,
    Object? anioPublicacion = freezed,
    Object? numeroPaginas = freezed,
    Object? descripcion = freezed,
    Object? tomo = freezed,
    Object? totalTomos = freezed,
    Object? formato = freezed,
    Object? duracion = freezed,
    Object? marca = freezed,
    Object? modelo = freezed,
    Object? numeroSerie = freezed,
    Object? ubicacion = freezed,
    Object? accesorios = freezed,
    Object? condicion = null,
    Object? valorReferencial = freezed,
    Object? esPrestable = null,
    Object? plazoPrestamoHoras = freezed,
    Object? cantidadTotal = null,
    Object? cantidadReservada = null,
    Object? cantidadPrestada = null,
    Object? cantidadVencida = null,
    Object? cantidadFueraServicio = null,
    Object? cantidadDisponible = freezed,
    Object? imagenUrl = freezed,
    Object? fechaCreacion = freezed,
    Object? fechaActualizacion = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            codigo: null == codigo
                ? _value.codigo
                : codigo // ignore: cast_nullable_to_non_nullable
                      as String,
            titulo: null == titulo
                ? _value.titulo
                : titulo // ignore: cast_nullable_to_non_nullable
                      as String,
            tipoMaterial: null == tipoMaterial
                ? _value.tipoMaterial
                : tipoMaterial // ignore: cast_nullable_to_non_nullable
                      as TipoMaterial,
            estado: null == estado
                ? _value.estado
                : estado // ignore: cast_nullable_to_non_nullable
                      as EstadoMaterial,
            categoriaId: null == categoriaId
                ? _value.categoriaId
                : categoriaId // ignore: cast_nullable_to_non_nullable
                      as String,
            autor: freezed == autor
                ? _value.autor
                : autor // ignore: cast_nullable_to_non_nullable
                      as String?,
            autores: null == autores
                ? _value.autores
                : autores // ignore: cast_nullable_to_non_nullable
                      as List<Autor>,
            isbn: freezed == isbn
                ? _value.isbn
                : isbn // ignore: cast_nullable_to_non_nullable
                      as String?,
            editorial: freezed == editorial
                ? _value.editorial
                : editorial // ignore: cast_nullable_to_non_nullable
                      as String?,
            anioPublicacion: freezed == anioPublicacion
                ? _value.anioPublicacion
                : anioPublicacion // ignore: cast_nullable_to_non_nullable
                      as int?,
            numeroPaginas: freezed == numeroPaginas
                ? _value.numeroPaginas
                : numeroPaginas // ignore: cast_nullable_to_non_nullable
                      as int?,
            descripcion: freezed == descripcion
                ? _value.descripcion
                : descripcion // ignore: cast_nullable_to_non_nullable
                      as String?,
            tomo: freezed == tomo
                ? _value.tomo
                : tomo // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalTomos: freezed == totalTomos
                ? _value.totalTomos
                : totalTomos // ignore: cast_nullable_to_non_nullable
                      as int?,
            formato: freezed == formato
                ? _value.formato
                : formato // ignore: cast_nullable_to_non_nullable
                      as String?,
            duracion: freezed == duracion
                ? _value.duracion
                : duracion // ignore: cast_nullable_to_non_nullable
                      as String?,
            marca: freezed == marca
                ? _value.marca
                : marca // ignore: cast_nullable_to_non_nullable
                      as String?,
            modelo: freezed == modelo
                ? _value.modelo
                : modelo // ignore: cast_nullable_to_non_nullable
                      as String?,
            numeroSerie: freezed == numeroSerie
                ? _value.numeroSerie
                : numeroSerie // ignore: cast_nullable_to_non_nullable
                      as String?,
            ubicacion: freezed == ubicacion
                ? _value.ubicacion
                : ubicacion // ignore: cast_nullable_to_non_nullable
                      as String?,
            accesorios: freezed == accesorios
                ? _value.accesorios
                : accesorios // ignore: cast_nullable_to_non_nullable
                      as String?,
            condicion: null == condicion
                ? _value.condicion
                : condicion // ignore: cast_nullable_to_non_nullable
                      as CondicionMaterial,
            valorReferencial: freezed == valorReferencial
                ? _value.valorReferencial
                : valorReferencial // ignore: cast_nullable_to_non_nullable
                      as double?,
            esPrestable: null == esPrestable
                ? _value.esPrestable
                : esPrestable // ignore: cast_nullable_to_non_nullable
                      as bool,
            plazoPrestamoHoras: freezed == plazoPrestamoHoras
                ? _value.plazoPrestamoHoras
                : plazoPrestamoHoras // ignore: cast_nullable_to_non_nullable
                      as int?,
            cantidadTotal: null == cantidadTotal
                ? _value.cantidadTotal
                : cantidadTotal // ignore: cast_nullable_to_non_nullable
                      as int,
            cantidadReservada: null == cantidadReservada
                ? _value.cantidadReservada
                : cantidadReservada // ignore: cast_nullable_to_non_nullable
                      as int,
            cantidadPrestada: null == cantidadPrestada
                ? _value.cantidadPrestada
                : cantidadPrestada // ignore: cast_nullable_to_non_nullable
                      as int,
            cantidadVencida: null == cantidadVencida
                ? _value.cantidadVencida
                : cantidadVencida // ignore: cast_nullable_to_non_nullable
                      as int,
            cantidadFueraServicio: null == cantidadFueraServicio
                ? _value.cantidadFueraServicio
                : cantidadFueraServicio // ignore: cast_nullable_to_non_nullable
                      as int,
            cantidadDisponible: freezed == cantidadDisponible
                ? _value.cantidadDisponible
                : cantidadDisponible // ignore: cast_nullable_to_non_nullable
                      as int?,
            imagenUrl: freezed == imagenUrl
                ? _value.imagenUrl
                : imagenUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            fechaCreacion: freezed == fechaCreacion
                ? _value.fechaCreacion
                : fechaCreacion // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            fechaActualizacion: freezed == fechaActualizacion
                ? _value.fechaActualizacion
                : fechaActualizacion // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MaterialBibliotecaImplCopyWith<$Res>
    implements $MaterialBibliotecaCopyWith<$Res> {
  factory _$$MaterialBibliotecaImplCopyWith(
    _$MaterialBibliotecaImpl value,
    $Res Function(_$MaterialBibliotecaImpl) then,
  ) = __$$MaterialBibliotecaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String codigo,
    String titulo,
    @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
    TipoMaterial tipoMaterial,
    @JsonKey(unknownEnumValue: EstadoMaterial.disponible) EstadoMaterial estado,
    @JsonKey(name: 'categoria_id') String categoriaId,
    String? autor,
    List<Autor> autores,
    String? isbn,
    String? editorial,
    @JsonKey(name: 'anio_publicacion') int? anioPublicacion,
    @JsonKey(name: 'numero_paginas') int? numeroPaginas,
    String? descripcion,
    String? tomo,
    @JsonKey(name: 'total_tomos') int? totalTomos,
    String? formato,
    String? duracion,
    String? marca,
    String? modelo,
    @JsonKey(name: 'numero_serie') String? numeroSerie,
    String? ubicacion,
    String? accesorios,
    @JsonKey(unknownEnumValue: CondicionMaterial.bueno)
    CondicionMaterial condicion,
    @JsonKey(name: 'valor_referencial') double? valorReferencial,
    @JsonKey(name: 'es_prestable') bool esPrestable,
    @JsonKey(name: 'plazo_prestamo_horas') int? plazoPrestamoHoras,
    @JsonKey(name: 'cantidad_total') int cantidadTotal,
    @JsonKey(name: 'cantidad_reservada') int cantidadReservada,
    @JsonKey(name: 'cantidad_prestada') int cantidadPrestada,
    @JsonKey(name: 'cantidad_vencida') int cantidadVencida,
    @JsonKey(name: 'cantidad_fuera_servicio') int cantidadFueraServicio,
    @JsonKey(name: 'cantidad_disponible') int? cantidadDisponible,
    @JsonKey(name: 'imagen_url') String? imagenUrl,
    @JsonKey(name: 'fecha_creacion') DateTime? fechaCreacion,
    @JsonKey(name: 'fecha_actualizacion') DateTime? fechaActualizacion,
  });
}

/// @nodoc
class __$$MaterialBibliotecaImplCopyWithImpl<$Res>
    extends _$MaterialBibliotecaCopyWithImpl<$Res, _$MaterialBibliotecaImpl>
    implements _$$MaterialBibliotecaImplCopyWith<$Res> {
  __$$MaterialBibliotecaImplCopyWithImpl(
    _$MaterialBibliotecaImpl _value,
    $Res Function(_$MaterialBibliotecaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MaterialBiblioteca
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? titulo = null,
    Object? tipoMaterial = null,
    Object? estado = null,
    Object? categoriaId = null,
    Object? autor = freezed,
    Object? autores = null,
    Object? isbn = freezed,
    Object? editorial = freezed,
    Object? anioPublicacion = freezed,
    Object? numeroPaginas = freezed,
    Object? descripcion = freezed,
    Object? tomo = freezed,
    Object? totalTomos = freezed,
    Object? formato = freezed,
    Object? duracion = freezed,
    Object? marca = freezed,
    Object? modelo = freezed,
    Object? numeroSerie = freezed,
    Object? ubicacion = freezed,
    Object? accesorios = freezed,
    Object? condicion = null,
    Object? valorReferencial = freezed,
    Object? esPrestable = null,
    Object? plazoPrestamoHoras = freezed,
    Object? cantidadTotal = null,
    Object? cantidadReservada = null,
    Object? cantidadPrestada = null,
    Object? cantidadVencida = null,
    Object? cantidadFueraServicio = null,
    Object? cantidadDisponible = freezed,
    Object? imagenUrl = freezed,
    Object? fechaCreacion = freezed,
    Object? fechaActualizacion = freezed,
  }) {
    return _then(
      _$MaterialBibliotecaImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        codigo: null == codigo
            ? _value.codigo
            : codigo // ignore: cast_nullable_to_non_nullable
                  as String,
        titulo: null == titulo
            ? _value.titulo
            : titulo // ignore: cast_nullable_to_non_nullable
                  as String,
        tipoMaterial: null == tipoMaterial
            ? _value.tipoMaterial
            : tipoMaterial // ignore: cast_nullable_to_non_nullable
                  as TipoMaterial,
        estado: null == estado
            ? _value.estado
            : estado // ignore: cast_nullable_to_non_nullable
                  as EstadoMaterial,
        categoriaId: null == categoriaId
            ? _value.categoriaId
            : categoriaId // ignore: cast_nullable_to_non_nullable
                  as String,
        autor: freezed == autor
            ? _value.autor
            : autor // ignore: cast_nullable_to_non_nullable
                  as String?,
        autores: null == autores
            ? _value._autores
            : autores // ignore: cast_nullable_to_non_nullable
                  as List<Autor>,
        isbn: freezed == isbn
            ? _value.isbn
            : isbn // ignore: cast_nullable_to_non_nullable
                  as String?,
        editorial: freezed == editorial
            ? _value.editorial
            : editorial // ignore: cast_nullable_to_non_nullable
                  as String?,
        anioPublicacion: freezed == anioPublicacion
            ? _value.anioPublicacion
            : anioPublicacion // ignore: cast_nullable_to_non_nullable
                  as int?,
        numeroPaginas: freezed == numeroPaginas
            ? _value.numeroPaginas
            : numeroPaginas // ignore: cast_nullable_to_non_nullable
                  as int?,
        descripcion: freezed == descripcion
            ? _value.descripcion
            : descripcion // ignore: cast_nullable_to_non_nullable
                  as String?,
        tomo: freezed == tomo
            ? _value.tomo
            : tomo // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalTomos: freezed == totalTomos
            ? _value.totalTomos
            : totalTomos // ignore: cast_nullable_to_non_nullable
                  as int?,
        formato: freezed == formato
            ? _value.formato
            : formato // ignore: cast_nullable_to_non_nullable
                  as String?,
        duracion: freezed == duracion
            ? _value.duracion
            : duracion // ignore: cast_nullable_to_non_nullable
                  as String?,
        marca: freezed == marca
            ? _value.marca
            : marca // ignore: cast_nullable_to_non_nullable
                  as String?,
        modelo: freezed == modelo
            ? _value.modelo
            : modelo // ignore: cast_nullable_to_non_nullable
                  as String?,
        numeroSerie: freezed == numeroSerie
            ? _value.numeroSerie
            : numeroSerie // ignore: cast_nullable_to_non_nullable
                  as String?,
        ubicacion: freezed == ubicacion
            ? _value.ubicacion
            : ubicacion // ignore: cast_nullable_to_non_nullable
                  as String?,
        accesorios: freezed == accesorios
            ? _value.accesorios
            : accesorios // ignore: cast_nullable_to_non_nullable
                  as String?,
        condicion: null == condicion
            ? _value.condicion
            : condicion // ignore: cast_nullable_to_non_nullable
                  as CondicionMaterial,
        valorReferencial: freezed == valorReferencial
            ? _value.valorReferencial
            : valorReferencial // ignore: cast_nullable_to_non_nullable
                  as double?,
        esPrestable: null == esPrestable
            ? _value.esPrestable
            : esPrestable // ignore: cast_nullable_to_non_nullable
                  as bool,
        plazoPrestamoHoras: freezed == plazoPrestamoHoras
            ? _value.plazoPrestamoHoras
            : plazoPrestamoHoras // ignore: cast_nullable_to_non_nullable
                  as int?,
        cantidadTotal: null == cantidadTotal
            ? _value.cantidadTotal
            : cantidadTotal // ignore: cast_nullable_to_non_nullable
                  as int,
        cantidadReservada: null == cantidadReservada
            ? _value.cantidadReservada
            : cantidadReservada // ignore: cast_nullable_to_non_nullable
                  as int,
        cantidadPrestada: null == cantidadPrestada
            ? _value.cantidadPrestada
            : cantidadPrestada // ignore: cast_nullable_to_non_nullable
                  as int,
        cantidadVencida: null == cantidadVencida
            ? _value.cantidadVencida
            : cantidadVencida // ignore: cast_nullable_to_non_nullable
                  as int,
        cantidadFueraServicio: null == cantidadFueraServicio
            ? _value.cantidadFueraServicio
            : cantidadFueraServicio // ignore: cast_nullable_to_non_nullable
                  as int,
        cantidadDisponible: freezed == cantidadDisponible
            ? _value.cantidadDisponible
            : cantidadDisponible // ignore: cast_nullable_to_non_nullable
                  as int?,
        imagenUrl: freezed == imagenUrl
            ? _value.imagenUrl
            : imagenUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        fechaCreacion: freezed == fechaCreacion
            ? _value.fechaCreacion
            : fechaCreacion // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        fechaActualizacion: freezed == fechaActualizacion
            ? _value.fechaActualizacion
            : fechaActualizacion // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$MaterialBibliotecaImpl extends _MaterialBiblioteca {
  const _$MaterialBibliotecaImpl({
    required this.id,
    required this.codigo,
    required this.titulo,
    @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
    required this.tipoMaterial,
    @JsonKey(unknownEnumValue: EstadoMaterial.disponible) required this.estado,
    @JsonKey(name: 'categoria_id') required this.categoriaId,
    this.autor,
    final List<Autor> autores = const <Autor>[],
    this.isbn,
    this.editorial,
    @JsonKey(name: 'anio_publicacion') this.anioPublicacion,
    @JsonKey(name: 'numero_paginas') this.numeroPaginas,
    this.descripcion,
    this.tomo,
    @JsonKey(name: 'total_tomos') this.totalTomos,
    this.formato,
    this.duracion,
    this.marca,
    this.modelo,
    @JsonKey(name: 'numero_serie') this.numeroSerie,
    this.ubicacion,
    this.accesorios,
    @JsonKey(unknownEnumValue: CondicionMaterial.bueno)
    this.condicion = CondicionMaterial.bueno,
    @JsonKey(name: 'valor_referencial') this.valorReferencial,
    @JsonKey(name: 'es_prestable') this.esPrestable = true,
    @JsonKey(name: 'plazo_prestamo_horas') this.plazoPrestamoHoras,
    @JsonKey(name: 'cantidad_total') this.cantidadTotal = 1,
    @JsonKey(name: 'cantidad_reservada') this.cantidadReservada = 0,
    @JsonKey(name: 'cantidad_prestada') this.cantidadPrestada = 0,
    @JsonKey(name: 'cantidad_vencida') this.cantidadVencida = 0,
    @JsonKey(name: 'cantidad_fuera_servicio') this.cantidadFueraServicio = 0,
    @JsonKey(name: 'cantidad_disponible') this.cantidadDisponible,
    @JsonKey(name: 'imagen_url') this.imagenUrl,
    @JsonKey(name: 'fecha_creacion') this.fechaCreacion,
    @JsonKey(name: 'fecha_actualizacion') this.fechaActualizacion,
  }) : _autores = autores,
       super._();

  factory _$MaterialBibliotecaImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaterialBibliotecaImplFromJson(json);

  @override
  final String id;
  @override
  final String codigo;
  @override
  final String titulo;
  @override
  @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
  final TipoMaterial tipoMaterial;
  @override
  @JsonKey(unknownEnumValue: EstadoMaterial.disponible)
  final EstadoMaterial estado;
  @override
  @JsonKey(name: 'categoria_id')
  final String categoriaId;
  // Bibliográficos
  /// Resumen en texto de los autores ("A, B"); la lista real está en [autores].
  @override
  final String? autor;
  final List<Autor> _autores;
  @override
  @JsonKey()
  List<Autor> get autores {
    if (_autores is EqualUnmodifiableListView) return _autores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_autores);
  }

  @override
  final String? isbn;
  @override
  final String? editorial;
  @override
  @JsonKey(name: 'anio_publicacion')
  final int? anioPublicacion;
  @override
  @JsonKey(name: 'numero_paginas')
  final int? numeroPaginas;
  @override
  final String? descripcion;

  /// Obras de varios tomos: cada tomo es un material con su código y sus ejemplares.
  @override
  final String? tomo;
  @override
  @JsonKey(name: 'total_tomos')
  final int? totalTomos;
  // Medios
  @override
  final String? formato;
  @override
  final String? duracion;
  // Equipos
  @override
  final String? marca;
  @override
  final String? modelo;
  @override
  @JsonKey(name: 'numero_serie')
  final String? numeroSerie;
  @override
  final String? ubicacion;
  @override
  final String? accesorios;
  // Gestión de la unidad
  @override
  @JsonKey(unknownEnumValue: CondicionMaterial.bueno)
  final CondicionMaterial condicion;
  @override
  @JsonKey(name: 'valor_referencial')
  final double? valorReferencial;
  @override
  @JsonKey(name: 'es_prestable')
  final bool esPrestable;
  @override
  @JsonKey(name: 'plazo_prestamo_horas')
  final int? plazoPrestamoHoras;
  // Ejemplares. Una respuesta antigua (o una copia guardada por una versión
  // anterior de la app) no los trae: se asume un solo ejemplar.
  @override
  @JsonKey(name: 'cantidad_total')
  final int cantidadTotal;
  @override
  @JsonKey(name: 'cantidad_reservada')
  final int cantidadReservada;
  @override
  @JsonKey(name: 'cantidad_prestada')
  final int cantidadPrestada;
  @override
  @JsonKey(name: 'cantidad_vencida')
  final int cantidadVencida;
  @override
  @JsonKey(name: 'cantidad_fuera_servicio')
  final int cantidadFueraServicio;
  @override
  @JsonKey(name: 'cantidad_disponible')
  final int? cantidadDisponible;
  @override
  @JsonKey(name: 'imagen_url')
  final String? imagenUrl;
  @override
  @JsonKey(name: 'fecha_creacion')
  final DateTime? fechaCreacion;
  @override
  @JsonKey(name: 'fecha_actualizacion')
  final DateTime? fechaActualizacion;

  @override
  String toString() {
    return 'MaterialBiblioteca(id: $id, codigo: $codigo, titulo: $titulo, tipoMaterial: $tipoMaterial, estado: $estado, categoriaId: $categoriaId, autor: $autor, autores: $autores, isbn: $isbn, editorial: $editorial, anioPublicacion: $anioPublicacion, numeroPaginas: $numeroPaginas, descripcion: $descripcion, tomo: $tomo, totalTomos: $totalTomos, formato: $formato, duracion: $duracion, marca: $marca, modelo: $modelo, numeroSerie: $numeroSerie, ubicacion: $ubicacion, accesorios: $accesorios, condicion: $condicion, valorReferencial: $valorReferencial, esPrestable: $esPrestable, plazoPrestamoHoras: $plazoPrestamoHoras, cantidadTotal: $cantidadTotal, cantidadReservada: $cantidadReservada, cantidadPrestada: $cantidadPrestada, cantidadVencida: $cantidadVencida, cantidadFueraServicio: $cantidadFueraServicio, cantidadDisponible: $cantidadDisponible, imagenUrl: $imagenUrl, fechaCreacion: $fechaCreacion, fechaActualizacion: $fechaActualizacion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaterialBibliotecaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.tipoMaterial, tipoMaterial) ||
                other.tipoMaterial == tipoMaterial) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId) &&
            (identical(other.autor, autor) || other.autor == autor) &&
            const DeepCollectionEquality().equals(other._autores, _autores) &&
            (identical(other.isbn, isbn) || other.isbn == isbn) &&
            (identical(other.editorial, editorial) ||
                other.editorial == editorial) &&
            (identical(other.anioPublicacion, anioPublicacion) ||
                other.anioPublicacion == anioPublicacion) &&
            (identical(other.numeroPaginas, numeroPaginas) ||
                other.numeroPaginas == numeroPaginas) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.tomo, tomo) || other.tomo == tomo) &&
            (identical(other.totalTomos, totalTomos) ||
                other.totalTomos == totalTomos) &&
            (identical(other.formato, formato) || other.formato == formato) &&
            (identical(other.duracion, duracion) ||
                other.duracion == duracion) &&
            (identical(other.marca, marca) || other.marca == marca) &&
            (identical(other.modelo, modelo) || other.modelo == modelo) &&
            (identical(other.numeroSerie, numeroSerie) ||
                other.numeroSerie == numeroSerie) &&
            (identical(other.ubicacion, ubicacion) ||
                other.ubicacion == ubicacion) &&
            (identical(other.accesorios, accesorios) ||
                other.accesorios == accesorios) &&
            (identical(other.condicion, condicion) ||
                other.condicion == condicion) &&
            (identical(other.valorReferencial, valorReferencial) ||
                other.valorReferencial == valorReferencial) &&
            (identical(other.esPrestable, esPrestable) ||
                other.esPrestable == esPrestable) &&
            (identical(other.plazoPrestamoHoras, plazoPrestamoHoras) ||
                other.plazoPrestamoHoras == plazoPrestamoHoras) &&
            (identical(other.cantidadTotal, cantidadTotal) ||
                other.cantidadTotal == cantidadTotal) &&
            (identical(other.cantidadReservada, cantidadReservada) ||
                other.cantidadReservada == cantidadReservada) &&
            (identical(other.cantidadPrestada, cantidadPrestada) ||
                other.cantidadPrestada == cantidadPrestada) &&
            (identical(other.cantidadVencida, cantidadVencida) ||
                other.cantidadVencida == cantidadVencida) &&
            (identical(other.cantidadFueraServicio, cantidadFueraServicio) ||
                other.cantidadFueraServicio == cantidadFueraServicio) &&
            (identical(other.cantidadDisponible, cantidadDisponible) ||
                other.cantidadDisponible == cantidadDisponible) &&
            (identical(other.imagenUrl, imagenUrl) ||
                other.imagenUrl == imagenUrl) &&
            (identical(other.fechaCreacion, fechaCreacion) ||
                other.fechaCreacion == fechaCreacion) &&
            (identical(other.fechaActualizacion, fechaActualizacion) ||
                other.fechaActualizacion == fechaActualizacion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    codigo,
    titulo,
    tipoMaterial,
    estado,
    categoriaId,
    autor,
    const DeepCollectionEquality().hash(_autores),
    isbn,
    editorial,
    anioPublicacion,
    numeroPaginas,
    descripcion,
    tomo,
    totalTomos,
    formato,
    duracion,
    marca,
    modelo,
    numeroSerie,
    ubicacion,
    accesorios,
    condicion,
    valorReferencial,
    esPrestable,
    plazoPrestamoHoras,
    cantidadTotal,
    cantidadReservada,
    cantidadPrestada,
    cantidadVencida,
    cantidadFueraServicio,
    cantidadDisponible,
    imagenUrl,
    fechaCreacion,
    fechaActualizacion,
  ]);

  /// Create a copy of MaterialBiblioteca
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaterialBibliotecaImplCopyWith<_$MaterialBibliotecaImpl> get copyWith =>
      __$$MaterialBibliotecaImplCopyWithImpl<_$MaterialBibliotecaImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MaterialBibliotecaImplToJson(this);
  }
}

abstract class _MaterialBiblioteca extends MaterialBiblioteca {
  const factory _MaterialBiblioteca({
    required final String id,
    required final String codigo,
    required final String titulo,
    @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
    required final TipoMaterial tipoMaterial,
    @JsonKey(unknownEnumValue: EstadoMaterial.disponible)
    required final EstadoMaterial estado,
    @JsonKey(name: 'categoria_id') required final String categoriaId,
    final String? autor,
    final List<Autor> autores,
    final String? isbn,
    final String? editorial,
    @JsonKey(name: 'anio_publicacion') final int? anioPublicacion,
    @JsonKey(name: 'numero_paginas') final int? numeroPaginas,
    final String? descripcion,
    final String? tomo,
    @JsonKey(name: 'total_tomos') final int? totalTomos,
    final String? formato,
    final String? duracion,
    final String? marca,
    final String? modelo,
    @JsonKey(name: 'numero_serie') final String? numeroSerie,
    final String? ubicacion,
    final String? accesorios,
    @JsonKey(unknownEnumValue: CondicionMaterial.bueno)
    final CondicionMaterial condicion,
    @JsonKey(name: 'valor_referencial') final double? valorReferencial,
    @JsonKey(name: 'es_prestable') final bool esPrestable,
    @JsonKey(name: 'plazo_prestamo_horas') final int? plazoPrestamoHoras,
    @JsonKey(name: 'cantidad_total') final int cantidadTotal,
    @JsonKey(name: 'cantidad_reservada') final int cantidadReservada,
    @JsonKey(name: 'cantidad_prestada') final int cantidadPrestada,
    @JsonKey(name: 'cantidad_vencida') final int cantidadVencida,
    @JsonKey(name: 'cantidad_fuera_servicio') final int cantidadFueraServicio,
    @JsonKey(name: 'cantidad_disponible') final int? cantidadDisponible,
    @JsonKey(name: 'imagen_url') final String? imagenUrl,
    @JsonKey(name: 'fecha_creacion') final DateTime? fechaCreacion,
    @JsonKey(name: 'fecha_actualizacion') final DateTime? fechaActualizacion,
  }) = _$MaterialBibliotecaImpl;
  const _MaterialBiblioteca._() : super._();

  factory _MaterialBiblioteca.fromJson(Map<String, dynamic> json) =
      _$MaterialBibliotecaImpl.fromJson;

  @override
  String get id;
  @override
  String get codigo;
  @override
  String get titulo;
  @override
  @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
  TipoMaterial get tipoMaterial;
  @override
  @JsonKey(unknownEnumValue: EstadoMaterial.disponible)
  EstadoMaterial get estado;
  @override
  @JsonKey(name: 'categoria_id')
  String get categoriaId; // Bibliográficos
  /// Resumen en texto de los autores ("A, B"); la lista real está en [autores].
  @override
  String? get autor;
  @override
  List<Autor> get autores;
  @override
  String? get isbn;
  @override
  String? get editorial;
  @override
  @JsonKey(name: 'anio_publicacion')
  int? get anioPublicacion;
  @override
  @JsonKey(name: 'numero_paginas')
  int? get numeroPaginas;
  @override
  String? get descripcion;

  /// Obras de varios tomos: cada tomo es un material con su código y sus ejemplares.
  @override
  String? get tomo;
  @override
  @JsonKey(name: 'total_tomos')
  int? get totalTomos; // Medios
  @override
  String? get formato;
  @override
  String? get duracion; // Equipos
  @override
  String? get marca;
  @override
  String? get modelo;
  @override
  @JsonKey(name: 'numero_serie')
  String? get numeroSerie;
  @override
  String? get ubicacion;
  @override
  String? get accesorios; // Gestión de la unidad
  @override
  @JsonKey(unknownEnumValue: CondicionMaterial.bueno)
  CondicionMaterial get condicion;
  @override
  @JsonKey(name: 'valor_referencial')
  double? get valorReferencial;
  @override
  @JsonKey(name: 'es_prestable')
  bool get esPrestable;
  @override
  @JsonKey(name: 'plazo_prestamo_horas')
  int? get plazoPrestamoHoras; // Ejemplares. Una respuesta antigua (o una copia guardada por una versión
  // anterior de la app) no los trae: se asume un solo ejemplar.
  @override
  @JsonKey(name: 'cantidad_total')
  int get cantidadTotal;
  @override
  @JsonKey(name: 'cantidad_reservada')
  int get cantidadReservada;
  @override
  @JsonKey(name: 'cantidad_prestada')
  int get cantidadPrestada;
  @override
  @JsonKey(name: 'cantidad_vencida')
  int get cantidadVencida;
  @override
  @JsonKey(name: 'cantidad_fuera_servicio')
  int get cantidadFueraServicio;
  @override
  @JsonKey(name: 'cantidad_disponible')
  int? get cantidadDisponible;
  @override
  @JsonKey(name: 'imagen_url')
  String? get imagenUrl;
  @override
  @JsonKey(name: 'fecha_creacion')
  DateTime? get fechaCreacion;
  @override
  @JsonKey(name: 'fecha_actualizacion')
  DateTime? get fechaActualizacion;

  /// Create a copy of MaterialBiblioteca
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaterialBibliotecaImplCopyWith<_$MaterialBibliotecaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
