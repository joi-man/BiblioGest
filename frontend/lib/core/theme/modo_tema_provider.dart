import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'almacen_modo_tema.dart';

/// Instancia de [SharedPreferences]; se inicializa en `main()` con `overrideWithValue`.
final preferenciasProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Debe sobrescribirse en main() antes de runApp');
});

/// Almacén de persistencia del modo de tema.
final almacenModoTemaProvider = Provider<AlmacenModoTema>((ref) {
  return AlmacenModoTema(ref.watch(preferenciasProvider));
});

/// Modo de tema actual (claro/oscuro) y acciones para cambiarlo.
final modoTemaProvider =
    StateNotifierProvider<ModoTemaNotifier, ThemeMode>((ref) {
  return ModoTemaNotifier(ref.watch(almacenModoTemaProvider));
});

class ModoTemaNotifier extends StateNotifier<ThemeMode> {
  ModoTemaNotifier(this._almacen) : super(_almacen.leer());

  final AlmacenModoTema _almacen;

  /// Cambia entre modo claro y oscuro y recuerda la elección.
  Future<void> alternar() async {
    final nuevo = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = nuevo;
    await _almacen.guardar(nuevo);
  }
}
