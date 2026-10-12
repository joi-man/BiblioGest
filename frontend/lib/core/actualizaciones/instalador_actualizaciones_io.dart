import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'instalador_actualizaciones_base.dart';
import 'manifiesto.dart';
import 'version_app.dart';

/// Instalador de actualizaciones para el sistema donde corre la aplicación:
/// el ejecutable de Windows o la app de Android.
///
/// [carpetaDescargas] existe para las pruebas; por defecto es
/// `%LOCALAPPDATA%\BiblioGest\actualizaciones` en Windows (junto a los datos de
/// la biblioteca) y la carpeta de caché de la app en Android.
InstaladorActualizaciones crearInstaladorActualizaciones({String? carpetaDescargas}) {
  if (Platform.isAndroid) return _InstaladorAndroid(carpetaDescargas);
  return _InstaladorWindows(carpetaDescargas);
}

/// Lo común a ambos sistemas: guardar la descarga verificada y limpiar las viejas.
/// Cada uno decide dónde guarda los archivos y cómo se instalan.
abstract class _InstaladorDescargable implements InstaladorActualizaciones {
  _InstaladorDescargable(this._carpetaIndicada);

  final String? _carpetaIndicada;

  /// Nombre de los archivos descargados, con la versión en el primer grupo.
  RegExp get _formatoArchivo;

  Future<Directory> _carpetaPorDefecto();

  Future<Directory> _carpeta() async =>
      _carpetaIndicada != null ? Directory(_carpetaIndicada) : _carpetaPorDefecto();

  @override
  Future<void> limpiarDescargas(String versionActual) async {
    final actual = VersionApp.intentar(versionActual);
    final carpeta = await _carpeta();
    if (actual == null || !await carpeta.exists()) return;
    await for (final entrada in carpeta.list()) {
      if (entrada is! File) continue;
      final nombre = entrada.uri.pathSegments.last;
      final version = VersionApp.intentar(_formatoArchivo.firstMatch(nombre)?.group(1));
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
    final carpeta = await _carpeta();
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
}

/// Instalador para el ejecutable de Windows.
class _InstaladorWindows extends _InstaladorDescargable {
  _InstaladorWindows(super.carpetaIndicada);

  @override
  bool get disponible => Platform.isWindows;

  @override
  RegExp get _formatoArchivo => RegExp(r'^BiblioGest-Setup-(\d+\.\d+\.\d+)\.exe$');

  @override
  Future<Directory> _carpetaPorDefecto() async {
    final base = Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path;
    final s = Platform.pathSeparator;
    return Directory('$base${s}BiblioGest${s}actualizaciones');
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

/// Instalador para la app de Android.
///
/// La descarga queda en la carpeta de caché de la app y se entrega al
/// instalador del sistema (ver `MainActivity.kt`), que pide confirmar a la
/// persona. Android solo acepta la actualización si el APK está firmado con la
/// misma clave que la app instalada.
class _InstaladorAndroid extends _InstaladorDescargable implements ContinuaTrasInstalar {
  _InstaladorAndroid(super.carpetaIndicada);

  static const _canal = MethodChannel('com.bibliogest.app/actualizaciones');

  @override
  bool get disponible => Platform.isAndroid;

  @override
  RegExp get _formatoArchivo => RegExp(r'^BiblioGest-(\d+\.\d+\.\d+)\.apk$');

  @override
  Future<Directory> _carpetaPorDefecto() async {
    final ruta = await _canal.invokeMethod<String>('carpeta');
    return Directory(ruta!);
  }

  @override
  Future<void> instalar(String ruta, {required Future<void> Function() cerrarBackend}) async {
    final puedeInstalar = await _canal.invokeMethod<bool>('puedeInstalar') ?? false;
    if (!puedeInstalar) {
      // Android exige que la persona autorice, una vez, a BiblioGest a instalar apps.
      await _canal.invokeMethod<void>('pedirPermisoInstalar');
      throw const ErrorInstalacion(
        'Para actualizar, permite que BiblioGest instale aplicaciones en la pantalla '
        'que se abrió. Luego vuelve y pulsa Actualizar otra vez.',
      );
    }
    await _canal.invokeMethod<void>('instalar', {'ruta': ruta});
  }

  @override
  Future<void> salir({required Future<void> Function() cerrarBackend}) async {
    await SystemNavigator.pop();
  }
}
