import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/auth/data/models/usuario.dart';
import 'package:frontend/features/auth/presentation/providers/usuarios_provider.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'package:frontend/features/loans/presentation/providers/acciones_prestamo.dart';
import 'package:frontend/features/loans/presentation/widgets/campo_fecha_devolucion.dart';

/// Presta a otra persona un material que está reservado para alguien más.
///
/// Es un caso excepcional (por ejemplo, un docente lo necesita para una clase
/// ahora mismo). Se cancela la reserva original, se entrega el material a la
/// persona elegida y a quien había reservado se le informa el [motivo] por
/// correo y en la aplicación.
Future<void> cederReserva(BuildContext context, Prestamo reserva) {
  return showDialog<void>(
    context: context,
    builder: (_) => _DialogoCederReserva(reserva: reserva),
  );
}

class _DialogoCederReserva extends ConsumerStatefulWidget {
  const _DialogoCederReserva({required this.reserva});

  final Prestamo reserva;

  @override
  ConsumerState<_DialogoCederReserva> createState() =>
      _DialogoCederReservaState();
}

class _DialogoCederReservaState extends ConsumerState<_DialogoCederReserva> {
  final _formKey = GlobalKey<FormState>();
  final _motivo = TextEditingController();
  Usuario? _usuario;
  DateTime? _fechaLimite;
  bool _guardando = false;

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _ceder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final cedida = await ejecutarAccion(
      context,
      () => ref
          .read(accionesPrestamoProvider)
          .ceder(
            widget.reserva.id,
            usuarioId: _usuario!.id,
            motivo: _motivo.text.trim(),
            fechaDevolucionEsperada: _fechaLimite,
          ),
      exito: 'Material prestado. Se avisó a quien lo tenía reservado',
    );

    if (!mounted) return;
    if (cedida) {
      Navigator.pop(context);
    } else {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;
    final reserva = widget.reserva;
    final usuarios = ref.watch(usuariosProvider);

    return AlertDialog(
      title: const Text('Prestar a otra persona'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${reserva.resumenMateriales} está reservado para '
                  '${reserva.usuario.nombreCompleto}.',
                  style: textos.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Úsalo solo en casos importantes: se cancelará su reserva y se le '
                  'enviará el motivo por correo.',
                  style: textos.bodySmall?.copyWith(color: colores.tintaSuave),
                ),
                const SizedBox(height: 20),
                if (usuarios.isLoading) const LinearProgressIndicator(),
                DropdownSearch<Usuario>(
                  mode: Mode.form,
                  items: (filtro, _) async => [
                    for (final u in usuarios.value ?? const <Usuario>[])
                      if (u.id != reserva.usuario.id) u,
                  ],
                  itemAsString: (u) =>
                      '${u.nombre} ${u.apellido} · ${u.numeroDocumento}',
                  compareFn: (a, b) => a.id == b.id,
                  filterFn: (u, filtro) =>
                      '${u.nombre} ${u.apellido} ${u.numeroDocumento} ${u.username}'
                          .toLowerCase()
                          .contains(filtro.toLowerCase()),
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
                TextFormField(
                  controller: _motivo,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: 'Motivo *',
                    helperText: '${reserva.usuario.nombre} verá este mensaje.',
                  ),
                  validator: (valor) =>
                      (valor == null || valor.trim().length < 10)
                      ? 'Explica el motivo (al menos 10 caracteres)'
                      : null,
                ),
                const SizedBox(height: 8),
                CampoFechaDevolucion(
                  valor: _fechaLimite,
                  onChanged: (f) => setState(() => _fechaLimite = f),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _ceder,
          child: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Prestar a esta persona'),
        ),
      ],
    );
  }
}
