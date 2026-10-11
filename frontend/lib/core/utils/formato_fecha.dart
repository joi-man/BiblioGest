import 'package:intl/intl.dart';

/// Formatos de fecha y hora para mostrar en pantalla, siempre en hora local.
///
/// El backend entrega las fechas en UTC con sufijo `Z`; `DateTime.parse` las
/// convierte y aquí se pasan a la hora del dispositivo.
class FormatoFecha {
  FormatoFecha._();

  static final DateFormat _fechaHora = DateFormat("d MMM yyyy, HH:mm", 'es');
  static final DateFormat _fecha = DateFormat("d MMM yyyy", 'es');
  static final DateFormat _hora = DateFormat('HH:mm', 'es');

  /// Ejemplo: `10 oct 2026, 14:30`.
  static String fechaHora(DateTime fecha) =>
      _fechaHora.format(fecha.toLocal());

  /// Ejemplo: `10 oct 2026`.
  static String soloFecha(DateTime fecha) => _fecha.format(fecha.toLocal());

  /// Ejemplo: `14:30`.
  static String soloHora(DateTime fecha) => _hora.format(fecha.toLocal());

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
