import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';

/// Avisos breves (SnackBar) con el color y el icono de cada tipo de mensaje.
extension AlertasExtension on BuildContext {
  void mostrarExito(String mensaje) =>
      _mostrar(mensaje, Icons.check_circle_outline, colores.disponible, 2);

  void mostrarError(String mensaje) =>
      _mostrar(mensaje, Icons.error_outline, colores.vencido, 3);

  void mostrarInfo(String mensaje) =>
      _mostrar(mensaje, Icons.info_outline, colores.prestado, 2);

  void mostrarAdvertencia(String mensaje) =>
      _mostrar(mensaje, Icons.warning_amber_outlined, colores.reservado, 3);

  /// Construye y muestra el aviso. Un único lugar define su aspecto.
  void _mostrar(String mensaje, IconData icono, Color fondo, int segundos) {
    // Texto oscuro sobre fondos claros (modo oscuro) y blanco sobre fondos oscuros.
    final fondoOscuro =
        ThemeData.estimateBrightnessForColor(fondo) == Brightness.dark;
    final textoColor = fondoOscuro ? Colors.white : const Color(0xFF1B1815);

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: fondo,
        duration: Duration(seconds: segundos),
        content: Row(
          children: [
            Icon(icono, color: textoColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(mensaje, style: TextStyle(color: textoColor)),
            ),
          ],
        ),
      ),
    );
  }
}
