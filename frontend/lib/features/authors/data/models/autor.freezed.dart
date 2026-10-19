// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'autor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Autor _$AutorFromJson(Map<String, dynamic> json) {
  return _Autor.fromJson(json);
}

/// @nodoc
mixin _$Autor {
  String get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  @JsonKey(name: 'cantidad_materiales')
  int get cantidadMateriales => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_creacion')
  DateTime? get fechaCreacion => throw _privateConstructorUsedError;

  /// Serializes this Autor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Autor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutorCopyWith<Autor> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutorCopyWith<$Res> {
  factory $AutorCopyWith(Autor value, $Res Function(Autor) then) =
      _$AutorCopyWithImpl<$Res, Autor>;
  @useResult
  $Res call({
    String id,
    String nombre,
    @JsonKey(name: 'cantidad_materiales') int cantidadMateriales,
    @JsonKey(name: 'fecha_creacion') DateTime? fechaCreacion,
  });
}

/// @nodoc
class _$AutorCopyWithImpl<$Res, $Val extends Autor>
    implements $AutorCopyWith<$Res> {
  _$AutorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Autor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? cantidadMateriales = null,
    Object? fechaCreacion = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            cantidadMateriales: null == cantidadMateriales
                ? _value.cantidadMateriales
                : cantidadMateriales // ignore: cast_nullable_to_non_nullable
                      as int,
            fechaCreacion: freezed == fechaCreacion
                ? _value.fechaCreacion
                : fechaCreacion // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AutorImplCopyWith<$Res> implements $AutorCopyWith<$Res> {
  factory _$$AutorImplCopyWith(
    _$AutorImpl value,
    $Res Function(_$AutorImpl) then,
  ) = __$$AutorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nombre,
    @JsonKey(name: 'cantidad_materiales') int cantidadMateriales,
    @JsonKey(name: 'fecha_creacion') DateTime? fechaCreacion,
  });
}

/// @nodoc
class __$$AutorImplCopyWithImpl<$Res>
    extends _$AutorCopyWithImpl<$Res, _$AutorImpl>
    implements _$$AutorImplCopyWith<$Res> {
  __$$AutorImplCopyWithImpl(
    _$AutorImpl _value,
    $Res Function(_$AutorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Autor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? cantidadMateriales = null,
    Object? fechaCreacion = freezed,
  }) {
    return _then(
      _$AutorImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        cantidadMateriales: null == cantidadMateriales
            ? _value.cantidadMateriales
            : cantidadMateriales // ignore: cast_nullable_to_non_nullable
                  as int,
        fechaCreacion: freezed == fechaCreacion
            ? _value.fechaCreacion
            : fechaCreacion // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AutorImpl implements _Autor {
  const _$AutorImpl({
    required this.id,
    required this.nombre,
    @JsonKey(name: 'cantidad_materiales') this.cantidadMateriales = 0,
    @JsonKey(name: 'fecha_creacion') this.fechaCreacion,
  });

  factory _$AutorImpl.fromJson(Map<String, dynamic> json) =>
      _$$AutorImplFromJson(json);

  @override
  final String id;
  @override
  final String nombre;
  @override
  @JsonKey(name: 'cantidad_materiales')
  final int cantidadMateriales;
  @override
  @JsonKey(name: 'fecha_creacion')
  final DateTime? fechaCreacion;

  @override
  String toString() {
    return 'Autor(id: $id, nombre: $nombre, cantidadMateriales: $cantidadMateriales, fechaCreacion: $fechaCreacion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.cantidadMateriales, cantidadMateriales) ||
                other.cantidadMateriales == cantidadMateriales) &&
            (identical(other.fechaCreacion, fechaCreacion) ||
                other.fechaCreacion == fechaCreacion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nombre, cantidadMateriales, fechaCreacion);

  /// Create a copy of Autor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutorImplCopyWith<_$AutorImpl> get copyWith =>
      __$$AutorImplCopyWithImpl<_$AutorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AutorImplToJson(this);
  }
}

abstract class _Autor implements Autor {
  const factory _Autor({
    required final String id,
    required final String nombre,
    @JsonKey(name: 'cantidad_materiales') final int cantidadMateriales,
    @JsonKey(name: 'fecha_creacion') final DateTime? fechaCreacion,
  }) = _$AutorImpl;

  factory _Autor.fromJson(Map<String, dynamic> json) = _$AutorImpl.fromJson;

  @override
  String get id;
  @override
  String get nombre;
  @override
  @JsonKey(name: 'cantidad_materiales')
  int get cantidadMateriales;
  @override
  @JsonKey(name: 'fecha_creacion')
  DateTime? get fechaCreacion;

  /// Create a copy of Autor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutorImplCopyWith<_$AutorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
