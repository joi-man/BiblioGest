import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/actualizaciones/actualizaciones_provider.dart';
import 'package:frontend/core/actualizaciones/decision.dart';
import 'package:frontend/core/platform/plataforma.dart';
import 'package:frontend/core/theme/colores_app.dart';

/// Versión instalada, búsqueda manual de actualizaciones y opción de instalarlas solas.
class TarjetaActualizaciones extends ConsumerWidget {
  const TarjetaActualizaciones({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(actualizacionesProvider);
    final notifier = ref.read(actualizacionesProvider.notifier);
    final version = ref.watch(versionAppProvider);
    final textos = Theme.of(context).textTheme;
    final colores = context.colores;

    final hayNueva = estado.urgencia != Urgencia.ninguna && estado.manifiesto != null;
    final (icono, color, resumen) = switch (estado.fase) {
      FaseActualizacion.comprobando => (Icons.sync, colores.prestado, 'Buscando actualizaciones…'),
      FaseActualizacion.error => (
          Icons.error_outline,
          colores.vencido,
          estado.mensaje ?? 'No se pudo completar la acción',
        ),
      _ when hayNueva => (
          Icons.system_update_alt,
          colores.reservado,
          'Hay una versión nueva: ${estado.manifiesto!.version}',
        ),
      FaseActualizacion.alDia => (Icons.check_circle_outline, colores.disponible, 'Tienes la última versión'),
      _ => (Icons.info_outline, colores.tintaSuave, 'Aún no se buscaron actualizaciones'),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actualizaciones', style: textos.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Versión instalada: $version',
              style: textos.bodyMedium?.copyWith(color: colores.tintaSuave),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(icono, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(resumen)),
              ],
            ),
            const SizedBox(height: 8),
            // En Android el sistema siempre pide confirmar la instalación: no hay modo automático.
            if (!esAndroid)
              SwitchListTile(
                value: estado.automatica,
                onChanged: notifier.fijarAutomatica,
                contentPadding: EdgeInsets.zero,
                title: const Text('Instalar actualizaciones automáticamente'),
                subtitle: const Text(
                  'Al abrir BiblioGest se descargan e instalan solas. Las obligatorias siempre se piden.',
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: estado.ocupado ? null : () => notifier.comprobar(manual: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Buscar actualizaciones'),
                ),
                if (hayNueva)
                  FilledButton.icon(
                    onPressed: estado.ocupado ? null : notifier.mostrarAviso,
                    icon: const Icon(Icons.system_update_alt),
                    label: Text('Actualizar a ${estado.manifiesto!.version}'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
