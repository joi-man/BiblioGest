import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/theme/tipografia_app.dart';
import 'package:frontend/features/core/widgets/barra_busqueda.dart';
import 'package:frontend/features/core/widgets/chip_estado.dart';
import 'package:frontend/features/core/widgets/encabezado_pagina.dart';
import 'package:frontend/features/core/widgets/estado_vacio.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_etiquetas.dart';
import 'package:frontend/features/materials/presentation/providers/materiales_provider.dart';

/// Inventario para el personal en el teléfono: solo consulta.
///
/// Sirve para saber rápido si algo está disponible o quién lo tiene. Registrar,
/// editar, eliminar y exportar materiales se hace desde la web o el escritorio.
class MaterialesMovilScreen extends ConsumerStatefulWidget {
  const MaterialesMovilScreen({super.key});

  @override
  ConsumerState<MaterialesMovilScreen> createState() =>
      _MaterialesMovilScreenState();
}

class _MaterialesMovilScreenState extends ConsumerState<MaterialesMovilScreen> {
  String _texto = '';
  EstadoMaterial? _estado;

  FiltroMateriales get _filtro =>
      (texto: _texto, tipo: null, estado: _estado, soloDisponibles: false);

  @override
  Widget build(BuildContext context) {
    final materiales = ref.watch(materialesProvider(_filtro));

    return Scaffold(
      body: Column(
        children: [
          EncabezadoPagina(
            titulo: 'Materiales',
            subtitulo: materiales.whenOrNull(
              data: (lista) => '${lista.length} unidades',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: BarraBusqueda(
              sugerencia: 'Título, código, autor o marca...',
              alCambiar: (texto) => setState(() => _texto = texto),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _estado == null,
                  onSelected: (_) => setState(() => _estado = null),
                ),
                for (final estado in EstadoMaterial.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(estado.etiqueta),
                    selected: _estado == estado,
                    onSelected: (_) => setState(() => _estado = estado),
                  ),
                ],
              ],
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

  Widget _lista(List<MaterialBiblioteca> lista) {
    if (lista.isEmpty) {
      return const EstadoVacio(
        titulo: 'No hay materiales',
        detalle: 'Prueba con otra búsqueda o quita el filtro de estado.',
        icono: Icons.inventory_2_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(materialesProvider(_filtro).future),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: lista.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, indice) {
          if (indice == lista.length) return const _AvisoSoloConsulta();
          return _TarjetaMaterial(material: lista[indice]);
        },
      ),
    );
  }
}

class _TarjetaMaterial extends StatelessWidget {
  const _TarjetaMaterial({required this.material});

  final MaterialBiblioteca material;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;
    final detalle = [
      if (material.esBibliografico) material.autor,
      if (material.esEquipo) ...[material.marca, material.modelo],
      material.tipoMaterial.etiqueta,
      material.ubicacion,
    ].where((p) => p != null && p.isNotEmpty).join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(material.tipoMaterial.icono, color: colores.acento),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.titulo,
                    style: textos.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detalle,
                    style: textos.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ChipEstado(estado: material.estado.valor),
                      const SizedBox(width: 8),
                      Text(
                        material.codigo,
                        style: TipografiaApp.codigo(
                          colores.tintaSuave,
                          tamano: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoSoloConsulta extends StatelessWidget {
  const _AvisoSoloConsulta();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Para registrar, editar o exportar materiales usa la versión web o de escritorio.',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: context.colores.tintaSuave),
      ),
    );
  }
}
