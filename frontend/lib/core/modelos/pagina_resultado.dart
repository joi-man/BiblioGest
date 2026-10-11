/// Una página de resultados de un listado del backend, con los datos para
/// navegar el resto de las páginas.
class PaginaResultado<T> {
  const PaginaResultado({
    required this.items,
    required this.total,
    required this.pagina,
    required this.tamano,
    required this.totalPaginas,
  });

  /// Construye la página a partir del JSON del backend; [leerItem] convierte cada fila.
  factory PaginaResultado.desdeJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> fila) leerItem,
  ) {
    return PaginaResultado<T>(
      items: (json['items'] as List)
          .map((fila) => leerItem(fila as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      pagina: json['pagina'] as int,
      tamano: json['tamano'] as int,
      totalPaginas: json['total_paginas'] as int,
    );
  }

  /// Filas de esta página.
  final List<T> items;

  /// Filas que cumplen el filtro en todas las páginas.
  final int total;

  /// Número de página actual, desde 1.
  final int pagina;

  /// Filas por página.
  final int tamano;
  final int totalPaginas;

  /// Posición (desde 1) de la primera fila de la página; 0 si no hay filas.
  int get desde => items.isEmpty ? 0 : (pagina - 1) * tamano + 1;

  /// Posición de la última fila de la página.
  int get hasta => items.isEmpty ? 0 : desde + items.length - 1;

  /// Página a mostrar tras borrar filas: si la actual quedó vacía (era la
  /// última y se eliminó su único elemento), la última que aún tiene datos.
  int get paginaValida => items.isEmpty && total > 0 ? totalPaginas : pagina;

  bool get hayAnterior => pagina > 1;
  bool get haySiguiente => pagina < totalPaginas;

}
