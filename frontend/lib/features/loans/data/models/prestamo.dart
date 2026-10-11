import 'package:freezed_annotation/freezed_annotation.dart';
import 'prestamo_detalle.dart';
import 'usuario_resumen.dart';

part 'prestamo.freezed.dart';
part 'prestamo.g.dart';

/// Estado de un préstamo a lo largo de su ciclo de vida.
enum EstadoPrestamo {
  pendiente,
  aprobado,
  rechazado,
  cancelado,
  activo,
  vencido,
  devuelto,
}

extension EstadoPrestamoValor on EstadoPrestamo {
  /// Valor que entiende el backend.
  String get valor => name;
}

/// Solicitud o préstamo de uno o varios materiales para una persona.
@freezed
class Prestamo with _$Prestamo {
  const Prestamo._();

  const factory Prestamo({
    required String id,
    @JsonKey(unknownEnumValue: EstadoPrestamo.pendiente)
    required EstadoPrestamo estado,
    required UsuarioResumen usuario,
    required List<PrestamoDetalle> detalles,
    @JsonKey(name: 'fecha_solicitud') required DateTime fechaSolicitud,
    @JsonKey(name: 'fecha_retiro_limite') DateTime? fechaRetiroLimite,
    @JsonKey(name: 'fecha_prestamo') DateTime? fechaPrestamo,
    @JsonKey(name: 'fecha_devolucion_esperada') DateTime? fechaDevolucionEsperada,
    @JsonKey(name: 'fecha_devolucion_real') DateTime? fechaDevolucionReal,
    @JsonKey(name: 'aprobado_por') UsuarioResumen? aprobadoPor,
    @JsonKey(name: 'entregado_por') UsuarioResumen? entregadoPor,
    String? observaciones,
    @JsonKey(name: 'motivo_rechazo') String? motivoRechazo,
  }) = _Prestamo;

  factory Prestamo.fromJson(Map<String, dynamic> json) =>
      _$PrestamoFromJson(json);

  /// Items que aún no se devolvieron.
  List<PrestamoDetalle> get itemsPendientes =>
      detalles.where((d) => !d.devuelto).toList();

  /// Los títulos de los materiales separados por coma, para mostrar en una línea.
  String get resumenMateriales => detalles.map((d) => d.material.titulo).join(', ');
}
