/// Normaliza texto para comparar sin importar mayúsculas ni tildes.
///
/// Es lo mismo que hace el servidor al buscar, para que la búsqueda sobre una
/// copia guardada (sin conexión) dé los mismos resultados.
String sinTildes(String texto) => texto
    .toLowerCase()
    .replaceAll(RegExp('[áàäâ]'), 'a')
    .replaceAll(RegExp('[éèëê]'), 'e')
    .replaceAll(RegExp('[íìïî]'), 'i')
    .replaceAll(RegExp('[óòöô]'), 'o')
    .replaceAll(RegExp('[úùüû]'), 'u')
    .replaceAll('ñ', 'n')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// Las palabras de una búsqueda, sin tildes y sin repetir.
List<String> palabrasDeBusqueda(String texto) {
  final normalizado = sinTildes(texto);
  if (normalizado.isEmpty) return const [];
  return normalizado.split(' ').toSet().toList();
}

/// `true` si [texto] contiene todas las palabras de [busqueda] (en cualquier orden).
bool coincideConTodasLasPalabras(String texto, String busqueda) {
  final palabras = palabrasDeBusqueda(busqueda);
  if (palabras.isEmpty) return true;
  final normalizado = sinTildes(texto);
  return palabras.every(normalizado.contains);
}
