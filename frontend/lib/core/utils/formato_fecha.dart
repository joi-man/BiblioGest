import 'package:intl/intl.dart';

/// Formatos de fecha y hora para mostrar en pantalla, siempre en hora de Paraguay.
///
/// El backend entrega las fechas en UTC con sufijo `Z`. Paraguay usa UTC-3 todo el
/// año (desde octubre de 2024 no cambia de horario), así que se muestra igual en
/// cualquier dispositivo, sin depender de su zona horaria.
class FormatoFecha {
  FormatoFecha._();

  /// Pasa un instante a la hora de pared de Paraguay.
  static DateTime enParaguay(DateTime fecha) =>
      fecha.toUtc().subtract(const Duration(hours: 3));

  /// Hora de pared de Paraguay -> instante en UTC (lo contrario de [enParaguay]).
  ///
  /// Sirve para convertir la fecha y la hora que elige una persona en pantalla,
  /// que son de Paraguay aunque el dispositivo tenga otra zona horaria.
  static DateTime desdeParaguay(DateTime paredParaguay) => DateTime.utc(
    paredParaguay.year,
    paredParaguay.month,
    paredParaguay.day,
    paredParaguay.hour,
    paredParaguay.minute,
  ).add(const Duration(hours: 3));

  static final DateFormat _fechaHora = DateFormat("d MMM yyyy, HH:mm", 'es');
  static final DateFormat _fecha = DateFormat("d MMM yyyy", 'es');
  static final DateFormat _hora = DateFormat('HH:mm', 'es');

  /// Ejemplo: `10 oct 2026, 14:30`.
  static String fechaHora(DateTime fecha) =>
      _fechaHora.format(enParaguay(fecha));

  /// Ejemplo: `10 oct 2026`.
  static String soloFecha(DateTime fecha) => _fecha.format(enParaguay(fecha));

  /// Ejemplo: `14:30`.
  static String soloHora(DateTime fecha) => _hora.format(enParaguay(fecha));

  /// Texto corto sobre cuánto falta o cuánto se pasó de [limite].
  ///
  /// Ejemplos: `Vence en 3 h`, `Vencido hace 2 días`, `Vence en 25 min`.
  static String tiempoRestante(DateTime limite, {DateTime? ahora}) {
    final referencia = ahora ?? DateTime.now();
    final diferencia = limite.difference(referencia);
    final texto = _duracionLegible(diferencia.abs());
    return diferencia.isNegative ? 'Vencido hace $texto' : 'Vence en $texto';
  }

  static String _duracionLegible(Duration duracion) {
    if (duracion.inDays >= 1) {
      final dias = duracion.inDays;
      return dias == 1 ? '1 día' : '$dias días';
    }
    if (duracion.inHours >= 1) return '${duracion.inHours} h';
    final minutos = duracion.inMinutes < 1 ? 1 : duracion.inMinutes;
    return '$minutos min';
  }
}
