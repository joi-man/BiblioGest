import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/estado_conexion.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:frontend/features/loans/presentation/providers/prestamos_provider.dart';
import 'package:frontend/features/materials/presentation/providers/materiales_provider.dart';
import 'package:frontend/features/returns/presentation/providers/devoluciones_provider.dart';

/// Mantiene al día las pantallas del personal mientras la app está abierta.
///
/// Sin esto, una solicitud hecha por un estudiante en otro dispositivo solo
/// aparecía al cerrar sesión y volver a entrar. Vuelve a pedir préstamos,
/// devoluciones pendientes, materiales e indicadores cada [periodo] y al volver
/// a la app. Las listas conservan lo que muestran mientras se recargan.
class ActualizadorPersonal extends ConsumerStatefulWidget {
  const ActualizadorPersonal({
    super.key,
    required this.hijo,
    this.periodo = const Duration(seconds: 30),
  });

  final Widget hijo;
  final Duration periodo;

  @override
  ConsumerState<ActualizadorPersonal> createState() => _ActualizadorPersonalState();
}

class _ActualizadorPersonalState extends ConsumerState<ActualizadorPersonal>
    with WidgetsBindingObserver {
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _temporizador = Timer.periodic(widget.periodo, (_) => actualizar());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado == AppLifecycleState.resumed) actualizar();
  }

  /// Vuelve a pedir los datos, salvo que ya se sepa que no hay conexión.
  void actualizar() {
    if (!mounted || estadoConexion.hayProblema) return;
    ref.invalidate(prestamosProvider);
    ref.invalidate(devolucionesPendientesProvider);
    ref.invalidate(materialesProvider);
    ref.invalidate(resumenDashboardProvider);
  }

  @override
  Widget build(BuildContext context) => widget.hijo;
}
