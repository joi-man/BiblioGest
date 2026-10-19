import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/loans/data/models/plazo_devolucion.dart';

/// Elige la fecha y la hora de devolución, o deja el plazo automático.
///
/// Sin elección, el sistema calcula el plazo de cada material (el del material,
/// el de su categoría o el general). La fecha y la hora son **de Paraguay**, sin
/// importar la zona horaria del dispositivo. [valor] es un instante en UTC.
class CampoFechaDevolucion extends StatelessWidget {
  const CampoFechaDevolucion({
    super.key,
    required this.valor,
    required this.onChanged,
  });

  final DateTime? valor;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _elegir(BuildContext context) async {
    final hoy = PlazoDevolucion.hoyEnParaguay();
    final actual = valor == null ? null : FormatoFecha.enParaguay(valor!);

    final dia = await showDatePicker(
      context: context,
      helpText: 'Día de devolución',
      initialDate: actual ?? hoy.add(const Duration(days: 1)),
      firstDate: hoy,
      lastDate: hoy.add(PlazoDevolucion.maximo),
    );
    if (dia == null || !context.mounted) return;

    final hora = await showTimePicker(
      context: context,
      helpText: 'Hora de devolución (Paraguay)',
      initialTime: actual == null
          ? const TimeOfDay(hour: PlazoDevolucion.horaPropuesta, minute: 0)
          : TimeOfDay(hour: actual.hour, minute: actual.minute),
    );
    if (hora == null || !context.mounted) return;

    final elegido = PlazoDevolucion.combinar(dia, hora.hour, hora.minute);
    final error = PlazoDevolucion.validar(elegido);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    onChanged(elegido);
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final fijada = valor != null;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(
        fijada
            ? 'Devolver el ${FormatoFecha.fechaHora(valor!)}'
            : 'Plazo automático según el material',
      ),
      subtitle: Text(
        fijada
            ? 'Hora de Paraguay'
            : 'Toca para elegir otra fecha y hora de devolución',
        style: TextStyle(color: colores.tintaSuave),
      ),
      trailing: fijada
          ? IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Volver al plazo automático',
              onPressed: () => onChanged(null),
            )
          : const Icon(Icons.edit_calendar_outlined),
      onTap: () => _elegir(context),
    );
  }
}
