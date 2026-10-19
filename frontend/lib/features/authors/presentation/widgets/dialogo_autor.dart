import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/authors/data/models/autor.dart';
import 'package:frontend/features/authors/data/repositories/autor_repository.dart';
import 'package:frontend/features/authors/presentation/providers/autores_paginados_provider.dart';
import 'package:frontend/features/core/widgets/campo_texto.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';

/// Formulario para crear o renombrar un autor.
class DialogoAutor extends ConsumerStatefulWidget {
  const DialogoAutor({super.key, this.autor});

  /// Autor a editar; `null` para crear uno nuevo.
  final Autor? autor;

  @override
  ConsumerState<DialogoAutor> createState() => _DialogoAutorState();
}

class _DialogoAutorState extends ConsumerState<DialogoAutor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  bool _guardando = false;

  bool get _esNuevo => widget.autor == null;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.autor?.nombre);
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final nombre = _nombre.text.trim();
    final repositorio = ref.read(autorRepositoryProvider);

    final guardado = await ejecutarAccion(context, () async {
      if (_esNuevo) {
        await repositorio.crear(nombre);
      } else {
        await repositorio.actualizar(widget.autor!.id, nombre);
      }
      ref.invalidate(autoresPaginadosProvider);
    }, exito: 'Autor guardado');

    if (!mounted) return;
    if (guardado) {
      Navigator.pop(context);
    } else {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _esNuevo ? 'Nuevo autor' : 'Editar autor',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                CampoTexto(
                  etiqueta: 'Nombre',
                  controlador: _nombre,
                  requerido: true,
                  maxCaracteres: 200,
                  ayuda: _esNuevo
                      ? 'Nombre y apellido, como figura en la portada'
                      : 'Al renombrarlo cambia en todos sus materiales',
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: _guardando
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: _guardando ? null : _guardar,
                      child: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
