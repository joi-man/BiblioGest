import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/loans/data/models/plazo_devolucion.dart';
import 'package:frontend/features/returns/data/models/fecha_recepcion.dart';

/// Elige la fecha y la hora en que se recibió el material, o deja "ahora".
///
/// Lo normal es registrar en el momento: sin elección se usa la hora actual y no
/// hace falta nada más. La fecha y la hora son **de Paraguay**. [valor] es un
/// instante en UTC; [entrega] es cuándo se entregó el préstamo (no se puede
/// anotar una devolución anterior).
class CampoFechaRecepcion extends StatelessWidget {
  const CampoFechaRecepcion({
    super.key,
    required this.valor,
    required this.onChanged,
    this.entrega,
  });

  final DateTime? valor;
  final DateTime? entrega;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _elegir(BuildContext context) async {
    final primero = FechaRecepcion.primerDia(entrega: entrega);
    final ultimo = FechaRecepcion.ultimoDia();
    final actual = valor == null ? null : FormatoFecha.enParaguay(valor!);

    final dia = await showDatePicker(
      context: context,
      helpText: 'Día en que se recibió',
      initialDate: _dentro(actual ?? ultimo, primero, ultimo),
      firstDate: primero,
      lastDate: ultimo,
    );
    if (dia == null || !context.mounted) return;

    final hora = await showTimePicker(
      context: context,
      helpText: 'Hora en que se recibió (Paraguay)',
      initialTime: actual == null
          ? TimeOfDay.fromDateTime(FormatoFecha.enParaguay(DateTime.now()))
          : TimeOfDay(hour: actual.hour, minute: actual.minute),
    );
    if (hora == null || !context.mounted) return;

    final elegido = PlazoDevolucion.combinar(dia, hora.hour, hora.minute);
    final error = FechaRecepcion.validar(elegido, entrega: entrega);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    onChanged(elegido);
  }

  static DateTime _dentro(DateTime fecha, DateTime primero, DateTime ultimo) {
    if (fecha.isBefore(primero)) return primero;
    if (fecha.isAfter(ultimo)) return ultimo;
    return fecha;
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final fijada = valor != null;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_available_outlined),
      title: Text(
        fijada
            ? 'Recibido el ${FormatoFecha.fechaHora(valor!)}'
            : 'Recibido ahora',
      ),
      subtitle: Text(
        fijada
            ? 'Hora de Paraguay'
            : 'Toca si se recibió antes y se anota después',
        style: TextStyle(color: colores.tintaSuave),
      ),
      trailing: fijada
          ? IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Volver a «Recibido ahora»',
              onPressed: () => onChanged(null),
            )
          : const Icon(Icons.edit_calendar_outlined),
      onTap: () => _elegir(context),
    );
  }
}
