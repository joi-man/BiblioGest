import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';

/// Una columna de [GrillaDatos]: su título y cómo dibujar la celda de cada fila.
class ColumnaGrilla<T> {
  const ColumnaGrilla({
    required this.titulo,
    required this.celda,
    this.numerica = false,
  });

  final String titulo;
  final Widget Function(T fila) celda;

  /// Alinea el contenido a la derecha (cifras).
  final bool numerica;
}

/// Grilla de datos desplazable en ambos sentidos.
///
/// Solo dibuja; no sabe de filtros ni de páginas. Se adapta al ancho
/// disponible y, si las columnas no caben, permite desplazarse en horizontal.
class GrillaDatos<T> extends StatelessWidget {
  const GrillaDatos({
    super.key,
    required this.columnas,
    required this.filas,
    this.acciones,
  });

  final List<ColumnaGrilla<T>> columnas;
  final List<T> filas;

  /// Última columna sin título con los botones de cada fila (por ejemplo un menú).
  final Widget Function(T fila)? acciones;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, restricciones) {
        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: restricciones.maxWidth),
              child: DataTable(
                headingRowHeight: 44,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 64,
                columnSpacing: 24,
                horizontalMargin: 24,
                dividerThickness: 1,
                headingRowColor: WidgetStatePropertyAll(colores.superficie),
                headingTextStyle: textos.labelLarge?.copyWith(
                  color: colores.tintaSuave,
                  fontWeight: FontWeight.w600,
                ),
                columns: [
                  for (final columna in columnas)
                    DataColumn(
                      label: Text(columna.titulo),
                      numeric: columna.numerica,
                    ),
                  if (acciones != null)
                    const DataColumn(label: SizedBox.shrink()),
                ],
                rows: [
                  for (final fila in filas)
                    DataRow(
                      cells: [
                        for (final columna in columnas)
                          DataCell(columna.celda(fila)),
                        if (acciones != null) DataCell(acciones!(fila)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
