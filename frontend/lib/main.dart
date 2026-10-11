import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/theme/modo_tema_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Se cargan antes de arrancar para que el tema y las fechas en español
  // funcionen desde el primer cuadro.
  await initializeDateFormatting('es');
  final preferencias = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [preferenciasProvider.overrideWithValue(preferencias)],
      child: const BiblioGestApp(),
    ),
  );
}
