import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/core/widgets/confirmacion.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/core/widgets/encabezado_pagina.dart';
import 'package:frontend/features/core/widgets/estado_vacio.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/repositories/material_repository.dart';
import 'package:frontend/features/materials/presentation/providers/materiales_provider.dart';
import 'package:frontend/features/materials/presentation/widgets/dialogo_material.dart';
import 'package:frontend/features/materials/presentation/widgets/fila_material.dart';
import 'package:frontend/features/materials/presentation/widgets/filtros_materiales.dart';

/// Inventario: libros y equipos que presta la biblioteca.
class MaterialsScreen extends ConsumerStatefulWidget {
  const MaterialsScreen({super.key});

  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> {
  FiltroMateriales _filtro = filtroMaterialesVacio;

  void _abrirFormulario([MaterialBiblioteca? material]) {
    showDialog(
      context: context,
      builder: (_) => DialogoMaterial(material: material),
    );
  }

  Future<void> _eliminar(MaterialBiblioteca material) async {
    final confirmado = await confirmarEliminar(
      context,
      titulo: 'Eliminar material',
      mensaje: '¿Eliminar "${material.titulo}" (${material.codigo})?',
    );
    if (!confirmado || !mounted) return;

    await ejecutarAccion(
      context,
      () async {
        await ref.read(materialRepositoryProvider).eliminar(material.id);
        ref.invalidate(materialesProvider);
      },
      exito: 'Material eliminado',
    );
  }

  void _alElegirAccion(MaterialBiblioteca material, AccionMaterial accion) {
    switch (accion) {
      case AccionMaterial.editar:
        _abrirFormulario(material);
      case AccionMaterial.eliminar:
        _eliminar(material);
    }
  }

  @override
  Widget build(BuildContext context) {
    final materiales = ref.watch(materialesProvider(_filtro));

    return Scaffold(
      body: Column(
        children: [
          EncabezadoPagina(
            titulo: 'Materiales',
            subtitulo: materiales.whenOrNull(
              data: (lista) => '${lista.length} unidades en el inventario',
            ),
            acciones: [
              FilledButton.icon(
                onPressed: _abrirFormulario,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo material'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: FiltrosMateriales(
              filtro: _filtro,
              alCambiar: (nuevo) => setState(() => _filtro = nuevo),
            ),
          ),
          Expanded(
            child: ValorAsincrono(
              valor: materiales,
              alReintentar: () => ref.invalidate(materialesProvider),
              construir: _lista,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lista(List<MaterialBiblioteca> materiales) {
    if (materiales.isEmpty) {
      return const EstadoVacio(
        titulo: 'No hay materiales',
        detalle: 'Prueba con otro filtro o registra un material nuevo.',
        icono: Icons.inventory_2_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: materiales.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, indice) {
        final material = materiales[indice];
        return Card(
          child: FilaMaterial(
            material: material,
            alElegirAccion: (accion) => _alElegirAccion(material, accion),
          ),
        );
      },
    );
  }
}
