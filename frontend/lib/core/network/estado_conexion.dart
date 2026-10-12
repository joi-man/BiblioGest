import 'package:flutter/foundation.dart';

/// Situación de la conexión con el servidor, vista desde la aplicación móvil.
enum FaseConexion {
  /// Todo normal: las últimas peticiones llegaron al servidor.
  conectado,

  /// Una petición falló por la red y se está reintentando.
  reconectando,

  /// Se agotaron los reintentos: hay que avisar a la persona.
  sinConexion,
}

/// Estado compartido de la conexión. Lo actualiza el cliente HTTP
/// (ver `ReintentoInterceptor`) y lo muestra el aviso de la app móvil.
///
/// Es un [ChangeNotifier] global, igual que `authStateNotifier`, porque lo
/// escribe código que vive fuera del árbol de widgets.
class EstadoConexion extends ChangeNotifier {
  FaseConexion _fase = FaseConexion.conectado;
  int _intento = 0;
  int _maximo = 0;

  FaseConexion get fase => _fase;

  /// Número del reintento en curso (1, 2, 3...). Solo vale en [FaseConexion.reconectando].
  int get intento => _intento;

  /// Cantidad de reintentos antes de rendirse y avisar.
  int get maximo => _maximo;

  bool get hayProblema => _fase != FaseConexion.conectado;

  void reconectando(int intento, int maximo) {
    // Si ya se había avisado, un reintento nuevo no debe ocultar el aviso.
    if (_fase == FaseConexion.sinConexion) return;
    _fase = FaseConexion.reconectando;
    _intento = intento;
    _maximo = maximo;
    notifyListeners();
  }

  void sinConexion() {
    if (_fase == FaseConexion.sinConexion) return;
    _fase = FaseConexion.sinConexion;
    notifyListeners();
  }

  /// Una petición llegó al servidor: la conexión funciona.
  void conectado() {
    if (_fase == FaseConexion.conectado) return;
    _fase = FaseConexion.conectado;
    _intento = 0;
    notifyListeners();
  }
}

/// El estado de la conexión de toda la aplicación.
final estadoConexion = EstadoConexion();
