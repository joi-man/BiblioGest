// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'material_resumen.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MaterialResumen _$MaterialResumenFromJson(Map<String, dynamic> json) {
  return _MaterialResumen.fromJson(json);
}

/// @nodoc
mixin _$MaterialResumen {
  String get id => throw _privateConstructorUsedError;
  String get codigo => throw _privateConstructorUsedError;
  String get titulo => throw _privateConstructorUsedError;
  @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
  TipoMaterial get tipoMaterial => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: EstadoMaterial.disponible)
  EstadoMaterial get estado => throw _privateConstructorUsedError;
  String? get ubicacion => throw _privateConstructorUsedError;

  /// Solo en obras de varios tomos.
  String? get tomo => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_tomos')
  int? get totalTomos => throw _privateConstructorUsedError;

  /// Serializes this MaterialResumen to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MaterialResumen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaterialResumenCopyWith<MaterialResumen> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaterialResumenCopyWith<$Res> {
  factory $MaterialResumenCopyWith(
    MaterialResumen value,
    $Res Function(MaterialResumen) then,
  ) = _$MaterialResumenCopyWithImpl<$Res, MaterialResumen>;
  @useResult
  $Res call({
    String id,
    String codigo,
    String titulo,
    @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
    TipoMaterial tipoMaterial,
    @JsonKey(unknownEnumValue: EstadoMaterial.disponible) EstadoMaterial estado,
    String? ubicacion,
    String? tomo,
    @JsonKey(name: 'total_tomos') int? totalTomos,
  });
}

/// @nodoc
class _$MaterialResumenCopyWithImpl<$Res, $Val extends MaterialResumen>
    implements $MaterialResumenCopyWith<$Res> {
  _$MaterialResumenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MaterialResumen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? titulo = null,
    Object? tipoMaterial = null,
    Object? estado = null,
    Object? ubicacion = freezed,
    Object? tomo = freezed,
    Object? totalTomos = freezed,
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
            ubicacion: freezed == ubicacion
                ? _value.ubicacion
                : ubicacion // ignore: cast_nullable_to_non_nullable
                      as String?,
            tomo: freezed == tomo
                ? _value.tomo
                : tomo // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalTomos: freezed == totalTomos
                ? _value.totalTomos
                : totalTomos // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MaterialResumenImplCopyWith<$Res>
    implements $MaterialResumenCopyWith<$Res> {
  factory _$$MaterialResumenImplCopyWith(
    _$MaterialResumenImpl value,
    $Res Function(_$MaterialResumenImpl) then,
  ) = __$$MaterialResumenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String codigo,
    String titulo,
    @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
    TipoMaterial tipoMaterial,
    @JsonKey(unknownEnumValue: EstadoMaterial.disponible) EstadoMaterial estado,
    String? ubicacion,
    String? tomo,
    @JsonKey(name: 'total_tomos') int? totalTomos,
  });
}

/// @nodoc
class __$$MaterialResumenImplCopyWithImpl<$Res>
    extends _$MaterialResumenCopyWithImpl<$Res, _$MaterialResumenImpl>
    implements _$$MaterialResumenImplCopyWith<$Res> {
  __$$MaterialResumenImplCopyWithImpl(
    _$MaterialResumenImpl _value,
    $Res Function(_$MaterialResumenImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MaterialResumen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? titulo = null,
    Object? tipoMaterial = null,
    Object? estado = null,
    Object? ubicacion = freezed,
    Object? tomo = freezed,
    Object? totalTomos = freezed,
  }) {
    return _then(
      _$MaterialResumenImpl(
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
        ubicacion: freezed == ubicacion
            ? _value.ubicacion
            : ubicacion // ignore: cast_nullable_to_non_nullable
                  as String?,
        tomo: freezed == tomo
            ? _value.tomo
            : tomo // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalTomos: freezed == totalTomos
            ? _value.totalTomos
            : totalTomos // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MaterialResumenImpl implements _MaterialResumen {
  const _$MaterialResumenImpl({
    required this.id,
    required this.codigo,
    required this.titulo,
    @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
    required this.tipoMaterial,
    @JsonKey(unknownEnumValue: EstadoMaterial.disponible) required this.estado,
    this.ubicacion,
    this.tomo,
    @JsonKey(name: 'total_tomos') this.totalTomos,
  });

  factory _$MaterialResumenImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaterialResumenImplFromJson(json);

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
  final String? ubicacion;

  /// Solo en obras de varios tomos.
  @override
  final String? tomo;
  @override
  @JsonKey(name: 'total_tomos')
  final int? totalTomos;

  @override
  String toString() {
    return 'MaterialResumen(id: $id, codigo: $codigo, titulo: $titulo, tipoMaterial: $tipoMaterial, estado: $estado, ubicacion: $ubicacion, tomo: $tomo, totalTomos: $totalTomos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaterialResumenImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.tipoMaterial, tipoMaterial) ||
                other.tipoMaterial == tipoMaterial) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.ubicacion, ubicacion) ||
                other.ubicacion == ubicacion) &&
            (identical(other.tomo, tomo) || other.tomo == tomo) &&
            (identical(other.totalTomos, totalTomos) ||
                other.totalTomos == totalTomos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    codigo,
    titulo,
    tipoMaterial,
    estado,
    ubicacion,
    tomo,
    totalTomos,
  );

  /// Create a copy of MaterialResumen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaterialResumenImplCopyWith<_$MaterialResumenImpl> get copyWith =>
      __$$MaterialResumenImplCopyWithImpl<_$MaterialResumenImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MaterialResumenImplToJson(this);
  }
}

abstract class _MaterialResumen implements MaterialResumen {
  const factory _MaterialResumen({
    required final String id,
    required final String codigo,
    required final String titulo,
    @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
    required final TipoMaterial tipoMaterial,
    @JsonKey(unknownEnumValue: EstadoMaterial.disponible)
    required final EstadoMaterial estado,
    final String? ubicacion,
    final String? tomo,
    @JsonKey(name: 'total_tomos') final int? totalTomos,
  }) = _$MaterialResumenImpl;

  factory _MaterialResumen.fromJson(Map<String, dynamic> json) =
      _$MaterialResumenImpl.fromJson;

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
  String? get ubicacion;

  /// Solo en obras de varios tomos.
  @override
  String? get tomo;
  @override
  @JsonKey(name: 'total_tomos')
  int? get totalTomos;

  /// Create a copy of MaterialResumen
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaterialResumenImplCopyWith<_$MaterialResumenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
