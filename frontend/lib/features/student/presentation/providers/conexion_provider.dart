import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/network/estado_conexion.dart';
import 'package:frontend/core/network/reconector_conexion.dart';
import 'package:frontend/features/loans/presentation/providers/prestamos_provider.dart';
import 'package:frontend/features/student/presentation/providers/catalogo_provider.dart';

/// Reconector de la app móvil. Al volver la conexión, las pantallas del
/// estudiante piden de nuevo sus datos para ponerse al día.
final reconectorConexionProvider = Provider<ReconectorConexion>((ref) {
  final reconector = ReconectorConexion(
    dio: ref.watch(dioClientProvider).dio,
    estado: estadoConexion,
    alRecuperar: () {
      ref.invalidate(misSolicitudesProvider);
      ref.invalidate(catalogoEstudianteProvider);
    },
  );
  ref.onDispose(reconector.detener);
  return reconector;
});
