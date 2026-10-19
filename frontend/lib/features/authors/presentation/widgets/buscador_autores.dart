import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/texto_busqueda.dart';
import 'package:frontend/features/authors/data/models/autor.dart';
import 'package:frontend/features/authors/data/repositories/autor_repository.dart';

/// Una opción del buscador: un autor existente o "crear este nombre".
@immutable
class OpcionAutor {
  const OpcionAutor.existente(Autor this.autor) : nombreNuevo = null;
  const OpcionAutor.nueva(String this.nombreNuevo) : autor = null;

  final Autor? autor;
  final String? nombreNuevo;

  bool get esNueva => nombreNuevo != null;
  String get texto => esNueva ? nombreNuevo! : autor!.nombre;
}

/// Opciones a mostrar para lo escrito: los autores que coinciden y, si se
/// permite crear y ninguno tiene exactamente ese nombre, "Crear autor «x»".
List<OpcionAutor> opcionesParaTexto(
  String escrito,
  List<Autor> encontrados, {
  required bool permitirCrear,
  Set<String> excluidos = const {},
}) {
  final nombre = escrito.trim();
  final hayIgual = encontrados.any(
    (a) => sinTildes(a.nombre) == sinTildes(nombre),
  );
  return [
    for (final a in encontrados)
      if (!excluidos.contains(a.id)) OpcionAutor.existente(a),
    if (permitirCrear && nombre.isNotEmpty && !hayIgual)
      OpcionAutor.nueva(nombre),
  ];
}

/// Campo con autocompletado que busca autores en el servidor mientras se escribe.
///
/// - Al elegir un autor existente llama a [alElegir].
/// - Con [alCrear] también ofrece crear el nombre escrito (Enter o punto y coma lo agrega).
class BuscadorAutores extends ConsumerStatefulWidget {
  const BuscadorAutores({
    super.key,
    required this.alElegir,
    this.alCrear,
    this.excluidos = const {},
    this.etiqueta = 'Autores',
    this.sugerencia,
    this.ayuda,
  });

  final ValueChanged<Autor> alElegir;

  /// Si no es `null`, se permite crear autores nuevos desde el mismo campo.
  final ValueChanged<String>? alCrear;

  /// IDs de autores que no deben ofrecerse (ya están elegidos).
  final Set<String> excluidos;
  final String etiqueta;
  final String? sugerencia;
  final String? ayuda;

  @override
  ConsumerState<BuscadorAutores> createState() => _BuscadorAutoresState();
}

class _BuscadorAutoresState extends ConsumerState<BuscadorAutores> {
  final _controlador = TextEditingController();
  final _foco = FocusNode();

  /// Cada búsqueda lleva un número; solo la última responde (las demás quedaron viejas).
  int _consulta = 0;
  List<OpcionAutor> _ultimasOpciones = const [];

  @override
  void dispose() {
    _controlador.dispose();
    _foco.dispose();
    super.dispose();
  }

  Future<Iterable<OpcionAutor>> _buscar(TextEditingValue valor) async {
    final escrito = valor.text;
    if (escrito.trim().isEmpty) return _ultimasOpciones = const [];

    final numero = ++_consulta;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (numero != _consulta) return const [];

    List<Autor> encontrados;
    try {
      encontrados = await ref
          .read(autorRepositoryProvider)
          .listar(texto: escrito);
    } catch (_) {
      encontrados = const [];
    }
    if (numero != _consulta) return const [];
    return _ultimasOpciones = opcionesParaTexto(
      escrito,
      encontrados,
      permitirCrear: widget.alCrear != null,
      excluidos: widget.excluidos,
    );
  }

  void _elegir(OpcionAutor opcion) {
    _consulta++; // descarta las búsquedas en curso
    if (opcion.esNueva) {
      widget.alCrear?.call(opcion.nombreNuevo!);
    } else {
      widget.alElegir(opcion.autor!);
    }
    _controlador.clear();
    _foco.requestFocus();
  }

  /// Enter: elige el autor que se llama igual a lo escrito; si no hay, crea el nombre.
  void _alEnviar() {
    final escrito = _controlador.text.trim();
    if (escrito.isEmpty) return;
    final iguales = _ultimasOpciones.where(
      (o) => !o.esNueva && sinTildes(o.texto) == sinTildes(escrito),
    );
    if (iguales.isNotEmpty) return _elegir(iguales.first);
    if (widget.alCrear != null) {
      _consulta++;
      widget.alCrear!(escrito);
      _controlador.clear();
      _foco.requestFocus();
    }
  }

  /// Un punto y coma termina el nombre escrito: se agrega y se sigue con el siguiente.
  void _alCambiar(String texto) {
    if (widget.alCrear == null || !texto.contains(';')) return;
    final partes = texto.split(';');
    final resto = partes.removeLast().trimLeft();
    for (final parte in partes) {
      if (parte.trim().isNotEmpty) widget.alCrear!(parte.trim());
    }
    _controlador.value = TextEditingValue(
      text: resto,
      selection: TextSelection.collapsed(offset: resto.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) => RawAutocomplete<OpcionAutor>(
        textEditingController: _controlador,
        focusNode: _foco,
        optionsBuilder: _buscar,
        displayStringForOption: (o) => o.texto,
        onSelected: _elegir,
        fieldViewBuilder: (context, controlador, foco, alEnviar) => TextField(
          controller: controlador,
          focusNode: foco,
          onChanged: _alCambiar,
          onSubmitted: (_) => _alEnviar(),
          decoration: InputDecoration(
            labelText: widget.etiqueta,
            hintText: widget.sugerencia,
            helperText: widget.ayuda,
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.person_search_outlined),
          ),
        ),
        optionsViewBuilder: (context, alElegir, opciones) => Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(4),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 240,
                maxWidth: restricciones.maxWidth,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: opciones.length,
                itemBuilder: (context, i) {
                  final opcion = opciones.elementAt(i);
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      opcion.esNueva
                          ? Icons.add_circle_outline
                          : Icons.person_outline,
                    ),
                    title: Text(
                      opcion.esNueva
                          ? 'Crear autor «${opcion.texto}»'
                          : opcion.texto,
                    ),
                    subtitle:
                        opcion.esNueva || opcion.autor!.cantidadMateriales == 0
                        ? null
                        : Text('${opcion.autor!.cantidadMateriales} materiales'),
                    onTap: () => alElegir(opcion),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
