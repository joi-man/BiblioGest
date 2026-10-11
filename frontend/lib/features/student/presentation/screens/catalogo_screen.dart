import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/core/widgets/barra_busqueda.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/core/widgets/estado_vacio.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';
import 'package:frontend/features/loans/presentation/providers/acciones_prestamo.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_etiquetas.dart';
import 'package:frontend/features/materials/presentation/providers/materiales_provider.dart';
import 'package:frontend/features/student/presentation/widgets/detalle_material_hoja.dart';
import 'package:frontend/features/student/presentation/widgets/tarjeta_catalogo.dart';

/// Catálogo para el estudiante: busca materiales y arma una solicitud.
class CatalogoScreen extends ConsumerStatefulWidget {
  const CatalogoScreen({super.key, required this.alSolicitado});

  /// Se llama cuando la solicitud se envió, para llevar al estudiante a "Mis solicitudes".
  final VoidCallback alSolicitado;

  @override
  ConsumerState<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends ConsumerState<CatalogoScreen> {
  String _texto = '';
  TipoMaterial? _tipo;
  bool _soloDisponibles = true;
  bool _enviando = false;

  /// Materiales elegidos para solicitar, por ID.
  final Map<String, MaterialBiblioteca> _seleccion = {};

  FiltroMateriales get _filtro => (
        texto: _texto,
        tipo: _tipo,
        estado: null,
        soloDisponibles: _soloDisponibles,
      );

  void _alternar(MaterialBiblioteca material) {
    setState(() {
      if (_seleccion.remove(material.id) == null) {
        _seleccion[material.id] = material;
      }
    });
  }

  void _verDetalle(MaterialBiblioteca material) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DetalleMaterialHoja(
        material: material,
        seleccionado: _seleccion.containsKey(material.id),
        alAlternarSeleccion: () => _alternar(material),
      ),
    );
  }

  Future<void> _solicitar() async {
    setState(() => _enviando = true);

    final enviada = await ejecutarAccion(
      context,
      () => ref
          .read(accionesPrestamoProvider)
          .solicitar(_seleccion.keys.toList()),
      exito: 'Solicitud enviada. Te avisaremos cuando la revisen',
    );

    if (!mounted) return;
    setState(() => _enviando = false);
    if (enviada) {
      setState(_seleccion.clear);
      widget.alSolicitado();
    }
  }

  @override
  Widget build(BuildContext context) {
    final materiales = ref.watch(materialesProvider(_filtro));

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: BarraBusqueda(
              sugerencia: 'Busca un libro, proyector, alargador...',
              alCambiar: (texto) => setState(() => _texto = texto),
            ),
          ),
          _filtros(),
          Expanded(
            child: ValorAsincrono(
              valor: materiales,
              alReintentar: () => ref.invalidate(materialesProvider),
              construir: _lista,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _seleccion.isEmpty ? null : _barraSolicitud(),
    );
  }

  Widget _filtros() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('Solo disponibles'),
            selected: _soloDisponibles,
            onSelected: (v) => setState(() => _soloDisponibles = v),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Todo'),
            selected: _tipo == null,
            onSelected: (_) => setState(() => _tipo = null),
          ),
          for (final tipo in TipoMaterial.values) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(tipo.etiqueta),
              selected: _tipo == tipo,
              onSelected: (_) => setState(() => _tipo = tipo),
            ),
          ],
        ],
      ),
    );
  }

  Widget _lista(List<MaterialBiblioteca> materiales) {
    if (materiales.isEmpty) {
      return const EstadoVacio(
        titulo: 'No encontramos nada',
        detalle: 'Prueba con otra búsqueda o quita el filtro de disponibles.',
        icono: Icons.search_off,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: materiales.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, indice) {
        final material = materiales[indice];
        return TarjetaCatalogo(
          material: material,
          seleccionado: _seleccion.containsKey(material.id),
          alTocar: () => _verDetalle(material),
          alAlternarSeleccion: () => _alternar(material),
        );
      },
    );
  }

  Widget _barraSolicitud() {
    final colores = context.colores;
    final cantidad = _seleccion.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: colores.superficie,
        border: Border(top: BorderSide(color: colores.linea)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Text(
                cantidad == 1 ? '1 material elegido' : '$cantidad materiales elegidos',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton(
              onPressed: _enviando ? null : () => setState(_seleccion.clear),
              child: const Text('Vaciar'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _enviando ? null : _solicitar,
              child: _enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Solicitar'),
            ),
          ],
        ),
      ),
    );
  }
}
