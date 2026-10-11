import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/providers/usuarios_paginados_provider.dart';
import 'package:frontend/features/core/widgets/barra_busqueda.dart';

/// Roles que se pueden filtrar, con el valor que entiende el backend.
const Map<String, String> rolesUsuario = {
  'admin': 'Administrador',
  'bibliotecario': 'Bibliotecario',
  'estudiante': 'Estudiante',
};

/// Búsqueda por texto, rol y estado para la grilla de usuarios.
class FiltrosUsuarios extends StatelessWidget {
  const FiltrosUsuarios({
    super.key,
    required this.consulta,
    required this.alCambiar,
  });

  final ConsultaUsuarios consulta;
  final ValueChanged<ConsultaUsuarios> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 360,
          child: BarraBusqueda(
            sugerencia: 'Buscar por nombre, usuario, correo o documento',
            textoInicial: consulta.texto,
            alCambiar: (texto) => alCambiar(consulta.conFiltros(texto: texto)),
          ),
        ),
        SizedBox(width: 190, child: _selectorRol()),
        SizedBox(width: 170, child: _selectorEstado()),
      ],
    );
  }

  Widget _selectorRol() {
    return DropdownButtonFormField<String?>(
      value: consulta.rol,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Rol'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos los roles')),
        for (final rol in rolesUsuario.entries)
          DropdownMenuItem(value: rol.key, child: Text(rol.value)),
      ],
      onChanged: (rol) => alCambiar(consulta.conFiltros(rol: () => rol)),
    );
  }

  Widget _selectorEstado() {
    return DropdownButtonFormField<bool?>(
      value: consulta.activo,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Estado'),
      items: const [
        DropdownMenuItem(value: null, child: Text('Todos')),
        DropdownMenuItem(value: true, child: Text('Activos')),
        DropdownMenuItem(value: false, child: Text('Inactivos')),
      ],
      onChanged: (activo) =>
          alCambiar(consulta.conFiltros(activo: () => activo)),
    );
  }
}
