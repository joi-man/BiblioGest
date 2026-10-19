import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/theme/tipografia_app.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/loans/data/models/devolucion.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'package:frontend/features/loans/data/models/prestamo_detalle.dart';
import 'package:frontend/features/loans/presentation/providers/acciones_prestamo.dart';
import 'package:frontend/features/returns/data/models/fecha_recepcion.dart';
import 'package:frontend/features/returns/data/repositories/devolucion_repository.dart';
import 'package:frontend/features/returns/presentation/widgets/campo_fecha_recepcion.dart';

/// Diálogo para recibir materiales de un préstamo.
///
/// Muestra los items pendientes, todos marcados y "en buen estado" de entrada,
/// de modo que el caso común se resuelve con un solo clic. Se puede
/// desmarcar un item (devolución parcial) o indicar daños o pérdida.
class DialogoDevolver extends ConsumerStatefulWidget {
  const DialogoDevolver({super.key, required this.prestamo});

  final Prestamo prestamo;

  @override
  ConsumerState<DialogoDevolver> createState() => _DialogoDevolverState();
}

class _DialogoDevolverState extends ConsumerState<DialogoDevolver> {
  late final List<PrestamoDetalle> _pendientes;
  late final Map<String, bool> _seleccionado;
  late final Map<String, CondicionDevolucion> _condicion;
  final _observaciones = TextEditingController();
  final _motivoFecha = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _recibidoEn;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _pendientes = widget.prestamo.itemsPendientes;
    _seleccionado = {for (final d in _pendientes) d.id: true};
    _condicion = {for (final d in _pendientes) d.id: CondicionDevolucion.bueno};
  }

  @override
  void dispose() {
    _observaciones.dispose();
    _motivoFecha.dispose();
    super.dispose();
  }

  int get _cantidad => _seleccionado.values.where((v) => v).length;

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final observaciones = _observaciones.text.trim();
    final items = [
      for (final detalle in _pendientes)
        if (_seleccionado[detalle.id]!)
          ItemADevolver(
            detalleId: detalle.id,
            condicion: _condicion[detalle.id]!,
            observaciones: observaciones.isEmpty ? null : observaciones,
          ),
    ];

    final registrado = await ejecutarAccion(
      context,
      () => ref
          .read(accionesPrestamoProvider)
          .registrarDevolucion(
            widget.prestamo.id,
            items,
            fechaDevolucion: _recibidoEn,
            motivoFecha: _recibidoEn == null ? null : _motivoFecha.text,
          ),
      exito: items.length == _pendientes.length
          ? 'Devolución registrada'
          : 'Devolución parcial registrada',
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
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
              child: Text('Registrar devolución', style: textos.headlineSmall),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.prestamo.usuario.nombreCompleto,
                style: textos.bodyMedium,
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    for (final detalle in _pendientes) _filaItem(detalle),
                    const SizedBox(height: 12),
                    CampoFechaRecepcion(
                      valor: _recibidoEn,
                      entrega: widget.prestamo.fechaPrestamo,
                      onChanged: (f) => setState(() => _recibidoEn = f),
                    ),
                    if (_recibidoEn != null) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _motivoFecha,
                        maxLines: 2,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Motivo de la fecha *',
                          helperText:
                              'Queda registrado en la bitácora junto con tu usuario',
                        ),
                        validator: FechaRecepcion.validarMotivo,
                      ),
                    ],
                    const SizedBox(height: 4),
                    TextField(
                      controller: _observaciones,
                      maxLines: 2,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones',
                        helperText: 'Se guardan en cada item devuelto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _acciones(),
          ],
        ),
      ),
    );
  }

  Widget _filaItem(PrestamoDetalle detalle) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;
    final marcado = _seleccionado[detalle.id]!;
    final vencido = detalle.estaVencido();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
      decoration: BoxDecoration(
        border: Border.all(color: marcado ? colores.acento : colores.linea),
        borderRadius: BorderRadius.circular(4),
        color: marcado ? colores.acentoSuave.withValues(alpha: 0.4) : null,
      ),
      child: Row(
        children: [
          Checkbox(
            value: marcado,
            onChanged: _guardando
                ? null
                : (v) => setState(() => _seleccionado[detalle.id] = v ?? false),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detalle.material.titulo, style: textos.titleSmall),
                Row(
                  children: [
                    Text(
                      detalle.material.codigo,
                      style: TipografiaApp.codigo(
                        colores.tintaSuave,
                        tamano: 12,
                      ),
                    ),
                    if (vencido) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Vencido',
                        style: textos.labelMedium?.copyWith(
                          color: colores.vencido,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 170,
            child: DropdownButtonFormField<CondicionDevolucion>(
              value: _condicion[detalle.id],
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Condición',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              items: [
                for (final c in CondicionDevolucion.values)
                  DropdownMenuItem(value: c, child: Text(c.etiqueta)),
              ],
              onChanged: marcado && !_guardando
                  ? (c) => setState(
                      () => _condicion[detalle.id] =
                          c ?? CondicionDevolucion.bueno,
                    )
                  : null,
            ),
          ),
        ],
      ),
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
            onPressed: _guardando || _cantidad == 0 ? null : _registrar,
            child: _guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _cantidad == 1
                        ? 'Registrar 1 devolución'
                        : 'Registrar $_cantidad devoluciones',
                  ),
          ),
        ],
      ),
    );
  }
}
