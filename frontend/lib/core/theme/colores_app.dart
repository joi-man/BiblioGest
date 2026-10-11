import 'package:flutter/material.dart';

/// Paleta semántica de BiblioGest (estilo editorial cálido).
///
/// Se registra como [ThemeExtension] para que cualquier widget pueda leer los
/// colores con `context.colores` y reaccione solo al cambio entre modo claro
/// y oscuro. Así no hace falta escribir colores fijos en las pantallas.
@immutable
class ColoresApp extends ThemeExtension<ColoresApp> {
  const ColoresApp({
    required this.papel,
    required this.superficie,
    required this.superficieElevada,
    required this.linea,
    required this.tinta,
    required this.tintaSuave,
    required this.acento,
    required this.sobreAcento,
    required this.acentoSuave,
    required this.disponible,
    required this.prestado,
    required this.reservado,
    required this.pendiente,
    required this.vencido,
    required this.fueraDeServicio,
  });

  /// Fondo general de la aplicación (el "papel").
  final Color papel;

  /// Fondo de paneles, tarjetas y diálogos.
  final Color superficie;

  /// Fondo de elementos que flotan sobre una superficie (menús, filas activas).
  final Color superficieElevada;

  /// Color de filetes, bordes y divisores.
  final Color linea;

  /// Color del texto principal.
  final Color tinta;

  /// Color del texto secundario y de las etiquetas.
  final Color tintaSuave;

  /// Único color de acento: acciones principales y elemento seleccionado.
  final Color acento;

  /// Color del texto o icono que va sobre [acento].
  final Color sobreAcento;

  /// Versión tenue del acento, para fondos de selección.
  final Color acentoSuave;

  // Colores de estado de materiales y préstamos.
  final Color disponible;
  final Color prestado;
  final Color reservado;
  final Color pendiente;
  final Color vencido;
  final Color fueraDeServicio;

  /// Paleta del modo claro: papel crema, tinta casi negra y acento terracota.
  static const ColoresApp claro = ColoresApp(
    papel: Color(0xFFF4EEE3),
    superficie: Color(0xFFFBF8F2),
    superficieElevada: Color(0xFFFFFFFF),
    linea: Color(0xFFD9CFBD),
    tinta: Color(0xFF231F1A),
    tintaSuave: Color(0xFF6B6256),
    acento: Color(0xFFB4472A),
    sobreAcento: Color(0xFFFFFFFF),
    acentoSuave: Color(0xFFF0DCCF),
    disponible: Color(0xFF3F6B4B),
    prestado: Color(0xFF2F5D7C),
    reservado: Color(0xFF8A6A1F),
    pendiente: Color(0xFF8A6A1F),
    vencido: Color(0xFFA32D2D),
    fueraDeServicio: Color(0xFF7A7266),
  );

  /// Paleta del modo oscuro: mismo carácter cálido, sin negros puros.
  static const ColoresApp oscuro = ColoresApp(
    papel: Color(0xFF1B1815),
    superficie: Color(0xFF24201C),
    superficieElevada: Color(0xFF2E2924),
    linea: Color(0xFF3F382F),
    tinta: Color(0xFFEDE5D6),
    tintaSuave: Color(0xFFA89F90),
    acento: Color(0xFFE08A66),
    sobreAcento: Color(0xFF1B1815),
    acentoSuave: Color(0xFF3A2A22),
    disponible: Color(0xFF7DB38B),
    prestado: Color(0xFF7FAED0),
    reservado: Color(0xFFD1AE5B),
    pendiente: Color(0xFFD1AE5B),
    vencido: Color(0xFFE27A7A),
    fueraDeServicio: Color(0xFFA89F90),
  );

  @override
  ColoresApp copyWith({
    Color? papel,
    Color? superficie,
    Color? superficieElevada,
    Color? linea,
    Color? tinta,
    Color? tintaSuave,
    Color? acento,
    Color? sobreAcento,
    Color? acentoSuave,
    Color? disponible,
    Color? prestado,
    Color? reservado,
    Color? pendiente,
    Color? vencido,
    Color? fueraDeServicio,
  }) {
    return ColoresApp(
      papel: papel ?? this.papel,
      superficie: superficie ?? this.superficie,
      superficieElevada: superficieElevada ?? this.superficieElevada,
      linea: linea ?? this.linea,
      tinta: tinta ?? this.tinta,
      tintaSuave: tintaSuave ?? this.tintaSuave,
      acento: acento ?? this.acento,
      sobreAcento: sobreAcento ?? this.sobreAcento,
      acentoSuave: acentoSuave ?? this.acentoSuave,
      disponible: disponible ?? this.disponible,
      prestado: prestado ?? this.prestado,
      reservado: reservado ?? this.reservado,
      pendiente: pendiente ?? this.pendiente,
      vencido: vencido ?? this.vencido,
      fueraDeServicio: fueraDeServicio ?? this.fueraDeServicio,
    );
  }

  @override
  ColoresApp lerp(ThemeExtension<ColoresApp>? other, double t) {
    if (other is! ColoresApp) return this;
    return ColoresApp(
      papel: Color.lerp(papel, other.papel, t)!,
      superficie: Color.lerp(superficie, other.superficie, t)!,
      superficieElevada:
          Color.lerp(superficieElevada, other.superficieElevada, t)!,
      linea: Color.lerp(linea, other.linea, t)!,
      tinta: Color.lerp(tinta, other.tinta, t)!,
      tintaSuave: Color.lerp(tintaSuave, other.tintaSuave, t)!,
      acento: Color.lerp(acento, other.acento, t)!,
      sobreAcento: Color.lerp(sobreAcento, other.sobreAcento, t)!,
      acentoSuave: Color.lerp(acentoSuave, other.acentoSuave, t)!,
      disponible: Color.lerp(disponible, other.disponible, t)!,
      prestado: Color.lerp(prestado, other.prestado, t)!,
      reservado: Color.lerp(reservado, other.reservado, t)!,
      pendiente: Color.lerp(pendiente, other.pendiente, t)!,
      vencido: Color.lerp(vencido, other.vencido, t)!,
      fueraDeServicio: Color.lerp(fueraDeServicio, other.fueraDeServicio, t)!,
    );
  }
}

/// Atajo para leer la paleta desde cualquier widget: `context.colores`.
extension ColoresAppContexto on BuildContext {
  ColoresApp get colores => Theme.of(this).extension<ColoresApp>()!;
}
