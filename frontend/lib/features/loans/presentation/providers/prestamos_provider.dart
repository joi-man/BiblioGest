import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'package:frontend/features/loans/data/repositories/prestamo_repository.dart';

/// Criterios para listar préstamos. Tiene igualdad por valor para que Riverpod
/// reutilice el resultado cuando el filtro no cambió.
@immutable
class FiltroPrestamos {
  const FiltroPrestamos({
    this.estados = const [],
    this.texto = '',
    this.masAntiguosPrimero = false,
  });

  final List<EstadoPrestamo> estados;
  final String texto;
  final bool masAntiguosPrimero;

  @override
  bool operator ==(Object other) =>
      other is FiltroPrestamos &&
      listEquals(other.estados, estados) &&
      other.texto == texto &&
      other.masAntiguosPrimero == masAntiguosPrimero;

  @override
  int get hashCode => Object.hash(Object.hashAll(estados), texto, masAntiguosPrimero);
}

/// Préstamos del personal que cumplen un [FiltroPrestamos].
final prestamosProvider =
    FutureProvider.family<List<Prestamo>, FiltroPrestamos>((ref, filtro) async {
  if (ref.watch(tokenSesionProvider) == null) return [];
  return ref.read(prestamoRepositoryProvider).listar(
        estados: filtro.estados,
        texto: filtro.texto,
        masAntiguosPrimero: filtro.masAntiguosPrimero,
      );
});

/// Solicitudes y préstamos de la persona que tiene la sesión iniciada.
final misSolicitudesProvider = FutureProvider<List<Prestamo>>((ref) async {
  if (ref.watch(tokenSesionProvider) == null) return [];
  return ref.read(prestamoRepositoryProvider).listarMias();
});
