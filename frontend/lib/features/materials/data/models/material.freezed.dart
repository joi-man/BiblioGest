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
  @JsonKey(name: 'tipo_material')
  TipoMaterial get tipoMaterial => throw _privateConstructorUsedError;
  @JsonKey(name: 'estado')
  EstadoMaterial get estado => throw _privateConstructorUsedError;
  String? get autor => throw _privateConstructorUsedError;
  String? get isbn => throw _privateConstructorUsedError;
  String? get editorial => throw _privateConstructorUsedError;
  @JsonKey(name: 'anio_publicacion')
  int? get anioPublicacion => throw _privateConstructorUsedError;
  @JsonKey(name: 'numero_paginas')
  int? get numeroPaginas => throw _privateConstructorUsedError;
  String? get idioma => throw _privateConstructorUsedError;
  String? get edicion => throw _privateConstructorUsedError;
  String? get formato => throw _privateConstructorUsedError;
  String? get duracion => throw _privateConstructorUsedError;
  String? get descripcion => throw _privateConstructorUsedError;
  String? get ubicacion => throw _privateConstructorUsedError;
  @JsonKey(name: 'cantidad_disponible')
  int? get cantidadDisponible => throw _privateConstructorUsedError;
  @JsonKey(name: 'categoria_id')
  String? get categoriaId => throw _privateConstructorUsedError;
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
    @JsonKey(name: 'tipo_material') TipoMaterial tipoMaterial,
    @JsonKey(name: 'estado') EstadoMaterial estado,
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
    Object? autor = freezed,
    Object? isbn = freezed,
    Object? editorial = freezed,
    Object? anioPublicacion = freezed,
    Object? numeroPaginas = freezed,
    Object? idioma = freezed,
    Object? edicion = freezed,
    Object? formato = freezed,
    Object? duracion = freezed,
    Object? descripcion = freezed,
    Object? ubicacion = freezed,
    Object? cantidadDisponible = freezed,
    Object? categoriaId = freezed,
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
            autor: freezed == autor
                ? _value.autor
                : autor // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            idioma: freezed == idioma
                ? _value.idioma
                : idioma // ignore: cast_nullable_to_non_nullable
                      as String?,
            edicion: freezed == edicion
                ? _value.edicion
                : edicion // ignore: cast_nullable_to_non_nullable
                      as String?,
            formato: freezed == formato
                ? _value.formato
                : formato // ignore: cast_nullable_to_non_nullable
                      as String?,
            duracion: freezed == duracion
                ? _value.duracion
                : duracion // ignore: cast_nullable_to_non_nullable
                      as String?,
            descripcion: freezed == descripcion
                ? _value.descripcion
                : descripcion // ignore: cast_nullable_to_non_nullable
                      as String?,
            ubicacion: freezed == ubicacion
                ? _value.ubicacion
                : ubicacion // ignore: cast_nullable_to_non_nullable
                      as String?,
            cantidadDisponible: freezed == cantidadDisponible
                ? _value.cantidadDisponible
                : cantidadDisponible // ignore: cast_nullable_to_non_nullable
                      as int?,
            categoriaId: freezed == categoriaId
                ? _value.categoriaId
                : categoriaId // ignore: cast_nullable_to_non_nullable
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
    @JsonKey(name: 'tipo_material') TipoMaterial tipoMaterial,
    @JsonKey(name: 'estado') EstadoMaterial estado,
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
    Object? autor = freezed,
    Object? isbn = freezed,
    Object? editorial = freezed,
    Object? anioPublicacion = freezed,
    Object? numeroPaginas = freezed,
    Object? idioma = freezed,
    Object? edicion = freezed,
    Object? formato = freezed,
    Object? duracion = freezed,
    Object? descripcion = freezed,
    Object? ubicacion = freezed,
    Object? cantidadDisponible = freezed,
    Object? categoriaId = freezed,
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
        autor: freezed == autor
            ? _value.autor
            : autor // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        idioma: freezed == idioma
            ? _value.idioma
            : idioma // ignore: cast_nullable_to_non_nullable
                  as String?,
        edicion: freezed == edicion
            ? _value.edicion
            : edicion // ignore: cast_nullable_to_non_nullable
                  as String?,
        formato: freezed == formato
            ? _value.formato
            : formato // ignore: cast_nullable_to_non_nullable
                  as String?,
        duracion: freezed == duracion
            ? _value.duracion
            : duracion // ignore: cast_nullable_to_non_nullable
                  as String?,
        descripcion: freezed == descripcion
            ? _value.descripcion
            : descripcion // ignore: cast_nullable_to_non_nullable
                  as String?,
        ubicacion: freezed == ubicacion
            ? _value.ubicacion
            : ubicacion // ignore: cast_nullable_to_non_nullable
                  as String?,
        cantidadDisponible: freezed == cantidadDisponible
            ? _value.cantidadDisponible
            : cantidadDisponible // ignore: cast_nullable_to_non_nullable
                  as int?,
        categoriaId: freezed == categoriaId
            ? _value.categoriaId
            : categoriaId // ignore: cast_nullable_to_non_nullable
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
@JsonSerializable()
class _$MaterialBibliotecaImpl implements _MaterialBiblioteca {
  const _$MaterialBibliotecaImpl({
    required this.id,
    required this.codigo,
    required this.titulo,
    @JsonKey(name: 'tipo_material') required this.tipoMaterial,
    @JsonKey(name: 'estado') required this.estado,
    this.autor,
    this.isbn,
    this.editorial,
    @JsonKey(name: 'anio_publicacion') this.anioPublicacion,
    @JsonKey(name: 'numero_paginas') this.numeroPaginas,
    this.idioma,
    this.edicion,
    this.formato,
    this.duracion,
    this.descripcion,
    this.ubicacion,
    @JsonKey(name: 'cantidad_disponible') this.cantidadDisponible,
    @JsonKey(name: 'categoria_id') this.categoriaId,
    @JsonKey(name: 'fecha_creacion') this.fechaCreacion,
    @JsonKey(name: 'fecha_actualizacion') this.fechaActualizacion,
  });

  factory _$MaterialBibliotecaImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaterialBibliotecaImplFromJson(json);

  @override
  final String id;
  @override
  final String codigo;
  @override
  final String titulo;
  @override
  @JsonKey(name: 'tipo_material')
  final TipoMaterial tipoMaterial;
  @override
  @JsonKey(name: 'estado')
  final EstadoMaterial estado;
  @override
  final String? autor;
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
  final String? idioma;
  @override
  final String? edicion;
  @override
  final String? formato;
  @override
  final String? duracion;
  @override
  final String? descripcion;
  @override
  final String? ubicacion;
  @override
  @JsonKey(name: 'cantidad_disponible')
  final int? cantidadDisponible;
  @override
  @JsonKey(name: 'categoria_id')
  final String? categoriaId;
  @override
  @JsonKey(name: 'fecha_creacion')
  final DateTime? fechaCreacion;
  @override
  @JsonKey(name: 'fecha_actualizacion')
  final DateTime? fechaActualizacion;

  @override
  String toString() {
    return 'MaterialBiblioteca(id: $id, codigo: $codigo, titulo: $titulo, tipoMaterial: $tipoMaterial, estado: $estado, autor: $autor, isbn: $isbn, editorial: $editorial, anioPublicacion: $anioPublicacion, numeroPaginas: $numeroPaginas, idioma: $idioma, edicion: $edicion, formato: $formato, duracion: $duracion, descripcion: $descripcion, ubicacion: $ubicacion, cantidadDisponible: $cantidadDisponible, categoriaId: $categoriaId, fechaCreacion: $fechaCreacion, fechaActualizacion: $fechaActualizacion)';
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
            (identical(other.autor, autor) || other.autor == autor) &&
            (identical(other.isbn, isbn) || other.isbn == isbn) &&
            (identical(other.editorial, editorial) ||
                other.editorial == editorial) &&
            (identical(other.anioPublicacion, anioPublicacion) ||
                other.anioPublicacion == anioPublicacion) &&
            (identical(other.numeroPaginas, numeroPaginas) ||
                other.numeroPaginas == numeroPaginas) &&
            (identical(other.idioma, idioma) || other.idioma == idioma) &&
            (identical(other.edicion, edicion) || other.edicion == edicion) &&
            (identical(other.formato, formato) || other.formato == formato) &&
            (identical(other.duracion, duracion) ||
                other.duracion == duracion) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.ubicacion, ubicacion) ||
                other.ubicacion == ubicacion) &&
            (identical(other.cantidadDisponible, cantidadDisponible) ||
                other.cantidadDisponible == cantidadDisponible) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId) &&
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
    autor,
    isbn,
    editorial,
    anioPublicacion,
    numeroPaginas,
    idioma,
    edicion,
    formato,
    duracion,
    descripcion,
    ubicacion,
    cantidadDisponible,
    categoriaId,
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

abstract class _MaterialBiblioteca implements MaterialBiblioteca {
  const factory _MaterialBiblioteca({
    required final String id,
    required final String codigo,
    required final String titulo,
    @JsonKey(name: 'tipo_material') required final TipoMaterial tipoMaterial,
    @JsonKey(name: 'estado') required final EstadoMaterial estado,
    final String? autor,
    final String? isbn,
    final String? editorial,
    @JsonKey(name: 'anio_publicacion') final int? anioPublicacion,
    @JsonKey(name: 'numero_paginas') final int? numeroPaginas,
    final String? idioma,
    final String? edicion,
    final String? formato,
    final String? duracion,
    final String? descripcion,
    final String? ubicacion,
    @JsonKey(name: 'cantidad_disponible') final int? cantidadDisponible,
    @JsonKey(name: 'categoria_id') final String? categoriaId,
    @JsonKey(name: 'fecha_creacion') final DateTime? fechaCreacion,
    @JsonKey(name: 'fecha_actualizacion') final DateTime? fechaActualizacion,
  }) = _$MaterialBibliotecaImpl;

  factory _MaterialBiblioteca.fromJson(Map<String, dynamic> json) =
      _$MaterialBibliotecaImpl.fromJson;

  @override
  String get id;
  @override
  String get codigo;
  @override
  String get titulo;
  @override
  @JsonKey(name: 'tipo_material')
  TipoMaterial get tipoMaterial;
  @override
  @JsonKey(name: 'estado')
  EstadoMaterial get estado;
  @override
  String? get autor;
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
  String? get idioma;
  @override
  String? get edicion;
  @override
  String? get formato;
  @override
  String? get duracion;
  @override
  String? get descripcion;
  @override
  String? get ubicacion;
  @override
  @JsonKey(name: 'cantidad_disponible')
  int? get cantidadDisponible;
  @override
  @JsonKey(name: 'categoria_id')
  String? get categoriaId;
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
