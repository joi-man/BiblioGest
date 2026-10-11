import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/core/widgets/chip_estado.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'botones_prestamo.dart';
import 'item_prestamo.dart';
import 'meta_prestamo.dart';

/// Resumen de un préstamo o solicitud: quién, qué materiales, cuándo y qué hacer.
class TarjetaPrestamo extends StatelessWidget {
  const TarjetaPrestamo({
    super.key,
    required this.prestamo,
    this.mostrarBotones = true,
    this.botonesPersonalizados,
    this.mostrarPersona = true,
  });

  final Prestamo prestamo;

  /// Si es `false` se omite el nombre de la persona (cuando es quien mira la pantalla).
  final bool mostrarPersona;

  /// Si es `false` no se muestra ninguna acción (por ejemplo en el historial).
  final bool mostrarBotones;

  /// Acciones propias de la pantalla que usa la tarjeta; reemplazan a las
  /// del flujo de préstamos (útil en la app del estudiante).
  final Widget? botonesPersonalizados;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;
    final botones = botonesPersonalizados ??
        (mostrarBotones ? BotonesPrestamo(prestamo: prestamo) : null);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: mostrarPersona
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(prestamo.usuario.nombreCompleto,
                                style: textos.titleMedium),
                            Text(
                              'Doc. ${prestamo.usuario.numeroDocumento}',
                              style: textos.bodySmall,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                ChipEstado(estado: prestamo.estado.valor),
              ],
            ),
            Divider(height: 24, color: colores.linea),
            for (final detalle in prestamo.detalles) ItemPrestamo(detalle: detalle),
            const SizedBox(height: 8),
            MetaPrestamo(prestamo: prestamo),
            if (prestamo.observaciones != null && prestamo.observaciones!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Nota: ${prestamo.observaciones}',
                  style: textos.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            if (botones != null) ...[
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: botones),
            ],
          ],
        ),
      ),
    );
  }
}
