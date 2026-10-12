import 'package:flutter/material.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
import 'package:frontend/core/theme/colores_app.dart';

/// Opciones de "filas por página" que ofrece el selector.
const List<int> tamanosDePagina = [10, 25, 50, 100];

/// Pie de una grilla: "1–10 de 53", filas por página y botones de navegación.
class ControlesPaginacion extends StatelessWidget {
  const ControlesPaginacion({
    super.key,
    required this.pagina,
    required this.alCambiarPagina,
    required this.alCambiarTamano,
  });

  final PaginaResultado<dynamic> pagina;
  final ValueChanged<int> alCambiarPagina;
  final ValueChanged<int> alCambiarTamano;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final estiloTexto = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: colores.tintaSuave);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colores.linea)),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 4,
        children: [
          Text('Filas por página', style: estiloTexto),
          DropdownButton<int>(
            value: tamanosDePagina.contains(pagina.tamano)
                ? pagina.tamano
                : null,
            underline: const SizedBox.shrink(),
            items: [
              for (final tamano in tamanosDePagina)
                DropdownMenuItem(value: tamano, child: Text('$tamano')),
            ],
            onChanged: (tamano) {
              if (tamano != null) alCambiarTamano(tamano);
            },
          ),
          Text(_resumen, style: estiloTexto),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Primera página',
                icon: const Icon(Icons.first_page),
                onPressed: pagina.hayAnterior ? () => alCambiarPagina(1) : null,
              ),
              IconButton(
                tooltip: 'Página anterior',
                icon: const Icon(Icons.chevron_left),
                onPressed: pagina.hayAnterior
                    ? () => alCambiarPagina(pagina.pagina - 1)
                    : null,
              ),
              IconButton(
                tooltip: 'Página siguiente',
                icon: const Icon(Icons.chevron_right),
                onPressed: pagina.haySiguiente
                    ? () => alCambiarPagina(pagina.pagina + 1)
                    : null,
              ),
              IconButton(
                tooltip: 'Última página',
                icon: const Icon(Icons.last_page),
                onPressed: pagina.haySiguiente
                    ? () => alCambiarPagina(pagina.totalPaginas)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _resumen => pagina.total == 0
      ? '0 resultados'
      : '${pagina.desde}–${pagina.hasta} de ${pagina.total}';
}
