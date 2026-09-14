import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/repositories/material_repository.dart';

final materialsProvider = StateNotifierProvider<
    MaterialsNotifier, AsyncValue<List<MaterialBiblioteca>>>((ref) {
  return MaterialsNotifier(ref);
});

class MaterialsNotifier
    extends StateNotifier<AsyncValue<List<MaterialBiblioteca>>> {
  final Ref _ref;

  MaterialsNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> cargarMateriales({String? token}) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(materialRepositoryProvider);
      final materiales = await repository.listar(token: token);
      state = AsyncValue.data(materiales);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> crearMaterial(MaterialBiblioteca material,
      {String? token}) async {
    try {
      final repository = _ref.read(materialRepositoryProvider);
      await repository.crear(material, token: token);
      await cargarMateriales(token: token);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> actualizarMaterial(String id, Map<String, dynamic> datos,
      {String? token}) async {
    try {
      final repository = _ref.read(materialRepositoryProvider);
      await repository.actualizar(id, datos, token: token);
      await cargarMateriales(token: token);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> eliminarMaterial(String id, {String? token}) async {
    try {
      final repository = _ref.read(materialRepositoryProvider);
      await repository.eliminar(id, token: token);
      await cargarMateriales(token: token);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
