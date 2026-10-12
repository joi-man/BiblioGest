import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/repositories/material_repository.dart';

/// Criterios de búsqueda del inventario. Es un record para tener igualdad por
/// valor y que Riverpod reutilice resultados de filtros iguales.
typedef FiltroMateriales = ({
  String texto,
  TipoMaterial? tipo,
  EstadoMaterial? estado,
  bool soloDisponibles,
});

/// Filtro sin criterios: devuelve todo el inventario.
const FiltroMateriales filtroMaterialesVacio = (
  texto: '',
  tipo: null,
  estado: null,
  soloDisponibles: false,
);

/// Materiales que cumplen un [FiltroMateriales]. Se recarga al cambiar la sesión.
final materialesProvider =
    FutureProvider.family<List<MaterialBiblioteca>, FiltroMateriales>((
      ref,
      filtro,
    ) async {
      if (ref.watch(tokenSesionProvider) == null) return [];
      return ref
          .read(materialRepositoryProvider)
          .listar(
            texto: filtro.texto,
            tipo: filtro.tipo,
            estado: filtro.estado,
            soloDisponibles: filtro.soloDisponibles,
          );
    });
