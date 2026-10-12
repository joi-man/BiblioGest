import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/reports/data/reporte_repository.dart';

/// Una página de un reporte según su tipo y su [ConsultaReporte].
/// Se recarga al cambiar la sesión.
final reporteProvider = FutureProvider.family<ResultadoReporte,
    ({TipoReporte tipo, ConsultaReporte consulta})>((ref, parametros) async {
  if (ref.watch(tokenSesionProvider) == null) {
    return const ResultadoReporte(
      descripcion: '',
      columnas: [],
      pagina: PaginaResultado(
          items: [], total: 0, pagina: 1, tamano: 10, totalPaginas: 0),
    );
  }
  return ref
      .read(reporteRepositoryProvider)
      .consultar(parametros.tipo, parametros.consulta);
});
