import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/core/archivos/formato_exportacion.dart';
import 'package:frontend/core/archivos/guardar_archivo.dart';
import 'package:frontend/core/network/mensaje_error.dart';
import 'alertas.dart';

/// Botón con menú para descargar el listado actual en Excel, PDF o CSV.
///
/// Pide los bytes del archivo a [obtenerArchivo], lo guarda con
/// [guardarArchivo] y avisa el resultado. Mientras descarga muestra un
/// indicador y no admite otro clic.
class BotonExportar extends StatefulWidget {
  const BotonExportar({
    super.key,
    required this.nombreBase,
    required this.obtenerArchivo,
  });

  /// Nombre del archivo sin fecha ni extensión (por ejemplo `usuarios`).
  final String nombreBase;

  /// Pide al backend el archivo en el [FormatoExportacion] elegido.
  final Future<Uint8List> Function(FormatoExportacion formato) obtenerArchivo;

  @override
  State<BotonExportar> createState() => _BotonExportarState();
}

class _BotonExportarState extends State<BotonExportar> {
  bool _exportando = false;

  Future<void> _exportar(FormatoExportacion formato) async {
    setState(() => _exportando = true);
    try {
      final contenido = await widget.obtenerArchivo(formato);
      final destino = await guardarArchivo(
        contenido,
        _nombreArchivo(formato),
        formato.tipoContenido,
      );
      if (mounted) context.mostrarExito('Archivo guardado: $destino');
    } catch (error) {
      if (mounted) context.mostrarError(mensajeDeError(error));
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  /// Por ejemplo `usuarios_20261011.xlsx`.
  String _nombreArchivo(FormatoExportacion formato) {
    final hoy = DateTime.now();
    final fecha = '${hoy.year}${hoy.month.toString().padLeft(2, '0')}'
        '${hoy.day.toString().padLeft(2, '0')}';
    return '${widget.nombreBase}_$fecha.${formato.extension}';
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FormatoExportacion>(
      enabled: !_exportando,
      tooltip: 'Exportar el listado con los filtros actuales',
      onSelected: _exportar,
      itemBuilder: (_) => [
        for (final formato in FormatoExportacion.values)
          PopupMenuItem(
            value: formato,
            child: Row(
              children: [
                Icon(
                  switch (formato) {
                    FormatoExportacion.pdf => Icons.picture_as_pdf_outlined,
                    FormatoExportacion.csv => Icons.description_outlined,
                    FormatoExportacion.excel => Icons.table_chart_outlined,
                  },
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(formato.etiqueta),
              ],
            ),
          ),
      ],
      // El menú recibe el clic; el botón solo aporta la apariencia.
      child: IgnorePointer(
        child: OutlinedButton.icon(
          onPressed: _exportando ? null : () {},
          icon: _exportando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_outlined),
          label: const Text('Exportar'),
        ),
      ),
    );
  }
}
