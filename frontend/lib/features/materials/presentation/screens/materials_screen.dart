import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/theme/tipografia_app.dart';
import 'package:frontend/features/categories/presentation/providers/categorias_provider.dart';
import 'package:frontend/features/core/widgets/boton_exportar.dart';
import 'package:frontend/features/core/widgets/chip_estado.dart';
import 'package:frontend/features/core/widgets/confirmacion.dart';
import 'package:frontend/features/core/widgets/controles_paginacion.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/core/widgets/encabezado_pagina.dart';
import 'package:frontend/features/core/widgets/estado_vacio.dart';
import 'package:frontend/features/core/widgets/grilla_datos.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_etiquetas.dart';
import 'package:frontend/features/materials/data/repositories/material_repository.dart';
import 'package:frontend/features/materials/presentation/providers/inventario_provider.dart';
import 'package:frontend/features/materials/presentation/providers/materiales_provider.dart';
import 'package:frontend/features/materials/presentation/widgets/dialogo_material.dart';
import 'package:frontend/features/materials/presentation/widgets/filtros_materiales.dart';

enum _AccionMaterial { editar, eliminar }

/// Inventario: grilla paginada de libros y equipos con búsqueda, filtros y
/// exportación a Excel y PDF.
class MaterialsScreen extends ConsumerStatefulWidget {
  const MaterialsScreen({super.key});

  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> {
  ConsultaInventario _consulta = const ConsultaInventario();

  /// Vuelve a pedir los datos: la grilla y el catálogo que ven otras pantallas.
  void _recargar() {
    ref.invalidate(inventarioPaginadoProvider);
    ref.invalidate(materialesProvider);
  }

  Future<void> _abrirFormulario([MaterialBiblioteca? material]) async {
    await showDialog(
      context: context,
      builder: (_) => DialogoMaterial(material: material),
    );
    // El diálogo refresca el catálogo; aquí se refresca la grilla paginada.
    if (mounted) _recargar();
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
        _recargar();
      },
      exito: 'Material eliminado',
    );
  }

  /// Si la página actual quedó vacía (se borró su último material), retrocede.
  void _corregirPaginaVacia(PaginaResultado<MaterialBiblioteca> pagina) {
    if (pagina.paginaValida == _consulta.pagina) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _consulta = _consulta.enPagina(pagina.paginaValida));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final materiales = ref.watch(inventarioPaginadoProvider(_consulta));

    return Scaffold(
      body: Column(
        children: [
          EncabezadoPagina(
            titulo: 'Materiales',
            subtitulo: materiales.whenOrNull(
              data: (pagina) => '${pagina.total} unidades en el inventario',
            ),
            acciones: [
              BotonExportar(
                nombreBase: 'materiales',
                obtenerArchivo: (formato) =>
                    ref.read(materialRepositoryProvider).exportar(
                          formato,
                          texto: _consulta.texto,
                          tipo: _consulta.tipo,
                          estado: _consulta.estado,
                          categoriaId: _consulta.categoriaId,
                        ),
              ),
              FilledButton.icon(
                onPressed: _abrirFormulario,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo material'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: FiltrosMateriales(
              consulta: _consulta,
              alCambiar: (nueva) => setState(() => _consulta = nueva),
            ),
          ),
          Expanded(
            child: ValorAsincrono(
              valor: materiales,
              alReintentar: _recargar,
              construir: _grilla,
            ),
          ),
        ],
      ),
    );
  }

  Widget _grilla(PaginaResultado<MaterialBiblioteca> pagina) {
    _corregirPaginaVacia(pagina);

    if (pagina.items.isEmpty) {
      return const EstadoVacio(
        titulo: 'No hay materiales',
        detalle: 'Prueba con otro filtro o registra un material nuevo.',
        icono: Icons.inventory_2_outlined,
      );
    }

    final nombresCategoria = {
      for (final c in ref.watch(categoriasProvider).valueOrNull ?? const [])
        c.id: c.nombre,
    };

    return Column(
      children: [
        Expanded(
          child: GrillaDatos<MaterialBiblioteca>(
            filas: pagina.items,
            columnas: [
              ColumnaGrilla(titulo: 'Material', celda: _celdaMaterial),
              ColumnaGrilla(
                titulo: 'Código',
                celda: (m) => Text(
                  m.codigo,
                  style: TipografiaApp.codigo(context.colores.tintaSuave, tamano: 12),
                ),
              ),
              ColumnaGrilla(
                titulo: 'Tipo',
                celda: (m) => Text(m.tipoMaterial.etiqueta),
              ),
              ColumnaGrilla(
                titulo: 'Categoría',
                celda: (m) => Text(nombresCategoria[m.categoriaId] ?? '—'),
              ),
              ColumnaGrilla(
                titulo: 'Ubicación',
                celda: (m) => Text(m.ubicacion ?? '—'),
              ),
              ColumnaGrilla(titulo: 'Estado', celda: _celdaEstado),
            ],
            acciones: _menuDeFila,
          ),
        ),
        ControlesPaginacion(
          pagina: pagina,
          alCambiarPagina: (numero) =>
              setState(() => _consulta = _consulta.enPagina(numero)),
          alCambiarTamano: (tamano) =>
              setState(() => _consulta = _consulta.conTamano(tamano)),
        ),
      ],
    );
  }

  /// Título con icono del tipo y una línea de detalle (autor, o marca y modelo).
  Widget _celdaMaterial(MaterialBiblioteca material) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;
    final detalle = [
      if (material.esBibliografico) material.autor,
      if (material.esEquipo) ...[material.marca, material.modelo],
      if (material.esMedio) material.formato,
    ].where((p) => p != null && p.isNotEmpty).join(' · ');

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Row(
        children: [
          Icon(material.tipoMaterial.icono, color: colores.acento, size: 22),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material.titulo,
                    style: textos.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (detalle.isNotEmpty)
                  Text(
                    detalle,
                    style: textos.bodySmall?.copyWith(color: colores.tintaSuave),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _celdaEstado(MaterialBiblioteca material) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChipEstado(estado: material.estado.valor),
        if (!material.esPrestable) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: 'Solo consulta en sala',
            child: Icon(Icons.lock_outline,
                size: 18, color: context.colores.tintaSuave),
          ),
        ],
      ],
    );
  }

  Widget _menuDeFila(MaterialBiblioteca material) {
    return PopupMenuButton<_AccionMaterial>(
      tooltip: 'Más acciones',
      onSelected: (accion) => switch (accion) {
        _AccionMaterial.editar => _abrirFormulario(material),
        _AccionMaterial.eliminar => _eliminar(material),
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: _AccionMaterial.editar, child: Text('Editar')),
        PopupMenuItem(value: _AccionMaterial.eliminar, child: Text('Eliminar')),
      ],
    );
  }
}
