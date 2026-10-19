// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prestamo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Prestamo _$PrestamoFromJson(Map<String, dynamic> json) {
  return _Prestamo.fromJson(json);
}

/// @nodoc
mixin _$Prestamo {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: EstadoPrestamo.pendiente)
  EstadoPrestamo get estado => throw _privateConstructorUsedError;
  UsuarioResumen get usuario => throw _privateConstructorUsedError;
  List<PrestamoDetalle> get detalles => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_solicitud')
  DateTime get fechaSolicitud => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_retiro_solicitada')
  DateTime? get fechaRetiroSolicitada => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_retiro_limite')
  DateTime? get fechaRetiroLimite => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_prestamo')
  DateTime? get fechaPrestamo => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_devolucion_esperada')
  DateTime? get fechaDevolucionEsperada => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_devolucion_real')
  DateTime? get fechaDevolucionReal => throw _privateConstructorUsedError;
  @JsonKey(name: 'aprobado_por')
  UsuarioResumen? get aprobadoPor => throw _privateConstructorUsedError;
  @JsonKey(name: 'entregado_por')
  UsuarioResumen? get entregadoPor => throw _privateConstructorUsedError;
  String? get observaciones => throw _privateConstructorUsedError;
  @JsonKey(name: 'motivo_rechazo')
  String? get motivoRechazo => throw _privateConstructorUsedError;

  /// Serializes this Prestamo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Prestamo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrestamoCopyWith<Prestamo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrestamoCopyWith<$Res> {
  factory $PrestamoCopyWith(Prestamo value, $Res Function(Prestamo) then) =
      _$PrestamoCopyWithImpl<$Res, Prestamo>;
  @useResult
  $Res call({
    String id,
    @JsonKey(unknownEnumValue: EstadoPrestamo.pendiente) EstadoPrestamo estado,
    UsuarioResumen usuario,
    List<PrestamoDetalle> detalles,
    @JsonKey(name: 'fecha_solicitud') DateTime fechaSolicitud,
    @JsonKey(name: 'fecha_retiro_solicitada') DateTime? fechaRetiroSolicitada,
    @JsonKey(name: 'fecha_retiro_limite') DateTime? fechaRetiroLimite,
    @JsonKey(name: 'fecha_prestamo') DateTime? fechaPrestamo,
    @JsonKey(name: 'fecha_devolucion_esperada')
    DateTime? fechaDevolucionEsperada,
    @JsonKey(name: 'fecha_devolucion_real') DateTime? fechaDevolucionReal,
    @JsonKey(name: 'aprobado_por') UsuarioResumen? aprobadoPor,
    @JsonKey(name: 'entregado_por') UsuarioResumen? entregadoPor,
    String? observaciones,
    @JsonKey(name: 'motivo_rechazo') String? motivoRechazo,
  });

  $UsuarioResumenCopyWith<$Res> get usuario;
  $UsuarioResumenCopyWith<$Res>? get aprobadoPor;
  $UsuarioResumenCopyWith<$Res>? get entregadoPor;
}

/// @nodoc
class _$PrestamoCopyWithImpl<$Res, $Val extends Prestamo>
    implements $PrestamoCopyWith<$Res> {
  _$PrestamoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Prestamo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? estado = null,
    Object? usuario = null,
    Object? detalles = null,
    Object? fechaSolicitud = null,
    Object? fechaRetiroSolicitada = freezed,
    Object? fechaRetiroLimite = freezed,
    Object? fechaPrestamo = freezed,
    Object? fechaDevolucionEsperada = freezed,
    Object? fechaDevolucionReal = freezed,
    Object? aprobadoPor = freezed,
    Object? entregadoPor = freezed,
    Object? observaciones = freezed,
    Object? motivoRechazo = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            estado: null == estado
                ? _value.estado
                : estado // ignore: cast_nullable_to_non_nullable
                      as EstadoPrestamo,
            usuario: null == usuario
                ? _value.usuario
                : usuario // ignore: cast_nullable_to_non_nullable
                      as UsuarioResumen,
            detalles: null == detalles
                ? _value.detalles
                : detalles // ignore: cast_nullable_to_non_nullable
                      as List<PrestamoDetalle>,
            fechaSolicitud: null == fechaSolicitud
                ? _value.fechaSolicitud
                : fechaSolicitud // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            fechaRetiroSolicitada: freezed == fechaRetiroSolicitada
                ? _value.fechaRetiroSolicitada
                : fechaRetiroSolicitada // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            fechaRetiroLimite: freezed == fechaRetiroLimite
                ? _value.fechaRetiroLimite
                : fechaRetiroLimite // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            fechaPrestamo: freezed == fechaPrestamo
                ? _value.fechaPrestamo
                : fechaPrestamo // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            fechaDevolucionEsperada: freezed == fechaDevolucionEsperada
                ? _value.fechaDevolucionEsperada
                : fechaDevolucionEsperada // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            fechaDevolucionReal: freezed == fechaDevolucionReal
                ? _value.fechaDevolucionReal
                : fechaDevolucionReal // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            aprobadoPor: freezed == aprobadoPor
                ? _value.aprobadoPor
                : aprobadoPor // ignore: cast_nullable_to_non_nullable
                      as UsuarioResumen?,
            entregadoPor: freezed == entregadoPor
                ? _value.entregadoPor
                : entregadoPor // ignore: cast_nullable_to_non_nullable
                      as UsuarioResumen?,
            observaciones: freezed == observaciones
                ? _value.observaciones
                : observaciones // ignore: cast_nullable_to_non_nullable
                      as String?,
            motivoRechazo: freezed == motivoRechazo
                ? _value.motivoRechazo
                : motivoRechazo // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of Prestamo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UsuarioResumenCopyWith<$Res> get usuario {
    return $UsuarioResumenCopyWith<$Res>(_value.usuario, (value) {
      return _then(_value.copyWith(usuario: value) as $Val);
    });
  }

  /// Create a copy of Prestamo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UsuarioResumenCopyWith<$Res>? get aprobadoPor {
    if (_value.aprobadoPor == null) {
      return null;
    }

    return $UsuarioResumenCopyWith<$Res>(_value.aprobadoPor!, (value) {
      return _then(_value.copyWith(aprobadoPor: value) as $Val);
    });
  }

  /// Create a copy of Prestamo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UsuarioResumenCopyWith<$Res>? get entregadoPor {
    if (_value.entregadoPor == null) {
      return null;
    }

    return $UsuarioResumenCopyWith<$Res>(_value.entregadoPor!, (value) {
      return _then(_value.copyWith(entregadoPor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PrestamoImplCopyWith<$Res>
    implements $PrestamoCopyWith<$Res> {
  factory _$$PrestamoImplCopyWith(
    _$PrestamoImpl value,
    $Res Function(_$PrestamoImpl) then,
  ) = __$$PrestamoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(unknownEnumValue: EstadoPrestamo.pendiente) EstadoPrestamo estado,
    UsuarioResumen usuario,
    List<PrestamoDetalle> detalles,
    @JsonKey(name: 'fecha_solicitud') DateTime fechaSolicitud,
    @JsonKey(name: 'fecha_retiro_solicitada') DateTime? fechaRetiroSolicitada,
    @JsonKey(name: 'fecha_retiro_limite') DateTime? fechaRetiroLimite,
    @JsonKey(name: 'fecha_prestamo') DateTime? fechaPrestamo,
    @JsonKey(name: 'fecha_devolucion_esperada')
    DateTime? fechaDevolucionEsperada,
    @JsonKey(name: 'fecha_devolucion_real') DateTime? fechaDevolucionReal,
    @JsonKey(name: 'aprobado_por') UsuarioResumen? aprobadoPor,
    @JsonKey(name: 'entregado_por') UsuarioResumen? entregadoPor,
    String? observaciones,
    @JsonKey(name: 'motivo_rechazo') String? motivoRechazo,
  });

  @override
  $UsuarioResumenCopyWith<$Res> get usuario;
  @override
  $UsuarioResumenCopyWith<$Res>? get aprobadoPor;
  @override
  $UsuarioResumenCopyWith<$Res>? get entregadoPor;
}

/// @nodoc
class __$$PrestamoImplCopyWithImpl<$Res>
    extends _$PrestamoCopyWithImpl<$Res, _$PrestamoImpl>
    implements _$$PrestamoImplCopyWith<$Res> {
  __$$PrestamoImplCopyWithImpl(
    _$PrestamoImpl _value,
    $Res Function(_$PrestamoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Prestamo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? estado = null,
    Object? usuario = null,
    Object? detalles = null,
    Object? fechaSolicitud = null,
    Object? fechaRetiroSolicitada = freezed,
    Object? fechaRetiroLimite = freezed,
    Object? fechaPrestamo = freezed,
    Object? fechaDevolucionEsperada = freezed,
    Object? fechaDevolucionReal = freezed,
    Object? aprobadoPor = freezed,
    Object? entregadoPor = freezed,
    Object? observaciones = freezed,
    Object? motivoRechazo = freezed,
  }) {
    return _then(
      _$PrestamoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        estado: null == estado
            ? _value.estado
            : estado // ignore: cast_nullable_to_non_nullable
                  as EstadoPrestamo,
        usuario: null == usuario
            ? _value.usuario
            : usuario // ignore: cast_nullable_to_non_nullable
                  as UsuarioResumen,
        detalles: null == detalles
            ? _value._detalles
            : detalles // ignore: cast_nullable_to_non_nullable
                  as List<PrestamoDetalle>,
        fechaSolicitud: null == fechaSolicitud
            ? _value.fechaSolicitud
            : fechaSolicitud // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        fechaRetiroSolicitada: freezed == fechaRetiroSolicitada
            ? _value.fechaRetiroSolicitada
            : fechaRetiroSolicitada // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        fechaRetiroLimite: freezed == fechaRetiroLimite
            ? _value.fechaRetiroLimite
            : fechaRetiroLimite // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        fechaPrestamo: freezed == fechaPrestamo
            ? _value.fechaPrestamo
            : fechaPrestamo // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        fechaDevolucionEsperada: freezed == fechaDevolucionEsperada
            ? _value.fechaDevolucionEsperada
            : fechaDevolucionEsperada // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        fechaDevolucionReal: freezed == fechaDevolucionReal
            ? _value.fechaDevolucionReal
            : fechaDevolucionReal // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        aprobadoPor: freezed == aprobadoPor
            ? _value.aprobadoPor
            : aprobadoPor // ignore: cast_nullable_to_non_nullable
                  as UsuarioResumen?,
        entregadoPor: freezed == entregadoPor
            ? _value.entregadoPor
            : entregadoPor // ignore: cast_nullable_to_non_nullable
                  as UsuarioResumen?,
        observaciones: freezed == observaciones
            ? _value.observaciones
            : observaciones // ignore: cast_nullable_to_non_nullable
                  as String?,
        motivoRechazo: freezed == motivoRechazo
            ? _value.motivoRechazo
            : motivoRechazo // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrestamoImpl extends _Prestamo {
  const _$PrestamoImpl({
    required this.id,
    @JsonKey(unknownEnumValue: EstadoPrestamo.pendiente) required this.estado,
    required this.usuario,
    required final List<PrestamoDetalle> detalles,
    @JsonKey(name: 'fecha_solicitud') required this.fechaSolicitud,
    @JsonKey(name: 'fecha_retiro_solicitada') this.fechaRetiroSolicitada,
    @JsonKey(name: 'fecha_retiro_limite') this.fechaRetiroLimite,
    @JsonKey(name: 'fecha_prestamo') this.fechaPrestamo,
    @JsonKey(name: 'fecha_devolucion_esperada') this.fechaDevolucionEsperada,
    @JsonKey(name: 'fecha_devolucion_real') this.fechaDevolucionReal,
    @JsonKey(name: 'aprobado_por') this.aprobadoPor,
    @JsonKey(name: 'entregado_por') this.entregadoPor,
    this.observaciones,
    @JsonKey(name: 'motivo_rechazo') this.motivoRechazo,
  }) : _detalles = detalles,
       super._();

  factory _$PrestamoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrestamoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(unknownEnumValue: EstadoPrestamo.pendiente)
  final EstadoPrestamo estado;
  @override
  final UsuarioResumen usuario;
  final List<PrestamoDetalle> _detalles;
  @override
  List<PrestamoDetalle> get detalles {
    if (_detalles is EqualUnmodifiableListView) return _detalles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_detalles);
  }

  @override
  @JsonKey(name: 'fecha_solicitud')
  final DateTime fechaSolicitud;
  @override
  @JsonKey(name: 'fecha_retiro_solicitada')
  final DateTime? fechaRetiroSolicitada;
  @override
  @JsonKey(name: 'fecha_retiro_limite')
  final DateTime? fechaRetiroLimite;
  @override
  @JsonKey(name: 'fecha_prestamo')
  final DateTime? fechaPrestamo;
  @override
  @JsonKey(name: 'fecha_devolucion_esperada')
  final DateTime? fechaDevolucionEsperada;
  @override
  @JsonKey(name: 'fecha_devolucion_real')
  final DateTime? fechaDevolucionReal;
  @override
  @JsonKey(name: 'aprobado_por')
  final UsuarioResumen? aprobadoPor;
  @override
  @JsonKey(name: 'entregado_por')
  final UsuarioResumen? entregadoPor;
  @override
  final String? observaciones;
  @override
  @JsonKey(name: 'motivo_rechazo')
  final String? motivoRechazo;

  @override
  String toString() {
    return 'Prestamo(id: $id, estado: $estado, usuario: $usuario, detalles: $detalles, fechaSolicitud: $fechaSolicitud, fechaRetiroSolicitada: $fechaRetiroSolicitada, fechaRetiroLimite: $fechaRetiroLimite, fechaPrestamo: $fechaPrestamo, fechaDevolucionEsperada: $fechaDevolucionEsperada, fechaDevolucionReal: $fechaDevolucionReal, aprobadoPor: $aprobadoPor, entregadoPor: $entregadoPor, observaciones: $observaciones, motivoRechazo: $motivoRechazo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrestamoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.usuario, usuario) || other.usuario == usuario) &&
            const DeepCollectionEquality().equals(other._detalles, _detalles) &&
            (identical(other.fechaSolicitud, fechaSolicitud) ||
                other.fechaSolicitud == fechaSolicitud) &&
            (identical(other.fechaRetiroSolicitada, fechaRetiroSolicitada) ||
                other.fechaRetiroSolicitada == fechaRetiroSolicitada) &&
            (identical(other.fechaRetiroLimite, fechaRetiroLimite) ||
                other.fechaRetiroLimite == fechaRetiroLimite) &&
            (identical(other.fechaPrestamo, fechaPrestamo) ||
                other.fechaPrestamo == fechaPrestamo) &&
            (identical(
                  other.fechaDevolucionEsperada,
                  fechaDevolucionEsperada,
                ) ||
                other.fechaDevolucionEsperada == fechaDevolucionEsperada) &&
            (identical(other.fechaDevolucionReal, fechaDevolucionReal) ||
                other.fechaDevolucionReal == fechaDevolucionReal) &&
            (identical(other.aprobadoPor, aprobadoPor) ||
                other.aprobadoPor == aprobadoPor) &&
            (identical(other.entregadoPor, entregadoPor) ||
                other.entregadoPor == entregadoPor) &&
            (identical(other.observaciones, observaciones) ||
                other.observaciones == observaciones) &&
            (identical(other.motivoRechazo, motivoRechazo) ||
                other.motivoRechazo == motivoRechazo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    estado,
    usuario,
    const DeepCollectionEquality().hash(_detalles),
    fechaSolicitud,
    fechaRetiroSolicitada,
    fechaRetiroLimite,
    fechaPrestamo,
    fechaDevolucionEsperada,
    fechaDevolucionReal,
    aprobadoPor,
    entregadoPor,
    observaciones,
    motivoRechazo,
  );

  /// Create a copy of Prestamo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrestamoImplCopyWith<_$PrestamoImpl> get copyWith =>
      __$$PrestamoImplCopyWithImpl<_$PrestamoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrestamoImplToJson(this);
  }
}

abstract class _Prestamo extends Prestamo {
  const factory _Prestamo({
    required final String id,
    @JsonKey(unknownEnumValue: EstadoPrestamo.pendiente)
    required final EstadoPrestamo estado,
    required final UsuarioResumen usuario,
    required final List<PrestamoDetalle> detalles,
    @JsonKey(name: 'fecha_solicitud') required final DateTime fechaSolicitud,
    @JsonKey(name: 'fecha_retiro_solicitada')
    final DateTime? fechaRetiroSolicitada,
    @JsonKey(name: 'fecha_retiro_limite') final DateTime? fechaRetiroLimite,
    @JsonKey(name: 'fecha_prestamo') final DateTime? fechaPrestamo,
    @JsonKey(name: 'fecha_devolucion_esperada')
    final DateTime? fechaDevolucionEsperada,
    @JsonKey(name: 'fecha_devolucion_real') final DateTime? fechaDevolucionReal,
    @JsonKey(name: 'aprobado_por') final UsuarioResumen? aprobadoPor,
    @JsonKey(name: 'entregado_por') final UsuarioResumen? entregadoPor,
    final String? observaciones,
    @JsonKey(name: 'motivo_rechazo') final String? motivoRechazo,
  }) = _$PrestamoImpl;
  const _Prestamo._() : super._();

  factory _Prestamo.fromJson(Map<String, dynamic> json) =
      _$PrestamoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(unknownEnumValue: EstadoPrestamo.pendiente)
  EstadoPrestamo get estado;
  @override
  UsuarioResumen get usuario;
  @override
  List<PrestamoDetalle> get detalles;
  @override
  @JsonKey(name: 'fecha_solicitud')
  DateTime get fechaSolicitud;
  @override
  @JsonKey(name: 'fecha_retiro_solicitada')
  DateTime? get fechaRetiroSolicitada;
  @JsonKey(name: 'fecha_retiro_limite')
  DateTime? get fechaRetiroLimite;
  @override
  @JsonKey(name: 'fecha_prestamo')
  DateTime? get fechaPrestamo;
  @override
  @JsonKey(name: 'fecha_devolucion_esperada')
  DateTime? get fechaDevolucionEsperada;
  @override
  @JsonKey(name: 'fecha_devolucion_real')
  DateTime? get fechaDevolucionReal;
  @override
  @JsonKey(name: 'aprobado_por')
  UsuarioResumen? get aprobadoPor;
  @override
  @JsonKey(name: 'entregado_por')
  UsuarioResumen? get entregadoPor;
  @override
  String? get observaciones;
  @override
  @JsonKey(name: 'motivo_rechazo')
  String? get motivoRechazo;

  /// Create a copy of Prestamo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrestamoImplCopyWith<_$PrestamoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
