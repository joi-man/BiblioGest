import 'dart:convert';

import 'version_app.dart';

/// El manifiesto de actualizaciones no es válido o no está firmado por BiblioGest.
class ErrorManifiesto implements Exception {
  const ErrorManifiesto(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Datos de la última versión publicada (`latest.json` para Windows y
/// `latest-android.json` para Android; tienen el mismo formato).
///
/// Ejemplo:
/// ```json
/// {
///   "version": "0.9.1",
///   "minima": "0.9.0",
///   "url": "https://.../BiblioGest-Setup-0.9.1.exe",
///   "sha256": "<64 caracteres hexadecimales>",
///   "tamano": 48123456,
///   "notas": "Qué cambió en esta versión.",
///   "fecha": "2026-10-11"
/// }
/// ```
/// `minima` es la versión más antigua que puede seguir usándose: quien tenga
/// una anterior debe actualizar sí o sí.
class Manifiesto {
  const Manifiesto({
    required this.version,
    required this.minima,
    required this.url,
    required this.sha256,
    required this.tamano,
    this.notas = '',
    this.fecha,
  });

  final VersionApp version;
  final VersionApp minima;
  final Uri url;

  /// Huella SHA-256 del instalador, en hexadecimal y minúsculas.
  final String sha256;
  final int tamano;
  final String notas;
  final String? fecha;

  /// Nombre de archivo con el que se guarda el instalador descargado: el APK en
  /// Android (la dirección termina en `.apk`) o el instalador de Windows.
  String get nombreArchivo => url.path.toLowerCase().endsWith('.apk')
      ? 'BiblioGest-$version.apk'
      : 'BiblioGest-Setup-$version.exe';

  factory Manifiesto.desdeTexto(String texto) {
    final Object? crudo;
    try {
      crudo = jsonDecode(texto);
    } on FormatException {
      throw const ErrorManifiesto('El manifiesto no es un JSON válido');
    }
    if (crudo is! Map<String, dynamic>) {
      throw const ErrorManifiesto('El manifiesto no tiene el formato esperado');
    }

    final datos = crudo;

    String requerido(String campo) {
      final valor = datos[campo];
      if (valor is! String || valor.isEmpty) {
        throw ErrorManifiesto('Al manifiesto le falta "$campo"');
      }
      return valor;
    }

    VersionApp version(String campo) {
      final v = VersionApp.intentar(requerido(campo));
      if (v == null) throw ErrorManifiesto('"$campo" no es una versión válida');
      return v;
    }

    final url = Uri.tryParse(requerido('url'));
    // Un instalador solo se descarga por una conexión cifrada. Se admite http
    // únicamente hacia este mismo equipo, para probar sin certificado.
    final esLocal = url != null && (url.host == 'localhost' || url.host == '127.0.0.1');
    if (url == null || url.host.isEmpty || !(url.scheme == 'https' || (url.scheme == 'http' && esLocal))) {
      throw const ErrorManifiesto('La dirección del instalador debe ser https');
    }

    final huella = requerido('sha256').toLowerCase();
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(huella)) {
      throw const ErrorManifiesto('La huella SHA-256 no es válida');
    }

    final tamano = datos['tamano'];
    if (tamano is! int || tamano <= 0) {
      throw const ErrorManifiesto('El tamaño del instalador no es válido');
    }

    final version0 = version('version');
    final minima = version('minima');
    if (version0 < minima) {
      throw const ErrorManifiesto('La versión mínima no puede superar a la última');
    }

    return Manifiesto(
      version: version0,
      minima: minima,
      url: url,
      sha256: huella,
      tamano: tamano,
      notas: (datos['notas'] as String?) ?? '',
      fecha: datos['fecha'] as String?,
    );
  }
}
