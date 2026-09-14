import 'package:freezed_annotation/freezed_annotation.dart';

part 'categoria.freezed.dart';
part 'categoria.g.dart';

@freezed
class Categoria with _$Categoria {
  const factory Categoria({
    required String id,
    required String nombre,
    String? descripcion,
  }) = _Categoria;

  factory Categoria.fromJson(Map<String, dynamic> json) =>
      _$CategoriaFromJson(json);
}
