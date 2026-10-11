// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'usuario_resumen.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UsuarioResumen _$UsuarioResumenFromJson(Map<String, dynamic> json) {
  return _UsuarioResumen.fromJson(json);
}

/// @nodoc
mixin _$UsuarioResumen {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get apellido => throw _privateConstructorUsedError;
  @JsonKey(name: 'numero_documento')
  String get numeroDocumento => throw _privateConstructorUsedError;
  @JsonKey(name: 'correo_electronico')
  String get correoElectronico => throw _privateConstructorUsedError;

  /// Serializes this UsuarioResumen to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UsuarioResumen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UsuarioResumenCopyWith<UsuarioResumen> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UsuarioResumenCopyWith<$Res> {
  factory $UsuarioResumenCopyWith(
    UsuarioResumen value,
    $Res Function(UsuarioResumen) then,
  ) = _$UsuarioResumenCopyWithImpl<$Res, UsuarioResumen>;
  @useResult
  $Res call({
    String id,
    String username,
    String nombre,
    String apellido,
    @JsonKey(name: 'numero_documento') String numeroDocumento,
    @JsonKey(name: 'correo_electronico') String correoElectronico,
  });
}

/// @nodoc
class _$UsuarioResumenCopyWithImpl<$Res, $Val extends UsuarioResumen>
    implements $UsuarioResumenCopyWith<$Res> {
  _$UsuarioResumenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UsuarioResumen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? numeroDocumento = null,
    Object? correoElectronico = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            apellido: null == apellido
                ? _value.apellido
                : apellido // ignore: cast_nullable_to_non_nullable
                      as String,
            numeroDocumento: null == numeroDocumento
                ? _value.numeroDocumento
                : numeroDocumento // ignore: cast_nullable_to_non_nullable
                      as String,
            correoElectronico: null == correoElectronico
                ? _value.correoElectronico
                : correoElectronico // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UsuarioResumenImplCopyWith<$Res>
    implements $UsuarioResumenCopyWith<$Res> {
  factory _$$UsuarioResumenImplCopyWith(
    _$UsuarioResumenImpl value,
    $Res Function(_$UsuarioResumenImpl) then,
  ) = __$$UsuarioResumenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String username,
    String nombre,
    String apellido,
    @JsonKey(name: 'numero_documento') String numeroDocumento,
    @JsonKey(name: 'correo_electronico') String correoElectronico,
  });
}

/// @nodoc
class __$$UsuarioResumenImplCopyWithImpl<$Res>
    extends _$UsuarioResumenCopyWithImpl<$Res, _$UsuarioResumenImpl>
    implements _$$UsuarioResumenImplCopyWith<$Res> {
  __$$UsuarioResumenImplCopyWithImpl(
    _$UsuarioResumenImpl _value,
    $Res Function(_$UsuarioResumenImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UsuarioResumen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? numeroDocumento = null,
    Object? correoElectronico = null,
  }) {
    return _then(
      _$UsuarioResumenImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        apellido: null == apellido
            ? _value.apellido
            : apellido // ignore: cast_nullable_to_non_nullable
                  as String,
        numeroDocumento: null == numeroDocumento
            ? _value.numeroDocumento
            : numeroDocumento // ignore: cast_nullable_to_non_nullable
                  as String,
        correoElectronico: null == correoElectronico
            ? _value.correoElectronico
            : correoElectronico // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UsuarioResumenImpl extends _UsuarioResumen {
  const _$UsuarioResumenImpl({
    required this.id,
    required this.username,
    required this.nombre,
    required this.apellido,
    @JsonKey(name: 'numero_documento') required this.numeroDocumento,
    @JsonKey(name: 'correo_electronico') required this.correoElectronico,
  }) : super._();

  factory _$UsuarioResumenImpl.fromJson(Map<String, dynamic> json) =>
      _$$UsuarioResumenImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  final String nombre;
  @override
  final String apellido;
  @override
  @JsonKey(name: 'numero_documento')
  final String numeroDocumento;
  @override
  @JsonKey(name: 'correo_electronico')
  final String correoElectronico;

  @override
  String toString() {
    return 'UsuarioResumen(id: $id, username: $username, nombre: $nombre, apellido: $apellido, numeroDocumento: $numeroDocumento, correoElectronico: $correoElectronico)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UsuarioResumenImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.apellido, apellido) ||
                other.apellido == apellido) &&
            (identical(other.numeroDocumento, numeroDocumento) ||
                other.numeroDocumento == numeroDocumento) &&
            (identical(other.correoElectronico, correoElectronico) ||
                other.correoElectronico == correoElectronico));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    username,
    nombre,
    apellido,
    numeroDocumento,
    correoElectronico,
  );

  /// Create a copy of UsuarioResumen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UsuarioResumenImplCopyWith<_$UsuarioResumenImpl> get copyWith =>
      __$$UsuarioResumenImplCopyWithImpl<_$UsuarioResumenImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UsuarioResumenImplToJson(this);
  }
}

abstract class _UsuarioResumen extends UsuarioResumen {
  const factory _UsuarioResumen({
    required final String id,
    required final String username,
    required final String nombre,
    required final String apellido,
    @JsonKey(name: 'numero_documento') required final String numeroDocumento,
    @JsonKey(name: 'correo_electronico')
    required final String correoElectronico,
  }) = _$UsuarioResumenImpl;
  const _UsuarioResumen._() : super._();

  factory _UsuarioResumen.fromJson(Map<String, dynamic> json) =
      _$UsuarioResumenImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  String get nombre;
  @override
  String get apellido;
  @override
  @JsonKey(name: 'numero_documento')
  String get numeroDocumento;
  @override
  @JsonKey(name: 'correo_electronico')
  String get correoElectronico;

  /// Create a copy of UsuarioResumen
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UsuarioResumenImplCopyWith<_$UsuarioResumenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
