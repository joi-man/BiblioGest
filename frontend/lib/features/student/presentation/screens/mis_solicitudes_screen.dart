import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/core/widgets/confirmacion.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/core/widgets/estado_vacio.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'package:frontend/features/loans/presentation/providers/acciones_prestamo.dart';
import 'package:frontend/features/loans/presentation/providers/prestamos_provider.dart';
import 'package:frontend/features/loans/presentation/widgets/tarjeta_prestamo.dart';
import 'package:frontend/features/student/presentation/widgets/hoja_fecha_retiro.dart';

/// Las solicitudes y préstamos del propio estudiante, con su estado.
class MisSolicitudesScreen extends ConsumerWidget {
  const MisSolicitudesScreen({super.key});

  /// Solo se puede cancelar lo que aún no se entregó.
  bool _sePuedeCancelar(Prestamo p) =>
      p.estado == EstadoPrestamo.pendiente ||
      p.estado == EstadoPrestamo.aprobado;

  /// Una solicitud rechazada o cancelada se puede pedir de nuevo.
  bool _sePuedeVolverAReservar(Prestamo p) =>
      p.estado == EstadoPrestamo.rechazado ||
      p.estado == EstadoPrestamo.cancelado;

  Future<void> _volverAReservar(
    BuildContext context,
    WidgetRef ref,
    Prestamo prestamo,
  ) async {
    final retiro = await pedirFechaRetiro(
      context,
      resumen: prestamo.resumenMateriales,
    );
    if (retiro == null || !context.mounted) return;

    await ejecutarAccion(
      context,
      () => ref.read(accionesPrestamoProvider).solicitar([
        for (final d in prestamo.detalles) d.material.id,
      ], fechaRetiro: retiro),
      exito: 'Reserva enviada. El bibliotecario la revisará y te avisaremos',
    );
  }

  Future<void> _cancelar(
    BuildContext context,
    WidgetRef ref,
    Prestamo prestamo,
  ) async {
    final confirmado = await confirmarEliminar(
      context,
      titulo: 'Cancelar reserva',
      mensaje: '¿Quieres cancelar esta reserva?',
    );
    if (!confirmado || !context.mounted) return;

    await ejecutarAccion(
      context,
      () => ref.read(accionesPrestamoProvider).cancelarPropia(prestamo.id),
      exito: 'Reserva cancelada',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudes = ref.watch(misSolicitudesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis reservas')),
      body: ValorAsincrono(
        valor: solicitudes,
        alReintentar: () => ref.invalidate(misSolicitudesProvider),
        construir: (lista) {
          if (lista.isEmpty) {
            return const EstadoVacio(
              titulo: 'Aún no has reservado nada',
              detalle: 'Busca en el catálogo y reserva lo que necesites.',
              icono: Icons.assignment_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(misSolicitudesProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, indice) {
                final prestamo = lista[indice];
                return TarjetaPrestamo(
                  prestamo: prestamo,
                  mostrarPersona: false,
                  mostrarBotones: false,
                  botonesPersonalizados: _sePuedeCancelar(prestamo)
                      ? OutlinedButton(
                          onPressed: () => _cancelar(context, ref, prestamo),
                          child: const Text('Cancelar reserva'),
                        )
                      : _sePuedeVolverAReservar(prestamo)
                      ? FilledButton(
                          onPressed: () =>
                              _volverAReservar(context, ref, prestamo),
                          child: const Text('Volver a reservar'),
                        )
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
