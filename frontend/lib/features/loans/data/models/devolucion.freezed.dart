// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'devolucion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Devolucion _$DevolucionFromJson(Map<String, dynamic> json) {
  return _Devolucion.fromJson(json);
}

/// @nodoc
mixin _$Devolucion {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'prestamo_detalle_id')
  String get prestamoDetalleId => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_devolucion')
  DateTime get fechaDevolucion => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: CondicionDevolucion.bueno)
  CondicionDevolucion get condicion => throw _privateConstructorUsedError;
  String? get observaciones => throw _privateConstructorUsedError;
  @JsonKey(name: 'dias_retraso')
  int get diasRetraso => throw _privateConstructorUsedError;

  /// Nulo cuando el sistema de multas está desactivado.
  @JsonKey(name: 'multa_monto')
  double? get multaMonto => throw _privateConstructorUsedError;

  /// Serializes this Devolucion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Devolucion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DevolucionCopyWith<Devolucion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DevolucionCopyWith<$Res> {
  factory $DevolucionCopyWith(
    Devolucion value,
    $Res Function(Devolucion) then,
  ) = _$DevolucionCopyWithImpl<$Res, Devolucion>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'prestamo_detalle_id') String prestamoDetalleId,
    @JsonKey(name: 'fecha_devolucion') DateTime fechaDevolucion,
    @JsonKey(unknownEnumValue: CondicionDevolucion.bueno)
    CondicionDevolucion condicion,
    String? observaciones,
    @JsonKey(name: 'dias_retraso') int diasRetraso,
    @JsonKey(name: 'multa_monto') double? multaMonto,
  });
}

/// @nodoc
class _$DevolucionCopyWithImpl<$Res, $Val extends Devolucion>
    implements $DevolucionCopyWith<$Res> {
  _$DevolucionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Devolucion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? prestamoDetalleId = null,
    Object? fechaDevolucion = null,
    Object? condicion = null,
    Object? observaciones = freezed,
    Object? diasRetraso = null,
    Object? multaMonto = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            prestamoDetalleId: null == prestamoDetalleId
                ? _value.prestamoDetalleId
                : prestamoDetalleId // ignore: cast_nullable_to_non_nullable
                      as String,
            fechaDevolucion: null == fechaDevolucion
                ? _value.fechaDevolucion
                : fechaDevolucion // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            condicion: null == condicion
                ? _value.condicion
                : condicion // ignore: cast_nullable_to_non_nullable
                      as CondicionDevolucion,
            observaciones: freezed == observaciones
                ? _value.observaciones
                : observaciones // ignore: cast_nullable_to_non_nullable
                      as String?,
            diasRetraso: null == diasRetraso
                ? _value.diasRetraso
                : diasRetraso // ignore: cast_nullable_to_non_nullable
                      as int,
            multaMonto: freezed == multaMonto
                ? _value.multaMonto
                : multaMonto // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DevolucionImplCopyWith<$Res>
    implements $DevolucionCopyWith<$Res> {
  factory _$$DevolucionImplCopyWith(
    _$DevolucionImpl value,
    $Res Function(_$DevolucionImpl) then,
  ) = __$$DevolucionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'prestamo_detalle_id') String prestamoDetalleId,
    @JsonKey(name: 'fecha_devolucion') DateTime fechaDevolucion,
    @JsonKey(unknownEnumValue: CondicionDevolucion.bueno)
    CondicionDevolucion condicion,
    String? observaciones,
    @JsonKey(name: 'dias_retraso') int diasRetraso,
    @JsonKey(name: 'multa_monto') double? multaMonto,
  });
}

/// @nodoc
class __$$DevolucionImplCopyWithImpl<$Res>
    extends _$DevolucionCopyWithImpl<$Res, _$DevolucionImpl>
    implements _$$DevolucionImplCopyWith<$Res> {
  __$$DevolucionImplCopyWithImpl(
    _$DevolucionImpl _value,
    $Res Function(_$DevolucionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Devolucion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? prestamoDetalleId = null,
    Object? fechaDevolucion = null,
    Object? condicion = null,
    Object? observaciones = freezed,
    Object? diasRetraso = null,
    Object? multaMonto = freezed,
  }) {
    return _then(
      _$DevolucionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        prestamoDetalleId: null == prestamoDetalleId
            ? _value.prestamoDetalleId
            : prestamoDetalleId // ignore: cast_nullable_to_non_nullable
                  as String,
        fechaDevolucion: null == fechaDevolucion
            ? _value.fechaDevolucion
            : fechaDevolucion // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        condicion: null == condicion
            ? _value.condicion
            : condicion // ignore: cast_nullable_to_non_nullable
                  as CondicionDevolucion,
        observaciones: freezed == observaciones
            ? _value.observaciones
            : observaciones // ignore: cast_nullable_to_non_nullable
                  as String?,
        diasRetraso: null == diasRetraso
            ? _value.diasRetraso
            : diasRetraso // ignore: cast_nullable_to_non_nullable
                  as int,
        multaMonto: freezed == multaMonto
            ? _value.multaMonto
            : multaMonto // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DevolucionImpl implements _Devolucion {
  const _$DevolucionImpl({
    required this.id,
    @JsonKey(name: 'prestamo_detalle_id') required this.prestamoDetalleId,
    @JsonKey(name: 'fecha_devolucion') required this.fechaDevolucion,
    @JsonKey(unknownEnumValue: CondicionDevolucion.bueno)
    required this.condicion,
    this.observaciones,
    @JsonKey(name: 'dias_retraso') this.diasRetraso = 0,
    @JsonKey(name: 'multa_monto') this.multaMonto,
  });

  factory _$DevolucionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DevolucionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'prestamo_detalle_id')
  final String prestamoDetalleId;
  @override
  @JsonKey(name: 'fecha_devolucion')
  final DateTime fechaDevolucion;
  @override
  @JsonKey(unknownEnumValue: CondicionDevolucion.bueno)
  final CondicionDevolucion condicion;
  @override
  final String? observaciones;
  @override
  @JsonKey(name: 'dias_retraso')
  final int diasRetraso;

  /// Nulo cuando el sistema de multas está desactivado.
  @override
  @JsonKey(name: 'multa_monto')
  final double? multaMonto;

  @override
  String toString() {
    return 'Devolucion(id: $id, prestamoDetalleId: $prestamoDetalleId, fechaDevolucion: $fechaDevolucion, condicion: $condicion, observaciones: $observaciones, diasRetraso: $diasRetraso, multaMonto: $multaMonto)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DevolucionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.prestamoDetalleId, prestamoDetalleId) ||
                other.prestamoDetalleId == prestamoDetalleId) &&
            (identical(other.fechaDevolucion, fechaDevolucion) ||
                other.fechaDevolucion == fechaDevolucion) &&
            (identical(other.condicion, condicion) ||
                other.condicion == condicion) &&
            (identical(other.observaciones, observaciones) ||
                other.observaciones == observaciones) &&
            (identical(other.diasRetraso, diasRetraso) ||
                other.diasRetraso == diasRetraso) &&
            (identical(other.multaMonto, multaMonto) ||
                other.multaMonto == multaMonto));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    prestamoDetalleId,
    fechaDevolucion,
    condicion,
    observaciones,
    diasRetraso,
    multaMonto,
  );

  /// Create a copy of Devolucion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DevolucionImplCopyWith<_$DevolucionImpl> get copyWith =>
      __$$DevolucionImplCopyWithImpl<_$DevolucionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DevolucionImplToJson(this);
  }
}

abstract class _Devolucion implements Devolucion {
  const factory _Devolucion({
    required final String id,
    @JsonKey(name: 'prestamo_detalle_id')
    required final String prestamoDetalleId,
    @JsonKey(name: 'fecha_devolucion') required final DateTime fechaDevolucion,
    @JsonKey(unknownEnumValue: CondicionDevolucion.bueno)
    required final CondicionDevolucion condicion,
    final String? observaciones,
    @JsonKey(name: 'dias_retraso') final int diasRetraso,
    @JsonKey(name: 'multa_monto') final double? multaMonto,
  }) = _$DevolucionImpl;

  factory _Devolucion.fromJson(Map<String, dynamic> json) =
      _$DevolucionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'prestamo_detalle_id')
  String get prestamoDetalleId;
  @override
  @JsonKey(name: 'fecha_devolucion')
  DateTime get fechaDevolucion;
  @override
  @JsonKey(unknownEnumValue: CondicionDevolucion.bueno)
  CondicionDevolucion get condicion;
  @override
  String? get observaciones;
  @override
  @JsonKey(name: 'dias_retraso')
  int get diasRetraso;

  /// Nulo cuando el sistema de multas está desactivado.
  @override
  @JsonKey(name: 'multa_monto')
  double? get multaMonto;

  /// Create a copy of Devolucion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DevolucionImplCopyWith<_$DevolucionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
