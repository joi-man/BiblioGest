// Guarda o descarga un archivo según la plataforma:
// - navegador: dispara la descarga del navegador.
// - escritorio: lo escribe en la carpeta Descargas.
export 'guardar_archivo_io.dart'
    if (dart.library.js_interop) 'guardar_archivo_web.dart';
