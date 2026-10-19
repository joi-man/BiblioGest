import 'package:flutter/material.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';

import 'campo_fecha_devolucion.dart';

/// Pide la fecha y hora de devolución al entregar una solicitud.
///
/// Devuelve `(confirmado, fecha)`: `confirmado` es falso si se cancela y [fecha]
/// es `null` cuando se deja el plazo automático.
Future<({bool confirmado, DateTime? fecha})> pedirFechaDeEntrega(
  BuildContext context,
  Prestamo prestamo,
) async {
  final resultado = await showDialog<({bool confirmado, DateTime? fecha})>(
    context: context,
    builder: (_) => _DialogoEntrega(prestamo: prestamo),
  );
  return resultado ?? (confirmado: false, fecha: null);
}

class _DialogoEntrega extends StatefulWidget {
  const _DialogoEntrega({required this.prestamo});

  final Prestamo prestamo;

  @override
  State<_DialogoEntrega> createState() => _DialogoEntregaState();
}

class _DialogoEntregaState extends State<_DialogoEntrega> {
  DateTime? _fecha;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Entregar con otra fecha'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.prestamo.resumenMateriales} para '
              '${widget.prestamo.usuario.nombreCompleto}.',
              style: textos.bodyMedium,
            ),
            const SizedBox(height: 12),
            CampoFechaDevolucion(
              valor: _fecha,
              onChanged: (f) => setState(() => _fecha = f),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, (confirmado: false, fecha: null)),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, (confirmado: true, fecha: _fecha)),
          child: const Text('Entregar'),
        ),
      ],
    );
  }
}
