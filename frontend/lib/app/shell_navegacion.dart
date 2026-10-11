import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/local/modo_local.dart';
import '../core/theme/colores_app.dart';
import '../features/core/widgets/boton_cerrar_sesion.dart';
import '../features/core/widgets/boton_modo_tema.dart';
import '../features/sincronizacion/presentation/widgets/indicador_conexion.dart';

/// Un destino del menú principal del personal de la biblioteca.
class DestinoNavegacion {
  const DestinoNavegacion({
    required this.ruta,
    required this.etiqueta,
    required this.icono,
    required this.iconoActivo,
  });

  final String ruta;
  final String etiqueta;
  final IconData icono;
  final IconData iconoActivo;
}

/// Destinos del menú, en el orden en que se muestran.
const List<DestinoNavegacion> destinosPersonal = [
  DestinoNavegacion(
    ruta: '/',
    etiqueta: 'Inicio',
    icono: Icons.dashboard_outlined,
    iconoActivo: Icons.dashboard,
  ),
  DestinoNavegacion(
    ruta: '/materials',
    etiqueta: 'Materiales',
    icono: Icons.menu_book_outlined,
    iconoActivo: Icons.menu_book,
  ),
  DestinoNavegacion(
    ruta: '/loans',
    etiqueta: 'Préstamos',
    icono: Icons.assignment_outlined,
    iconoActivo: Icons.assignment,
  ),
  DestinoNavegacion(
    ruta: '/returns',
    etiqueta: 'Devoluciones',
    icono: Icons.assignment_return_outlined,
    iconoActivo: Icons.assignment_return,
  ),
  DestinoNavegacion(
    ruta: '/users',
    etiqueta: 'Usuarios',
    icono: Icons.people_outline,
    iconoActivo: Icons.people,
  ),
  DestinoNavegacion(
    ruta: '/categories',
    etiqueta: 'Categorías',
    icono: Icons.category_outlined,
    iconoActivo: Icons.category,
  ),
];

/// Destino extra del ejecutable de escritorio: estado de la sincronización.
const DestinoNavegacion destinoSincronizacion = DestinoNavegacion(
  ruta: '/sync',
  etiqueta: 'Sincronización',
  icono: Icons.sync_outlined,
  iconoActivo: Icons.sync,
);

/// Marco de la aplicación del personal: menú lateral en pantallas anchas
/// y barra inferior en pantallas angostas.
class ShellNavegacion extends ConsumerWidget {
  const ShellNavegacion({super.key, required this.hijo});

  /// Pantalla actual, que se dibuja junto al menú.
  final Widget hijo;

  /// Ancho a partir del cual se usa el menú lateral.
  static const double _anchoMinimoEscritorio = 900;

  /// Índice del destino cuya ruta coincide con la ubicación actual.
  int _indiceSeleccionado(BuildContext context, List<DestinoNavegacion> destinos) {
    final ubicacion = GoRouterState.of(context).uri.path;
    final indice =
        destinos.indexWhere((d) => d.ruta != '/' && ubicacion.startsWith(d.ruta));
    return indice == -1 ? 0 : indice;
  }

  void _alSeleccionar(BuildContext context, List<DestinoNavegacion> destinos, int indice) {
    context.go(destinos[indice].ruta);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // El ejecutable de escritorio agrega la sección de sincronización.
    final destinos = [
      ...destinosPersonal,
      if (ref.watch(modoLocalProvider)) destinoSincronizacion,
    ];
    final indice = _indiceSeleccionado(context, destinos);

    return LayoutBuilder(
      builder: (context, restricciones) {
        if (restricciones.maxWidth >= _anchoMinimoEscritorio) {
          return _conMenuLateral(context, destinos, indice);
        }
        return _conBarraInferior(context, destinos, indice);
      },
    );
  }

  Widget _conMenuLateral(
      BuildContext context, List<DestinoNavegacion> destinos, int indice) {
    final colores = context.colores;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: indice,
            onDestinationSelected: (i) => _alSeleccionar(context, destinos, i),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'BiblioGest',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: colores.acento),
              ),
            ),
            trailing: const Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IndicadorConexion(),
                      BotonModoTema(),
                      BotonCerrarSesion(),
                    ],
                  ),
                ),
              ),
            ),
            destinations: [
              for (final d in destinos)
                NavigationRailDestination(
                  icon: Icon(d.icono),
                  selectedIcon: Icon(d.iconoActivo),
                  label: Text(d.etiqueta),
                ),
            ],
          ),
          VerticalDivider(width: 1, color: colores.linea),
          Expanded(child: hijo),
        ],
      ),
    );
  }

  Widget _conBarraInferior(
      BuildContext context, List<DestinoNavegacion> destinos, int indice) {
    return Scaffold(
      body: hijo,
      bottomNavigationBar: NavigationBar(
        selectedIndex: indice,
        onDestinationSelected: (i) => _alSeleccionar(context, destinos, i),
        destinations: [
          for (final d in destinos)
            NavigationDestination(
              icon: Icon(d.icono),
              selectedIcon: Icon(d.iconoActivo),
              label: d.etiqueta,
            ),
        ],
      ),
    );
  }
}
