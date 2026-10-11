import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/core/widgets/barra_busqueda.dart';
import 'package:frontend/features/core/widgets/encabezado_pagina.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'package:frontend/features/loans/presentation/providers/prestamos_provider.dart';
import 'package:frontend/features/loans/presentation/widgets/dialogo_prestamo_directo.dart';
import 'package:frontend/features/loans/presentation/widgets/lista_prestamos.dart';

/// Una pestaña de la pantalla de préstamos: qué estados muestra y cómo se llama.
class _Pestana {
  const _Pestana({
    required this.titulo,
    required this.estados,
    required this.mensajeVacio,
    this.masAntiguosPrimero = false,
    this.mostrarBotones = true,
  });

  final String titulo;
  final List<EstadoPrestamo> estados;
  final String mensajeVacio;
  final bool masAntiguosPrimero;
  final bool mostrarBotones;
}

const _pestanas = [
  _Pestana(
    titulo: 'Solicitudes',
    estados: [EstadoPrestamo.pendiente],
    mensajeVacio: 'No hay solicitudes pendientes',
    masAntiguosPrimero: true, // la que lleva más tiempo esperando va primero
  ),
  _Pestana(
    titulo: 'Por retirar',
    estados: [EstadoPrestamo.aprobado],
    mensajeVacio: 'No hay reservas esperando retiro',
    masAntiguosPrimero: true,
  ),
  _Pestana(
    titulo: 'En préstamo',
    estados: [EstadoPrestamo.activo, EstadoPrestamo.vencido],
    mensajeVacio: 'No hay materiales prestados',
  ),
  _Pestana(
    titulo: 'Historial',
    estados: [
      EstadoPrestamo.devuelto,
      EstadoPrestamo.rechazado,
      EstadoPrestamo.cancelado,
    ],
    mensajeVacio: 'Aún no hay historial',
    mostrarBotones: false,
  ),
];

/// Gestión de solicitudes y préstamos por parte del personal.
class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _texto = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _pestanas.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  /// Cantidad de elementos de cada pestaña, tomada del resumen del dashboard.
  List<int?> _contadores() {
    final prestamos = ref.watch(resumenDashboardProvider).value?.prestamos;
    if (prestamos == null) return List.filled(_pestanas.length, null);
    return [
      prestamos.solicitudesPendientes,
      prestamos.porRetirar,
      prestamos.activos + prestamos.vencidos,
      null, // el historial no tiene contador
    ];
  }

  @override
  Widget build(BuildContext context) {
    final contadores = _contadores();

    return Scaffold(
      body: Column(
        children: [
          EncabezadoPagina(
            titulo: 'Préstamos',
            subtitulo: 'Solicitudes de los usuarios y materiales en circulación',
            acciones: [
              FilledButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const DialogoPrestamoDirecto(),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo préstamo'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: BarraBusqueda(
              sugerencia: 'Buscar por nombre, documento, usuario o material',
              alCambiar: (texto) => setState(() => _texto = texto),
            ),
          ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (var i = 0; i < _pestanas.length; i++)
                Tab(
                  text: contadores[i] == null
                      ? _pestanas[i].titulo
                      : '${_pestanas[i].titulo} (${contadores[i]})',
                ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                for (final pestana in _pestanas)
                  ListaPrestamos(
                    filtro: FiltroPrestamos(
                      estados: pestana.estados,
                      texto: _texto,
                      masAntiguosPrimero: pestana.masAntiguosPrimero,
                    ),
                    mensajeVacio: pestana.mensajeVacio,
                    mostrarBotones: pestana.mostrarBotones,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
