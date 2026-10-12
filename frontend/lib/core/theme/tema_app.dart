import 'package:flutter/material.dart';
import 'colores_app.dart';
import 'tipografia_app.dart';

/// Construye los [ThemeData] claro y oscuro a partir de la paleta [ColoresApp].
///
/// El estilo es editorial: superficies planas, filetes finos en lugar de
/// sombras, esquinas poco redondeadas y un único color de acento.
class TemaApp {
  TemaApp._();

  /// Radio de esquina usado en todos los componentes.
  static const double radio = 4;

  static ThemeData get claro => _construir(ColoresApp.claro, Brightness.light);

  static ThemeData get oscuro => _construir(ColoresApp.oscuro, Brightness.dark);

  static ThemeData _construir(ColoresApp c, Brightness brillo) {
    final textos = TipografiaApp.crear(c.tinta, c.tintaSuave);
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radio),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brillo,
      fontFamily: FamiliasTipograficas.sans,
      textTheme: textos,
      scaffoldBackgroundColor: c.papel,
      colorScheme: _esquemaColor(c, brillo),
      extensions: <ThemeExtension<dynamic>>[c],
      dividerTheme: DividerThemeData(color: c.linea, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.papel,
        foregroundColor: c.tinta,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textos.titleLarge,
        shape: Border(bottom: BorderSide(color: c.linea)),
      ),
      cardTheme: CardThemeData(
        color: c.superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio),
          side: BorderSide(color: c.linea),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.superficie,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio + 2),
          side: BorderSide(color: c.linea),
        ),
        titleTextStyle: textos.headlineSmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.superficieElevada,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: textos.bodyMedium?.copyWith(color: c.tintaSuave),
        floatingLabelStyle: textos.labelMedium?.copyWith(color: c.acento),
        border: _borde(c.linea),
        enabledBorder: _borde(c.linea),
        focusedBorder: _borde(c.acento, ancho: 1.6),
        errorBorder: _borde(c.vencido),
        focusedErrorBorder: _borde(c.vencido, ancho: 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.acento,
          foregroundColor: c.sobreAcento,
          elevation: 0,
          shape: forma,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: textos.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.acento,
          foregroundColor: c.sobreAcento,
          elevation: 0,
          shape: forma,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: textos.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.tinta,
          side: BorderSide(color: c.tinta.withValues(alpha: 0.5)),
          shape: forma,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: textos.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.acento,
          shape: forma,
          textStyle: textos.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: c.tinta),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.acento,
        foregroundColor: c.sobreAcento,
        elevation: 0,
        shape: forma,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.tinta,
        unselectedLabelColor: c.tintaSuave,
        labelStyle: textos.labelLarge,
        unselectedLabelStyle: textos.labelLarge,
        indicatorColor: c.acento,
        dividerColor: c.linea,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.superficie,
        selectedColor: c.acentoSuave,
        side: BorderSide(color: c.linea),
        shape: forma,
        labelStyle: textos.labelMedium?.copyWith(color: c.tinta),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.superficie,
        indicatorColor: c.acentoSuave,
        indicatorShape: forma,
        selectedIconTheme: IconThemeData(color: c.acento),
        unselectedIconTheme: IconThemeData(color: c.tintaSuave),
        selectedLabelTextStyle: textos.labelMedium?.copyWith(color: c.acento),
        unselectedLabelTextStyle: textos.labelMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.superficie,
        indicatorColor: c.acentoSuave,
        indicatorShape: forma,
        surfaceTintColor: Colors.transparent,
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith((estados) {
          final activo = estados.contains(WidgetState.selected);
          return IconThemeData(color: activo ? c.acento : c.tintaSuave);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((estados) {
          final activo = estados.contains(WidgetState.selected);
          return textos.labelMedium?.copyWith(
            color: activo ? c.acento : c.tintaSuave,
          );
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.superficieElevada,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio),
          side: BorderSide(color: c.linea),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.tinta,
        contentTextStyle: textos.bodyMedium?.copyWith(color: c.papel),
        behavior: SnackBarBehavior.floating,
        shape: forma,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.tintaSuave,
        textColor: c.tinta,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.acento),
    );
  }

  /// Esquema de color de Material derivado de la paleta propia.
  static ColorScheme _esquemaColor(ColoresApp c, Brightness brillo) {
    return ColorScheme(
      brightness: brillo,
      primary: c.acento,
      onPrimary: c.sobreAcento,
      secondary: c.tintaSuave,
      onSecondary: c.papel,
      error: c.vencido,
      onError: c.sobreAcento,
      surface: c.superficie,
      onSurface: c.tinta,
      outline: c.linea,
      outlineVariant: c.linea,
      primaryContainer: c.acentoSuave,
      onPrimaryContainer: c.tinta,
      surfaceContainerHighest: c.superficieElevada,
    );
  }

  static OutlineInputBorder _borde(Color color, {double ancho = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radio),
      borderSide: BorderSide(color: color, width: ancho),
    );
  }
}
