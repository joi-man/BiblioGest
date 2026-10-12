import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/theme/colores_estado.dart';

/// Etiqueta compacta que muestra el estado de un material o préstamo.
///
/// Usa un punto de color y texto, sin relleno saturado, para mantener el
/// aspecto sobrio del sistema.
class ChipEstado extends StatelessWidget {
  const ChipEstado({super.key, required this.estado, this.etiqueta});

  /// Estado tal como lo entrega el backend (por ejemplo `disponible`).
  final String estado;

  /// Texto a mostrar; por defecto, el de [ColoresEstado.etiqueta].
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final color = ColoresEstado.de(colores, estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            etiqueta ?? ColoresEstado.etiqueta(estado),
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
