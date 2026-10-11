import 'dart:io';
import 'dart:typed_data';

/// Escribe [contenido] en la carpeta Descargas y devuelve la ruta del archivo.
///
/// Si ya existe un archivo con ese nombre agrega un número (`nombre (2).ext`)
/// para no sobrescribirlo.
Future<String> guardarArchivo(
  Uint8List contenido,
  String nombre,
  String tipoContenido,
) async {
  final carpeta = _carpetaDescargas();
  final archivo = _rutaLibre(carpeta, nombre);
  await archivo.writeAsBytes(contenido);
  return archivo.path;
}

/// Carpeta Descargas del usuario; si no existe usa la carpeta temporal.
Directory _carpetaDescargas() {
  final inicio =
      Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
  if (inicio != null) {
    final descargas = Directory('$inicio${Platform.pathSeparator}Downloads');
    if (descargas.existsSync()) return descargas;
  }
  return Directory.systemTemp;
}

File _rutaLibre(Directory carpeta, String nombre) {
  final punto = nombre.lastIndexOf('.');
  final base = punto == -1 ? nombre : nombre.substring(0, punto);
  final extension = punto == -1 ? '' : nombre.substring(punto);

  var archivo = File('${carpeta.path}${Platform.pathSeparator}$nombre');
  for (var numero = 2; archivo.existsSync(); numero++) {
    archivo = File(
        '${carpeta.path}${Platform.pathSeparator}$base ($numero)$extension');
  }
  return archivo;
}
