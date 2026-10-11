import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/categories/presentation/providers/categorias_provider.dart';
import 'package:frontend/features/core/widgets/barra_busqueda.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_etiquetas.dart';
import 'package:frontend/features/materials/presentation/providers/inventario_provider.dart';

/// Búsqueda por texto, tipo, categoría y estado para la grilla del inventario.
class FiltrosMateriales extends ConsumerWidget {
  const FiltrosMateriales({
    super.key,
    required this.consulta,
    required this.alCambiar,
  });

  final ConsultaInventario consulta;
  final ValueChanged<ConsultaInventario> alCambiar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 360,
          child: BarraBusqueda(
            sugerencia: 'Buscar por título, código, autor, marca o serie',
            textoInicial: consulta.texto,
            alCambiar: (texto) => alCambiar(consulta.conFiltros(texto: texto)),
          ),
        ),
        SizedBox(width: 180, child: _selectorTipo()),
        SizedBox(width: 200, child: _selectorCategoria(ref)),
        SizedBox(width: 190, child: _selectorEstado()),
      ],
    );
  }

  Widget _selectorTipo() {
    return DropdownButtonFormField<TipoMaterial?>(
      value: consulta.tipo,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Tipo'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos los tipos')),
        for (final tipo in TipoMaterial.values)
          DropdownMenuItem(value: tipo, child: Text(tipo.etiqueta)),
      ],
      onChanged: (tipo) => alCambiar(consulta.conFiltros(tipo: () => tipo)),
    );
  }

  Widget _selectorCategoria(WidgetRef ref) {
    // Mientras cargan (o si fallan) las categorías, el selector queda con "Todas".
    final categorias = ref.watch(categoriasProvider).valueOrNull ?? const [];

    return DropdownButtonFormField<String?>(
      value: categorias.any((c) => c.id == consulta.categoriaId)
          ? consulta.categoriaId
          : null,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Categoría'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todas')),
        for (final categoria in categorias)
          DropdownMenuItem(value: categoria.id, child: Text(categoria.nombre)),
      ],
      onChanged: (id) => alCambiar(consulta.conFiltros(categoriaId: () => id)),
    );
  }

  Widget _selectorEstado() {
    return DropdownButtonFormField<EstadoMaterial?>(
      value: consulta.estado,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Estado'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos los estados')),
        for (final estado in EstadoMaterial.values)
          DropdownMenuItem(value: estado, child: Text(estado.etiqueta)),
      ],
      onChanged: (estado) =>
          alCambiar(consulta.conFiltros(estado: () => estado)),
    );
  }
}
