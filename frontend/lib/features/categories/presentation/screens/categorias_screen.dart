import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/categories/data/models/categoria.dart';
import 'package:frontend/features/categories/data/repositories/categoria_repository.dart';
import 'package:frontend/features/categories/presentation/providers/categorias_provider.dart';
import 'package:frontend/features/categories/presentation/widgets/dialogo_categoria.dart';
import 'package:frontend/features/core/widgets/confirmacion.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/core/widgets/encabezado_pagina.dart';
import 'package:frontend/features/core/widgets/estado_vacio.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';

/// Categorías de materiales y su plazo de préstamo por defecto.
class CategoriasScreen extends ConsumerWidget {
  const CategoriasScreen({super.key});

  void _abrirFormulario(BuildContext context, [Categoria? categoria]) {
    showDialog(
      context: context,
      builder: (_) => DialogoCategoria(categoria: categoria),
    );
  }

  Future<void> _eliminar(
    BuildContext context,
    WidgetRef ref,
    Categoria categoria,
  ) async {
    final confirmado = await confirmarEliminar(
      context,
      titulo: 'Eliminar categoría',
      mensaje: '¿Eliminar la categoría "${categoria.nombre}"?',
    );
    if (!confirmado || !context.mounted) return;

    await ejecutarAccion(context, () async {
      await ref.read(categoriaRepositoryProvider).eliminar(categoria.id);
      ref.invalidate(categoriasProvider);
    }, exito: 'Categoría eliminada');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorias = ref.watch(categoriasProvider);

    return Scaffold(
      body: Column(
        children: [
          EncabezadoPagina(
            titulo: 'Categorías',
            subtitulo: 'Agrupan los materiales y definen su plazo de préstamo',
            acciones: [
              FilledButton.icon(
                onPressed: () => _abrirFormulario(context),
                icon: const Icon(Icons.add),
                label: const Text('Nueva categoría'),
              ),
            ],
          ),
          Expanded(
            child: ValorAsincrono(
              valor: categorias,
              alReintentar: () => ref.invalidate(categoriasProvider),
              construir: (lista) => _lista(context, ref, lista),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lista(
    BuildContext context,
    WidgetRef ref,
    List<Categoria> categorias,
  ) {
    if (categorias.isEmpty) {
      return const EstadoVacio(
        titulo: 'No hay categorías',
        detalle: 'Crea la primera para poder registrar materiales.',
        icono: Icons.category_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: categorias.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, indice) {
        final categoria = categorias[indice];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            title: Text(
              categoria.nombre,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle:
                categoria.descripcion == null || categoria.descripcion!.isEmpty
                ? null
                : Text(categoria.descripcion!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EtiquetaPlazo(horas: categoria.plazoPrestamoHoras),
                PopupMenuButton<String>(
                  tooltip: 'Más acciones',
                  onSelected: (accion) {
                    if (accion == 'editar') {
                      _abrirFormulario(context, categoria);
                    } else {
                      _eliminar(context, ref, categoria);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Muestra el plazo de préstamo de la categoría en una forma legible.
class _EtiquetaPlazo extends StatelessWidget {
  const _EtiquetaPlazo({required this.horas});

  final int? horas;

  String get _texto {
    if (horas == null) return 'Plazo general';
    if (horas! % 24 == 0) {
      final dias = horas! ~/ 24;
      return dias == 1 ? '1 día' : '$dias días';
    }
    return '$horas h';
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule, size: 16, color: colores.tintaSuave),
        const SizedBox(width: 4),
        Text(_texto, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(width: 8),
      ],
    );
  }
}
