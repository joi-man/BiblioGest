import 'package:flutter/material.dart';
import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';

/// Línea de texto con el dato de fecha más relevante según el estado del préstamo.
class MetaPrestamo extends StatelessWidget {
  const MetaPrestamo({super.key, required this.prestamo});

  final Prestamo prestamo;

  String get _texto {
    switch (prestamo.estado) {
      case EstadoPrestamo.pendiente:
        final prevista = prestamo.fechaRetiroSolicitada;
        final solicitado =
            'Solicitado ${FormatoFecha.fechaHora(prestamo.fechaSolicitud)}';
        return prevista == null
            ? solicitado
            : '$solicitado\nRetiro previsto: ${FormatoFecha.fechaHora(prevista)}';
      case EstadoPrestamo.aprobado:
        final limite = prestamo.fechaRetiroLimite;
        final prevista = prestamo.fechaRetiroSolicitada;
        final hasta = limite == null
            ? 'Aprobado'
            : 'Retirar antes de ${FormatoFecha.fechaHora(limite)}';
        return prevista == null
            ? hasta
            : 'Retiro previsto: ${FormatoFecha.fechaHora(prevista)}\n$hasta';
      case EstadoPrestamo.activo:
      case EstadoPrestamo.vencido:
        final entrega = prestamo.fechaPrestamo;
        return entrega == null
            ? 'En préstamo'
            : 'Entregado ${FormatoFecha.fechaHora(entrega)}';
      case EstadoPrestamo.devuelto:
        final devuelto = prestamo.fechaDevolucionReal;
        return devuelto == null
            ? 'Devuelto'
            : 'Devuelto ${FormatoFecha.fechaHora(devuelto)}';
      case EstadoPrestamo.rechazado:
        return 'Rechazado: ${prestamo.motivoRechazo ?? 'sin motivo'}';
      case EstadoPrestamo.cancelado:
        // Cuando la biblioteca cancela (cesión de la reserva, reserva sin retirar), explica el motivo.
        final motivo = prestamo.motivoRechazo;
        return motivo == null ? 'Cancelado' : 'Cancelado: $motivo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_texto, style: Theme.of(context).textTheme.bodySmall);
  }
}
