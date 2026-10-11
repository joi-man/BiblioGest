import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/data/models/usuario.dart';
import 'package:frontend/features/auth/data/repositories/usuario_repository.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';

/// Lista de usuarios del sistema. Se recarga sola cuando cambia la sesión.
final usuariosProvider = FutureProvider<List<Usuario>>((ref) async {
  final token = ref.watch(tokenSesionProvider);
  if (token == null) return [];
  return ref.read(usuarioRepositoryProvider).listar(token);
});
