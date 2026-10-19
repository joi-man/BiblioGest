import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/estado_conexion.dart';
import 'package:frontend/core/theme/modo_tema_provider.dart';
import 'package:frontend/core/utils/texto_busqueda.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_presentacion.dart';
import 'package:frontend/features/materials/data/repositories/material_repository.dart';
import 'package:frontend/features/materials/presentation/providers/materiales_provider.dart';
import 'package:frontend/features/student/data/catalogo_cache.dart';

/// Catálogo que ve el estudiante.
///
/// [guardadoEn] solo tiene valor cuando no hubo conexión y se muestra la última
/// copia guardada: es la fecha de esa copia.
class ResultadoCatalogo {
  const ResultadoCatalogo(this.materiales, {this.guardadoEn});

  final List<MaterialBiblioteca> materiales;
  final DateTime? guardadoEn;

  bool get desdeCache => guardadoEn != null;
}

final catalogoCacheProvider = Provider<CatalogoCache>((ref) {
  return CatalogoCache(ref.watch(preferenciasProvider));
});

/// Intentos de reconexión que se anuncian en el aviso cuando se muestra la copia guardada.
const _intentosAntesDeAvisar = 5;

/// Materiales que cumplen el filtro, con la copia guardada como respaldo.
///
/// - Con conexión: pide el catálogo al servidor y, si no hay filtros, lo guarda.
/// - Sin conexión y con copia guardada: responde de inmediato con la copia
///   (filtrada aquí) y deja que el reconector siga intentando en segundo plano.
/// - Sin conexión y sin copia: reintenta como cualquier otra pantalla.
final catalogoEstudianteProvider =
    FutureProvider.family<ResultadoCatalogo, FiltroMateriales>((
      ref,
      filtro,
    ) async {
      if (ref.watch(tokenSesionProvider) == null)
        return const ResultadoCatalogo([]);

      final cache = ref.read(catalogoCacheProvider);
      final copia = cache.leer();

      try {
        final materiales = await ref
            .read(materialRepositoryProvider)
            .listar(
              texto: filtro.texto,
              tipo: filtro.tipo,
              estado: filtro.estado,
              soloDisponibles: filtro.soloDisponibles,
              // Con una copia que mostrar no vale la pena hacer esperar a la persona.
              sinReintento: copia != null,
            );
        if (_esCatalogoCompleto(filtro)) await cache.guardar(materiales);
        return ResultadoCatalogo(materiales);
      } on DioException catch (error) {
        if (copia == null || !_esFallaDeRed(error)) rethrow;
        estadoConexion.reconectando(0, _intentosAntesDeAvisar);
        return ResultadoCatalogo(
          filtrarMateriales(copia.materiales, filtro),
          guardadoEn: copia.fecha,
        );
      }
    });

/// Solo el catálogo sin ningún filtro sirve como copia completa.
bool _esCatalogoCompleto(FiltroMateriales filtro) =>
    filtro.texto.trim().isEmpty &&
    filtro.tipo == null &&
    filtro.estado == null &&
    !filtro.soloDisponibles;

bool _esFallaDeRed(DioException error) =>
    error.type == DioExceptionType.connectionError ||
    error.type == DioExceptionType.connectionTimeout ||
    error.type == DioExceptionType.receiveTimeout ||
    error.type == DioExceptionType.sendTimeout;

/// Aplica el [filtro] a una lista ya descargada, igual que lo haría el servidor.
List<MaterialBiblioteca> filtrarMateriales(
  List<MaterialBiblioteca> materiales,
  FiltroMateriales filtro,
) {
  return [
    for (final m in materiales)
      if ((filtro.tipo == null || m.tipoMaterial == filtro.tipo) &&
          (filtro.estado == null || m.estado == filtro.estado) &&
          (!filtro.soloDisponibles || m.sePuedeSolicitar) &&
          // Todas las palabras deben aparecer, igual que en la búsqueda del servidor.
          coincideConTodasLasPalabras(
            '${m.titulo} ${m.autoresTexto} ${m.etiquetaTomo} ${m.codigo} '
            '${m.isbn ?? ''} ${m.editorial ?? ''}',
            filtro.texto,
          ))
        m,
  ];
}
