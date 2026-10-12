import 'package:freezed_annotation/freezed_annotation.dart';
import 'devolucion.dart';
import 'material_resumen.dart';

part 'prestamo_detalle.freezed.dart';
part 'prestamo_detalle.g.dart';

/// Un material dentro de un préstamo, con su propia fecha límite.
@freezed
class PrestamoDetalle with _$PrestamoDetalle {
  const PrestamoDetalle._();

  const factory PrestamoDetalle({
    required String id,
    required MaterialResumen material,
    @JsonKey(name: 'fecha_devolucion_esperada')
    DateTime? fechaDevolucionEsperada,
    @Default(false) bool devuelto,
    Devolucion? devolucion,
  }) = _PrestamoDetalle;

  factory PrestamoDetalle.fromJson(Map<String, dynamic> json) =>
      _$PrestamoDetalleFromJson(json);

  /// Tiene fecha límite, no se devolvió y esa fecha ya pasó.
  bool estaVencido({DateTime? ahora}) {
    final limite = fechaDevolucionEsperada;
    if (devuelto || limite == null) return false;
    return limite.isBefore(ahora ?? DateTime.now());
  }
}
