import 'package:frontend/features/loans/data/models/prestamo.dart';

/// Avisos para el estudiante sobre lo que cambió en sus reservas entre dos
/// consultas: la respuesta del bibliotecario (aprobada o rechazada) o una
/// cancelación hecha por la biblioteca.
///
/// Solo compara reservas que ya existían en [antes]; la primera carga no avisa nada.
List<String> novedadesDeSolicitudes(
  List<Prestamo> antes,
  List<Prestamo> ahora,
) {
  final estadoAnterior = {for (final p in antes) p.id: p.estado};
  final avisos = <String>[];

  for (final prestamo in ahora) {
    final anterior = estadoAnterior[prestamo.id];
    if (anterior == null || anterior == prestamo.estado) continue;

    final titulo = prestamo.detalles.length == 1
        ? '«${prestamo.detalles.first.material.titulo}»'
        : '${prestamo.detalles.length} materiales';
    final motivo = prestamo.motivoRechazo;

    switch ((anterior, prestamo.estado)) {
      case (EstadoPrestamo.pendiente, EstadoPrestamo.aprobado):
        avisos.add('Tu reserva de $titulo fue aprobada. Pasa a retirarla.');
      case (EstadoPrestamo.pendiente, EstadoPrestamo.rechazado):
        avisos.add(
          'Tu reserva de $titulo fue rechazada'
          '${motivo == null ? '.' : ': $motivo'}',
        );
      case (
            EstadoPrestamo.pendiente || EstadoPrestamo.aprobado,
            EstadoPrestamo.cancelado,
          )
          when motivo != null:
        avisos.add('Tu reserva de $titulo fue cancelada: $motivo');
      default:
        break;
    }
  }
  return avisos;
}
