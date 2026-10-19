import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/authors/data/models/autor.dart';
import 'package:frontend/features/authors/data/repositories/autor_repository.dart';

/// Lo que se le pide a la grilla de autores: búsqueda y página.
///
/// Es inmutable y tiene igualdad por valor para que Riverpod reutilice el
/// resultado cuando la consulta no cambió.
@immutable
class ConsultaAutores {
  const ConsultaAutores({this.texto = '', this.pagina = 1, this.tamano = 10});

  final String texto;
  final int pagina;
  final int tamano;

  /// Cambia el texto y vuelve a la primera página.
  ConsultaAutores conTexto(String nuevo) =>
      ConsultaAutores(texto: nuevo, tamano: tamano);

  ConsultaAutores enPagina(int nueva) =>
      ConsultaAutores(texto: texto, pagina: nueva, tamano: tamano);

  /// Cambia las filas por página y vuelve a la primera.
  ConsultaAutores conTamano(int nuevo) =>
      ConsultaAutores(texto: texto, tamano: nuevo);

  @override
  bool operator ==(Object other) =>
      other is ConsultaAutores &&
      other.texto == texto &&
      other.pagina == pagina &&
      other.tamano == tamano;

  @override
  int get hashCode => Object.hash(texto, pagina, tamano);
}

/// Una página de autores según la [ConsultaAutores]. Se recarga al cambiar la sesión.
final autoresPaginadosProvider =
    FutureProvider.family<PaginaResultado<Autor>, ConsultaAutores>((
      ref,
      consulta,
    ) async {
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
          .read(autorRepositoryProvider)
          .buscar(
            texto: consulta.texto,
            pagina: consulta.pagina,
            tamano: consulta.tamano,
          );
    });
