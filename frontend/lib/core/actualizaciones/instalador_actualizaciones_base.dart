import 'manifiesto.dart';

/// Falló la descarga o la verificación del instalador.
class ErrorInstalacion implements Exception {
  const ErrorInstalacion(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Marca a los instaladores tras los cuales la aplicación sigue abierta (el
/// instalador del sistema se abre encima y la persona puede cancelarlo), a
/// diferencia de Windows, donde la aplicación se cierra para actualizarse.
abstract interface class ContinuaTrasInstalar {}

/// Descarga el instalador de una versión y lo ejecuta.
///
/// No usa `dart:io`, para poder importarse también desde la versión web.
abstract class InstaladorActualizaciones {
  /// False donde no se pueden instalar actualizaciones (web, móvil).
  bool get disponible;

  /// Borra instaladores ya usados o viejos, dejando solo los de versiones
  /// posteriores a [versionActual].
  Future<void> limpiarDescargas(String versionActual);

  /// Descarga el instalador (o reutiliza uno ya descargado y verificado) y
  /// devuelve su ruta. Comprueba tamaño y huella SHA-256 antes de entregarlo.
  Future<String> descargar(Manifiesto manifiesto, {required void Function(double) alProgreso});

  /// Ejecuta el instalador sobre la instalación actual y cierra la aplicación.
  /// Los datos de la biblioteca no se tocan. [cerrarBackend] debe terminar el
  /// backend local para que el instalador pueda reemplazar sus archivos.
  Future<void> instalar(String ruta, {required Future<void> Function() cerrarBackend});

  /// Cierra la aplicación (y su backend local).
  Future<void> salir({required Future<void> Function() cerrarBackend});
}
