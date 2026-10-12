import 'package:flutter/material.dart';
import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/core/widgets/barra_busqueda.dart';
import 'package:frontend/features/reports/data/reporte_repository.dart';

/// Estados de préstamo que se pueden filtrar en el reporte de préstamos.
const _estados = {
  'pendiente': 'Pendiente',
  'aprobado': 'Por retirar',
  'activo': 'En préstamo',
  'vencido': 'Vencido',
  'devuelto': 'Devuelto',
  'rechazado': 'Rechazado',
  'cancelado': 'Cancelado',
};

/// Condiciones en que puede llegar un material devuelto.
const _condiciones = {
  'bueno': 'Bueno',
  'dano_menor': 'Daño menor',
  'dano_mayor': 'Daño mayor',
  'perdido': 'Perdido',
};

/// Rango de fechas, estado o condición y búsqueda de un reporte.
class FiltrosReporte extends StatelessWidget {
  const FiltrosReporte({
    super.key,
    required this.tipo,
    required this.consulta,
    required this.alCambiar,
  });

  final TipoReporte tipo;
  final ConsultaReporte consulta;
  final ValueChanged<ConsultaReporte> alCambiar;

  Future<void> _elegirFecha(
    BuildContext context, {
    required DateTime? actual,
    required DateTime? minima,
    required void Function(DateTime?) alElegir,
  }) async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: actual ?? ahora,
      firstDate: minima ?? DateTime(2020),
      lastDate: DateTime(ahora.year + 2),
    );
    if (fecha != null) alElegir(fecha);
  }

  @override
  Widget build(BuildContext context) {
    final etiquetaFecha = tipo == TipoReporte.vencidos
        ? 'Límite desde'
        : tipo == TipoReporte.devoluciones
        ? 'Devuelto desde'
        : 'Solicitado desde';
    final etiquetaHasta = etiquetaFecha.replaceFirst('desde', 'hasta');

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: BarraBusqueda(
            sugerencia: 'Buscar por persona, documento o material',
            textoInicial: consulta.texto,
            alCambiar: (texto) => alCambiar(consulta.conFiltros(texto: texto)),
          ),
        ),
        _CampoFecha(
          etiqueta: etiquetaFecha,
          fecha: consulta.desde,
          alTocar: () => _elegirFecha(
            context,
            actual: consulta.desde,
            minima: null,
            alElegir: (f) => alCambiar(consulta.conFiltros(desde: () => f)),
          ),
          alQuitar: () => alCambiar(consulta.conFiltros(desde: () => null)),
        ),
        _CampoFecha(
          etiqueta: etiquetaHasta,
          fecha: consulta.hasta,
          alTocar: () => _elegirFecha(
            context,
            actual: consulta.hasta,
            minima: consulta.desde,
            alElegir: (f) => alCambiar(consulta.conFiltros(hasta: () => f)),
          ),
          alQuitar: () => alCambiar(consulta.conFiltros(hasta: () => null)),
        ),
        if (tipo == TipoReporte.prestamos)
          SizedBox(
            width: 190,
            child: _selector(
              etiqueta: 'Estado',
              valor: consulta.estado,
              opciones: _estados,
              alElegir: (v) => alCambiar(consulta.conFiltros(estado: () => v)),
            ),
          ),
        if (tipo == TipoReporte.devoluciones)
          SizedBox(
            width: 190,
            child: _selector(
              etiqueta: 'Condición',
              valor: consulta.condicion,
              opciones: _condiciones,
              alElegir: (v) =>
                  alCambiar(consulta.conFiltros(condicion: () => v)),
            ),
          ),
      ],
    );
  }

  Widget _selector({
    required String etiqueta,
    required String? valor,
    required Map<String, String> opciones,
    required ValueChanged<String?> alElegir,
  }) {
    return DropdownButtonFormField<String?>(
      value: valor,
      isExpanded: true,
      decoration: InputDecoration(labelText: etiqueta),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos')),
        for (final e in opciones.entries)
          DropdownMenuItem(value: e.key, child: Text(e.value)),
      ],
      onChanged: alElegir,
    );
  }
}

/// Campo de solo lectura que abre un selector de fecha y permite quitar la fecha.
class _CampoFecha extends StatelessWidget {
  const _CampoFecha({
    required this.etiqueta,
    required this.fecha,
    required this.alTocar,
    required this.alQuitar,
  });

  final String etiqueta;
  final DateTime? fecha;
  final VoidCallback alTocar;
  final VoidCallback alQuitar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: InkWell(
        onTap: alTocar,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: etiqueta,
            suffixIcon: fecha == null
                ? const Icon(Icons.calendar_today_outlined, size: 18)
                : IconButton(
                    tooltip: 'Quitar fecha',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: alQuitar,
                  ),
          ),
          child: Text(
            fecha == null ? 'Cualquiera' : FormatoFecha.soloFecha(fecha!),
          ),
        ),
      ),
    );
  }
}
