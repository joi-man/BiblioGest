import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/api_constants.dart';

/// Dirección de la API que usa la aplicación.
///
/// En el ejecutable de escritorio es el backend local; en la web, el servidor.
/// `main` la reemplaza antes de arrancar.
final urlApiProvider = Provider<String>((ref) => ApiConstants.baseUrl);

/// Estado del ejecutable de escritorio que necesita el router.
///
/// Es un [ChangeNotifier] para que `GoRouter` reevalúe sus redirecciones, igual
/// que con la sesión.
class ModoLocal extends ChangeNotifier {
  bool _activo = false;
  bool _requiereConfiguracion = false;

  /// True cuando la aplicación trabaja con su propio backend (ejecutable de escritorio).
  bool get activo => _activo;

  /// True mientras el equipo no tenga ni servidor ni administrador configurado.
  bool get requiereConfiguracion => _requiereConfiguracion;

  void iniciar({required bool activo, required bool requiereConfiguracion}) {
    _activo = activo;
    _requiereConfiguracion = requiereConfiguracion;
    notifyListeners();
  }

  /// El equipo ya tiene administrador o servidor: se puede iniciar sesión.
  void configuracionTerminada() {
    _requiereConfiguracion = false;
    notifyListeners();
  }
}

final modoLocalNotifier = ModoLocal();

/// True si la aplicación es el ejecutable de escritorio con backend propio.
final modoLocalProvider = Provider<bool>((ref) => modoLocalNotifier.activo);
