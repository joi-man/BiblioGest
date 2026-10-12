import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/actualizaciones/clave_publica.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/core/widgets/alertas.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enlaces para descargar las aplicaciones de Windows y de Android.
///
/// Solo aparece en la versión web (donde tiene sentido ofrecerlas): las
/// aplicaciones ya instaladas no necesitan descargarse otra vez.
class DescargasAplicaciones extends StatelessWidget {
  const DescargasAplicaciones({super.key});

  Future<void> _abrir(BuildContext context, String direccion) async {
    final abierto = await launchUrl(
      Uri.parse(direccion),
      mode: LaunchMode.externalApplication,
    );
    if (!abierto && context.mounted) {
      context.mostrarError('No se pudo abrir la descarga');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    final colores = context.colores;
    final textos = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 40, color: colores.linea),
        Text('Descarga la aplicación', style: textos.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Instálala en tu computador o en tu celular Android.',
          style: textos.bodySmall?.copyWith(color: colores.tintaSuave),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _abrir(context, urlDescargaWindows),
                icon: const Icon(Icons.desktop_windows_outlined, size: 18),
                label: const Text('Windows'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _abrir(context, urlDescargaAndroid),
                icon: const Icon(Icons.android, size: 18),
                label: const Text('Android'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
