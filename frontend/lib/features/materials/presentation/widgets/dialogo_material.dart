import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/authors/presentation/providers/autores_paginados_provider.dart';
import 'package:frontend/features/authors/presentation/widgets/selector_autores.dart';
import 'package:frontend/features/authors/presentation/widgets/seleccion_autores.dart';
import 'package:frontend/features/categories/presentation/providers/categorias_provider.dart';
import 'package:frontend/features/core/widgets/campo_texto.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_etiquetas.dart';
import 'package:frontend/features/materials/data/repositories/material_repository.dart';
import 'package:frontend/features/materials/presentation/providers/materiales_provider.dart';
import 'controladores_material.dart';
import 'selector_categoria.dart';

/// Formulario para crear o editar una unidad de material.
///
/// Los campos cambian según el tipo: un libro pide autores, tomo e ISBN, un
/// proyector pide marca, modelo, número de serie y accesorios. Los autores se
/// eligen (o se crean) en el mismo formulario.
class DialogoMaterial extends ConsumerStatefulWidget {
  const DialogoMaterial({super.key, this.material});

  /// Material a editar; `null` para crear uno nuevo.
  final MaterialBiblioteca? material;

  @override
  ConsumerState<DialogoMaterial> createState() => _DialogoMaterialState();
}

class _DialogoMaterialState extends ConsumerState<DialogoMaterial> {
  final _formKey = GlobalKey<FormState>();
  late final ControladoresMaterial _c;
  late TipoMaterial _tipo;
  late CondicionMaterial _condicion;
  late bool _esPrestable;
  String? _categoriaId;
  late SeleccionAutores _autores;
  bool _guardando = false;

  bool get _esNuevo => widget.material == null;
  bool get _esBibliografico =>
      _tipo == TipoMaterial.libro || _tipo == TipoMaterial.revista;
  bool get _esMedio => _tipo == TipoMaterial.dvd || _tipo == TipoMaterial.cd;
  bool get _esEquipo => !_esBibliografico && !_esMedio;

  @override
  void initState() {
    super.initState();
    final material = widget.material;
    _c = ControladoresMaterial(material);
    _tipo = material?.tipoMaterial ?? TipoMaterial.libro;
    _condicion = material?.condicion ?? CondicionMaterial.bueno;
    _esPrestable = material?.esPrestable ?? true;
    _categoriaId = material?.categoriaId;
    _autores = SeleccionAutores(existentes: material?.autores ?? const []);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final datos = _c.aPeticion(
      autores: _autores,
      tipo: _tipo,
      categoriaId: _categoriaId!,
      condicion: _condicion,
      esPrestable: _esPrestable,
      esNuevo: _esNuevo,
    );
    final repositorio = ref.read(materialRepositoryProvider);

    final guardado = await ejecutarAccion(context, () async {
      if (_esNuevo) {
        await repositorio.crear(datos);
      } else {
        await repositorio.actualizar(widget.material!.id, datos);
      }
      ref.invalidate(materialesProvider);
      // Un autor nuevo pasa a existir al guardar el material.
      ref.invalidate(autoresPaginadosProvider);
    }, exito: 'Material guardado');

    if (!mounted) return;
    if (guardado) {
      Navigator.pop(context);
    } else {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  _esNuevo ? 'Nuevo material' : 'Editar material',
                  style: textos.headlineSmall,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: _campos(),
                ),
              ),
              _acciones(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fila([
          CampoTexto(
            etiqueta: 'Código de inventario',
            controlador: _c.codigo,
            requerido: true,
            maxCaracteres: 50,
            mayusculas: true,
            habilitado: _esNuevo,
            ayuda: _esNuevo ? null : 'El código no se puede cambiar',
          ),
          _selectorTipo(),
        ]),
        CampoTexto(
          etiqueta: 'Título o nombre',
          controlador: _c.titulo,
          requerido: true,
          maxCaracteres: 255,
        ),
        SelectorCategoria(
          categoriaId: _categoriaId,
          alCambiar: (c) => setState(() => _categoriaId = c?.id),
        ),
        if (_esBibliografico) ..._camposBibliograficos(),
        if (_esMedio) ..._camposMedio(),
        if (_esEquipo) ..._camposEquipo(),
        ..._camposGestion(),
        CampoTexto(
          etiqueta: 'Descripción',
          controlador: _c.descripcion,
          maxLineas: 3,
          maxCaracteres: 1000,
        ),
      ].expand((w) => [w, const SizedBox(height: 16)]).toList(),
    );
  }

  List<Widget> _camposBibliograficos() => [
    SelectorAutores(
      seleccion: _autores,
      alCambiar: (nueva) => setState(() => _autores = nueva),
    ),
    _fila([
      CampoTexto(
        etiqueta: 'Tomo',
        controlador: _c.tomo,
        maxCaracteres: 20,
        ayuda: 'Solo si es una obra de varios tomos. Ej: 2',
      ),
      CampoTexto(
        etiqueta: 'Total de tomos',
        controlador: _c.totalTomos,
        soloDigitos: true,
        maxCaracteres: 3,
        validador: (v) => v != null && v.isNotEmpty && int.parse(v) < 1
            ? 'Debe ser 1 o más'
            : null,
      ),
    ]),
    _fila([
      CampoTexto(etiqueta: 'ISBN', controlador: _c.isbn, maxCaracteres: 20),
      CampoTexto(
        etiqueta: 'Editorial',
        controlador: _c.editorial,
        maxCaracteres: 200,
      ),
    ]),
    _fila([
      CampoTexto(
        etiqueta: 'Año de publicación',
        controlador: _c.anio,
        soloDigitos: true,
        maxCaracteres: 4,
      ),
      CampoTexto(
        etiqueta: 'Número de páginas',
        controlador: _c.paginas,
        soloDigitos: true,
        maxCaracteres: 5,
      ),
    ]),
  ];

  List<Widget> _camposMedio() => [
    _fila([
      CampoTexto(
        etiqueta: 'Formato',
        controlador: _c.formato,
        maxCaracteres: 50,
      ),
      CampoTexto(
        etiqueta: 'Duración',
        controlador: _c.duracion,
        maxCaracteres: 50,
        ayuda: 'Ej: 120 min',
      ),
    ]),
  ];

  List<Widget> _camposEquipo() => [
    _fila([
      CampoTexto(etiqueta: 'Marca', controlador: _c.marca, maxCaracteres: 100),
      CampoTexto(
        etiqueta: 'Modelo',
        controlador: _c.modelo,
        maxCaracteres: 100,
      ),
    ]),
    CampoTexto(
      etiqueta: 'Número de serie',
      controlador: _c.numeroSerie,
      maxCaracteres: 100,
    ),
    CampoTexto(
      etiqueta: 'Accesorios incluidos',
      controlador: _c.accesorios,
      maxLineas: 2,
      maxCaracteres: 500,
      ayuda: 'Ej: cable HDMI, control remoto, maletín',
    ),
  ];

  List<Widget> _camposGestion() {
    final plazoCategoria = _plazoDeLaCategoria();
    return [
      _filaEjemplares(),
      _fila([
        CampoTexto(
          etiqueta: 'Ubicación',
          controlador: _c.ubicacion,
          maxCaracteres: 150,
          ayuda: 'Ej: Estante B3',
        ),
        _selectorCondicion(),
      ]),
      _fila([
        CampoTexto(
          etiqueta: 'Plazo de préstamo (horas)',
          controlador: _c.plazoHoras,
          soloDigitos: true,
          maxCaracteres: 5,
          ayuda: plazoCategoria == null
              ? 'Vacío = plazo general'
              : 'Vacío = $plazoCategoria h de la categoría',
        ),
        CampoTexto(
          etiqueta: 'Valor de reposición',
          controlador: _c.valor,
          teclado: const TextInputType.numberWithOptions(decimal: true),
          maxCaracteres: 10,
          ayuda: 'Se usa si el material se pierde',
        ),
      ]),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Se puede prestar'),
        subtitle: const Text(
          'Desactívalo para material de consulta solo en sala',
        ),
        value: _esPrestable,
        onChanged: (v) => setState(() => _esPrestable = v),
      ),
    ];
  }

  /// Cantidad de ejemplares y, al editar, cuántos están fuera de servicio.
  Widget _filaEjemplares() {
    final material = widget.material;
    return _fila([
      CampoTexto(
        etiqueta: 'Cantidad de ejemplares',
        controlador: _c.cantidad,
        requerido: true,
        soloDigitos: true,
        maxCaracteres: 5,
        ayuda: material == null || material.ejemplaresEnUso == 0
            ? 'Copias que tiene la biblioteca'
            : 'Ahora hay ${material.ejemplaresEnUso} reservados o prestados',
        validador: (v) {
          final cantidad = int.tryParse(v ?? '') ?? 0;
          if (cantidad < 1) return 'Debe haber al menos 1 ejemplar';
          if (material != null && cantidad < material.ejemplaresEnUso) {
            return 'Hay ${material.ejemplaresEnUso} en uso';
          }
          return null;
        },
      ),
      if (_esNuevo)
        const SizedBox.shrink()
      else
        CampoTexto(
          etiqueta: 'Fuera de servicio',
          controlador: _c.fueraServicio,
          soloDigitos: true,
          maxCaracteres: 5,
          ayuda: 'Ejemplares dañados o perdidos',
        ),
    ]);
  }

  /// Plazo en horas de la categoría elegida, para mostrarlo como referencia.
  int? _plazoDeLaCategoria() {
    final categorias = ref.watch(categoriasProvider).value;
    if (categorias == null || _categoriaId == null) return null;
    for (final c in categorias) {
      if (c.id == _categoriaId) return c.plazoPrestamoHoras;
    }
    return null;
  }

  Widget _selectorTipo() {
    return DropdownButtonFormField<TipoMaterial>(
      value: _tipo,
      decoration: const InputDecoration(labelText: 'Tipo de material *'),
      items: [
        for (final t in TipoMaterial.values)
          DropdownMenuItem(value: t, child: Text(t.etiqueta)),
      ],
      onChanged: (t) => setState(() => _tipo = t ?? _tipo),
    );
  }

  Widget _selectorCondicion() {
    return DropdownButtonFormField<CondicionMaterial>(
      value: _condicion,
      decoration: const InputDecoration(labelText: 'Condición'),
      items: [
        for (final c in CondicionMaterial.values)
          DropdownMenuItem(value: c, child: Text(c.etiqueta)),
      ],
      onChanged: (c) => setState(() => _condicion = c ?? _condicion),
    );
  }

  /// Coloca los campos lado a lado, repartiendo el ancho por igual.
  Widget _fila(List<Widget> hijos) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < hijos.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: hijos[i]),
        ],
      ],
    );
  }

  Widget _acciones() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          TextButton(
            onPressed: _guardando ? null : () => Navigator.pop(context),
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
    );
  }
}
