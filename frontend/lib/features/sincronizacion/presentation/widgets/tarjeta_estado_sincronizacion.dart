import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/sincronizacion/data/models/estado_local.dart';

/// Resumen del estado de la sincronización: conexión, pendientes y último intento.
class TarjetaEstadoSincronizacion extends StatelessWidget {
  const TarjetaEstadoSincronizacion({super.key, required this.estado});

  final EstadoLocal estado;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;
    final situacion = _Situacion.de(estado, colores);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(situacion.icono, color: situacion.color, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text(situacion.titulo, style: textos.titleLarge)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              situacion.detalle,
              style: textos.bodyMedium?.copyWith(color: colores.tintaSuave),
            ),
            if (estado.tieneServidor) ...[
              const Divider(height: 32),
              _fila(context, 'Servidor', estado.servidorUrl!),
              _fila(context, 'Cambios por enviar', '${estado.pendientes}'),
              _fila(
                context,
                'Última sincronización',
                estado.ultimaSincronizacion == null
                    ? 'Todavía no'
                    : FormatoFecha.fechaHora(estado.ultimaSincronizacion!),
              ),
            ],
            if (estado.ultimoError != null) ...[
              const SizedBox(height: 12),
              Text(
                estado.ultimoError!,
                style: textos.bodyMedium?.copyWith(color: colores.vencido),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fila(BuildContext context, String etiqueta, String valor) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              etiqueta,
              style: textos.bodyMedium?.copyWith(color: context.colores.tintaSuave),
            ),
          ),
          Expanded(child: Text(valor, style: textos.bodyMedium)),
        ],
      ),
    );
  }
}

/// Cómo describir el estado actual a una persona.
class _Situacion {
  const _Situacion(this.icono, this.color, this.titulo, this.detalle);

  final IconData icono;
  final Color color;
  final String titulo;
  final String detalle;

  static _Situacion de(EstadoLocal estado, ColoresApp colores) {
    if (!estado.tieneServidor) {
      return _Situacion(
        Icons.computer_outlined,
        colores.prestado,
        'Trabajando solo en este equipo',
        'Los datos quedan en esta computadora. Puedes conectarlo con un servidor cuando quieras.',
      );
    }
    if (estado.sincronizando) {
      return _Situacion(Icons.sync, colores.prestado, 'Sincronizando…',
          'Enviando y recibiendo cambios.');
    }
    if (estado.conectado == false) {
      return _Situacion(
        Icons.cloud_off_outlined,
        colores.reservado,
        'Sin conexión con el servidor',
        'Puedes seguir trabajando: los cambios se guardan aquí y se enviarán solos al volver la conexión.',
      );
    }
    if (estado.requiereInicioDeSesion) {
      return _Situacion(
        Icons.lock_outline,
        colores.reservado,
        'Falta iniciar sesión',
        'Inicia sesión para sincronizar con el servidor.',
      );
    }
    return _Situacion(
      Icons.cloud_done_outlined,
      colores.disponible,
      'Conectado al servidor',
      estado.pendientes == 0
          ? 'Todo está al día.'
          : '${estado.pendientes} cambios esperan enviarse.',
    );
  }
}
