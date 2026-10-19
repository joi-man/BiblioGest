import 'package:freezed_annotation/freezed_annotation.dart';

part 'autor.freezed.dart';
part 'autor.g.dart';

/// Persona que escribió uno o varios materiales.
///
/// Un material puede tener varios autores y un autor varios materiales. Dentro
/// de un material solo vienen [id] y [nombre]; en el listado de autores, además,
/// [cantidadMateriales].
@freezed
class Autor with _$Autor {
  const factory Autor({
    required String id,
    required String nombre,
    @JsonKey(name: 'cantidad_materiales') @Default(0) int cantidadMateriales,
    @JsonKey(name: 'fecha_creacion') DateTime? fechaCreacion,
  }) = _Autor;

  factory Autor.fromJson(Map<String, dynamic> json) => _$AutorFromJson(json);
}
