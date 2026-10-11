import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/local/modo_local.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/sincronizacion/data/models/estado_local.dart';
import 'package:frontend/features/sincronizacion/data/repositories/local_repository.dart';

/// Cada cuánto se vuelve a consultar el estado de la sincronización.
const Duration intervaloConsultaEstado = Duration(seconds: 8);

/// Estado del equipo, actualizado periódicamente.
///
/// Fuera del ejecutable de escritorio no emite nada.
final estadoLocalProvider = StreamProvider<EstadoLocal>((ref) async* {
  if (!ref.watch(modoLocalProvider)) return;

  final repositorio = ref.watch(localRepositoryProvider);
  while (true) {
    try {
      yield await repositorio.estado();
    } catch (_) {
      // El backend local no respondió esta vez; se reintenta en el próximo ciclo.
    }
    await Future<void>.delayed(intervaloConsultaEstado);
  }
});

/// Cambios que el servidor rechazó. Se recarga al cambiar la sesión o el estado.
final conflictosProvider = FutureProvider<List<ConflictoLocal>>((ref) async {
  if (ref.watch(tokenSesionProvider) == null) return [];
  // Al cambiar la cantidad de conflictos se vuelve a pedir la lista.
  ref.watch(estadoLocalProvider.select((e) => e.valueOrNull?.conflictos));
  return ref.read(localRepositoryProvider).conflictos();
});
