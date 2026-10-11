import 'package:flutter/material.dart';

/// Campo de búsqueda con icono de lupa y botón para limpiar el texto.
class BarraBusqueda extends StatefulWidget {
  const BarraBusqueda({
    super.key,
    required this.alCambiar,
    this.sugerencia = 'Buscar',
  });

  /// Se invoca con el texto actual cada vez que el usuario escribe.
  final ValueChanged<String> alCambiar;
  final String sugerencia;

  @override
  State<BarraBusqueda> createState() => _BarraBusquedaState();
}

class _BarraBusquedaState extends State<BarraBusqueda> {
  final _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _limpiar() {
    _controlador.clear();
    widget.alCambiar('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controlador,
      onChanged: (valor) {
        widget.alCambiar(valor);
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: widget.sugerencia,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controlador.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Limpiar búsqueda',
                onPressed: _limpiar,
              ),
      ),
    );
  }
}
