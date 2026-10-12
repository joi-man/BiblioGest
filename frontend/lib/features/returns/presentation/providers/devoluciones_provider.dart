import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'package:frontend/features/returns/data/repositories/devolucion_repository.dart';

/// Préstamos pendientes de devolución que coinciden con el texto buscado
/// (nombre, documento, usuario o material). Texto vacío = todos.
final devolucionesPendientesProvider =
    FutureProvider.family<List<Prestamo>, String>((ref, texto) async {
      if (ref.watch(tokenSesionProvider) == null) return [];
      return ref
          .read(devolucionRepositoryProvider)
          .listarPendientes(texto: texto);
    });
