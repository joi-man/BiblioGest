import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/actualizaciones/actualizaciones_provider.dart';
import 'package:frontend/core/actualizaciones/decision.dart';
import 'package:frontend/core/platform/plataforma.dart';
import 'package:frontend/core/theme/colores_app.dart';

/// Texto, progreso y botones de una actualización pendiente.
///
/// Lo comparten el aviso opcional (un cuadro de diálogo) y la pantalla
/// obligatoria, que solo cambian en lo que permiten hacer.
class ContenidoActualizacion extends ConsumerWidget {
  const ContenidoActualizacion({super.key, required this.versionInstalada});

  final String versionInstalada;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(actualizacionesProvider);
    final manifiesto = estado.manifiesto;
    if (manifiesto == null) return const SizedBox.shrink();

    final notifier = ref.read(actualizacionesProvider.notifier);
    final textos = Theme.of(context).textTheme;
    final colores = context.colores;
    final obligatoria = estado.urgencia == Urgencia.obligatoria;
    final descargando = estado.fase == FaseActualizacion.descargando;
    final instalando = estado.fase == FaseActualizacion.instalando;
    final ocupado = descargando || instalando;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BiblioGest ${manifiesto.version} · ${_megabytes(manifiesto.tamano)}',
          style: textos.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Tienes la versión $versionInstalada.',
          style: textos.bodyMedium?.copyWith(color: colores.tintaSuave),
        ),
        if (manifiesto.notas.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Novedades', style: textos.labelLarge),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: SingleChildScrollView(child: Text(manifiesto.notas)),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          obligatoria
              ? 'Esta actualización es obligatoria: la versión que tienes ya no es compatible.'
              : esDispositivoMovil
                  ? 'Android te pedirá confirmar la instalación. Tus datos no se tocan.'
                  : 'Tus datos no se tocan. La aplicación se cerrará un momento y se volverá a abrir sola.',
          style: textos.bodySmall?.copyWith(color: colores.tintaSuave),
        ),
        if (ocupado) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(value: instalando ? null : estado.progreso),
          const SizedBox(height: 6),
          Text(
            instalando
                ? 'Instalando… la aplicación se reiniciará.'
                : 'Descargando… ${(estado.progreso * 100).round()} %',
            style: textos.bodySmall,
          ),
        ],
        if (estado.fase == FaseActualizacion.error && estado.mensaje != null) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, size: 18, color: colores.vencido),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  estado.mensaje!,
                  style: textos.bodySmall?.copyWith(color: colores.vencido),
                ),
              ),
            ],
          ),
        ],
        if (!obligatoria) ...[
          const SizedBox(height: 8),
          CheckboxListTile(
            value: estado.automatica,
            onChanged: ocupado ? null : (valor) => notifier.fijarAutomatica(valor ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            title: const Text('Instalar las próximas actualizaciones automáticamente'),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (!obligatoria) ...[
              TextButton(
                onPressed: ocupado ? null : notifier.omitir,
                child: const Text('Omitir esta versión'),
              ),
              TextButton(
                onPressed: ocupado ? null : notifier.posponer,
                child: const Text('Más tarde'),
              ),
            ],
            FilledButton.icon(
              onPressed: ocupado ? null : () => notifier.descargarEInstalar(),
              icon: const Icon(Icons.system_update_alt),
              label: Text(estado.fase == FaseActualizacion.error ? 'Reintentar' : 'Actualizar ahora'),
            ),
          ],
        ),
      ],
    );
  }

  static String _megabytes(int bytes) => '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
