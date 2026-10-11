import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';

/// Pide confirmación antes de una acción destructiva.
///
/// Devuelve `true` solo si la persona pulsa "Eliminar".
Future<bool> confirmarEliminar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (contexto) => AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contexto, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(contexto, true),
              style: FilledButton.styleFrom(
                backgroundColor: contexto.colores.vencido,
                foregroundColor: contexto.colores.sobreAcento,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ) ??
      false;
}
