import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/authors/data/models/autor.dart';
import 'package:frontend/features/authors/data/repositories/autor_repository.dart';
import 'package:frontend/features/authors/presentation/providers/autores_paginados_provider.dart';
import 'package:frontend/features/authors/presentation/widgets/dialogo_autor.dart';
import 'package:frontend/features/core/widgets/barra_busqueda.dart';
import 'package:frontend/features/core/widgets/confirmacion.dart';
import 'package:frontend/features/core/widgets/controles_paginacion.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/core/widgets/encabezado_pagina.dart';
import 'package:frontend/features/core/widgets/estado_vacio.dart';
import 'package:frontend/features/core/widgets/grilla_datos.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';

enum _AccionAutor { verMateriales, editar, eliminar }

/// Autores de los materiales: grilla paginada con búsqueda por nombre.
///
/// Desde aquí se crean, renombran y eliminan autores, y se llega a los
/// materiales de cada uno. Al cargar un material también se pueden crear
/// autores sin pasar por esta pantalla.
class AutoresScreen extends ConsumerStatefulWidget {
  const AutoresScreen({super.key});

  @override
  ConsumerState<AutoresScreen> createState() => _AutoresScreenState();
}

class _AutoresScreenState extends ConsumerState<AutoresScreen> {
  ConsultaAutores _consulta = const ConsultaAutores();

  void _recargar() => ref.invalidate(autoresPaginadosProvider);

  void _abrirFormulario([Autor? autor]) {
    showDialog(
      context: context,
      builder: (_) => DialogoAutor(autor: autor),
    );
  }

  /// Abre el inventario filtrado por este autor.
  void _verMateriales(Autor autor) {
    context.go(
      Uri(
        path: '/materials',
        queryParameters: {'autor': autor.id, 'nombre': autor.nombre},
      ).toString(),
    );
  }

  Future<void> _eliminar(Autor autor) async {
    final confirmado = await confirmarEliminar(
      context,
      titulo: 'Eliminar autor',
      mensaje: '¿Eliminar a "${autor.nombre}"?',
    );
    if (!confirmado || !mounted) return;

    await ejecutarAccion(context, () async {
      await ref.read(autorRepositoryProvider).eliminar(autor.id);
      _recargar();
    }, exito: 'Autor eliminado');
  }

  /// Si la página actual quedó vacía (se borró su último autor), retrocede.
  void _corregirPaginaVacia(PaginaResultado<Autor> pagina) {
    if (pagina.paginaValida == _consulta.pagina) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _consulta = _consulta.enPagina(pagina.paginaValida));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final autores = ref.watch(autoresPaginadosProvider(_consulta));

    return Scaffold(
      body: Column(
        children: [
          EncabezadoPagina(
            titulo: 'Autores',
            subtitulo: autores.whenOrNull(
              data: (pagina) => '${pagina.total} autores',
            ),
            acciones: [
              FilledButton.icon(
                onPressed: _abrirFormulario,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo autor'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 360,
                child: BarraBusqueda(
                  sugerencia: 'Buscar autor por nombre',
                  textoInicial: _consulta.texto,
                  alCambiar: (texto) =>
                      setState(() => _consulta = _consulta.conTexto(texto)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValorAsincrono(
              valor: autores,
              alReintentar: _recargar,
              construir: _grilla,
            ),
          ),
        ],
      ),
    );
  }

  Widget _grilla(PaginaResultado<Autor> pagina) {
    _corregirPaginaVacia(pagina);

    if (pagina.items.isEmpty) {
      return const EstadoVacio(
        titulo: 'No hay autores',
        detalle:
            'Prueba con otra búsqueda o crea un autor nuevo. También puedes '
            'crearlos al cargar un material.',
        icono: Icons.person_search_outlined,
      );
    }

    return Column(
      children: [
        Expanded(
          child: GrillaDatos<Autor>(
            filas: pagina.items,
            columnas: [
              ColumnaGrilla(titulo: 'Nombre', celda: _celdaNombre),
              ColumnaGrilla(
                titulo: 'Materiales',
                numerica: true,
                celda: (a) => Text('${a.cantidadMateriales}'),
              ),
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

  Widget _celdaNombre(Autor autor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.person_outline, color: context.colores.acento, size: 22),
        const SizedBox(width: 12),
        Text(autor.nombre, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget _menuDeFila(Autor autor) {
    return PopupMenuButton<_AccionAutor>(
      tooltip: 'Más acciones',
      onSelected: (accion) => switch (accion) {
        _AccionAutor.verMateriales => _verMateriales(autor),
        _AccionAutor.editar => _abrirFormulario(autor),
        _AccionAutor.eliminar => _eliminar(autor),
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _AccionAutor.verMateriales,
          enabled: autor.cantidadMateriales > 0,
          child: const Text('Ver sus materiales'),
        ),
        const PopupMenuItem(value: _AccionAutor.editar, child: Text('Editar')),
        const PopupMenuItem(
          value: _AccionAutor.eliminar,
          child: Text('Eliminar'),
        ),
      ],
    );
  }
}
