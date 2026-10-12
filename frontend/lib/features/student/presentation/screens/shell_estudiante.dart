import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/estado_conexion.dart';
import 'package:frontend/features/core/widgets/alertas.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'package:frontend/features/loans/presentation/providers/prestamos_provider.dart';
import 'package:frontend/features/student/presentation/providers/catalogo_provider.dart';
import 'package:frontend/features/student/presentation/providers/conexion_provider.dart';
import 'package:frontend/features/student/presentation/providers/novedades_solicitudes.dart';
import 'package:frontend/features/student/presentation/widgets/aviso_conexion.dart';
import 'catalogo_screen.dart';
import 'mis_solicitudes_screen.dart';
import 'perfil_screen.dart';

/// Marco de la app móvil del estudiante: tres secciones con barra inferior.
///
/// Las pantallas se mantienen vivas (`IndexedStack`) para conservar la
/// búsqueda y la selección al cambiar de pestaña.
///
/// Además mantiene la información al día mientras la app está abierta: vuelve a
/// pedir las reservas y el catálogo cada [_periodo] y al volver a la app, y
/// avisa cuando el bibliotecario responde una reserva.
class ShellEstudiante extends ConsumerStatefulWidget {
  const ShellEstudiante({super.key});

  @override
  ConsumerState<ShellEstudiante> createState() => _ShellEstudianteState();
}

class _ShellEstudianteState extends ConsumerState<ShellEstudiante>
    with WidgetsBindingObserver {
  static const _indiceSolicitudes = 1;
  static const _periodo = Duration(seconds: 30);

  int _indice = 0;
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _temporizador = Timer.periodic(_periodo, (_) => _actualizar());
    // Después del primer cuadro: el reconector lee providers que ya deben existir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(reconectorConexionProvider).iniciar();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado == AppLifecycleState.resumed) _actualizar();
  }

  /// Vuelve a pedir los datos, salvo que ya se sepa que no hay conexión
  /// (el reconector se encarga de eso).
  void _actualizar() {
    if (!mounted || estadoConexion.hayProblema) return;
    ref.invalidate(misSolicitudesProvider);
    ref.invalidate(catalogoEstudianteProvider);
  }

  void _avisarNovedades(AsyncValue<List<Prestamo>>? antes, AsyncValue<List<Prestamo>> ahora) {
    final previas = antes?.value;
    final nuevas = ahora.value;
    if (previas == null || nuevas == null) return;

    for (final aviso in novedadesDeSolicitudes(previas, nuevas)) {
      context.mostrarInfo(aviso);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(misSolicitudesProvider, _avisarNovedades);

    return Scaffold(
      body: IndexedStack(
        index: _indice,
        children: [
          CatalogoScreen(
            // Tras reservar, se lleva al estudiante a ver el estado de su reserva.
            alSolicitado: () => setState(() => _indice = _indiceSolicitudes),
          ),
          const MisSolicitudesScreen(),
          const PerfilScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AvisoConexion(),
          NavigationBar(
            selectedIndex: _indice,
            onDestinationSelected: (i) => setState(() => _indice = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search),
                label: 'Catálogo',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border),
                selectedIcon: Icon(Icons.bookmark),
                label: 'Mis reservas',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
