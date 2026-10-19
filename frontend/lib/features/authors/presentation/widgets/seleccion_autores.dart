import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/texto_busqueda.dart';
import 'package:frontend/features/authors/data/models/autor.dart';

/// Los autores elegidos para un material: los que ya existen y los que se
/// crearán al guardar (solo tienen nombre).
///
/// Es inmutable: cada cambio devuelve una selección nueva. Evita repetidos
/// comparando los nombres sin tildes ni mayúsculas, igual que el servidor.
@immutable
class SeleccionAutores {
  const SeleccionAutores({this.existentes = const [], this.nuevos = const []});

  /// Autores que ya están registrados.
  final List<Autor> existentes;

  /// Nombres de autores que se crearán junto con el material.
  final List<String> nuevos;

  bool get vacia => existentes.isEmpty && nuevos.isEmpty;

  /// Nombres en el orden en que se mostrarán: primero los registrados.
  List<String> get nombres => [...existentes.map((a) => a.nombre), ...nuevos];

  bool contiene(String nombre) {
    final buscado = sinTildes(nombre);
    return nombres.any((n) => sinTildes(n) == buscado);
  }

  SeleccionAutores agregarExistente(Autor autor) {
    if (existentes.any((a) => a.id == autor.id) || contiene(autor.nombre)) {
      return this;
    }
    return SeleccionAutores(existentes: [...existentes, autor], nuevos: nuevos);
  }

  /// Agrega autores por nombre. Pueden venir varios separados por punto y coma.
  SeleccionAutores agregarNombres(String texto) {
    var resultado = this;
    for (final nombre in dividirNombres(texto)) {
      if (!resultado.contiene(nombre)) {
        resultado = SeleccionAutores(
          existentes: resultado.existentes,
          nuevos: [...resultado.nuevos, nombre],
        );
      }
    }
    return resultado;
  }

  SeleccionAutores quitarExistente(String id) => SeleccionAutores(
    existentes: existentes.where((a) => a.id != id).toList(),
    nuevos: nuevos,
  );

  SeleccionAutores quitarNuevo(String nombre) => SeleccionAutores(
    existentes: existentes,
    nuevos: nuevos.where((n) => n != nombre).toList(),
  );

  /// Campos del cuerpo de la petición. El material queda con exactamente estos autores.
  Map<String, dynamic> aPeticion() => {
    'autores_ids': [for (final a in existentes) a.id],
    'autores_nuevos': nuevos,
  };

  /// Parte "Cervantes; Quevedo" en nombres limpios y sin vacíos.
  ///
  /// La coma no separa: "García Márquez, Gabriel" es un solo autor.
  static List<String> dividirNombres(String texto) => [
    for (final parte in texto.split(';'))
      if (parte.trim().isNotEmpty)
        parte.trim().replaceAll(RegExp(r'\s+'), ' '),
  ];

  @override
  bool operator ==(Object other) =>
      other is SeleccionAutores &&
      listEquals(other.existentes, existentes) &&
      listEquals(other.nuevos, nuevos);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(existentes), Object.hashAll(nuevos));
}
