import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
import 'package:frontend/features/auth/data/models/usuario.dart';
import 'package:frontend/features/auth/data/repositories/usuario_repository.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';

/// Lo que se le pide a la grilla de usuarios: filtros y página.
///
/// Es inmutable y tiene igualdad por valor para que Riverpod reutilice el
/// resultado cuando la consulta no cambió.
@immutable
class ConsultaUsuarios {
  const ConsultaUsuarios({
    this.texto = '',
    this.rol,
    this.activo,
    this.pagina = 1,
    this.tamano = 10,
  });

  final String texto;
  final String? rol;
  final bool? activo;
  final int pagina;
  final int tamano;

  /// Cambia el filtro y vuelve a la primera página, porque la página anterior
  /// puede no existir con el nuevo filtro.
  ConsultaUsuarios conFiltros({
    String? texto,
    String? Function()? rol,
    bool? Function()? activo,
  }) {
    return ConsultaUsuarios(
      texto: texto ?? this.texto,
      rol: rol != null ? rol() : this.rol,
      activo: activo != null ? activo() : this.activo,
      tamano: tamano,
    );
  }

  ConsultaUsuarios enPagina(int nueva) => ConsultaUsuarios(
        texto: texto,
        rol: rol,
        activo: activo,
        pagina: nueva,
        tamano: tamano,
      );

  /// Cambia las filas por página y vuelve a la primera.
  ConsultaUsuarios conTamano(int nuevo) => ConsultaUsuarios(
        texto: texto,
        rol: rol,
        activo: activo,
        tamano: nuevo,
      );

  @override
  bool operator ==(Object other) =>
      other is ConsultaUsuarios &&
      other.texto == texto &&
      other.rol == rol &&
      other.activo == activo &&
      other.pagina == pagina &&
      other.tamano == tamano;

  @override
  int get hashCode => Object.hash(texto, rol, activo, pagina, tamano);
}

/// Una página de usuarios según la [ConsultaUsuarios]. Se recarga al cambiar la sesión.
final usuariosPaginadosProvider =
    FutureProvider.family<PaginaResultado<Usuario>, ConsultaUsuarios>(
        (ref, consulta) async {
  if (ref.watch(tokenSesionProvider) == null) {
    return const PaginaResultado(
        items: [], total: 0, pagina: 1, tamano: 10, totalPaginas: 0);
  }
  return ref.read(usuarioRepositoryProvider).buscar(
        texto: consulta.texto,
        rol: consulta.rol,
        activo: consulta.activo,
        pagina: consulta.pagina,
        tamano: consulta.tamano,
      );
});
