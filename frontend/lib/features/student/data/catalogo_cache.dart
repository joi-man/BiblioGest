import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/materials/data/models/material.dart';

/// Última copia del catálogo que se pudo descargar, para poder consultarlo sin
/// internet. Solo sirve para leer: nada de lo que se haga sin conexión se guarda.
class CatalogoCache {
  CatalogoCache(this._preferencias);

  final SharedPreferences _preferencias;

  static const _claveMateriales = 'catalogo_cache_materiales';
  static const _claveFecha = 'catalogo_cache_fecha';

  /// Guarda el catálogo completo (sin filtros) recién descargado.
  Future<void> guardar(
    List<MaterialBiblioteca> materiales, {
    DateTime? ahora,
  }) async {
    final contenido = jsonEncode([for (final m in materiales) m.toJson()]);
    await _preferencias.setString(_claveMateriales, contenido);
    await _preferencias.setString(
      _claveFecha,
      (ahora ?? DateTime.now()).toUtc().toIso8601String(),
    );
  }

  /// El catálogo guardado y cuándo se descargó, o `null` si no hay copia o está dañada.
  ({List<MaterialBiblioteca> materiales, DateTime fecha})? leer() {
    final contenido = _preferencias.getString(_claveMateriales);
    final fecha = DateTime.tryParse(_preferencias.getString(_claveFecha) ?? '');
    if (contenido == null || fecha == null) return null;

    try {
      final lista = (jsonDecode(contenido) as List)
          .map(
            (json) => MaterialBiblioteca.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return (materiales: lista, fecha: fecha);
    } catch (_) {
      // Copia dañada o de una versión anterior de la app: se ignora.
      return null;
    }
  }

  Future<void> borrar() async {
    await _preferencias.remove(_claveMateriales);
    await _preferencias.remove(_claveFecha);
  }
}
