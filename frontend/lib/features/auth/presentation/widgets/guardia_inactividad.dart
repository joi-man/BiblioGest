import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/auth_state.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';

/// Minutos sin tocar la pantalla ni el teclado tras los cuales se bloquea la sesión.
///
/// Se puede cambiar al compilar (`--dart-define=INACTIVIDAD_MINUTOS=1`), por ejemplo
/// para una demostración.
const minutosInactividad = int.fromEnvironment(
  'INACTIVIDAD_MINUTOS',
  defaultValue: 10,
);

/// Bloquea la sesión cuando la persona deja de usar la aplicación.
///
/// Cuenta desde la última pulsación, toque, desplazamiento o tecla. Al vencer el
/// plazo cierra la sesión (el token se borra del equipo) y vuelve al inicio de
/// sesión con un aviso: para seguir hay que autenticarse otra vez. Así, una
/// pantalla abandonada en un equipo compartido no deja abierto el acceso.
class GuardiaInactividad extends ConsumerStatefulWidget {
  const GuardiaInactividad({
    super.key,
    required this.child,
    this.limite = const Duration(minutes: minutosInactividad),
    this.revision = const Duration(seconds: 5),
    this.ahora = DateTime.now,
  });

  final Widget child;

  /// Inactividad que provoca el bloqueo.
  final Duration limite;

  /// Cada cuánto se comprueba si ya se cumplió el [limite].
  final Duration revision;

  /// Reloj, para poder probar sin esperar.
  final DateTime Function() ahora;

  @override
  ConsumerState<GuardiaInactividad> createState() => _GuardiaInactividadState();
}

class _GuardiaInactividadState extends ConsumerState<GuardiaInactividad> {
  Timer? _temporizador;
  late DateTime _ultimaActividad;

  @override
  void initState() {
    super.initState();
    _ultimaActividad = widget.ahora();
    _temporizador = Timer.periodic(widget.revision, (_) => _revisar());
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  void _hayActividad() => _ultimaActividad = widget.ahora();

  void _revisar() {
    if (!mounted || ref.read(authProvider).value == null) return;
    if (widget.ahora().difference(_ultimaActividad) < widget.limite) return;

    final minutos = widget.limite.inMinutes;
    authStateNotifier.avisoAlLogin =
        'Tu sesión se bloqueó por inactividad'
        '${minutos >= 1 ? ' ($minutos ${minutos == 1 ? 'minuto' : 'minutos'})' : ''}. '
        'Inicia sesión de nuevo para continuar.';
    ref.read(authProvider.notifier).logout();
    _hayActividad();
  }

  @override
  Widget build(BuildContext context) {
    // Al iniciar sesión el conteo empieza de cero.
    ref.listen(tokenSesionProvider, (_, _) => _hayActividad());

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _hayActividad(),
      onPointerMove: (_) => _hayActividad(),
      onPointerSignal: (_) => _hayActividad(),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (_, _) {
          _hayActividad();
          return KeyEventResult.ignored;
        },
        child: widget.child,
      ),
    );
  }
}
