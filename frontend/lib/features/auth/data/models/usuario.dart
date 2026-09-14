import 'package:freezed_annotation/freezed_annotation.dart';

part 'usuario.freezed.dart';
part 'usuario.g.dart';

@freezed
class Usuario with _$Usuario {
  const factory Usuario({
    required String id,
    required String username,
    @JsonKey(name: 'correo_electronico') required String correoElectronico,
    @JsonKey(name: 'numero_documento') required String numeroDocumento,
    required String nombre,
    required String apellido,
    required String rol,
    String? telefono,
    @Default(true) bool activo,
  }) = _Usuario;

  factory Usuario.fromJson(Map<String, dynamic> json) =>
      _$UsuarioFromJson(json);
}
