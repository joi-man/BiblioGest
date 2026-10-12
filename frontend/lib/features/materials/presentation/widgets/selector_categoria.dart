import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/categories/data/models/categoria.dart';
import 'package:frontend/features/categories/presentation/providers/categorias_provider.dart';

/// Lista desplegable con búsqueda para elegir una categoría.
class SelectorCategoria extends ConsumerWidget {
  const SelectorCategoria({
    super.key,
    required this.categoriaId,
    required this.alCambiar,
  });

  /// ID de la categoría elegida, o `null` si aún no se eligió.
  final String? categoriaId;
  final ValueChanged<Categoria?> alCambiar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorias = ref.watch(categoriasProvider);

    return categorias.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => const Text('No se pudieron cargar las categorías'),
      data: (lista) {
        if (lista.isEmpty) return const Text('Primero crea una categoría');

        Categoria? seleccionada;
        for (final c in lista) {
          if (c.id == categoriaId) seleccionada = c;
        }

        return DropdownSearch<Categoria>(
          mode: Mode.form,
          items: (filtro, _) async => lista,
          selectedItem: seleccionada,
          itemAsString: (c) => c.nombre,
          compareFn: (a, b) => a.id == b.id,
          onChanged: alCambiar,
          popupProps: const PopupProps.dialog(
            showSearchBox: true,
            title: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Selecciona una categoría'),
            ),
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(hintText: 'Buscar...'),
            ),
          ),
          decoratorProps: const DropDownDecoratorProps(
            decoration: InputDecoration(labelText: 'Categoría *'),
          ),
          validator: (valor) =>
              valor == null ? 'Selecciona una categoría' : null,
        );
      },
    );
  }
}
