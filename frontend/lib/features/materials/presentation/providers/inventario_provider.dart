import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/authors/data/models/autor.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/repositories/material_repository.dart';

/// Lo que se le pide a la grilla del inventario: filtros y página.
///
/// Es inmutable y tiene igualdad por valor para que Riverpod reutilice el
/// resultado cuando la consulta no cambió.
@immutable
class ConsultaInventario {
  const ConsultaInventario({
    this.texto = '',
    this.tipo,
    this.estado,
    this.categoriaId,
    this.autor,
    this.pagina = 1,
    this.tamano = 10,
  });

  final String texto;
  final TipoMaterial? tipo;
  final EstadoMaterial? estado;
  final String? categoriaId;

  /// Solo los materiales de este autor.
  final Autor? autor;
  final int pagina;
  final int tamano;

  /// Cambia el filtro y vuelve a la primera página, porque la página anterior
  /// puede no existir con el nuevo filtro. Los filtros que aceptan "ninguno"
  /// se pasan como función para distinguir "no cambiar" de "quitar".
  ConsultaInventario conFiltros({
    String? texto,
    TipoMaterial? Function()? tipo,
    EstadoMaterial? Function()? estado,
    String? Function()? categoriaId,
    Autor? Function()? autor,
  }) {
    return ConsultaInventario(
      texto: texto ?? this.texto,
      tipo: tipo != null ? tipo() : this.tipo,
      estado: estado != null ? estado() : this.estado,
      categoriaId: categoriaId != null ? categoriaId() : this.categoriaId,
      autor: autor != null ? autor() : this.autor,
      tamano: tamano,
    );
  }

  ConsultaInventario enPagina(int nueva) => ConsultaInventario(
    texto: texto,
    tipo: tipo,
    estado: estado,
    categoriaId: categoriaId,
    autor: autor,
    pagina: nueva,
    tamano: tamano,
  );

  /// Cambia las filas por página y vuelve a la primera.
  ConsultaInventario conTamano(int nuevo) => ConsultaInventario(
    texto: texto,
    tipo: tipo,
    estado: estado,
    categoriaId: categoriaId,
    autor: autor,
    tamano: nuevo,
  );

  @override
  bool operator ==(Object other) =>
      other is ConsultaInventario &&
      other.texto == texto &&
      other.tipo == tipo &&
      other.estado == estado &&
      other.categoriaId == categoriaId &&
      other.autor?.id == autor?.id &&
      other.pagina == pagina &&
      other.tamano == tamano;

  @override
  int get hashCode =>
      Object.hash(texto, tipo, estado, categoriaId, autor?.id, pagina, tamano);
}

/// Una página del inventario según la [ConsultaInventario]. Se recarga al cambiar la sesión.
final inventarioPaginadoProvider =
    FutureProvider.family<
      PaginaResultado<MaterialBiblioteca>,
      ConsultaInventario
    >((ref, consulta) async {
      if (ref.watch(tokenSesionProvider) == null) {
        return const PaginaResultado(
          items: [],
          total: 0,
          pagina: 1,
          tamano: 10,
          totalPaginas: 0,
        );
      }
      return ref
          .read(materialRepositoryProvider)
          .buscar(
            texto: consulta.texto,
            tipo: consulta.tipo,
            estado: consulta.estado,
            categoriaId: consulta.categoriaId,
            autorId: consulta.autor?.id,
            pagina: consulta.pagina,
            tamano: consulta.tamano,
          );
    });
