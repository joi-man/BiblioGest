import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/actualizaciones/actualizaciones_provider.dart';
import 'package:frontend/features/actualizaciones/presentation/widgets/contenido_actualizacion.dart';

/// Envuelve toda la aplicación para pedir actualizarla.
///
/// - Al abrir, busca una versión nueva en segundo plano (no retrasa el inicio).
/// - Si es opcional, muestra un aviso encima de lo que se esté haciendo.
/// - Si es obligatoria, reemplaza la aplicación por una pantalla de actualización.
class GuardiaActualizacion extends ConsumerStatefulWidget {
  const GuardiaActualizacion({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GuardiaActualizacion> createState() => _GuardiaActualizacionState();
}

class _GuardiaActualizacionState extends ConsumerState<GuardiaActualizacion> {
  @override
  void initState() {
    super.initState();
    // Después del primer cuadro, para no competir con el arranque de la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(actualizacionesProvider.notifier).iniciar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(actualizacionesProvider);
    final versionInstalada = ref.watch(versionAppProvider);

    if (estado.bloqueaLaApp) {
      return _PantallaObligatoria(versionInstalada: versionInstalada);
    }

    return Stack(
      children: [
        widget.child,
        if (estado.avisoPendiente) ...[
          const ModalBarrier(color: Colors.black54, dismissible: false),
          Center(
            child: Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.circular(16),
              elevation: 6,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hay una nueva versión disponible',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Flexible(child: ContenidoActualizacion(versionInstalada: versionInstalada)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Pantalla completa cuando la versión instalada ya no puede usarse.
class _PantallaObligatoria extends ConsumerWidget {
  const _PantallaObligatoria({required this.versionInstalada});

  final String versionInstalada;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.system_update_alt, size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text('Actualización obligatoria', style: textos.headlineSmall),
                const SizedBox(height: 16),
                ContenidoActualizacion(versionInstalada: versionInstalada),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => ref
                        .read(instaladorActualizacionesProvider)
                        .salir(cerrarBackend: ref.read(cerrarBackendProvider)),
                    child: const Text('Salir'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
