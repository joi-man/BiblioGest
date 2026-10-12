import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/local/modo_local.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/sincronizacion/data/models/estado_local.dart';
import 'package:frontend/features/sincronizacion/presentation/providers/estado_local_provider.dart';

/// Icono del menú que muestra de un vistazo si el equipo está conectado y si
/// quedan cambios por enviar. Al pulsarlo abre la pantalla de sincronización.
class IndicadorConexion extends ConsumerWidget {
  const IndicadorConexion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(modoLocalProvider)) return const SizedBox.shrink();

    final estado = ref.watch(estadoLocalProvider).valueOrNull;
    if (estado == null) return const SizedBox.shrink();

    final colores = context.colores;
    final (icono, color, texto) = _apariencia(estado, colores);

    return Tooltip(
      message: texto,
      child: IconButton(
        onPressed: () => context.go('/sync'),
        icon: Badge(
          isLabelVisible: estado.conflictos > 0 || estado.pendientes > 0,
          backgroundColor: estado.conflictos > 0
              ? colores.vencido
              : colores.reservado,
          label: Text(
            '${estado.conflictos > 0 ? estado.conflictos : estado.pendientes}',
          ),
          child: Icon(icono, color: color),
        ),
      ),
    );
  }

  (IconData, Color, String) _apariencia(
    EstadoLocal estado,
    ColoresApp colores,
  ) {
    if (!estado.tieneServidor) {
      return (
        Icons.computer_outlined,
        colores.tintaSuave,
        'Trabajando solo en este equipo',
      );
    }
    if (estado.conflictos > 0) {
      return (
        Icons.warning_amber_outlined,
        colores.vencido,
        '${estado.conflictos} cambios por revisar',
      );
    }
    if (estado.sincronizando) {
      return (Icons.sync, colores.prestado, 'Sincronizando…');
    }
    if (estado.conectado == false) {
      return (
        Icons.cloud_off_outlined,
        colores.reservado,
        'Sin conexión · ${estado.pendientes} cambios por enviar',
      );
    }
    return (
      Icons.cloud_done_outlined,
      colores.disponible,
      estado.pendientes == 0
          ? 'Todo sincronizado'
          : '${estado.pendientes} cambios por enviar',
    );
  }
}
