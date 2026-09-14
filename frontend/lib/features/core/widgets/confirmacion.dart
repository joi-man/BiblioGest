import 'package:flutter/material.dart';

Future<bool> confirmarEliminar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ) ??
      false;
}
