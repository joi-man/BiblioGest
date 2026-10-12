import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/archivos/formato_exportacion.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
import 'package:frontend/core/network/dio_client.dart';

/// Los reportes que ofrece el backend (`/api/reportes/{tipo}`).
enum TipoReporte {
  prestamos('prestamos', 'Préstamos'),
  vencidos('vencidos', 'Vencidos'),
  devoluciones('devoluciones', 'Devoluciones');

  const TipoReporte(this.valor, this.etiqueta);

  /// Valor que entiende el backend.
  final String valor;
  final String etiqueta;
}

/// Criterios de un reporte: rango de fechas, estado o condición, texto y página.
///
/// Es inmutable y tiene igualdad por valor para que Riverpod reutilice el
/// resultado cuando la consulta no cambió.
class ConsultaReporte {
  const ConsultaReporte({
    this.desde,
    this.hasta,
    this.estado,
    this.condicion,
    this.texto = '',
    this.pagina = 1,
    this.tamano = 10,
  });

  final DateTime? desde;
  final DateTime? hasta;

  /// Estado del préstamo (`activo`, `devuelto`...); solo el reporte de préstamos.
  final String? estado;

  /// Condición al devolver (`bueno`, `dano_menor`...); solo el de devoluciones.
  final String? condicion;
  final String texto;
  final int pagina;
  final int tamano;

  /// Cambia el filtro y vuelve a la primera página. Los filtros que admiten
  /// "ninguno" se pasan como función para distinguir "no cambiar" de "quitar".
  ConsultaReporte conFiltros({
    DateTime? Function()? desde,
    DateTime? Function()? hasta,
    String? Function()? estado,
    String? Function()? condicion,
    String? texto,
  }) {
    return ConsultaReporte(
      desde: desde != null ? desde() : this.desde,
      hasta: hasta != null ? hasta() : this.hasta,
      estado: estado != null ? estado() : this.estado,
      condicion: condicion != null ? condicion() : this.condicion,
      texto: texto ?? this.texto,
      tamano: tamano,
    );
  }

  ConsultaReporte enPagina(int nueva) => ConsultaReporte(
    desde: desde,
    hasta: hasta,
    estado: estado,
    condicion: condicion,
    texto: texto,
    pagina: nueva,
    tamano: tamano,
  );

  /// Cambia las filas por página y vuelve a la primera.
  ConsultaReporte conTamano(int nuevo) => ConsultaReporte(
    desde: desde,
    hasta: hasta,
    estado: estado,
    condicion: condicion,
    texto: texto,
    tamano: nuevo,
  );

  /// Parámetros de filtro, comunes a la consulta y a la exportación.
  Map<String, dynamic> get filtros => {
    if (desde != null) 'desde': _dia(desde!),
    if (hasta != null) 'hasta': _dia(hasta!),
    if (estado != null) 'estado': estado,
    if (condicion != null) 'condicion': condicion,
    if (texto.trim().isNotEmpty) 'q': texto.trim(),
  };

  /// `2026-10-12`: el backend recibe días, sin hora.
  static String _dia(DateTime fecha) =>
      '${fecha.year.toString().padLeft(4, '0')}-'
      '${fecha.month.toString().padLeft(2, '0')}-'
      '${fecha.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is ConsultaReporte &&
      other.desde == desde &&
      other.hasta == hasta &&
      other.estado == estado &&
      other.condicion == condicion &&
      other.texto == texto &&
      other.pagina == pagina &&
      other.tamano == tamano;

  @override
  int get hashCode =>
      Object.hash(desde, hasta, estado, condicion, texto, pagina, tamano);
}

/// Una página de un reporte: encabezados, filas de texto y datos de navegación.
class ResultadoReporte {
  const ResultadoReporte({
    required this.descripcion,
    required this.columnas,
    required this.pagina,
  });

  factory ResultadoReporte.desdeJson(Map<String, dynamic> json) {
    final filas = (json['filas'] as List)
        .map((fila) => (fila as List).map((celda) => '$celda').toList())
        .toList();
    return ResultadoReporte(
      descripcion: json['descripcion'] as String,
      columnas: (json['columnas'] as List).map((c) => '$c').toList(),
      pagina: PaginaResultado<List<String>>(
        items: filas,
        total: json['total'] as int,
        pagina: json['pagina'] as int,
        tamano: json['tamano'] as int,
        totalPaginas: json['total_paginas'] as int,
      ),
    );
  }

  /// Filtros aplicados y total, tal como se escriben en los archivos exportados.
  final String descripcion;
  final List<String> columnas;
  final PaginaResultado<List<String>> pagina;
}

final reporteRepositoryProvider = Provider<ReporteRepository>((ref) {
  return ReporteRepository(ref.watch(dioClientProvider).dio);
});

/// Acceso a la API de reportes (solo personal). El token lo agrega el cliente HTTP.
class ReporteRepository {
  ReporteRepository(this._dio);

  final Dio _dio;

  Future<ResultadoReporte> consultar(
    TipoReporte tipo,
    ConsultaReporte consulta,
  ) async {
    final respuesta = await _dio.get(
      '/api/reportes/${tipo.valor}',
      queryParameters: {
        ...consulta.filtros,
        'pagina': consulta.pagina,
        'tamano': consulta.tamano,
      },
    );
    return ResultadoReporte.desdeJson(respuesta.data as Map<String, dynamic>);
  }

  /// Descarga todo el reporte que cumple el filtro (no solo una página).
  Future<Uint8List> exportar(
    TipoReporte tipo,
    ConsultaReporte consulta,
    FormatoExportacion formato,
  ) async {
    final respuesta = await _dio.get<List<int>>(
      '/api/reportes/${tipo.valor}/exportar',
      queryParameters: {...consulta.filtros, 'formato': formato.extension},
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(respuesta.data!);
  }
}
