import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/auth/data/models/usuario.dart';
import 'package:frontend/features/auth/presentation/providers/usuarios_provider.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/loans/presentation/providers/acciones_prestamo.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/presentation/providers/materiales_provider.dart';

/// Registra un préstamo en el mostrador, sin solicitud previa.
///
/// El personal elige a la persona y los materiales; el sistema calcula el
/// plazo de cada uno. Opcionalmente puede fijar otra fecha límite o saltarse
/// las validaciones del usuario (límite de items, préstamos vencidos).
class DialogoPrestamoDirecto extends ConsumerStatefulWidget {
  const DialogoPrestamoDirecto({super.key});

  @override
  ConsumerState<DialogoPrestamoDirecto> createState() =>
      _DialogoPrestamoDirectoState();
}

class _DialogoPrestamoDirectoState
    extends ConsumerState<DialogoPrestamoDirecto> {
  final _formKey = GlobalKey<FormState>();
  final _observaciones = TextEditingController();
  Usuario? _usuario;
  List<MaterialBiblioteca> _materiales = [];
  DateTime? _fechaLimite;
  bool _omitirValidaciones = false;
  bool _guardando = false;

  @override
  void dispose() {
    _observaciones.dispose();
    super.dispose();
  }

  Future<void> _elegirFechaLimite() async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaLimite ?? ahora.add(const Duration(days: 1)),
      firstDate: ahora,
      lastDate: ahora.add(const Duration(days: 365)),
    );
    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (hora == null) return;

    setState(() {
      _fechaLimite = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final registrado = await ejecutarAccion(
      context,
      () => ref
          .read(accionesPrestamoProvider)
          .crearDirecto(
            usuarioId: _usuario!.id,
            materialIds: _materiales.map((m) => m.id).toList(),
            observaciones: _observaciones.text.trim(),
            fechaDevolucionEsperada: _fechaLimite,
            omitirValidacionesUsuario: _omitirValidaciones,
          ),
      exito: 'Préstamo registrado',
    );

    if (!mounted) return;
    if (registrado) {
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
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 720),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
                child: Text('Nuevo préstamo', style: textos.headlineSmall),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Para entregar de inmediato, sin solicitud previa.',
                  style: textos.bodySmall,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
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
    final colores = context.colores;
    final usuarios = ref.watch(usuariosProvider);
    final materiales = ref.watch(materialesProvider(_filtroDisponibles));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (usuarios.isLoading || materiales.isLoading)
          const LinearProgressIndicator(),
        const SizedBox(height: 8),
        DropdownSearch<Usuario>(
          mode: Mode.form,
          items: (filtro, _) async => usuarios.value ?? [],
          itemAsString: (u) =>
              '${u.nombre} ${u.apellido} · ${u.numeroDocumento}',
          compareFn: (a, b) => a.id == b.id,
          filterFn: (u, filtro) => _coincide(
            '${u.nombre} ${u.apellido} ${u.numeroDocumento} ${u.username}',
            filtro,
          ),
          onChanged: (u) => setState(() => _usuario = u),
          popupProps: const PopupProps.dialog(
            showSearchBox: true,
            title: Padding(
              padding: EdgeInsets.all(16),
              child: Text('¿A quién se le presta?'),
            ),
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Nombre, documento o usuario',
              ),
            ),
          ),
          decoratorProps: const DropDownDecoratorProps(
            decoration: InputDecoration(labelText: 'Persona *'),
          ),
          validator: (u) => u == null ? 'Elige a la persona' : null,
        ),
        const SizedBox(height: 16),
        DropdownSearch<MaterialBiblioteca>.multiSelection(
          items: (filtro, _) async => materiales.value ?? [],
          itemAsString: (m) => '${m.titulo} · ${m.codigo}',
          compareFn: (a, b) => a.id == b.id,
          filterFn: (m, filtro) => _coincide(
            '${m.titulo} ${m.codigo} ${m.marca ?? ''} ${m.modelo ?? ''}',
            filtro,
          ),
          onChanged: (lista) => setState(() => _materiales = lista),
          popupProps: const PopupPropsMultiSelection.dialog(
            showSearchBox: true,
            title: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Materiales disponibles'),
            ),
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(hintText: 'Título, código o marca'),
            ),
          ),
          decoratorProps: const DropDownDecoratorProps(
            decoration: InputDecoration(labelText: 'Materiales *'),
          ),
          validator: (lista) => (lista == null || lista.isEmpty)
              ? 'Elige al menos un material'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _observaciones,
          maxLines: 2,
          maxLength: 500,
          decoration: const InputDecoration(labelText: 'Observaciones'),
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(
            'Opciones avanzadas',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(
                _fechaLimite == null
                    ? 'Plazo automático según el material'
                    : 'Devolver antes del ${FormatoFecha.fechaHora(_fechaLimite!)}',
              ),
              trailing: _fechaLimite == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Quitar fecha fija',
                      onPressed: () => setState(() => _fechaLimite = null),
                    ),
              onTap: _elegirFechaLimite,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Omitir validaciones de la persona'),
              subtitle: Text(
                'Ignora el máximo de items y los préstamos vencidos. Queda registrado en la bitácora.',
                style: TextStyle(color: colores.tintaSuave),
              ),
              value: _omitirValidaciones,
              onChanged: (v) => setState(() => _omitirValidaciones = v),
            ),
          ],
        ),
      ],
    );
  }

  /// Materiales que se pueden prestar ahora mismo.
  FiltroMateriales get _filtroDisponibles =>
      (texto: '', tipo: null, estado: null, soloDisponibles: true);

  /// Búsqueda sin distinguir mayúsculas ni tildes.
  bool _coincide(String texto, String filtro) {
    String limpiar(String s) => s
        .toLowerCase()
        .replaceAll(RegExp('[áàä]'), 'a')
        .replaceAll(RegExp('[éèë]'), 'e')
        .replaceAll(RegExp('[íìï]'), 'i')
        .replaceAll(RegExp('[óòö]'), 'o')
        .replaceAll(RegExp('[úùü]'), 'u');
    return limpiar(texto).contains(limpiar(filtro));
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
            onPressed: _guardando ? null : _registrar,
            child: _guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Registrar préstamo'),
          ),
        ],
      ),
    );
  }
}
