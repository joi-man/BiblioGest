import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/arranque.dart';
import 'app/pantalla_arranque.dart';
import 'core/local/modo_local.dart';
import 'core/theme/modo_tema_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Se cargan antes de arrancar para que el tema y las fechas en español
  // funcionen desde el primer cuadro.
  await initializeDateFormatting('es');
  final preferencias = await SharedPreferences.getInstance();
  await _arrancar(preferencias);
}

/// Muestra la pantalla de arranque mientras se prepara la aplicación y luego
/// la reemplaza por la aplicación real. Si falla, ofrece reintentar.
Future<void> _arrancar(SharedPreferences preferencias) async {
  runApp(const PantallaArranque());
  try {
    final arranque = await prepararArranque();
    runApp(
      ProviderScope(
        overrides: [
          preferenciasProvider.overrideWithValue(preferencias),
          urlApiProvider.overrideWithValue(arranque.urlApi),
        ],
        child: const BiblioGestApp(),
      ),
    );
  } catch (error) {
    runApp(
      PantallaArranque(
        error: '$error',
        alReintentar: () => _arrancar(preferencias),
      ),
    );
  }
}
