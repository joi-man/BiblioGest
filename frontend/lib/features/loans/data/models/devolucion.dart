import 'package:freezed_annotation/freezed_annotation.dart';

part 'devolucion.freezed.dart';
part 'devolucion.g.dart';

/// En qué condición llega un material al devolverse.
enum CondicionDevolucion {
  bueno,
  @JsonValue('dano_menor')
  danoMenor,
  @JsonValue('dano_mayor')
  danoMayor,
  perdido,
}

extension CondicionDevolucionEtiqueta on CondicionDevolucion {
  /// Valor que entiende el backend.
  String get valor => switch (this) {
    CondicionDevolucion.bueno => 'bueno',
    CondicionDevolucion.danoMenor => 'dano_menor',
    CondicionDevolucion.danoMayor => 'dano_mayor',
    CondicionDevolucion.perdido => 'perdido',
  };

  String get etiqueta => switch (this) {
    CondicionDevolucion.bueno => 'En buen estado',
    CondicionDevolucion.danoMenor => 'Daño menor',
    CondicionDevolucion.danoMayor => 'Daño mayor',
    CondicionDevolucion.perdido => 'Perdido',
  };
}

/// Registro de que un item de un préstamo ya fue devuelto.
@freezed
class Devolucion with _$Devolucion {
  const factory Devolucion({
    required String id,
    @JsonKey(name: 'prestamo_detalle_id') required String prestamoDetalleId,
    @JsonKey(name: 'fecha_devolucion') required DateTime fechaDevolucion,
    @JsonKey(unknownEnumValue: CondicionDevolucion.bueno)
    required CondicionDevolucion condicion,
    String? observaciones,
    @JsonKey(name: 'dias_retraso') @Default(0) int diasRetraso,

    /// Nulo cuando el sistema de multas está desactivado.
    @JsonKey(name: 'multa_monto') double? multaMonto,
  }) = _Devolucion;

  factory Devolucion.fromJson(Map<String, dynamic> json) =>
      _$DevolucionFromJson(json);
}
