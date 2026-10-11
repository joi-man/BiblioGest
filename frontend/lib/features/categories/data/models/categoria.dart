import 'package:freezed_annotation/freezed_annotation.dart';

part 'categoria.freezed.dart';
part 'categoria.g.dart';

/// Agrupación de materiales (por ejemplo "Novelas" o "Equipos de proyección").
@freezed
class Categoria with _$Categoria {
  const factory Categoria({
    required String id,
    required String nombre,
    String? descripcion,

    /// Plazo de préstamo por defecto, en horas, para los materiales de la categoría.
    @JsonKey(name: 'plazo_prestamo_horas') int? plazoPrestamoHoras,
  }) = _Categoria;

  factory Categoria.fromJson(Map<String, dynamic> json) =>
      _$CategoriaFromJson(json);
}
