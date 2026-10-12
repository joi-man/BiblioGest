import 'instalador_actualizaciones_base.dart';
import 'manifiesto.dart';

/// Versión para plataformas sin instalador (web y móvil): no hace nada.
InstaladorActualizaciones crearInstaladorActualizaciones({
  String? carpetaDescargas,
}) => _InstaladorNulo();

class _InstaladorNulo implements InstaladorActualizaciones {
  @override
  bool get disponible => false;

  @override
  Future<void> limpiarDescargas(String versionActual) async {}

  @override
  Future<String> descargar(
    Manifiesto manifiesto, {
    required void Function(double) alProgreso,
  }) => throw const ErrorInstalacion(
    'Las actualizaciones solo existen en el ejecutable de Windows',
  );

  @override
  Future<void> instalar(
    String ruta, {
    required Future<void> Function() cerrarBackend,
  }) => throw const ErrorInstalacion(
    'Las actualizaciones solo existen en el ejecutable de Windows',
  );

  @override
  Future<void> salir({required Future<void> Function() cerrarBackend}) async {}
}
