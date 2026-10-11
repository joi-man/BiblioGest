import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/mensaje_error.dart';
import 'package:frontend/core/theme/colores_app.dart';

/// Muestra un [AsyncValue] con su estado de carga, de error (con botón para
/// reintentar) o los datos, para no repetir esa lógica en cada pantalla.
class ValorAsincrono<T> extends StatelessWidget {
  const ValorAsincrono({
    super.key,
    required this.valor,
    required this.construir,
    this.alReintentar,
  });

  final AsyncValue<T> valor;

  /// Dibuja la pantalla cuando ya hay datos.
  final Widget Function(T datos) construir;

  /// Acción del botón "Reintentar"; si es nula, el botón no se muestra.
  final VoidCallback? alReintentar;

  @override
  Widget build(BuildContext context) {
    return valor.when(
      // Mientras recarga con datos previos, se siguen mostrando los anteriores.
      skipLoadingOnRefresh: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _VistaError(
        mensaje: mensajeDeError(error),
        alReintentar: alReintentar,
      ),
      data: construir,
    );
  }
}

class _VistaError extends StatelessWidget {
  const _VistaError({required this.mensaje, this.alReintentar});

  final String mensaje;
  final VoidCallback? alReintentar;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: colores.vencido),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (alReintentar != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: alReintentar,
                child: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
