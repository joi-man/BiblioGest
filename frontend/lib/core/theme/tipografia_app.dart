import 'package:flutter/material.dart';

/// Familias tipográficas empaquetadas en `assets/fonts` (IBM Plex, licencia OFL).
class FamiliasTipograficas {
  FamiliasTipograficas._();

  /// Serif para títulos: aporta el carácter editorial.
  static const String serif = 'IBMPlexSerif';

  /// Sans para texto corrido, tablas y formularios.
  static const String sans = 'IBMPlexSans';

  /// Monoespaciada para códigos de inventario, series y datos técnicos.
  static const String mono = 'IBMPlexMono';
}

/// Construye la escala tipográfica de la aplicación.
class TipografiaApp {
  TipografiaApp._();

  /// Crea el [TextTheme] con todos los estilos coloreados con [tinta].
  static TextTheme crear(Color tinta, Color tintaSuave) {
    TextStyle serif(double tamano, FontWeight peso, {double altura = 1.2}) {
      return TextStyle(
        fontFamily: FamiliasTipograficas.serif,
        fontSize: tamano,
        fontWeight: peso,
        height: altura,
        color: tinta,
        letterSpacing: -0.2,
      );
    }

    TextStyle sans(double tamano, FontWeight peso,
        {Color? color, double altura = 1.4}) {
      return TextStyle(
        fontFamily: FamiliasTipograficas.sans,
        fontSize: tamano,
        fontWeight: peso,
        height: altura,
        color: color ?? tinta,
      );
    }

    return TextTheme(
      displayLarge: serif(44, FontWeight.w600, altura: 1.1),
      displayMedium: serif(36, FontWeight.w600, altura: 1.1),
      displaySmall: serif(30, FontWeight.w600),
      headlineLarge: serif(28, FontWeight.w600),
      headlineMedium: serif(24, FontWeight.w600),
      headlineSmall: serif(20, FontWeight.w600),
      titleLarge: serif(18, FontWeight.w600),
      titleMedium: sans(16, FontWeight.w600),
      titleSmall: sans(14, FontWeight.w600),
      bodyLarge: sans(16, FontWeight.w400, altura: 1.5),
      bodyMedium: sans(14, FontWeight.w400, altura: 1.5),
      bodySmall: sans(12, FontWeight.w400, color: tintaSuave),
      labelLarge: sans(14, FontWeight.w500),
      labelMedium: sans(12, FontWeight.w500, color: tintaSuave),
      labelSmall: sans(11, FontWeight.w500, color: tintaSuave),
    );
  }

  /// Estilo para códigos de inventario y números de serie.
  static TextStyle codigo(Color color, {double tamano = 13}) {
    return TextStyle(
      fontFamily: FamiliasTipograficas.mono,
      fontSize: tamano,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: 0.2,
    );
  }
}
