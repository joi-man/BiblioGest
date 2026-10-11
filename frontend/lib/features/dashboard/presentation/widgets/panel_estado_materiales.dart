import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/dashboard/data/models/resumen_dashboard.dart';

/// Reparto del inventario por estado: una barra proporcional y su leyenda.
class PanelEstadoMateriales extends StatelessWidget {
  const PanelEstadoMateriales({super.key, required this.materiales});

  final ResumenMateriales materiales;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;

    final partes = [
      (nombre: 'Disponibles', cantidad: materiales.disponibles, color: colores.disponible),
      (nombre: 'Reservados', cantidad: materiales.reservados, color: colores.reservado),
      (nombre: 'Prestados', cantidad: materiales.prestados, color: colores.prestado),
      (nombre: 'Vencidos', cantidad: materiales.vencidos, color: colores.vencido),
      (nombre: 'Fuera de servicio', cantidad: materiales.fueraDeServicio, color: colores.fueraDeServicio),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventario', style: textos.titleLarge),
            const SizedBox(height: 4),
            Text('${materiales.total} unidades registradas', style: textos.bodySmall),
            const SizedBox(height: 16),
            _barra(partes),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                for (final p in partes)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text('${p.nombre}: ${p.cantidad}', style: textos.bodyMedium),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _barra(List<({String nombre, int cantidad, Color color})> partes) {
    final total = partes.fold<int>(0, (suma, p) => suma + p.cantidad);

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 12,
        child: total == 0
            ? const ColoredBox(color: Colors.black12)
            : Row(
                children: [
                  for (final p in partes)
                    if (p.cantidad > 0)
                      Expanded(
                        flex: p.cantidad,
                        child: ColoredBox(color: p.color),
                      ),
                ],
              ),
      ),
    );
  }
}
