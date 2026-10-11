// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resumen_dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ResumenMateriales _$ResumenMaterialesFromJson(Map<String, dynamic> json) {
  return _ResumenMateriales.fromJson(json);
}

/// @nodoc
mixin _$ResumenMateriales {
  int get total => throw _privateConstructorUsedError;
  int get disponibles => throw _privateConstructorUsedError;
  int get reservados => throw _privateConstructorUsedError;
  int get prestados => throw _privateConstructorUsedError;
  int get vencidos => throw _privateConstructorUsedError;
  @JsonKey(name: 'fuera_de_servicio')
  int get fueraDeServicio => throw _privateConstructorUsedError;

  /// Serializes this ResumenMateriales to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResumenMateriales
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResumenMaterialesCopyWith<ResumenMateriales> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResumenMaterialesCopyWith<$Res> {
  factory $ResumenMaterialesCopyWith(
    ResumenMateriales value,
    $Res Function(ResumenMateriales) then,
  ) = _$ResumenMaterialesCopyWithImpl<$Res, ResumenMateriales>;
  @useResult
  $Res call({
    int total,
    int disponibles,
    int reservados,
    int prestados,
    int vencidos,
    @JsonKey(name: 'fuera_de_servicio') int fueraDeServicio,
  });
}

/// @nodoc
class _$ResumenMaterialesCopyWithImpl<$Res, $Val extends ResumenMateriales>
    implements $ResumenMaterialesCopyWith<$Res> {
  _$ResumenMaterialesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResumenMateriales
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? disponibles = null,
    Object? reservados = null,
    Object? prestados = null,
    Object? vencidos = null,
    Object? fueraDeServicio = null,
  }) {
    return _then(
      _value.copyWith(
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            disponibles: null == disponibles
                ? _value.disponibles
                : disponibles // ignore: cast_nullable_to_non_nullable
                      as int,
            reservados: null == reservados
                ? _value.reservados
                : reservados // ignore: cast_nullable_to_non_nullable
                      as int,
            prestados: null == prestados
                ? _value.prestados
                : prestados // ignore: cast_nullable_to_non_nullable
                      as int,
            vencidos: null == vencidos
                ? _value.vencidos
                : vencidos // ignore: cast_nullable_to_non_nullable
                      as int,
            fueraDeServicio: null == fueraDeServicio
                ? _value.fueraDeServicio
                : fueraDeServicio // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResumenMaterialesImplCopyWith<$Res>
    implements $ResumenMaterialesCopyWith<$Res> {
  factory _$$ResumenMaterialesImplCopyWith(
    _$ResumenMaterialesImpl value,
    $Res Function(_$ResumenMaterialesImpl) then,
  ) = __$$ResumenMaterialesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int total,
    int disponibles,
    int reservados,
    int prestados,
    int vencidos,
    @JsonKey(name: 'fuera_de_servicio') int fueraDeServicio,
  });
}

/// @nodoc
class __$$ResumenMaterialesImplCopyWithImpl<$Res>
    extends _$ResumenMaterialesCopyWithImpl<$Res, _$ResumenMaterialesImpl>
    implements _$$ResumenMaterialesImplCopyWith<$Res> {
  __$$ResumenMaterialesImplCopyWithImpl(
    _$ResumenMaterialesImpl _value,
    $Res Function(_$ResumenMaterialesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResumenMateriales
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? disponibles = null,
    Object? reservados = null,
    Object? prestados = null,
    Object? vencidos = null,
    Object? fueraDeServicio = null,
  }) {
    return _then(
      _$ResumenMaterialesImpl(
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        disponibles: null == disponibles
            ? _value.disponibles
            : disponibles // ignore: cast_nullable_to_non_nullable
                  as int,
        reservados: null == reservados
            ? _value.reservados
            : reservados // ignore: cast_nullable_to_non_nullable
                  as int,
        prestados: null == prestados
            ? _value.prestados
            : prestados // ignore: cast_nullable_to_non_nullable
                  as int,
        vencidos: null == vencidos
            ? _value.vencidos
            : vencidos // ignore: cast_nullable_to_non_nullable
                  as int,
        fueraDeServicio: null == fueraDeServicio
            ? _value.fueraDeServicio
            : fueraDeServicio // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResumenMaterialesImpl implements _ResumenMateriales {
  const _$ResumenMaterialesImpl({
    required this.total,
    required this.disponibles,
    required this.reservados,
    required this.prestados,
    required this.vencidos,
    @JsonKey(name: 'fuera_de_servicio') required this.fueraDeServicio,
  });

  factory _$ResumenMaterialesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResumenMaterialesImplFromJson(json);

  @override
  final int total;
  @override
  final int disponibles;
  @override
  final int reservados;
  @override
  final int prestados;
  @override
  final int vencidos;
  @override
  @JsonKey(name: 'fuera_de_servicio')
  final int fueraDeServicio;

  @override
  String toString() {
    return 'ResumenMateriales(total: $total, disponibles: $disponibles, reservados: $reservados, prestados: $prestados, vencidos: $vencidos, fueraDeServicio: $fueraDeServicio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResumenMaterialesImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.disponibles, disponibles) ||
                other.disponibles == disponibles) &&
            (identical(other.reservados, reservados) ||
                other.reservados == reservados) &&
            (identical(other.prestados, prestados) ||
                other.prestados == prestados) &&
            (identical(other.vencidos, vencidos) ||
                other.vencidos == vencidos) &&
            (identical(other.fueraDeServicio, fueraDeServicio) ||
                other.fueraDeServicio == fueraDeServicio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    total,
    disponibles,
    reservados,
    prestados,
    vencidos,
    fueraDeServicio,
  );

  /// Create a copy of ResumenMateriales
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResumenMaterialesImplCopyWith<_$ResumenMaterialesImpl> get copyWith =>
      __$$ResumenMaterialesImplCopyWithImpl<_$ResumenMaterialesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ResumenMaterialesImplToJson(this);
  }
}

abstract class _ResumenMateriales implements ResumenMateriales {
  const factory _ResumenMateriales({
    required final int total,
    required final int disponibles,
    required final int reservados,
    required final int prestados,
    required final int vencidos,
    @JsonKey(name: 'fuera_de_servicio') required final int fueraDeServicio,
  }) = _$ResumenMaterialesImpl;

  factory _ResumenMateriales.fromJson(Map<String, dynamic> json) =
      _$ResumenMaterialesImpl.fromJson;

  @override
  int get total;
  @override
  int get disponibles;
  @override
  int get reservados;
  @override
  int get prestados;
  @override
  int get vencidos;
  @override
  @JsonKey(name: 'fuera_de_servicio')
  int get fueraDeServicio;

  /// Create a copy of ResumenMateriales
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResumenMaterialesImplCopyWith<_$ResumenMaterialesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResumenPrestamos _$ResumenPrestamosFromJson(Map<String, dynamic> json) {
  return _ResumenPrestamos.fromJson(json);
}

/// @nodoc
mixin _$ResumenPrestamos {
  @JsonKey(name: 'solicitudes_pendientes')
  int get solicitudesPendientes => throw _privateConstructorUsedError;
  @JsonKey(name: 'por_retirar')
  int get porRetirar => throw _privateConstructorUsedError;
  int get activos => throw _privateConstructorUsedError;
  int get vencidos => throw _privateConstructorUsedError;
  @JsonKey(name: 'por_vencer_24h')
  int get porVencer24h => throw _privateConstructorUsedError;
  @JsonKey(name: 'entregados_hoy')
  int get entregadosHoy => throw _privateConstructorUsedError;
  @JsonKey(name: 'devueltos_hoy')
  int get devueltosHoy => throw _privateConstructorUsedError;

  /// Serializes this ResumenPrestamos to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResumenPrestamos
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResumenPrestamosCopyWith<ResumenPrestamos> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResumenPrestamosCopyWith<$Res> {
  factory $ResumenPrestamosCopyWith(
    ResumenPrestamos value,
    $Res Function(ResumenPrestamos) then,
  ) = _$ResumenPrestamosCopyWithImpl<$Res, ResumenPrestamos>;
  @useResult
  $Res call({
    @JsonKey(name: 'solicitudes_pendientes') int solicitudesPendientes,
    @JsonKey(name: 'por_retirar') int porRetirar,
    int activos,
    int vencidos,
    @JsonKey(name: 'por_vencer_24h') int porVencer24h,
    @JsonKey(name: 'entregados_hoy') int entregadosHoy,
    @JsonKey(name: 'devueltos_hoy') int devueltosHoy,
  });
}

/// @nodoc
class _$ResumenPrestamosCopyWithImpl<$Res, $Val extends ResumenPrestamos>
    implements $ResumenPrestamosCopyWith<$Res> {
  _$ResumenPrestamosCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResumenPrestamos
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? solicitudesPendientes = null,
    Object? porRetirar = null,
    Object? activos = null,
    Object? vencidos = null,
    Object? porVencer24h = null,
    Object? entregadosHoy = null,
    Object? devueltosHoy = null,
  }) {
    return _then(
      _value.copyWith(
            solicitudesPendientes: null == solicitudesPendientes
                ? _value.solicitudesPendientes
                : solicitudesPendientes // ignore: cast_nullable_to_non_nullable
                      as int,
            porRetirar: null == porRetirar
                ? _value.porRetirar
                : porRetirar // ignore: cast_nullable_to_non_nullable
                      as int,
            activos: null == activos
                ? _value.activos
                : activos // ignore: cast_nullable_to_non_nullable
                      as int,
            vencidos: null == vencidos
                ? _value.vencidos
                : vencidos // ignore: cast_nullable_to_non_nullable
                      as int,
            porVencer24h: null == porVencer24h
                ? _value.porVencer24h
                : porVencer24h // ignore: cast_nullable_to_non_nullable
                      as int,
            entregadosHoy: null == entregadosHoy
                ? _value.entregadosHoy
                : entregadosHoy // ignore: cast_nullable_to_non_nullable
                      as int,
            devueltosHoy: null == devueltosHoy
                ? _value.devueltosHoy
                : devueltosHoy // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResumenPrestamosImplCopyWith<$Res>
    implements $ResumenPrestamosCopyWith<$Res> {
  factory _$$ResumenPrestamosImplCopyWith(
    _$ResumenPrestamosImpl value,
    $Res Function(_$ResumenPrestamosImpl) then,
  ) = __$$ResumenPrestamosImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'solicitudes_pendientes') int solicitudesPendientes,
    @JsonKey(name: 'por_retirar') int porRetirar,
    int activos,
    int vencidos,
    @JsonKey(name: 'por_vencer_24h') int porVencer24h,
    @JsonKey(name: 'entregados_hoy') int entregadosHoy,
    @JsonKey(name: 'devueltos_hoy') int devueltosHoy,
  });
}

/// @nodoc
class __$$ResumenPrestamosImplCopyWithImpl<$Res>
    extends _$ResumenPrestamosCopyWithImpl<$Res, _$ResumenPrestamosImpl>
    implements _$$ResumenPrestamosImplCopyWith<$Res> {
  __$$ResumenPrestamosImplCopyWithImpl(
    _$ResumenPrestamosImpl _value,
    $Res Function(_$ResumenPrestamosImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResumenPrestamos
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? solicitudesPendientes = null,
    Object? porRetirar = null,
    Object? activos = null,
    Object? vencidos = null,
    Object? porVencer24h = null,
    Object? entregadosHoy = null,
    Object? devueltosHoy = null,
  }) {
    return _then(
      _$ResumenPrestamosImpl(
        solicitudesPendientes: null == solicitudesPendientes
            ? _value.solicitudesPendientes
            : solicitudesPendientes // ignore: cast_nullable_to_non_nullable
                  as int,
        porRetirar: null == porRetirar
            ? _value.porRetirar
            : porRetirar // ignore: cast_nullable_to_non_nullable
                  as int,
        activos: null == activos
            ? _value.activos
            : activos // ignore: cast_nullable_to_non_nullable
                  as int,
        vencidos: null == vencidos
            ? _value.vencidos
            : vencidos // ignore: cast_nullable_to_non_nullable
                  as int,
        porVencer24h: null == porVencer24h
            ? _value.porVencer24h
            : porVencer24h // ignore: cast_nullable_to_non_nullable
                  as int,
        entregadosHoy: null == entregadosHoy
            ? _value.entregadosHoy
            : entregadosHoy // ignore: cast_nullable_to_non_nullable
                  as int,
        devueltosHoy: null == devueltosHoy
            ? _value.devueltosHoy
            : devueltosHoy // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResumenPrestamosImpl implements _ResumenPrestamos {
  const _$ResumenPrestamosImpl({
    @JsonKey(name: 'solicitudes_pendientes')
    required this.solicitudesPendientes,
    @JsonKey(name: 'por_retirar') required this.porRetirar,
    required this.activos,
    required this.vencidos,
    @JsonKey(name: 'por_vencer_24h') required this.porVencer24h,
    @JsonKey(name: 'entregados_hoy') required this.entregadosHoy,
    @JsonKey(name: 'devueltos_hoy') required this.devueltosHoy,
  });

  factory _$ResumenPrestamosImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResumenPrestamosImplFromJson(json);

  @override
  @JsonKey(name: 'solicitudes_pendientes')
  final int solicitudesPendientes;
  @override
  @JsonKey(name: 'por_retirar')
  final int porRetirar;
  @override
  final int activos;
  @override
  final int vencidos;
  @override
  @JsonKey(name: 'por_vencer_24h')
  final int porVencer24h;
  @override
  @JsonKey(name: 'entregados_hoy')
  final int entregadosHoy;
  @override
  @JsonKey(name: 'devueltos_hoy')
  final int devueltosHoy;

  @override
  String toString() {
    return 'ResumenPrestamos(solicitudesPendientes: $solicitudesPendientes, porRetirar: $porRetirar, activos: $activos, vencidos: $vencidos, porVencer24h: $porVencer24h, entregadosHoy: $entregadosHoy, devueltosHoy: $devueltosHoy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResumenPrestamosImpl &&
            (identical(other.solicitudesPendientes, solicitudesPendientes) ||
                other.solicitudesPendientes == solicitudesPendientes) &&
            (identical(other.porRetirar, porRetirar) ||
                other.porRetirar == porRetirar) &&
            (identical(other.activos, activos) || other.activos == activos) &&
            (identical(other.vencidos, vencidos) ||
                other.vencidos == vencidos) &&
            (identical(other.porVencer24h, porVencer24h) ||
                other.porVencer24h == porVencer24h) &&
            (identical(other.entregadosHoy, entregadosHoy) ||
                other.entregadosHoy == entregadosHoy) &&
            (identical(other.devueltosHoy, devueltosHoy) ||
                other.devueltosHoy == devueltosHoy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    solicitudesPendientes,
    porRetirar,
    activos,
    vencidos,
    porVencer24h,
    entregadosHoy,
    devueltosHoy,
  );

  /// Create a copy of ResumenPrestamos
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResumenPrestamosImplCopyWith<_$ResumenPrestamosImpl> get copyWith =>
      __$$ResumenPrestamosImplCopyWithImpl<_$ResumenPrestamosImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ResumenPrestamosImplToJson(this);
  }
}

abstract class _ResumenPrestamos implements ResumenPrestamos {
  const factory _ResumenPrestamos({
    @JsonKey(name: 'solicitudes_pendientes')
    required final int solicitudesPendientes,
    @JsonKey(name: 'por_retirar') required final int porRetirar,
    required final int activos,
    required final int vencidos,
    @JsonKey(name: 'por_vencer_24h') required final int porVencer24h,
    @JsonKey(name: 'entregados_hoy') required final int entregadosHoy,
    @JsonKey(name: 'devueltos_hoy') required final int devueltosHoy,
  }) = _$ResumenPrestamosImpl;

  factory _ResumenPrestamos.fromJson(Map<String, dynamic> json) =
      _$ResumenPrestamosImpl.fromJson;

  @override
  @JsonKey(name: 'solicitudes_pendientes')
  int get solicitudesPendientes;
  @override
  @JsonKey(name: 'por_retirar')
  int get porRetirar;
  @override
  int get activos;
  @override
  int get vencidos;
  @override
  @JsonKey(name: 'por_vencer_24h')
  int get porVencer24h;
  @override
  @JsonKey(name: 'entregados_hoy')
  int get entregadosHoy;
  @override
  @JsonKey(name: 'devueltos_hoy')
  int get devueltosHoy;

  /// Create a copy of ResumenPrestamos
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResumenPrestamosImplCopyWith<_$ResumenPrestamosImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResumenDashboard _$ResumenDashboardFromJson(Map<String, dynamic> json) {
  return _ResumenDashboard.fromJson(json);
}

/// @nodoc
mixin _$ResumenDashboard {
  ResumenMateriales get materiales => throw _privateConstructorUsedError;
  ResumenPrestamos get prestamos => throw _privateConstructorUsedError;

  /// Serializes this ResumenDashboard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResumenDashboard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResumenDashboardCopyWith<ResumenDashboard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResumenDashboardCopyWith<$Res> {
  factory $ResumenDashboardCopyWith(
    ResumenDashboard value,
    $Res Function(ResumenDashboard) then,
  ) = _$ResumenDashboardCopyWithImpl<$Res, ResumenDashboard>;
  @useResult
  $Res call({ResumenMateriales materiales, ResumenPrestamos prestamos});

  $ResumenMaterialesCopyWith<$Res> get materiales;
  $ResumenPrestamosCopyWith<$Res> get prestamos;
}

/// @nodoc
class _$ResumenDashboardCopyWithImpl<$Res, $Val extends ResumenDashboard>
    implements $ResumenDashboardCopyWith<$Res> {
  _$ResumenDashboardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResumenDashboard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? materiales = null, Object? prestamos = null}) {
    return _then(
      _value.copyWith(
            materiales: null == materiales
                ? _value.materiales
                : materiales // ignore: cast_nullable_to_non_nullable
                      as ResumenMateriales,
            prestamos: null == prestamos
                ? _value.prestamos
                : prestamos // ignore: cast_nullable_to_non_nullable
                      as ResumenPrestamos,
          )
          as $Val,
    );
  }

  /// Create a copy of ResumenDashboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ResumenMaterialesCopyWith<$Res> get materiales {
    return $ResumenMaterialesCopyWith<$Res>(_value.materiales, (value) {
      return _then(_value.copyWith(materiales: value) as $Val);
    });
  }

  /// Create a copy of ResumenDashboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ResumenPrestamosCopyWith<$Res> get prestamos {
    return $ResumenPrestamosCopyWith<$Res>(_value.prestamos, (value) {
      return _then(_value.copyWith(prestamos: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ResumenDashboardImplCopyWith<$Res>
    implements $ResumenDashboardCopyWith<$Res> {
  factory _$$ResumenDashboardImplCopyWith(
    _$ResumenDashboardImpl value,
    $Res Function(_$ResumenDashboardImpl) then,
  ) = __$$ResumenDashboardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ResumenMateriales materiales, ResumenPrestamos prestamos});

  @override
  $ResumenMaterialesCopyWith<$Res> get materiales;
  @override
  $ResumenPrestamosCopyWith<$Res> get prestamos;
}

/// @nodoc
class __$$ResumenDashboardImplCopyWithImpl<$Res>
    extends _$ResumenDashboardCopyWithImpl<$Res, _$ResumenDashboardImpl>
    implements _$$ResumenDashboardImplCopyWith<$Res> {
  __$$ResumenDashboardImplCopyWithImpl(
    _$ResumenDashboardImpl _value,
    $Res Function(_$ResumenDashboardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResumenDashboard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? materiales = null, Object? prestamos = null}) {
    return _then(
      _$ResumenDashboardImpl(
        materiales: null == materiales
            ? _value.materiales
            : materiales // ignore: cast_nullable_to_non_nullable
                  as ResumenMateriales,
        prestamos: null == prestamos
            ? _value.prestamos
            : prestamos // ignore: cast_nullable_to_non_nullable
                  as ResumenPrestamos,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResumenDashboardImpl implements _ResumenDashboard {
  const _$ResumenDashboardImpl({
    required this.materiales,
    required this.prestamos,
  });

  factory _$ResumenDashboardImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResumenDashboardImplFromJson(json);

  @override
  final ResumenMateriales materiales;
  @override
  final ResumenPrestamos prestamos;

  @override
  String toString() {
    return 'ResumenDashboard(materiales: $materiales, prestamos: $prestamos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResumenDashboardImpl &&
            (identical(other.materiales, materiales) ||
                other.materiales == materiales) &&
            (identical(other.prestamos, prestamos) ||
                other.prestamos == prestamos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, materiales, prestamos);

  /// Create a copy of ResumenDashboard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResumenDashboardImplCopyWith<_$ResumenDashboardImpl> get copyWith =>
      __$$ResumenDashboardImplCopyWithImpl<_$ResumenDashboardImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ResumenDashboardImplToJson(this);
  }
}

abstract class _ResumenDashboard implements ResumenDashboard {
  const factory _ResumenDashboard({
    required final ResumenMateriales materiales,
    required final ResumenPrestamos prestamos,
  }) = _$ResumenDashboardImpl;

  factory _ResumenDashboard.fromJson(Map<String, dynamic> json) =
      _$ResumenDashboardImpl.fromJson;

  @override
  ResumenMateriales get materiales;
  @override
  ResumenPrestamos get prestamos;

  /// Create a copy of ResumenDashboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResumenDashboardImplCopyWith<_$ResumenDashboardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
