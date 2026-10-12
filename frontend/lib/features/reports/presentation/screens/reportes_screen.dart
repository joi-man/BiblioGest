import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/core/widgets/boton_exportar.dart';
import 'package:frontend/features/core/widgets/controles_paginacion.dart';
import 'package:frontend/features/core/widgets/encabezado_pagina.dart';
import 'package:frontend/features/core/widgets/estado_vacio.dart';
import 'package:frontend/features/core/widgets/grilla_datos.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';
import 'package:frontend/features/reports/data/reporte_repository.dart';
import 'package:frontend/features/reports/presentation/providers/reporte_provider.dart';
import 'package:frontend/features/reports/presentation/widgets/filtros_reporte.dart';

/// Reportes del personal: préstamos, préstamos vencidos y devoluciones, con
/// filtros por fechas y exportación a CSV, Excel y PDF.
///
/// Solo existe en la web y el escritorio; el móvil es un complemento sin reportes.
class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: TipoReporte.values.length, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const EncabezadoPagina(
            titulo: 'Reportes',
            subtitulo: 'Consulta y exporta préstamos, vencidos y devoluciones',
          ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final tipo in TipoReporte.values) Tab(text: tipo.etiqueta)],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                for (final tipo in TipoReporte.values) _PanelReporte(tipo: tipo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Filtros, tabla y exportación de un reporte. Conserva sus filtros al cambiar de pestaña.
class _PanelReporte extends ConsumerStatefulWidget {
  const _PanelReporte({required this.tipo});

  final TipoReporte tipo;

  @override
  ConsumerState<_PanelReporte> createState() => _PanelReporteState();
}

class _PanelReporteState extends ConsumerState<_PanelReporte>
    with AutomaticKeepAliveClientMixin {
  ConsultaReporte _consulta = const ConsultaReporte();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final resultado =
        ref.watch(reporteProvider((tipo: widget.tipo, consulta: _consulta)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FiltrosReporte(
                  tipo: widget.tipo,
                  consulta: _consulta,
                  alCambiar: (nueva) => setState(() => _consulta = nueva),
                ),
              ),
              const SizedBox(width: 12),
              BotonExportar(
                nombreBase: 'reporte_${widget.tipo.valor}',
                obtenerArchivo: (formato) => ref
                    .read(reporteRepositoryProvider)
                    .exportar(widget.tipo, _consulta, formato),
              ),
            ],
          ),
        ),
        Expanded(
          child: ValorAsincrono(
            valor: resultado,
            alReintentar: () => ref.invalidate(reporteProvider),
            construir: _tabla,
          ),
        ),
      ],
    );
  }

  Widget _tabla(ResultadoReporte resultado) {
    final pagina = resultado.pagina;
    if (pagina.items.isEmpty && pagina.total == 0) {
      return const EstadoVacio(
        titulo: 'No hay resultados',
        detalle: 'Prueba con otro rango de fechas o quita algún filtro.',
        icono: Icons.assessment_outlined,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              resultado.descripcion,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.colores.tintaSuave),
            ),
          ),
        ),
        Expanded(
          child: GrillaDatos<List<String>>(
            filas: pagina.items,
            columnas: [
              for (var i = 0; i < resultado.columnas.length; i++)
                ColumnaGrilla<List<String>>(
                  titulo: resultado.columnas[i],
                  celda: (fila) => ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Text(fila[i], maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ),
            ],
          ),
        ),
        ControlesPaginacion(
          pagina: pagina,
          alCambiarPagina: (numero) =>
              setState(() => _consulta = _consulta.enPagina(numero)),
          alCambiarTamano: (tamano) =>
              setState(() => _consulta = _consulta.conTamano(tamano)),
        ),
      ],
    );
  }
}
