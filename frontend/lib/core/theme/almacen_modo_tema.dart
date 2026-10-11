import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda y recupera en el dispositivo el modo de tema elegido por el usuario.
///
/// Su única responsabilidad es la persistencia; no conoce a Riverpod ni a la UI.
class AlmacenModoTema {
  AlmacenModoTema(this._preferencias);

  static const String _clave = 'modo_tema';

  final SharedPreferences _preferencias;

  /// Devuelve el modo guardado, o [ThemeMode.light] si nunca se eligió uno.
  ThemeMode leer() {
    switch (_preferencias.getString(_clave)) {
      case 'oscuro':
        return ThemeMode.dark;
      case 'sistema':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  /// Guarda el [modo] elegido.
  Future<void> guardar(ThemeMode modo) {
    final valor = switch (modo) {
      ThemeMode.dark => 'oscuro',
      ThemeMode.system => 'sistema',
      ThemeMode.light => 'claro',
    };
    return _preferencias.setString(_clave, valor);
  }
}
