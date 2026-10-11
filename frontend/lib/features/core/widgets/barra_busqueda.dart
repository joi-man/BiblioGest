import 'dart:async';
import 'package:flutter/material.dart';

/// Campo de búsqueda con icono de lupa y botón para limpiar el texto.
///
/// Espera unos instantes después de la última tecla antes de avisar, para no
/// lanzar una consulta por cada letra escrita.
class BarraBusqueda extends StatefulWidget {
  const BarraBusqueda({
    super.key,
    required this.alCambiar,
    this.sugerencia = 'Buscar',
    this.textoInicial = '',
    this.retardo = const Duration(milliseconds: 350),
  });

  /// Se invoca con el texto actual cuando el usuario deja de escribir.
  final ValueChanged<String> alCambiar;
  final String sugerencia;

  /// Texto con el que aparece el campo al crearse.
  final String textoInicial;
  final Duration retardo;

  @override
  State<BarraBusqueda> createState() => _BarraBusquedaState();
}

class _BarraBusquedaState extends State<BarraBusqueda> {
  late final TextEditingController _controlador =
      TextEditingController(text: widget.textoInicial);
  Timer? _temporizador;

  @override
  void dispose() {
    _temporizador?.cancel();
    _controlador.dispose();
    super.dispose();
  }

  void _programarAviso(String texto) {
    _temporizador?.cancel();
    _temporizador = Timer(widget.retardo, () => widget.alCambiar(texto));
    setState(() {}); // actualiza la visibilidad del botón de limpiar
  }

  void _limpiar() {
    _temporizador?.cancel();
    _controlador.clear();
    widget.alCambiar('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controlador,
      onChanged: _programarAviso,
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
