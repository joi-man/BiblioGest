import 'package:flutter/material.dart';
import 'package:frontend/core/theme/tema_app.dart';

/// Pantalla que se muestra mientras la aplicación se prepara.
///
/// Si el arranque falla, muestra el motivo y un botón para reintentar.
class PantallaArranque extends StatelessWidget {
  const PantallaArranque({super.key, this.error, this.alReintentar});

  /// Motivo del fallo; si es nulo se muestra el indicador de progreso.
  final String? error;
  final VoidCallback? alReintentar;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      darkTheme: TemaApp.oscuro,
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: error == null ? _cargando(context) : _fallo(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cargando(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('BiblioGest', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        const Text('Iniciando…'),
      ],
    );
  }

  Widget _fallo(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'No se pudo iniciar',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(error!, textAlign: TextAlign.center),
        if (alReintentar != null) ...[
          const SizedBox(height: 20),
          FilledButton(
            onPressed: alReintentar,
            child: const Text('Reintentar'),
          ),
        ],
      ],
    );
  }
}
