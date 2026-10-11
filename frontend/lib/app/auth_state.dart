import 'package:flutter/foundation.dart';

/// Estado mínimo de la sesión que necesita el router para decidir a dónde ir.
///
/// Es un [ChangeNotifier] para que `GoRouter` reevalúe sus redirecciones cada
/// vez que alguien inicia o cierra sesión.
class AuthState extends ChangeNotifier {
  bool _autenticado = false;

  /// Mensaje que debe mostrar la pantalla de acceso (por ejemplo, "tu sesión terminó").
  /// Quien lo muestra debe dejarlo en null.
  String? avisoAlLogin;
  String? _rol;

  bool get isAuthenticated => _autenticado;

  /// Rol del usuario con sesión iniciada (`admin`, `bibliotecario` o `estudiante`).
  String? get rol => _rol;

  bool get esEstudiante => _rol == 'estudiante';

  /// Marca la sesión como iniciada con el [rol] indicado.
  void iniciarSesion(String rol) {
    _autenticado = true;
    _rol = rol;
    notifyListeners();
  }

  /// Marca la sesión como cerrada.
  void cerrarSesion() {
    _autenticado = false;
    _rol = null;
    notifyListeners();
  }
}

final authStateNotifier = AuthState();
