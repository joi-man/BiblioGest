import 'package:flutter/material.dart';
import 'package:frontend/core/network/mensaje_error.dart';
import 'alertas.dart';

/// Ejecuta una acción asíncrona y avisa el resultado con un mensaje.
///
/// Muestra [exito] si todo sale bien, o el motivo del fallo si no. Devuelve
/// `true` cuando la acción terminó sin errores. Evita repetir el mismo
/// `try/catch` en cada botón.
Future<bool> ejecutarAccion(
  BuildContext context,
  Future<void> Function() accion, {
  required String exito,
}) async {
  try {
    await accion();
    if (context.mounted) context.mostrarExito(exito);
    return true;
  } catch (error) {
    if (context.mounted) context.mostrarError(mensajeDeError(error));
    return false;
  }
}
