import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/auth/data/models/usuario.dart';
import 'package:frontend/features/auth/data/repositories/usuario_repository.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/presentation/providers/usuarios_paginados_provider.dart';
import 'package:frontend/features/auth/presentation/providers/usuarios_provider.dart';
import 'package:frontend/features/auth/presentation/widgets/dialogo_usuario.dart';
import 'package:frontend/features/auth/presentation/widgets/filtros_usuarios.dart';
import 'package:frontend/features/core/widgets/boton_exportar.dart';
import 'package:frontend/features/core/widgets/confirmacion.dart';
import 'package:frontend/features/core/widgets/controles_paginacion.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/core/widgets/encabezado_pagina.dart';
import 'package:frontend/features/core/widgets/estado_vacio.dart';
import 'package:frontend/features/core/widgets/grilla_datos.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';

enum _AccionUsuario { editar, eliminar }

/// Administración de usuarios: grilla paginada con búsqueda, filtros y
/// exportación a Excel y PDF.
class UsuariosScreen extends ConsumerStatefulWidget {
  const UsuariosScreen({super.key});

  @override
  ConsumerState<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends ConsumerState<UsuariosScreen> {
  ConsultaUsuarios _consulta = const ConsultaUsuarios();

  /// Vuelve a pedir los datos: el listado paginado y el que usan otros formularios.
  void _recargar() {
    ref.invalidate(usuariosPaginadosProvider);
    ref.invalidate(usuariosProvider);
  }

  void _abrirFormulario([Usuario? usuario]) {
    showDialog(
      context: context,
      builder: (_) => DialogoUsuario(usuario: usuario, onGuardado: _recargar),
    );
  }

  Future<void> _eliminar(Usuario usuario) async {
    final confirmado = await confirmarEliminar(
      context,
      titulo: 'Eliminar usuario',
      mensaje: '¿Eliminar a "${usuario.nombre} ${usuario.apellido}"?',
    );
    final token = ref.read(tokenSesionProvider);
    if (!confirmado || !mounted || token == null) return;

    await ejecutarAccion(
      context,
      () async {
        await ref.read(usuarioRepositoryProvider).eliminar(usuario.id, token);
        _recargar();
      },
      exito: 'Usuario eliminado',
    );
  }

  /// Si la página actual quedó vacía (se borró su último usuario), retrocede.
  void _corregirPaginaVacia(PaginaResultado<Usuario> pagina) {
    if (pagina.paginaValida == _consulta.pagina) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _consulta = _consulta.enPagina(pagina.paginaValida));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuarios = ref.watch(usuariosPaginadosProvider(_consulta));

    return Scaffold(
      body: Column(
        children: [
          EncabezadoPagina(
            titulo: 'Usuarios',
            subtitulo: usuarios.whenOrNull(
              data: (pagina) => '${pagina.total} usuarios',
            ),
            acciones: [
              BotonExportar(
                nombreBase: 'usuarios',
                obtenerArchivo: (formato) =>
                    ref.read(usuarioRepositoryProvider).exportar(
                          formato,
                          texto: _consulta.texto,
                          rol: _consulta.rol,
                          activo: _consulta.activo,
                        ),
              ),
              FilledButton.icon(
                onPressed: _abrirFormulario,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo usuario'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: FiltrosUsuarios(
              consulta: _consulta,
              alCambiar: (nueva) => setState(() => _consulta = nueva),
            ),
          ),
          Expanded(
            child: ValorAsincrono(
              valor: usuarios,
              alReintentar: _recargar,
              construir: _grilla,
            ),
          ),
        ],
      ),
    );
  }

  Widget _grilla(PaginaResultado<Usuario> pagina) {
    _corregirPaginaVacia(pagina);

    if (pagina.items.isEmpty) {
      return const EstadoVacio(
        titulo: 'No hay usuarios',
        detalle: 'Prueba con otro filtro o registra un usuario nuevo.',
        icono: Icons.people_outline,
      );
    }

    return Column(
      children: [
        Expanded(
          child: GrillaDatos<Usuario>(
            filas: pagina.items,
            columnas: [
              ColumnaGrilla(titulo: 'Nombre', celda: _celdaNombre),
              ColumnaGrilla(
                titulo: 'Documento',
                celda: (u) => Text(u.numeroDocumento),
              ),
              ColumnaGrilla(
                titulo: 'Correo',
                celda: (u) => Text(u.correoElectronico),
              ),
              ColumnaGrilla(
                titulo: 'Teléfono',
                celda: (u) => Text(u.telefono ?? '—'),
              ),
              ColumnaGrilla(
                titulo: 'Rol',
                celda: (u) => Text(rolesUsuario[u.rol] ?? u.rol),
              ),
              ColumnaGrilla(titulo: 'Estado', celda: _celdaEstado),
            ],
            acciones: _menuDeFila,
          ),
        ),
        ControlesPaginacion(
          pagina: pagina,
          alCambiarPagina: (numero) =>
              setState(() => _consulta = _consulta.enPagina(numero)),
          alCambiarTamano: (tamano) =>
              setState(() => _consulta = _consulta.conTamano(tamano)),
        ),
      ],
    );
  }

  Widget _celdaNombre(Usuario usuario) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;
    final iniciales = '${_inicial(usuario.nombre)}${_inicial(usuario.apellido)}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: colores.acentoSuave,
          child: Text(
            iniciales,
            style: textos.labelMedium?.copyWith(color: colores.acento),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${usuario.nombre} ${usuario.apellido}',
                style: textos.titleSmall),
            Text(
              '@${usuario.username}',
              style: textos.bodySmall?.copyWith(color: colores.tintaSuave),
            ),
          ],
        ),
      ],
    );
  }

  String _inicial(String texto) =>
      texto.isEmpty ? '' : texto.substring(0, 1).toUpperCase();

  Widget _celdaEstado(Usuario usuario) {
    final colores = context.colores;
    final color = usuario.activo ? colores.disponible : colores.fueraDeServicio;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(usuario.activo ? 'Activo' : 'Inactivo'),
      ],
    );
  }

  Widget _menuDeFila(Usuario usuario) {
    return PopupMenuButton<_AccionUsuario>(
      tooltip: 'Más acciones',
      onSelected: (accion) => switch (accion) {
        _AccionUsuario.editar => _abrirFormulario(usuario),
        _AccionUsuario.eliminar => _eliminar(usuario),
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: _AccionUsuario.editar, child: Text('Editar')),
        PopupMenuItem(value: _AccionUsuario.eliminar, child: Text('Eliminar')),
      ],
    );
  }
}
