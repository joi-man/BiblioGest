import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/loans/data/models/plazo_devolucion.dart';
import 'package:frontend/features/loans/data/models/plazo_retiro.dart';

/// Pregunta al estudiante cuándo pasará a retirar lo que reserva.
///
/// Devuelve la fecha y hora elegidas (instante UTC; el estudiante elige en hora de
/// Paraguay) o `null` si cancela. Es el último paso de la reserva: elegir los
/// materiales, tocar «Reservar» y confirmar cuándo se retira.
Future<DateTime?> pedirFechaRetiro(
  BuildContext context, {
  required String resumen,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    builder: (_) => HojaFechaRetiro(resumen: resumen),
  );
}

class HojaFechaRetiro extends StatefulWidget {
  const HojaFechaRetiro({super.key, required this.resumen});

  /// Qué se reserva, en una línea (por ejemplo, "Rayuela y 1 más").
  final String resumen;

  @override
  State<HojaFechaRetiro> createState() => _HojaFechaRetiroState();
}

class _HojaFechaRetiroState extends State<HojaFechaRetiro> {
  late DateTime _retiro = PlazoRetiro.propuesta();
  String? _error;

  Future<void> _elegirDia() async {
    final hoy = PlazoDevolucion.hoyEnParaguay();
    final actual = FormatoFecha.enParaguay(_retiro);
    final dia = await showDatePicker(
      context: context,
      helpText: 'Día en que pasarás a retirar',
      initialDate: DateTime(actual.year, actual.month, actual.day),
      firstDate: hoy,
      lastDate: PlazoRetiro.ultimoDia(),
    );
    if (dia == null) return;
    _actualizar(PlazoDevolucion.combinar(dia, actual.hour, actual.minute));
  }

  Future<void> _elegirHora() async {
    final actual = FormatoFecha.enParaguay(_retiro);
    final hora = await showTimePicker(
      context: context,
      helpText: 'Hora en que pasarás a retirar (Paraguay)',
      initialTime: TimeOfDay(hour: actual.hour, minute: actual.minute),
    );
    if (hora == null) return;
    _actualizar(
      PlazoDevolucion.combinar(
        DateTime(actual.year, actual.month, actual.day),
        hora.hour,
        hora.minute,
      ),
    );
  }

  void _actualizar(DateTime nuevo) {
    setState(() {
      _retiro = nuevo;
      _error = PlazoRetiro.validar(nuevo);
    });
  }

  void _confirmar() {
    final error = PlazoRetiro.validar(_retiro);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, _retiro);
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;
    final pared = FormatoFecha.enParaguay(_retiro);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('¿Cuándo pasarás a retirarlo?', style: textos.titleLarge),
            const SizedBox(height: 4),
            Text(widget.resumen, style: textos.bodyMedium),
            const SizedBox(height: 4),
            Text(
              'Te guardamos lo reservado hasta poco después de esa hora. '
              'Si no pasas, la reserva se libera para otra persona.',
              style: textos.bodySmall?.copyWith(color: colores.tintaSuave),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _elegirDia,
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(FormatoFecha.soloFecha(_retiro)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _elegirHora,
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(
                      '${pared.hour.toString().padLeft(2, '0')}:'
                      '${pared.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Hora de Paraguay',
              style: textos.bodySmall?.copyWith(color: colores.tintaSuave),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: textos.bodySmall?.copyWith(color: colores.vencido),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _error == null ? _confirmar : null,
                    child: const Text('Confirmar reserva'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
