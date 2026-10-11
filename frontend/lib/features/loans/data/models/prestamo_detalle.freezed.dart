// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prestamo_detalle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PrestamoDetalle _$PrestamoDetalleFromJson(Map<String, dynamic> json) {
  return _PrestamoDetalle.fromJson(json);
}

/// @nodoc
mixin _$PrestamoDetalle {
  String get id => throw _privateConstructorUsedError;
  MaterialResumen get material => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_devolucion_esperada')
  DateTime? get fechaDevolucionEsperada => throw _privateConstructorUsedError;
  bool get devuelto => throw _privateConstructorUsedError;
  Devolucion? get devolucion => throw _privateConstructorUsedError;

  /// Serializes this PrestamoDetalle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrestamoDetalle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrestamoDetalleCopyWith<PrestamoDetalle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrestamoDetalleCopyWith<$Res> {
  factory $PrestamoDetalleCopyWith(
    PrestamoDetalle value,
    $Res Function(PrestamoDetalle) then,
  ) = _$PrestamoDetalleCopyWithImpl<$Res, PrestamoDetalle>;
  @useResult
  $Res call({
    String id,
    MaterialResumen material,
    @JsonKey(name: 'fecha_devolucion_esperada')
    DateTime? fechaDevolucionEsperada,
    bool devuelto,
    Devolucion? devolucion,
  });

  $MaterialResumenCopyWith<$Res> get material;
  $DevolucionCopyWith<$Res>? get devolucion;
}

/// @nodoc
class _$PrestamoDetalleCopyWithImpl<$Res, $Val extends PrestamoDetalle>
    implements $PrestamoDetalleCopyWith<$Res> {
  _$PrestamoDetalleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrestamoDetalle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? material = null,
    Object? fechaDevolucionEsperada = freezed,
    Object? devuelto = null,
    Object? devolucion = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            material: null == material
                ? _value.material
                : material // ignore: cast_nullable_to_non_nullable
                      as MaterialResumen,
            fechaDevolucionEsperada: freezed == fechaDevolucionEsperada
                ? _value.fechaDevolucionEsperada
                : fechaDevolucionEsperada // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            devuelto: null == devuelto
                ? _value.devuelto
                : devuelto // ignore: cast_nullable_to_non_nullable
                      as bool,
            devolucion: freezed == devolucion
                ? _value.devolucion
                : devolucion // ignore: cast_nullable_to_non_nullable
                      as Devolucion?,
          )
          as $Val,
    );
  }

  /// Create a copy of PrestamoDetalle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MaterialResumenCopyWith<$Res> get material {
    return $MaterialResumenCopyWith<$Res>(_value.material, (value) {
      return _then(_value.copyWith(material: value) as $Val);
    });
  }

  /// Create a copy of PrestamoDetalle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DevolucionCopyWith<$Res>? get devolucion {
    if (_value.devolucion == null) {
      return null;
    }

    return $DevolucionCopyWith<$Res>(_value.devolucion!, (value) {
      return _then(_value.copyWith(devolucion: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PrestamoDetalleImplCopyWith<$Res>
    implements $PrestamoDetalleCopyWith<$Res> {
  factory _$$PrestamoDetalleImplCopyWith(
    _$PrestamoDetalleImpl value,
    $Res Function(_$PrestamoDetalleImpl) then,
  ) = __$$PrestamoDetalleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    MaterialResumen material,
    @JsonKey(name: 'fecha_devolucion_esperada')
    DateTime? fechaDevolucionEsperada,
    bool devuelto,
    Devolucion? devolucion,
  });

  @override
  $MaterialResumenCopyWith<$Res> get material;
  @override
  $DevolucionCopyWith<$Res>? get devolucion;
}

/// @nodoc
class __$$PrestamoDetalleImplCopyWithImpl<$Res>
    extends _$PrestamoDetalleCopyWithImpl<$Res, _$PrestamoDetalleImpl>
    implements _$$PrestamoDetalleImplCopyWith<$Res> {
  __$$PrestamoDetalleImplCopyWithImpl(
    _$PrestamoDetalleImpl _value,
    $Res Function(_$PrestamoDetalleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PrestamoDetalle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? material = null,
    Object? fechaDevolucionEsperada = freezed,
    Object? devuelto = null,
    Object? devolucion = freezed,
  }) {
    return _then(
      _$PrestamoDetalleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        material: null == material
            ? _value.material
            : material // ignore: cast_nullable_to_non_nullable
                  as MaterialResumen,
        fechaDevolucionEsperada: freezed == fechaDevolucionEsperada
            ? _value.fechaDevolucionEsperada
            : fechaDevolucionEsperada // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        devuelto: null == devuelto
            ? _value.devuelto
            : devuelto // ignore: cast_nullable_to_non_nullable
                  as bool,
        devolucion: freezed == devolucion
            ? _value.devolucion
            : devolucion // ignore: cast_nullable_to_non_nullable
                  as Devolucion?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrestamoDetalleImpl extends _PrestamoDetalle {
  const _$PrestamoDetalleImpl({
    required this.id,
    required this.material,
    @JsonKey(name: 'fecha_devolucion_esperada') this.fechaDevolucionEsperada,
    this.devuelto = false,
    this.devolucion,
  }) : super._();

  factory _$PrestamoDetalleImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrestamoDetalleImplFromJson(json);

  @override
  final String id;
  @override
  final MaterialResumen material;
  @override
  @JsonKey(name: 'fecha_devolucion_esperada')
  final DateTime? fechaDevolucionEsperada;
  @override
  @JsonKey()
  final bool devuelto;
  @override
  final Devolucion? devolucion;

  @override
  String toString() {
    return 'PrestamoDetalle(id: $id, material: $material, fechaDevolucionEsperada: $fechaDevolucionEsperada, devuelto: $devuelto, devolucion: $devolucion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrestamoDetalleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(
                  other.fechaDevolucionEsperada,
                  fechaDevolucionEsperada,
                ) ||
                other.fechaDevolucionEsperada == fechaDevolucionEsperada) &&
            (identical(other.devuelto, devuelto) ||
                other.devuelto == devuelto) &&
            (identical(other.devolucion, devolucion) ||
                other.devolucion == devolucion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    material,
    fechaDevolucionEsperada,
    devuelto,
    devolucion,
  );

  /// Create a copy of PrestamoDetalle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrestamoDetalleImplCopyWith<_$PrestamoDetalleImpl> get copyWith =>
      __$$PrestamoDetalleImplCopyWithImpl<_$PrestamoDetalleImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PrestamoDetalleImplToJson(this);
  }
}

abstract class _PrestamoDetalle extends PrestamoDetalle {
  const factory _PrestamoDetalle({
    required final String id,
    required final MaterialResumen material,
    @JsonKey(name: 'fecha_devolucion_esperada')
    final DateTime? fechaDevolucionEsperada,
    final bool devuelto,
    final Devolucion? devolucion,
  }) = _$PrestamoDetalleImpl;
  const _PrestamoDetalle._() : super._();

  factory _PrestamoDetalle.fromJson(Map<String, dynamic> json) =
      _$PrestamoDetalleImpl.fromJson;

  @override
  String get id;
  @override
  MaterialResumen get material;
  @override
  @JsonKey(name: 'fecha_devolucion_esperada')
  DateTime? get fechaDevolucionEsperada;
  @override
  bool get devuelto;
  @override
  Devolucion? get devolucion;

  /// Create a copy of PrestamoDetalle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrestamoDetalleImplCopyWith<_$PrestamoDetalleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
