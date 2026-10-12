import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/core/widgets/boton_modo_tema.dart';

/// Plantilla visual de las pantallas de acceso (login y recuperación).
///
/// En pantallas anchas muestra un panel de marca a la izquierda y el
/// formulario a la derecha; en pantallas angostas solo el formulario.
class PanelAutenticacion extends StatelessWidget {
  const PanelAutenticacion({
    super.key,
    required this.titulo,
    this.subtitulo,
    required this.hijo,
  });

  /// Título del formulario (se muestra en tipografía serif).
  final String titulo;
  final String? subtitulo;

  /// Contenido del formulario.
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return Scaffold(
      // SafeArea: en el telefono la barra de estado no debe tapar el contenido.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, restricciones) {
            final ancho = restricciones.maxWidth >= 860;
            return Row(
              children: [
                if (ancho) const Expanded(flex: 5, child: _PanelMarca()),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: colores.papel,
                    child: Stack(
                      children: [
                        const Positioned(
                          top: 12,
                          right: 12,
                          child: BotonModoTema(),
                        ),
                        Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(32),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: _Formulario(
                                titulo: titulo,
                                subtitulo: subtitulo,
                                hijo: hijo,
                                mostrarMarca: !ancho,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Columna con título, subtítulo y el contenido del formulario.
class _Formulario extends StatelessWidget {
  const _Formulario({
    required this.titulo,
    required this.subtitulo,
    required this.hijo,
    required this.mostrarMarca,
  });

  final String titulo;
  final String? subtitulo;
  final Widget hijo;
  final bool mostrarMarca;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final colores = context.colores;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mostrarMarca) ...[
          Text(
            'BiblioGest',
            style: textos.titleLarge?.copyWith(color: colores.acento),
          ),
          const SizedBox(height: 24),
        ],
        Text(titulo, style: textos.headlineLarge),
        if (subtitulo != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitulo!,
            style: textos.bodyMedium?.copyWith(color: colores.tintaSuave),
          ),
        ],
        const SizedBox(height: 28),
        hijo,
      ],
    );
  }
}

/// Panel decorativo de marca para pantallas anchas.
class _PanelMarca extends StatelessWidget {
  const _PanelMarca();

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;

    return Container(
      color: colores.acento,
      padding: const EdgeInsets.all(56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'BiblioGest',
            style: textos.titleLarge?.copyWith(color: colores.sobreAcento),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cada material,\nen su lugar.',
                style: textos.displayMedium?.copyWith(
                  color: colores.sobreAcento,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Libros, equipos y recursos de la biblioteca: '
                'solicitudes, préstamos y devoluciones en un solo sitio.',
                style: textos.bodyLarge?.copyWith(
                  color: colores.sobreAcento.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          Text(
            'Sistema de gestión bibliotecaria',
            style: textos.labelMedium?.copyWith(
              color: colores.sobreAcento.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
