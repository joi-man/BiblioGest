import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/categories/data/repositories/categoria_repository.dart';
import 'package:frontend/features/categories/data/models/categoria.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/core/widgets/alertas.dart';
import 'package:frontend/features/core/widgets/confirmacion.dart';

final categoriasProvider = FutureProvider<List<Categoria>>((ref) async {
  final authState = ref.watch(authProvider);
  final token = authState.value?.accessToken;
  if (token == null) return [];
  final repository = ref.read(categoriaRepositoryProvider);
  return repository.listar(token);
});

class CategoriasScreen extends ConsumerWidget {
  const CategoriasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarFormulario(context, ref),
          ),
        ],
      ),
      body: categoriasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(categoriasProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (categorias) {
          if (categorias.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay categorias registradas'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.category)),
                  title: Text(categoria.nombre),
                  subtitle: Text(categoria.descripcion ?? ''),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Editar'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Eliminar'),
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'editar') {
                        _mostrarFormulario(context, ref, categoria: categoria);
                      } else if (value == 'eliminar') {
                        final confirmado = await confirmarEliminar(
                          context,
                          titulo: 'Eliminar categoria',
                          mensaje:
                              'Estas seguro de eliminar "${categoria.nombre}"?',
                        );
                        if (confirmado && context.mounted) {
                          final token = ref.read(authProvider).value?.accessToken;
                          if (token != null) {
                            final repo = ref.read(categoriaRepositoryProvider);
                            await repo.eliminar(categoria.id, token);
                            ref.invalidate(categoriasProvider);
                            if (context.mounted) {
                              context.mostrarExito('Categoria eliminada');
                            }
                          }
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarFormulario(BuildContext context, WidgetRef ref,
      {Categoria? categoria}) {
    showDialog(
      context: context,
      builder: (context) => _DialogCategoria(
        categoria: categoria,
        onGuardado: () => ref.invalidate(categoriasProvider),
      ),
    );
  }
}

class _DialogCategoria extends ConsumerStatefulWidget {
  final Categoria? categoria;
  final VoidCallback onGuardado;

  const _DialogCategoria({this.categoria, required this.onGuardado});

  @override
  ConsumerState<_DialogCategoria> createState() => _DialogCategoriaState();
}

class _DialogCategoriaState extends ConsumerState<_DialogCategoria> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.categoria?.nombre ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.categoria?.descripcion ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.categoria == null
                      ? 'Nueva Categoria'
                      : 'Editar Categoria',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreController,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  maxLength: 500,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descripcion',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _guardando ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _guardando ? null : _guardar,
                      child: _guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
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

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final token = ref.read(authProvider).value?.accessToken;
      if (token == null) return;

      final repo = ref.read(categoriaRepositoryProvider);
      final datos = {
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
      };

      if (widget.categoria == null) {
        await repo.crear(datos, token);
      } else {
        await repo.actualizar(widget.categoria!.id, datos, token);
      }

      widget.onGuardado();
      if (mounted) Navigator.pop(context);
      if (mounted) context.mostrarExito('Categoria guardada correctamente');
    } catch (e) {
      if (mounted) context.mostrarError('Error: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}
