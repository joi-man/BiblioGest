import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/arranque.dart';
import 'app/pantalla_arranque.dart';
import 'core/actualizaciones/actualizaciones_provider.dart';
import 'core/local/modo_local.dart';
import 'core/sesion/sesion_guardada.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'app/auth_state.dart';
import 'core/theme/modo_tema_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Se cargan antes de arrancar para que el tema y las fechas en español
  // funcionen desde el primer cuadro.
  await initializeDateFormatting('es');
  final preferencias = await SharedPreferences.getInstance();
  final version = (await PackageInfo.fromPlatform()).version;
  await _arrancar(preferencias, version);
}

/// Muestra la pantalla de arranque mientras se prepara la aplicación y luego
/// la reemplaza por la aplicación real. Si falla, ofrece reintentar.
Future<void> _arrancar(SharedPreferences preferencias, String version) async {
  runApp(const PantallaArranque());
  try {
    final arranque = await prepararArranque();
    // Si se cerró la ventana sin cerrar sesión hace poco, se retoma donde quedó.
    final sesion = await SesionGuardada(preferencias).restaurar();
    if (sesion != null && !modoLocalNotifier.requiereConfiguracion) {
      authStateNotifier.iniciarSesion(sesion.usuario.rol);
    }
    runApp(
      ProviderScope(
        overrides: [
          preferenciasProvider.overrideWithValue(preferencias),
          urlApiProvider.overrideWithValue(arranque.urlApi),
          versionAppProvider.overrideWithValue(version),
          sesionRestauradaProvider.overrideWithValue(
            authStateNotifier.isAuthenticated ? sesion : null,
          ),
          // El instalador necesita cerrar el backend local para reemplazar sus archivos.
          cerrarBackendProvider.overrideWithValue(() async => arranque.backend?.detener()),
        ],
        child: const BiblioGestApp(),
      ),
    );
  } catch (error) {
    runApp(
      PantallaArranque(
        error: '$error',
        alReintentar: () => _arrancar(preferencias, version),
      ),
    );
  }
}
