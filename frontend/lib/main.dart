import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/theme/modo_tema_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Se carga antes de arrancar para que el tema correcto se vea desde el primer cuadro.
  final preferencias = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [preferenciasProvider.overrideWithValue(preferencias)],
      child: const BiblioGestApp(),
    ),
  );
}
