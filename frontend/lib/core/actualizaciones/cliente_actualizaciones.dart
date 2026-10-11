import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'firma_manifiesto.dart';
import 'manifiesto.dart';

/// Manifiesto verificado junto con los bytes que se firmaron, para guardarlos.
class ManifiestoDescargado {
  const ManifiestoDescargado({
    required this.manifiesto,
    required this.contenido,
    required this.firma,
  });

  final Manifiesto manifiesto;
  final String contenido;
  final String firma;
}

/// No se pudo consultar el servidor de actualizaciones (sin internet, caído...).
class SinConexionActualizaciones implements Exception {
  const SinConexionActualizaciones([this.detalle = '']);

  /// Motivo técnico (tipo de error de red), útil para diagnosticar.
  final String detalle;

  @override
  String toString() => 'No se pudo conectar para buscar actualizaciones';
}

/// Descarga y verifica el manifiesto de actualizaciones.
class ClienteActualizaciones {
  ClienteActualizaciones({
    required this.dio,
    required this.urlManifiesto,
    required this.clavePublica,
  });

  final Dio dio;
  final String urlManifiesto;
  final String clavePublica;

  static final _opciones = Options(
    responseType: ResponseType.bytes,
    sendTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
  );

  /// Lanza [SinConexionActualizaciones] si no hay red y [ErrorManifiesto] si el
  /// contenido es inválido o no está firmado por BiblioGest.
  Future<ManifiestoDescargado> consultar() async {
    final Uint8List contenido;
    final String firma;
    try {
      contenido = await _descargar(urlManifiesto);
      firma = utf8.decode(await _descargar('$urlManifiesto.sig'));
    } on DioException catch (error) {
      final causa = error.error ?? error.message ?? '';
      throw SinConexionActualizaciones('${error.type.name}: $causa');
    }

    final manifiesto = await verificarManifiesto(
      contenido: contenido,
      firmaBase64: firma,
      clavePublicaBase64: clavePublica,
    );
    return ManifiestoDescargado(
      manifiesto: manifiesto,
      contenido: utf8.decode(contenido),
      firma: firma,
    );
  }

  Future<Uint8List> _descargar(String url) async {
    final respuesta = await dio.get<List<int>>(url, options: _opciones);
    return Uint8List.fromList(respuesta.data ?? const []);
  }
}
