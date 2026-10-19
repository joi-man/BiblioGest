import 'material.dart';

/// Textos para mostrar los autores, el tomo y los ejemplares de un material.
extension MaterialPresentacion on MaterialBiblioteca {
  /// Todos los autores separados por coma; si no hay lista, el resumen en texto.
  String get autoresTexto {
    if (autores.isNotEmpty) return autores.map((a) => a.nombre).join(', ');
    return autor ?? '';
  }

  /// "Tomo 2 de 5", "Tomo 2" o vacío si el material no es de varios tomos.
  String get etiquetaTomo {
    final numero = tomo?.trim() ?? '';
    if (numero.isEmpty) return '';
    return totalTomos == null ? 'Tomo $numero' : 'Tomo $numero de $totalTomos';
  }

  /// Título seguido del tomo si lo tiene: "Historia de Roma · Tomo 2 de 5".
  String get tituloConTomo =>
      etiquetaTomo.isEmpty ? titulo : '$titulo · $etiquetaTomo';

  /// "3 de 5" (libres sobre el total), para columnas y etiquetas cortas.
  String get ejemplaresCorto => '$ejemplaresLibres de $cantidadTotal';

  /// "3 disponibles de 5", para el estudiante y el detalle.
  String get ejemplaresDisponibles {
    final libres = ejemplaresLibres;
    final texto = libres == 1 ? '1 disponible' : '$libres disponibles';
    return '$texto de $cantidadTotal';
  }
}
