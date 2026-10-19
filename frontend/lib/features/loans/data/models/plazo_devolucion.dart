import 'package:frontend/core/utils/formato_fecha.dart';

/// Reglas de la fecha y hora de devolución que elige el personal.
///
/// El servidor aplica la misma regla; se repite aquí para avisar con un mensaje
/// claro antes de enviar la petición.
class PlazoDevolucion {
  PlazoDevolucion._();

  /// Máximo que se puede fijar hacia adelante (un año, igual que el selector).
  static const maximo = Duration(days: 365);

  /// Hora que propone el selector cuando todavía no se eligió ninguna.
  static const horaPropuesta = 18;

  /// Mensaje si [limite] no es válido, o `null` si lo es.
  static String? validar(DateTime limite, {DateTime? ahora}) {
    final referencia = (ahora ?? DateTime.now()).toUtc();
    final instante = limite.toUtc();
    if (!instante.isAfter(referencia)) {
      return 'La fecha y hora de devolución deben ser posteriores a este momento.';
    }
    if (instante.isAfter(referencia.add(maximo))) {
      return 'La devolución no puede fijarse a más de un año.';
    }
    return null;
  }

  /// Primer día que se puede elegir: hoy, en Paraguay.
  static DateTime hoyEnParaguay({DateTime? ahora}) {
    final pared = FormatoFecha.enParaguay(ahora ?? DateTime.now());
    return DateTime(pared.year, pared.month, pared.day);
  }

  /// Une el día y la hora elegidos (de Paraguay) en el instante UTC que se envía.
  static DateTime combinar(DateTime dia, int hora, int minuto) =>
      FormatoFecha.desdeParaguay(
        DateTime(dia.year, dia.month, dia.day, hora, minuto),
      );
}
