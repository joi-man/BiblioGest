import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/colores_app.dart';
import '../features/core/widgets/boton_modo_tema.dart';

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

/// Marco de la aplicación del personal: menú lateral en pantallas anchas
/// y barra inferior en pantallas angostas.
class ShellNavegacion extends StatelessWidget {
  const ShellNavegacion({super.key, required this.hijo});

  /// Pantalla actual, que se dibuja junto al menú.
  final Widget hijo;

  /// Ancho a partir del cual se usa el menú lateral.
  static const double _anchoMinimoEscritorio = 900;

  /// Índice del destino cuya ruta coincide con la ubicación actual.
  int _indiceSeleccionado(BuildContext context) {
    final ubicacion = GoRouterState.of(context).uri.path;
    final indice = destinosPersonal
        .indexWhere((d) => d.ruta != '/' && ubicacion.startsWith(d.ruta));
    return indice == -1 ? 0 : indice;
  }

  void _alSeleccionar(BuildContext context, int indice) {
    context.go(destinosPersonal[indice].ruta);
  }

  @override
  Widget build(BuildContext context) {
    final indice = _indiceSeleccionado(context);

    return LayoutBuilder(
      builder: (context, restricciones) {
        if (restricciones.maxWidth >= _anchoMinimoEscritorio) {
          return _conMenuLateral(context, indice);
        }
        return _conBarraInferior(context, indice);
      },
    );
  }

  Widget _conMenuLateral(BuildContext context, int indice) {
    final colores = context.colores;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: indice,
            onDestinationSelected: (i) => _alSeleccionar(context, i),
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
                  child: BotonModoTema(),
                ),
              ),
            ),
            destinations: [
              for (final d in destinosPersonal)
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

  Widget _conBarraInferior(BuildContext context, int indice) {
    return Scaffold(
      body: hijo,
      bottomNavigationBar: NavigationBar(
        selectedIndex: indice,
        onDestinationSelected: (i) => _alSeleccionar(context, i),
        destinations: [
          for (final d in destinosPersonal)
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
