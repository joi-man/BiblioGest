import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'package:frontend/features/loans/presentation/providers/acciones_prestamo.dart';
import 'dialogo_ceder_reserva.dart';
import 'dialogo_rechazo.dart';

/// Botones de acción de un préstamo, según el paso del flujo en que está.
///
/// - Pendiente: entregar ahora (aprueba y entrega), aprobar o rechazar.
/// - Aprobado: entregar, cancelar la reserva o prestarla a otra persona (caso excepcional).
/// - En préstamo o vencido: ir a la pantalla de devoluciones.
class BotonesPrestamo extends ConsumerWidget {
  const BotonesPrestamo({super.key, required this.prestamo});

  final Prestamo prestamo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acciones = ref.read(accionesPrestamoProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: switch (prestamo.estado) {
        EstadoPrestamo.pendiente => [
            OutlinedButton(
              onPressed: () => _rechazar(context, acciones),
              child: const Text('Rechazar'),
            ),
            OutlinedButton(
              onPressed: () => ejecutarAccion(
                context,
                () => acciones.aprobar(prestamo.id),
                exito: 'Solicitud aprobada: material reservado',
              ),
              child: const Text('Aprobar'),
            ),
            FilledButton(
              onPressed: () => _entregar(context, acciones),
              child: const Text('Entregar ahora'),
            ),
          ],
        EstadoPrestamo.aprobado => [
            TextButton(
              onPressed: () => cederReserva(context, prestamo),
              child: const Text('Prestar a otra persona'),
            ),
            OutlinedButton(
              onPressed: () => ejecutarAccion(
                context,
                () => acciones.cancelar(prestamo.id),
                exito: 'Reserva cancelada',
              ),
              child: const Text('Cancelar reserva'),
            ),
            FilledButton(
              onPressed: () => _entregar(context, acciones),
              child: const Text('Marcar como entregado'),
            ),
          ],
        EstadoPrestamo.activo || EstadoPrestamo.vencido => [
            OutlinedButton.icon(
              onPressed: () => context.go(
                '/returns?q=${Uri.encodeQueryComponent(prestamo.usuario.numeroDocumento)}',
              ),
              icon: const Icon(Icons.assignment_return_outlined, size: 18),
              label: const Text('Ir a devolución'),
            ),
          ],
        _ => const [],
      },
    );
  }

  Future<void> _entregar(BuildContext context, AccionesPrestamo acciones) {
    return ejecutarAccion(
      context,
      () => acciones.entregar(prestamo.id),
      exito: 'Entrega registrada',
    );
  }

  Future<void> _rechazar(BuildContext context, AccionesPrestamo acciones) async {
    final motivo = await pedirMotivoRechazo(context);
    if (motivo == null || !context.mounted) return;

    await ejecutarAccion(
      context,
      () => acciones.rechazar(prestamo.id, motivo),
      exito: 'Solicitud rechazada',
    );
  }
}
