import 'dart:ui' show AppExitResponse;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';

/// Lo que decide la persona al cerrar la ventana con la sesión iniciada.
enum EleccionSalida { cancelar, mantenerSesion, cerrarSesion }

/// Pregunta si se cierra la sesión cuando se cierra la ventana de la aplicación
/// de escritorio. Si no se cierra, la sesión se conserva [SesionGuardada.duracion]
/// (o hasta que el equipo se reinicie).
class GuardiaCierreVentana extends ConsumerStatefulWidget {
  const GuardiaCierreVentana({
    super.key,
    required this.navegadorKey,
    required this.child,
    bool? habilitado,
  }) : _habilitado = habilitado;

  /// Navegador desde el que se muestra la pregunta.
  final GlobalKey<NavigatorState> navegadorKey;
  final Widget child;
  final bool? _habilitado;

  bool get habilitado =>
      _habilitado ?? (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows);

  @override
  ConsumerState<GuardiaCierreVentana> createState() => _GuardiaCierreVentanaState();
}

class _GuardiaCierreVentanaState extends ConsumerState<GuardiaCierreVentana> {
  AppLifecycleListener? _escucha;
  bool _preguntando = false;

  @override
  void initState() {
    super.initState();
    if (widget.habilitado) {
      _escucha = AppLifecycleListener(onExitRequested: _alPedirSalir);
    }
  }

  @override
  void dispose() {
    _escucha?.dispose();
    super.dispose();
  }

  Future<AppExitResponse> _alPedirSalir() async {
    final sesion = ref.read(authProvider).value;
    final contexto = widget.navegadorKey.currentContext;
    if (sesion == null || contexto == null) return AppExitResponse.exit;
    if (_preguntando) return AppExitResponse.cancel;

    _preguntando = true;
    try {
      final eleccion = await showDialog<EleccionSalida>(
        context: contexto,
        barrierDismissible: false,
        builder: (_) => const _DialogoSalida(),
      );
      switch (eleccion ?? EleccionSalida.cancelar) {
        case EleccionSalida.cancelar:
          return AppExitResponse.cancel;
        case EleccionSalida.mantenerSesion:
          await ref.read(sesionGuardadaProvider).guardar(sesion);
          return AppExitResponse.exit;
        case EleccionSalida.cerrarSesion:
          await ref.read(sesionGuardadaProvider).borrar();
          return AppExitResponse.exit;
      }
    } finally {
      _preguntando = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _DialogoSalida extends StatelessWidget {
  const _DialogoSalida();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Cerrar sesión al salir?'),
      content: const Text(
        'Si no cierras la sesión, podrás volver a entrar sin escribir tu contraseña '
        'durante los próximos 30 minutos, mientras el equipo no se apague o reinicie.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(EleccionSalida.cancelar),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(EleccionSalida.mantenerSesion),
          child: const Text('No cerrar sesión'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(EleccionSalida.cerrarSesion),
          child: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}
