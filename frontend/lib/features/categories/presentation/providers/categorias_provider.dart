import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/categories/data/models/categoria.dart';
import 'package:frontend/features/categories/data/repositories/categoria_repository.dart';

/// Lista de categorías. Se recarga sola cuando cambia la sesión.
final categoriasProvider = FutureProvider<List<Categoria>>((ref) async {
  if (ref.watch(tokenSesionProvider) == null) return [];
  return ref.read(categoriaRepositoryProvider).listar();
});
