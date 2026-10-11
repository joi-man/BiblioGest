import 'package:freezed_annotation/freezed_annotation.dart';

part 'usuario_resumen.freezed.dart';
part 'usuario_resumen.g.dart';

/// Datos mínimos de una persona, tal como vienen dentro de un préstamo.
@freezed
class UsuarioResumen with _$UsuarioResumen {
  const UsuarioResumen._();

  const factory UsuarioResumen({
    required String id,
    required String username,
    required String nombre,
    required String apellido,
    @JsonKey(name: 'numero_documento') required String numeroDocumento,
    @JsonKey(name: 'correo_electronico') required String correoElectronico,
  }) = _UsuarioResumen;

  factory UsuarioResumen.fromJson(Map<String, dynamic> json) =>
      _$UsuarioResumenFromJson(json);

  String get nombreCompleto => '$nombre $apellido';
}
