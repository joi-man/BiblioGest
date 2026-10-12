import 'dart:convert';

import 'package:frontend/features/auth/data/models/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'arranque_so.dart';

/// Vigencia de la sesión guardada en el navegador: algo menos que el token (60 min).
const vigenciaSesionWeb = Duration(minutes: 55);

/// Sesión que se conserva al cerrar la ventana sin cerrar sesión.
///
/// Se puede recuperar al volver a abrir la aplicación mientras no pase
/// [duracion] y el equipo no se haya reiniciado. Se usa una sola vez.
class SesionGuardada {
  SesionGuardada(
    this._preferencias, {
    DateTime Function()? ahora,
    Future<int?> Function()? arranqueSo,
    Duration? vigencia,
  }) : _ahora = ahora ?? DateTime.now,
       _vigencia = vigencia ?? duracion,
       _arranqueSo = arranqueSo ?? instanteArranqueSo;

  final SharedPreferences _preferencias;
  final DateTime Function() _ahora;
  final Future<int?> Function() _arranqueSo;
  final Duration _vigencia;

  /// Tiempo que se mantiene la sesión con la aplicación cerrada.
  static const duracion = Duration(minutes: 30);

  /// Margen para comparar el arranque del sistema (los relojes se ajustan un poco).
  static const _margenArranque = Duration(minutes: 2);

  static const _clave = 'sesion_guardada';

  Future<void> guardar(LoginResponse sesion) async {
    await _preferencias.setString(
      _clave,
      jsonEncode({
        'sesion': sesion.toJson(),
        'guardadaEn': _ahora().millisecondsSinceEpoch,
        'arranque': await _arranqueSo(),
      }),
    );
  }

  Future<void> borrar() => _preferencias.remove(_clave);

  /// Devuelve la sesión guardada si todavía vale.
  ///
  /// Con [consumir] (el escritorio) la elimina en cualquier caso: se usa una sola
  /// vez. En la web no se consume, para que F5 u otra pestaña la recuperen
  /// mientras dure su vigencia.
  Future<LoginResponse?> restaurar({bool consumir = true}) async {
    final texto = _preferencias.getString(_clave);
    if (texto == null) return null;
    if (consumir) await borrar();
    try {
      final datos = jsonDecode(texto) as Map<String, dynamic>;
      final guardadaEn = DateTime.fromMillisecondsSinceEpoch(
        datos['guardadaEn'] as int,
      );
      final transcurrido = _ahora().difference(guardadaEn);
      if (transcurrido.isNegative || transcurrido > _vigencia) {
        await borrar();
        return null;
      }

      final arranqueGuardado = datos['arranque'] as int?;
      final arranqueActual = await _arranqueSo();
      if (arranqueGuardado != null && arranqueActual != null) {
        final diferencia = (arranqueActual - arranqueGuardado).abs();
        if (diferencia > _margenArranque.inMilliseconds)
          return null; // el equipo se reinició
      }
      return LoginResponse.fromJson(
        Map<String, dynamic>.from(datos['sesion'] as Map),
      );
    } catch (_) {
      return null;
    }
  }
}
