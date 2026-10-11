import 'package:flutter/material.dart';
import 'catalogo_screen.dart';
import 'mis_solicitudes_screen.dart';
import 'perfil_screen.dart';

/// Marco de la app móvil del estudiante: tres secciones con barra inferior.
///
/// Las pantallas se mantienen vivas (`IndexedStack`) para conservar la
/// búsqueda y la selección al cambiar de pestaña.
class ShellEstudiante extends StatefulWidget {
  const ShellEstudiante({super.key});

  @override
  State<ShellEstudiante> createState() => _ShellEstudianteState();
}

class _ShellEstudianteState extends State<ShellEstudiante> {
  static const _indiceSolicitudes = 1;
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indice,
        children: [
          CatalogoScreen(
            // Tras solicitar, se lleva al estudiante a ver el estado de su pedido.
            alSolicitado: () => setState(() => _indice = _indiceSolicitudes),
          ),
          const MisSolicitudesScreen(),
          const PerfilScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Mis solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
