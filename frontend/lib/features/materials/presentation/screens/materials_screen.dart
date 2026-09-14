import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/repositories/material_repository.dart';
import 'package:frontend/features/categories/data/models/categoria.dart';
import 'package:frontend/features/categories/data/repositories/categoria_repository.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/core/widgets/alertas.dart';
import 'package:frontend/features/core/widgets/confirmacion.dart';

enum _PopupMode { dialog, bottomSheet }

final materialsProvider = FutureProvider<List<MaterialBiblioteca>>(
    (ref) async {
  final authState = ref.watch(authProvider);
  final token = authState.value?.accessToken;
  if (token == null) return [];
  final repository = ref.read(materialRepositoryProvider);
  return repository.listar(token: token);
});

final categoriasListProvider = FutureProvider<List<Categoria>>((ref) async {
  final authState = ref.watch(authProvider);
  final token = authState.value?.accessToken;
  if (token == null) return [];
  final repository = ref.read(categoriaRepositoryProvider);
  return repository.listar(token);
});

class MaterialsScreen extends ConsumerWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarFormulario(context, ref),
          ),
        ],
      ),
      body: materialsAsync.when(
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
                onPressed: () => ref.invalidate(materialsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (materiales) {
          if (materiales.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay materiales registrados'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materiales.length,
            itemBuilder: (context, index) {
              final material = materiales[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                        material.codigo.substring(0, 2).toUpperCase()),
                  ),
                  title: Text(material.titulo),
                  subtitle: Text(
                    '${material.tipoMaterial.name} - ${material.estado.name}',
                  ),
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
                          leading:
                              Icon(Icons.delete, color: Colors.red),
                          title: Text('Eliminar'),
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'editar') {
                        _mostrarFormulario(context, ref,
                            material: material);
                      } else if (value == 'eliminar') {
                        final confirmado = await confirmarEliminar(
                          context,
                          titulo: 'Eliminar material',
                          mensaje:
                              'Estas seguro de eliminar "${material.titulo}"?',
                        );
                        if (confirmado && context.mounted) {
                          final token = ref
                              .read(authProvider)
                              .value
                              ?.accessToken;
                          if (token != null) {
                            final repo = ref
                                .read(materialRepositoryProvider);
                            await repo.eliminar(material.id,
                                token: token);
                            ref.invalidate(materialsProvider);
                            if (context.mounted) {
                              context
                                  .mostrarExito('Material eliminado');
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
      {MaterialBiblioteca? material}) {
    showDialog(
      context: context,
      builder: (context) => _DialogMaterial(
        material: material,
        onGuardado: () => ref.invalidate(materialsProvider),
      ),
    );
  }
}

class _DialogMaterial extends ConsumerStatefulWidget {
  final MaterialBiblioteca? material;
  final VoidCallback onGuardado;

  const _DialogMaterial({this.material, required this.onGuardado});

  @override
  ConsumerState<_DialogMaterial> createState() => _DialogMaterialState();
}

class _DialogMaterialState extends ConsumerState<_DialogMaterial> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoController;
  late TextEditingController _tituloController;
  late TextEditingController _autorController;
  late TextEditingController _isbnController;
  late TextEditingController _editorialController;
  late TextEditingController _descripcionController;
  TipoMaterial _tipoMaterial = TipoMaterial.libro;
  String? _categoriaId;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController(
        text: widget.material?.codigo ?? '');
    _tituloController = TextEditingController(
        text: widget.material?.titulo ?? '');
    _autorController = TextEditingController(
        text: widget.material?.autor ?? '');
    _isbnController = TextEditingController(
        text: widget.material?.isbn ?? '');
    _editorialController = TextEditingController(
        text: widget.material?.editorial ?? '');
    _descripcionController = TextEditingController(
        text: widget.material?.descripcion ?? '');
    if (widget.material != null) {
      _tipoMaterial = widget.material!.tipoMaterial;
      _categoriaId = widget.material?.categoriaId;
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _tituloController.dispose();
    _autorController.dispose();
    _isbnController.dispose();
    _editorialController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriasListProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.material == null
                      ? 'Nuevo Material'
                      : 'Editar Material',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _codigoController,
                  maxLength: 50,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Codigo *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El codigo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tituloController,
                  maxLength: 255,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Titulo *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El titulo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TipoMaterial>(
                  value: _tipoMaterial,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Material *',
                    border: OutlineInputBorder(),
                  ),
                  items: TipoMaterial.values.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipoMaterial = value ?? TipoMaterial.libro;
                    });
                  },
                ),
                const SizedBox(height: 16),
                categoriasAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error cargando categorias: $e'),
                  data: (categorias) {
                    if (categorias.isEmpty) {
                      return const Text('Primero crea una categoria');
                    }
                    return DropdownSearch<Categoria>(
                      mode: Mode.form,
                      popupProps: PopupProps.dialog(
                        showSearchBox: true,
                        title: const Text('Selecciona una categoria'),
                        searchFieldProps: const TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Buscar...',
                          ),
                        ),
                        dialogProps: const DialogProps(
                          backgroundColor: Colors.white,
                          insetPadding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 24),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                      items: (filter, _) async => categorias,
                      selectedItem: _categoriaId != null
                          ? categorias.firstWhere(
                              (c) => c.id == _categoriaId,
                              orElse: () => categorias.first)
                          : null,
                      itemAsString: (cat) => cat.nombre,
                      onChanged: (selected) {
                        setState(() {
                          _categoriaId = selected?.id;
                        });
                      },
                      compareFn: (a, b) => a.id == b.id,
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          labelText: 'Categoria *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona una categoria';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _autorController,
                  maxLength: 255,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Autor',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _isbnController,
                  maxLength: 20,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ISBN',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _editorialController,
                  maxLength: 200,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Editorial',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  maxLength: 1000,
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

      final repo = ref.read(materialRepositoryProvider);

      if (widget.material == null) {
        await repo.crearMap(
          {
            'codigo': _codigoController.text.trim(),
            'titulo': _tituloController.text.trim(),
            'tipo_material': _tipoMaterial.name,
            'categoria_id': _categoriaId,
            'autor': _autorController.text.trim().isEmpty
                ? null
                : _autorController.text.trim(),
            'isbn': _isbnController.text.trim().isEmpty
                ? null
                : _isbnController.text.trim(),
            'editorial': _editorialController.text.trim().isEmpty
                ? null
                : _editorialController.text.trim(),
            'descripcion': _descripcionController.text.trim().isEmpty
                ? null
                : _descripcionController.text.trim(),
          },
          token: token,
        );
      } else {
        await repo.actualizar(
          widget.material!.id,
          {
            'titulo': _tituloController.text.trim(),
            'tipo_material': _tipoMaterial.name,
            'categoria_id': _categoriaId,
            'autor': _autorController.text.trim().isEmpty
                ? null
                : _autorController.text.trim(),
            'isbn': _isbnController.text.trim().isEmpty
                ? null
                : _isbnController.text.trim(),
            'editorial': _editorialController.text.trim().isEmpty
                ? null
                : _editorialController.text.trim(),
            'descripcion': _descripcionController.text.trim().isEmpty
                ? null
                : _descripcionController.text.trim(),
          },
          token: token,
        );
      }

      widget.onGuardado();
      if (mounted) Navigator.pop(context);
      if (mounted) context.mostrarExito('Material guardado correctamente');
    } catch (e) {
      if (mounted) context.mostrarError('Error: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}
