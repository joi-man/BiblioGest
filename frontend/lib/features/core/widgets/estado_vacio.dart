import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';

/// Mensaje que se muestra cuando una lista no tiene elementos.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.titulo,
    this.detalle,
    this.icono = Icons.inbox_outlined,
  });

  final String titulo;
  final String? detalle;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final colores = context.colores;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 40, color: colores.tintaSuave),
            const SizedBox(height: 12),
            Text(titulo, style: textos.titleLarge, textAlign: TextAlign.center),
            if (detalle != null) ...[
              const SizedBox(height: 6),
              Text(
                detalle!,
                style: textos.bodyMedium?.copyWith(color: colores.tintaSuave),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
