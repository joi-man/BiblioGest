/// Formatos en que se puede descargar un listado.
enum FormatoExportacion {
  excel('xlsx', 'Excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
  pdf('pdf', 'PDF', 'application/pdf'),
  csv('csv', 'CSV', 'text/csv');

  const FormatoExportacion(this.extension, this.etiqueta, this.tipoContenido);

  /// Extensión del archivo y valor del parámetro `formato` del backend.
  final String extension;
  final String etiqueta;
  final String tipoContenido;
}
