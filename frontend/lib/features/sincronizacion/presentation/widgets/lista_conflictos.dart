import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/core/widgets/confirmacion.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/sincronizacion/data/models/estado_local.dart';
import 'package:frontend/features/sincronizacion/data/repositories/local_repository.dart';
import 'package:frontend/features/sincronizacion/presentation/providers/estado_local_provider.dart';

/// Cambios hechos sin conexión que el servidor rechazó, con las opciones para resolverlos.
class ListaConflictos extends ConsumerWidget {
  const ListaConflictos({super.key, required this.conflictos});

  final List<ConflictoLocal> conflictos;

  void _recargar(WidgetRef ref) {
    ref.invalidate(estadoLocalProvider);
    ref.invalidate(conflictosProvider);
  }

  Future<void> _reintentar(
    BuildContext context,
    WidgetRef ref,
    ConflictoLocal conflicto,
  ) async {
    final exito = await ejecutarAccion(
      context,
      () => ref.read(localRepositoryProvider).reintentarConflicto(conflicto.id),
      exito: 'Se enviará de nuevo en la próxima sincronización',
    );
    if (exito) _recargar(ref);
  }

  Future<void> _descartar(
    BuildContext context,
    WidgetRef ref,
    ConflictoLocal conflicto,
  ) async {
    final confirmado = await confirmarAccion(
      context,
      titulo: 'Descartar mis cambios',
      mensaje:
          'Se deshará lo que hiciste sin conexión ("${conflicto.descripcion}") y '
          'se recuperará la versión del servidor. Esto no se puede deshacer.',
      etiquetaConfirmar: 'Descartar',
    );
    if (!confirmado || !context.mounted) return;

    final exito = await ejecutarAccion(
      context,
      () => ref.read(localRepositoryProvider).descartarConflicto(conflicto.id),
      exito: 'Cambios descartados',
    );
    if (exito) _recargar(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cambios por revisar', style: textos.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Estos cambios se hicieron sin conexión y el servidor no pudo aplicarlos '
          'porque alguien cambió lo mismo antes. Decide qué hacer con cada uno.',
          style: textos.bodyMedium?.copyWith(color: colores.tintaSuave),
        ),
        const SizedBox(height: 12),
        for (final conflicto in conflictos)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: colores.reservado,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          conflicto.descripcion,
                          style: textos.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    FormatoFecha.fechaHora(conflicto.creadoEn),
                    style: textos.bodySmall?.copyWith(
                      color: colores.tintaSuave,
                    ),
                  ),
                  if (conflicto.mensaje != null) ...[
                    const SizedBox(height: 8),
                    Text(conflicto.mensaje!, style: textos.bodyMedium),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => _reintentar(context, ref, conflicto),
                        child: const Text('Reintentar'),
                      ),
                      FilledButton(
                        onPressed: () => _descartar(context, ref, conflicto),
                        style: FilledButton.styleFrom(
                          backgroundColor: colores.vencido,
                          foregroundColor: colores.sobreAcento,
                        ),
                        child: const Text('Descartar mis cambios'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
