import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/theme/tipografia_app.dart';
import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/loans/data/models/devolucion.dart';
import 'package:frontend/features/loans/data/models/prestamo_detalle.dart';
import 'package:frontend/features/materials/data/models/material_etiquetas.dart';

/// Una línea del préstamo: el material y su situación (fecha límite o devuelto).
class ItemPrestamo extends StatelessWidget {
  const ItemPrestamo({super.key, required this.detalle});

  final PrestamoDetalle detalle;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;
    final material = detalle.material;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            material.tipoMaterial.icono,
            size: 20,
            color: colores.tintaSuave,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material.titulo, style: textos.bodyMedium),
                Text(
                  material.codigo,
                  style: TipografiaApp.codigo(colores.tintaSuave, tamano: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _situacion(context),
        ],
      ),
    );
  }

  Widget _situacion(BuildContext context) {
    final colores = context.colores;
    final estilo = Theme.of(context).textTheme.labelMedium;

    if (detalle.devuelto) {
      final condicion = detalle.devolucion?.condicion;
      final multa = detalle.devolucion?.multaMonto;
      final partes = [
        'Devuelto',
        if (condicion != null && condicion != CondicionDevolucion.bueno)
          condicion.etiqueta,
        // La multa solo existe cuando el sistema de multas está activado.
        if (multa != null && multa > 0) 'Multa ${multa.toStringAsFixed(2)}',
      ];
      return Text(
        partes.join(' · '),
        style: estilo?.copyWith(color: colores.disponible),
      );
    }

    final limite = detalle.fechaDevolucionEsperada;
    if (limite == null) return const SizedBox.shrink();

    final vencido = detalle.estaVencido();
    return Text(
      FormatoFecha.tiempoRestante(limite),
      style: estilo?.copyWith(
        color: vencido ? colores.vencido : colores.tintaSuave,
        fontWeight: vencido ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}
