// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'usuario.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Usuario _$UsuarioFromJson(Map<String, dynamic> json) {
  return _Usuario.fromJson(json);
}

/// @nodoc
mixin _$Usuario {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'correo_electronico')
  String get correoElectronico => throw _privateConstructorUsedError;
  @JsonKey(name: 'numero_documento')
  String get numeroDocumento => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get apellido => throw _privateConstructorUsedError;
  String get rol => throw _privateConstructorUsedError;
  String? get telefono => throw _privateConstructorUsedError;
  bool get activo => throw _privateConstructorUsedError;

  /// Serializes this Usuario to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Usuario
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UsuarioCopyWith<Usuario> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UsuarioCopyWith<$Res> {
  factory $UsuarioCopyWith(Usuario value, $Res Function(Usuario) then) =
      _$UsuarioCopyWithImpl<$Res, Usuario>;
  @useResult
  $Res call({
    String id,
    String username,
    @JsonKey(name: 'correo_electronico') String correoElectronico,
    @JsonKey(name: 'numero_documento') String numeroDocumento,
    String nombre,
    String apellido,
    String rol,
    String? telefono,
    bool activo,
  });
}

/// @nodoc
class _$UsuarioCopyWithImpl<$Res, $Val extends Usuario>
    implements $UsuarioCopyWith<$Res> {
  _$UsuarioCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Usuario
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? correoElectronico = null,
    Object? numeroDocumento = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? rol = null,
    Object? telefono = freezed,
    Object? activo = null,
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
            correoElectronico: null == correoElectronico
                ? _value.correoElectronico
                : correoElectronico // ignore: cast_nullable_to_non_nullable
                      as String,
            numeroDocumento: null == numeroDocumento
                ? _value.numeroDocumento
                : numeroDocumento // ignore: cast_nullable_to_non_nullable
                      as String,
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            apellido: null == apellido
                ? _value.apellido
                : apellido // ignore: cast_nullable_to_non_nullable
                      as String,
            rol: null == rol
                ? _value.rol
                : rol // ignore: cast_nullable_to_non_nullable
                      as String,
            telefono: freezed == telefono
                ? _value.telefono
                : telefono // ignore: cast_nullable_to_non_nullable
                      as String?,
            activo: null == activo
                ? _value.activo
                : activo // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UsuarioImplCopyWith<$Res> implements $UsuarioCopyWith<$Res> {
  factory _$$UsuarioImplCopyWith(
    _$UsuarioImpl value,
    $Res Function(_$UsuarioImpl) then,
  ) = __$$UsuarioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String username,
    @JsonKey(name: 'correo_electronico') String correoElectronico,
    @JsonKey(name: 'numero_documento') String numeroDocumento,
    String nombre,
    String apellido,
    String rol,
    String? telefono,
    bool activo,
  });
}

/// @nodoc
class __$$UsuarioImplCopyWithImpl<$Res>
    extends _$UsuarioCopyWithImpl<$Res, _$UsuarioImpl>
    implements _$$UsuarioImplCopyWith<$Res> {
  __$$UsuarioImplCopyWithImpl(
    _$UsuarioImpl _value,
    $Res Function(_$UsuarioImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Usuario
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? correoElectronico = null,
    Object? numeroDocumento = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? rol = null,
    Object? telefono = freezed,
    Object? activo = null,
  }) {
    return _then(
      _$UsuarioImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        correoElectronico: null == correoElectronico
            ? _value.correoElectronico
            : correoElectronico // ignore: cast_nullable_to_non_nullable
                  as String,
        numeroDocumento: null == numeroDocumento
            ? _value.numeroDocumento
            : numeroDocumento // ignore: cast_nullable_to_non_nullable
                  as String,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        apellido: null == apellido
            ? _value.apellido
            : apellido // ignore: cast_nullable_to_non_nullable
                  as String,
        rol: null == rol
            ? _value.rol
            : rol // ignore: cast_nullable_to_non_nullable
                  as String,
        telefono: freezed == telefono
            ? _value.telefono
            : telefono // ignore: cast_nullable_to_non_nullable
                  as String?,
        activo: null == activo
            ? _value.activo
            : activo // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UsuarioImpl implements _Usuario {
  const _$UsuarioImpl({
    required this.id,
    required this.username,
    @JsonKey(name: 'correo_electronico') required this.correoElectronico,
    @JsonKey(name: 'numero_documento') required this.numeroDocumento,
    required this.nombre,
    required this.apellido,
    required this.rol,
    this.telefono,
    this.activo = true,
  });

  factory _$UsuarioImpl.fromJson(Map<String, dynamic> json) =>
      _$$UsuarioImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  @JsonKey(name: 'correo_electronico')
  final String correoElectronico;
  @override
  @JsonKey(name: 'numero_documento')
  final String numeroDocumento;
  @override
  final String nombre;
  @override
  final String apellido;
  @override
  final String rol;
  @override
  final String? telefono;
  @override
  @JsonKey()
  final bool activo;

  @override
  String toString() {
    return 'Usuario(id: $id, username: $username, correoElectronico: $correoElectronico, numeroDocumento: $numeroDocumento, nombre: $nombre, apellido: $apellido, rol: $rol, telefono: $telefono, activo: $activo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UsuarioImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.correoElectronico, correoElectronico) ||
                other.correoElectronico == correoElectronico) &&
            (identical(other.numeroDocumento, numeroDocumento) ||
                other.numeroDocumento == numeroDocumento) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.apellido, apellido) ||
                other.apellido == apellido) &&
            (identical(other.rol, rol) || other.rol == rol) &&
            (identical(other.telefono, telefono) ||
                other.telefono == telefono) &&
            (identical(other.activo, activo) || other.activo == activo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    username,
    correoElectronico,
    numeroDocumento,
    nombre,
    apellido,
    rol,
    telefono,
    activo,
  );

  /// Create a copy of Usuario
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UsuarioImplCopyWith<_$UsuarioImpl> get copyWith =>
      __$$UsuarioImplCopyWithImpl<_$UsuarioImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UsuarioImplToJson(this);
  }
}

abstract class _Usuario implements Usuario {
  const factory _Usuario({
    required final String id,
    required final String username,
    @JsonKey(name: 'correo_electronico')
    required final String correoElectronico,
    @JsonKey(name: 'numero_documento') required final String numeroDocumento,
    required final String nombre,
    required final String apellido,
    required final String rol,
    final String? telefono,
    final bool activo,
  }) = _$UsuarioImpl;

  factory _Usuario.fromJson(Map<String, dynamic> json) = _$UsuarioImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  @JsonKey(name: 'correo_electronico')
  String get correoElectronico;
  @override
  @JsonKey(name: 'numero_documento')
  String get numeroDocumento;
  @override
  String get nombre;
  @override
  String get apellido;
  @override
  String get rol;
  @override
  String? get telefono;
  @override
  bool get activo;

  /// Create a copy of Usuario
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UsuarioImplCopyWith<_$UsuarioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
