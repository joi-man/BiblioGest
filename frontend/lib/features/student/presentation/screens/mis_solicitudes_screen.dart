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

/// Las solicitudes y préstamos del propio estudiante, con su estado.
class MisSolicitudesScreen extends ConsumerWidget {
  const MisSolicitudesScreen({super.key});

  /// Solo se puede cancelar lo que aún no se entregó.
  bool _sePuedeCancelar(Prestamo p) =>
      p.estado == EstadoPrestamo.pendiente || p.estado == EstadoPrestamo.aprobado;

  Future<void> _cancelar(BuildContext context, WidgetRef ref, Prestamo prestamo) async {
    final confirmado = await confirmarEliminar(
      context,
      titulo: 'Cancelar solicitud',
      mensaje: '¿Quieres cancelar esta solicitud?',
    );
    if (!confirmado || !context.mounted) return;

    await ejecutarAccion(
      context,
      () => ref.read(accionesPrestamoProvider).cancelarPropia(prestamo.id),
      exito: 'Solicitud cancelada',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudes = ref.watch(misSolicitudesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis solicitudes')),
      body: ValorAsincrono(
        valor: solicitudes,
        alReintentar: () => ref.invalidate(misSolicitudesProvider),
        construir: (lista) {
          if (lista.isEmpty) {
            return const EstadoVacio(
              titulo: 'Aún no has pedido nada',
              detalle: 'Busca en el catálogo y solicita lo que necesites.',
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
                          child: const Text('Cancelar solicitud'),
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
