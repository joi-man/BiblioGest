import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import 'instalador_actualizaciones_base.dart';
import 'manifiesto.dart';
import 'version_app.dart';

/// Instalador para el ejecutable de Windows.
///
/// [carpetaDescargas] existe para las pruebas; por defecto es
/// `%LOCALAPPDATA%\BiblioGest\actualizaciones`, junto a los datos de la biblioteca.
InstaladorActualizaciones crearInstaladorActualizaciones({String? carpetaDescargas}) =>
    _InstaladorWindows(carpetaDescargas);

class _InstaladorWindows implements InstaladorActualizaciones {
  _InstaladorWindows(this._carpetaIndicada);

  final String? _carpetaIndicada;

  @override
  bool get disponible => Platform.isWindows;

  Directory get _carpeta {
    if (_carpetaIndicada != null) return Directory(_carpetaIndicada);
    final base = Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path;
    final s = Platform.pathSeparator;
    return Directory('$base${s}BiblioGest${s}actualizaciones');
  }

  @override
  Future<void> limpiarDescargas(String versionActual) async {
    final actual = VersionApp.intentar(versionActual);
    final carpeta = _carpeta;
    if (actual == null || !await carpeta.exists()) return;
    final formato = RegExp(r'^BiblioGest-Setup-(\d+\.\d+\.\d+)\.exe$');
    await for (final entrada in carpeta.list()) {
      if (entrada is! File) continue;
      final nombre = entrada.uri.pathSegments.last;
      final version = VersionApp.intentar(formato.firstMatch(nombre)?.group(1));
      // Todo lo que no sea el instalador de una versión posterior (parciales,
      // instaladores ya aplicados, archivos ajenos) sobra.
      if (version == null || version <= actual) {
        try {
          await entrada.delete();
        } on FileSystemException {
          // En uso o sin permiso: se intentará en el próximo inicio.
        }
      }
    }
  }

  @override
  Future<String> descargar(Manifiesto manifiesto, {required void Function(double) alProgreso}) async {
    final carpeta = _carpeta;
    await carpeta.create(recursive: true);
    final destino = File('${carpeta.path}${Platform.pathSeparator}${manifiesto.nombreArchivo}');

    // Un instalador ya descargado y verificado se reutiliza (por ejemplo, tras
    // cerrar la app a mitad de camino o si la instalación no llegó a ejecutarse).
    if (await destino.exists() && await _esValido(destino, manifiesto)) {
      alProgreso(1);
      return destino.path;
    }

    // Se baja a un archivo parcial: nunca queda un instalador a medias con el nombre final.
    final parcial = File('${destino.path}.parcial');
    if (await parcial.exists()) await parcial.delete();
    try {
      await Dio().download(
        manifiesto.url.toString(),
        parcial.path,
        onReceiveProgress: (recibido, total) {
          final esperado = total > 0 ? total : manifiesto.tamano;
          alProgreso((recibido / esperado).clamp(0.0, 1.0));
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
    } on DioException {
      if (await parcial.exists()) await parcial.delete();
      throw const ErrorInstalacion(
        'No se pudo descargar la actualización. Revisa tu conexión a internet e inténtalo de nuevo.',
      );
    }

    if (!await _esValido(parcial, manifiesto)) {
      await parcial.delete();
      throw const ErrorInstalacion(
        'La descarga está dañada o no es la esperada, por seguridad no se instaló. Inténtalo de nuevo.',
      );
    }
    if (await destino.exists()) await destino.delete();
    await parcial.rename(destino.path);
    return destino.path;
  }

  /// Verifica tamaño y huella SHA-256 sin cargar el archivo completo en memoria.
  Future<bool> _esValido(File archivo, Manifiesto manifiesto) async {
    if (await archivo.length() != manifiesto.tamano) return false;
    final huella = await sha256.bind(archivo.openRead()).first;
    return huella.toString() == manifiesto.sha256;
  }

  @override
  Future<void> instalar(String ruta, {required Future<void> Function() cerrarBackend}) async {
    // Inno Setup en modo silencioso con ventana de progreso: cierra BiblioGest
    // si siguiera abierto, reemplaza los archivos y la vuelve a abrir (/RELANZAR=1).
    await Process.start(
      ruta,
      const [
        '/SILENT',
        '/SUPPRESSMSGBOXES',
        '/NORESTART',
        '/CLOSEAPPLICATIONS',
        '/RELANZAR=1',
      ],
      mode: ProcessStartMode.detached,
    );
    await salir(cerrarBackend: cerrarBackend);
  }

  @override
  Future<void> salir({required Future<void> Function() cerrarBackend}) async {
    await cerrarBackend();
    exit(0);
  }
}
