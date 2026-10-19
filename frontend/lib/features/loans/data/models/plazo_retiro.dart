import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/loans/data/models/plazo_devolucion.dart';

/// Reglas de la fecha y hora en que una persona dice que pasará a retirar lo que reservó.
///
/// El servidor aplica las mismas reglas; se repiten aquí para avisar con un
/// mensaje claro antes de enviar la reserva.
class PlazoRetiro {
  PlazoRetiro._();

  /// Con cuántos días de anticipación se puede reservar.
  static const maxDiasAnticipacion = 7;

  /// Hora que se propone al abrir la ventana (mañana a las 9:00, hora de Paraguay).
  static const horaPropuesta = 9;

  /// Mensaje si [retiro] no es válido, o `null` si lo es.
  static String? validar(DateTime retiro, {DateTime? ahora}) {
    final referencia = (ahora ?? DateTime.now()).toUtc();
    final instante = retiro.toUtc();
    if (!instante.isAfter(referencia)) {
      return 'La fecha y hora de retiro deben ser posteriores a este momento.';
    }
    if (instante.isAfter(
      referencia.add(const Duration(days: maxDiasAnticipacion)),
    )) {
      return 'Solo puedes reservar con hasta $maxDiasAnticipacion días de anticipación.';
    }
    return null;
  }

  /// Propuesta inicial: mañana a las 9:00 de Paraguay, como instante en UTC.
  static DateTime propuesta({DateTime? ahora}) {
    final hoy = PlazoDevolucion.hoyEnParaguay(ahora: ahora);
    final manana = hoy.add(const Duration(days: 1));
    return PlazoDevolucion.combinar(manana, horaPropuesta, 0);
  }

  /// Último día que se puede elegir (en Paraguay).
  static DateTime ultimoDia({DateTime? ahora}) {
    final pared = FormatoFecha.enParaguay(ahora ?? DateTime.now());
    return DateTime(
      pared.year,
      pared.month,
      pared.day,
    ).add(const Duration(days: maxDiasAnticipacion));
  }
}
