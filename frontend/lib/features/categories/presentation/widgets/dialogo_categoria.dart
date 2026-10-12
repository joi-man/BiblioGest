import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/categories/data/models/categoria.dart';
import 'package:frontend/features/categories/data/repositories/categoria_repository.dart';
import 'package:frontend/features/categories/presentation/providers/categorias_provider.dart';
import 'package:frontend/features/core/widgets/campo_texto.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';

/// Formulario para crear o editar una categoría.
class DialogoCategoria extends ConsumerStatefulWidget {
  const DialogoCategoria({super.key, this.categoria});

  /// Categoría a editar; `null` para crear una nueva.
  final Categoria? categoria;

  @override
  ConsumerState<DialogoCategoria> createState() => _DialogoCategoriaState();
}

class _DialogoCategoriaState extends ConsumerState<DialogoCategoria> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _plazoHoras;
  bool _guardando = false;

  bool get _esNueva => widget.categoria == null;

  @override
  void initState() {
    super.initState();
    final categoria = widget.categoria;
    _nombre = TextEditingController(text: categoria?.nombre);
    _descripcion = TextEditingController(text: categoria?.descripcion);
    _plazoHoras = TextEditingController(
      text: categoria?.plazoPrestamoHoras?.toString(),
    );
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _plazoHoras.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final descripcion = _descripcion.text.trim();
    final datos = {
      'nombre': _nombre.text.trim(),
      'descripcion': descripcion.isEmpty ? null : descripcion,
      'plazo_prestamo_horas': int.tryParse(_plazoHoras.text.trim()),
    };
    final repositorio = ref.read(categoriaRepositoryProvider);

    final guardada = await ejecutarAccion(context, () async {
      if (_esNueva) {
        await repositorio.crear(datos);
      } else {
        await repositorio.actualizar(widget.categoria!.id, datos);
      }
      ref.invalidate(categoriasProvider);
    }, exito: 'Categoría guardada');

    if (!mounted) return;
    if (guardada) {
      Navigator.pop(context);
    } else {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _esNueva ? 'Nueva categoría' : 'Editar categoría',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                CampoTexto(
                  etiqueta: 'Nombre',
                  controlador: _nombre,
                  requerido: true,
                  maxCaracteres: 100,
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: 'Descripción',
                  controlador: _descripcion,
                  maxLineas: 3,
                  maxCaracteres: 500,
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: 'Plazo de préstamo (horas)',
                  controlador: _plazoHoras,
                  soloDigitos: true,
                  maxCaracteres: 5,
                  ayuda:
                      'Ej: 168 para una semana, 4 para un equipo. '
                      'Vacío = plazo general del sistema.',
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
