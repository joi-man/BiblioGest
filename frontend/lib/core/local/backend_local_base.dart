/// Backend que la aplicación de escritorio inicia junto a ella.
///
/// No usa `dart:io` para poder importarse también desde la versión web.
class BackendLocal {
  const BackendLocal({required this.url, required this.detener});

  /// Dirección donde escucha, por ejemplo `http://127.0.0.1:50321`.
  final String url;

  /// Termina el proceso del backend.
  final Future<void> Function() detener;
}

/// El backend local no pudo iniciarse a tiempo.
class ErrorBackendLocal implements Exception {
  const ErrorBackendLocal(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
