import 'package:frontend/core/utils/formato_fecha.dart';

/// Reglas de la fecha y hora en que se recibió un material, cuando difiere de
/// "ahora" (por ejemplo, el estudiante lo trajo ayer y se anota hoy).
///
/// El servidor aplica las mismas reglas; se repiten aquí para avisar con un
/// mensaje claro antes de enviar. Cualquier fecha distinta de "ahora" exige un
/// motivo, que queda en la bitácora de auditoría.
class FechaRecepcion {
  FechaRecepcion._();

  /// Hasta cuántos días atrás se puede anotar una devolución.
  static const maxDiasAtras = 30;

  /// Largo mínimo del motivo.
  static const minCaracteresMotivo = 10;

  /// Mensaje si [recibido] no es válido, o `null` si lo es.
  static String? validar(
    DateTime recibido, {
    DateTime? ahora,
    DateTime? entrega,
  }) {
    final referencia = (ahora ?? DateTime.now()).toUtc();
    final instante = recibido.toUtc();
    if (instante.isAfter(referencia)) {
      return 'La fecha de devolución no puede ser posterior a este momento.';
    }
    if (entrega != null && instante.isBefore(entrega.toUtc())) {
      return 'La fecha de devolución no puede ser anterior a la entrega del préstamo.';
    }
    if (instante.isBefore(
      referencia.subtract(const Duration(days: maxDiasAtras)),
    )) {
      return 'La fecha de devolución no puede ser de hace más de $maxDiasAtras días.';
    }
    return null;
  }

  /// Mensaje si el [motivo] no alcanza, o `null` si es suficiente.
  static String? validarMotivo(String? motivo) {
    if ((motivo ?? '').trim().length < minCaracteresMotivo) {
      return 'Explica por qué se registra con otra fecha '
          '(al menos $minCaracteresMotivo caracteres).';
    }
    return null;
  }

  /// Primer día que se puede elegir: el de la entrega o, si es anterior, hace
  /// [maxDiasAtras] días. Es un día de Paraguay.
  static DateTime primerDia({DateTime? entrega, DateTime? ahora}) {
    final hoy = _dia(FormatoFecha.enParaguay(ahora ?? DateTime.now()));
    final limite = hoy.subtract(const Duration(days: maxDiasAtras));
    if (entrega == null) return limite;
    final diaEntrega = _dia(FormatoFecha.enParaguay(entrega));
    return diaEntrega.isAfter(limite) ? diaEntrega : limite;
  }

  /// Último día que se puede elegir: hoy, en Paraguay.
  static DateTime ultimoDia({DateTime? ahora}) =>
      _dia(FormatoFecha.enParaguay(ahora ?? DateTime.now()));

  static DateTime _dia(DateTime fecha) =>
      DateTime(fecha.year, fecha.month, fecha.day);
}
