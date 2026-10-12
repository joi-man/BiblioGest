import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';

/// Cabecera de una pantalla: título en serif, subtítulo y acciones a la derecha.
class EncabezadoPagina extends StatelessWidget {
  const EncabezadoPagina({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.acciones = const [],
  });

  final String titulo;
  final String? subtitulo;

  /// Botones que se alinean a la derecha (o debajo en pantallas angostas).
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final colores = context.colores;

    final textosTitulo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: textos.headlineMedium),
        if (subtitulo != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitulo!,
            style: textos.bodyMedium?.copyWith(color: colores.tintaSuave),
          ),
        ],
      ],
    );

    return Container(
      // Ocupa todo el ancho: si no, en pantallas angostas el título queda centrado.
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colores.linea)),
      ),
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final angosto = restricciones.maxWidth < 600;
          if (angosto || acciones.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textosTitulo,
                if (acciones.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: acciones),
                ],
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: textosTitulo),
              Wrap(spacing: 8, children: acciones),
            ],
          );
        },
      ),
    );
  }
}
