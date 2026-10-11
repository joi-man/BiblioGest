import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';

/// Pide confirmación antes de una acción que no se puede deshacer.
///
/// Devuelve `true` solo si la persona pulsa el botón de confirmar.
Future<bool> confirmarAccion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String etiquetaConfirmar,
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
              child: Text(etiquetaConfirmar),
            ),
          ],
        ),
      ) ??
      false;
}

/// Pide confirmación antes de eliminar. Devuelve `true` solo si se pulsa "Eliminar".
Future<bool> confirmarEliminar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) {
  return confirmarAccion(
    context,
    titulo: titulo,
    mensaje: mensaje,
    etiquetaConfirmar: 'Eliminar',
  );
}
