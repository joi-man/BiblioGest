import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/estado_conexion.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/student/presentation/providers/conexion_provider.dart';

/// Franja que informa del estado de la conexión con el servidor.
///
/// - Reconectando: aviso discreto; la app sigue funcionando y reintenta sola.
/// - Sin conexión (tras varios intentos): aviso claro con botón para reintentar.
/// - Conectado: no se ve.
class AvisoConexion extends ConsumerWidget {
  const AvisoConexion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListenableBuilder(
      listenable: estadoConexion,
      builder: (context, _) {
        final colores = context.colores;
        final textos = Theme.of(context).textTheme;

        switch (estadoConexion.fase) {
          case FaseConexion.conectado:
            return const SizedBox.shrink();

          case FaseConexion.reconectando:
            final intento = estadoConexion.intento;
            return _Franja(
              color: colores.reservado,
              icono: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              mensaje: intento > 0
                  ? 'Se perdió la conexión. Reconectando… (intento $intento de ${estadoConexion.maximo})'
                  : 'Se perdió la conexión. Reconectando…',
              estilo: textos.bodySmall,
            );

          case FaseConexion.sinConexion:
            return _Franja(
              color: colores.vencido,
              icono: const Icon(
                Icons.cloud_off_outlined,
                size: 18,
                color: Colors.white,
              ),
              mensaje:
                  'No pudimos conectar con el servidor. Revisa tu conexión a '
                  'internet; seguimos intentando.',
              estilo: textos.bodySmall,
              accion: TextButton(
                onPressed: () => ref.read(reconectorConexionProvider).sondear(),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Reintentar ahora'),
              ),
            );
        }
      },
    );
  }
}

class _Franja extends StatelessWidget {
  const _Franja({
    required this.color,
    required this.icono,
    required this.mensaje,
    required this.estilo,
    this.accion,
  });

  final Color color;
  final Widget icono;
  final String mensaje;
  final TextStyle? estilo;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            icono,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: estilo?.copyWith(color: Colors.white),
              ),
            ),
            if (accion != null) accion!,
          ],
        ),
      ),
    );
  }
}
