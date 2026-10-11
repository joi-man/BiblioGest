import 'package:flutter/material.dart';
import 'package:frontend/features/core/widgets/barra_busqueda.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_etiquetas.dart';
import 'package:frontend/features/materials/presentation/providers/materiales_provider.dart';

/// Barra de búsqueda, tipo y estado para filtrar el inventario.
class FiltrosMateriales extends StatelessWidget {
  const FiltrosMateriales({
    super.key,
    required this.filtro,
    required this.alCambiar,
  });

  final FiltroMateriales filtro;
  final ValueChanged<FiltroMateriales> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: BarraBusqueda(
                sugerencia: 'Buscar por título, código, autor, marca o serie',
                alCambiar: (texto) => alCambiar((
                  texto: texto,
                  tipo: filtro.tipo,
                  estado: filtro.estado,
                  soloDisponibles: filtro.soloDisponibles,
                )),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(width: 190, child: _selectorTipo()),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Todos'),
              selected: filtro.estado == null,
              onSelected: (_) => _cambiarEstado(null),
            ),
            for (final estado in EstadoMaterial.values)
              ChoiceChip(
                label: Text(estado.etiqueta),
                selected: filtro.estado == estado,
                onSelected: (_) => _cambiarEstado(estado),
              ),
          ],
        ),
      ],
    );
  }

  void _cambiarEstado(EstadoMaterial? estado) {
    alCambiar((
      texto: filtro.texto,
      tipo: filtro.tipo,
      estado: estado,
      soloDisponibles: filtro.soloDisponibles,
    ));
  }

  Widget _selectorTipo() {
    return DropdownButtonFormField<TipoMaterial?>(
      value: filtro.tipo,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Tipo'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos los tipos')),
        for (final tipo in TipoMaterial.values)
          DropdownMenuItem(value: tipo, child: Text(tipo.etiqueta)),
      ],
      onChanged: (tipo) => alCambiar((
        texto: filtro.texto,
        tipo: tipo,
        estado: filtro.estado,
        soloDisponibles: filtro.soloDisponibles,
      )),
    );
  }
}
