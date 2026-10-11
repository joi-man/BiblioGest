import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Descarga [contenido] con el navegador y devuelve el nombre del archivo.
Future<String> guardarArchivo(
  Uint8List contenido,
  String nombre,
  String tipoContenido,
) async {
  final blob = web.Blob(
    [contenido.toJS].toJS,
    web.BlobPropertyBag(type: tipoContenido),
  );
  final direccion = web.URL.createObjectURL(blob);

  // Un enlace temporal con el atributo "download" hace que el navegador guarde el archivo.
  final enlace = web.HTMLAnchorElement()
    ..href = direccion
    ..download = nombre;
  enlace.click();
  web.URL.revokeObjectURL(direccion);

  return nombre;
}
