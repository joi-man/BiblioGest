import 'package:flutter/material.dart';
import 'package:frontend/features/authors/presentation/widgets/buscador_autores.dart';
import 'package:frontend/features/authors/presentation/widgets/seleccion_autores.dart';

/// Elige los autores de un material sin salir del formulario.
///
/// Los elegidos se ven como chips. Se puede buscar un autor existente o escribir
/// un nombre nuevo (opción "Crear autor «x»", Enter o punto y coma): el autor nuevo se
/// crea al guardar el material.
class SelectorAutores extends StatelessWidget {
  const SelectorAutores({
    super.key,
    required this.seleccion,
    required this.alCambiar,
  });

  final SeleccionAutores seleccion;
  final ValueChanged<SeleccionAutores> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BuscadorAutores(
          etiqueta: 'Autores',
          sugerencia: 'Busca o escribe un nombre y pulsa Enter (o ;)',
          ayuda:
              'Puedes agregar varios. Si el autor no existe, se crea al guardar el material.',
          excluidos: {for (final a in seleccion.existentes) a.id},
          alElegir: (autor) => alCambiar(seleccion.agregarExistente(autor)),
          alCrear: (nombre) => alCambiar(seleccion.agregarNombres(nombre)),
        ),
        if (!seleccion.vacia) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final autor in seleccion.existentes)
                _chip(
                  autor.nombre,
                  nuevo: false,
                  alQuitar: () =>
                      alCambiar(seleccion.quitarExistente(autor.id)),
                ),
              for (final nombre in seleccion.nuevos)
                _chip(
                  nombre,
                  nuevo: true,
                  alQuitar: () => alCambiar(seleccion.quitarNuevo(nombre)),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _chip(
    String nombre, {
    required bool nuevo,
    required VoidCallback alQuitar,
  }) {
    return InputChip(
      avatar: Icon(nuevo ? Icons.add : Icons.person_outline, size: 18),
      label: Text(nuevo ? '$nombre (nuevo)' : nombre),
      onDeleted: alQuitar,
      deleteButtonTooltipMessage: 'Quitar autor',
    );
  }
}
