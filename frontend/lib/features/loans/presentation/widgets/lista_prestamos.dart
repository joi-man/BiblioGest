import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/core/widgets/estado_vacio.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';
import 'package:frontend/features/loans/presentation/providers/prestamos_provider.dart';
import 'tarjeta_prestamo.dart';

/// Lista de préstamos que cumplen un filtro, con sus estados de carga y vacío.
class ListaPrestamos extends ConsumerWidget {
  const ListaPrestamos({
    super.key,
    required this.filtro,
    required this.mensajeVacio,
    this.mostrarBotones = true,
  });

  final FiltroPrestamos filtro;

  /// Texto que se muestra cuando no hay resultados.
  final String mensajeVacio;
  final bool mostrarBotones;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValorAsincrono(
      valor: ref.watch(prestamosProvider(filtro)),
      alReintentar: () => ref.invalidate(prestamosProvider),
      construir: (prestamos) {
        if (prestamos.isEmpty) {
          return EstadoVacio(titulo: mensajeVacio, icono: Icons.inbox_outlined);
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: prestamos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => TarjetaPrestamo(
            prestamo: prestamos[i],
            mostrarBotones: mostrarBotones,
          ),
        );
      },
    );
  }
}
