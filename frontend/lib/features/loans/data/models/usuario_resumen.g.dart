// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_resumen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UsuarioResumenImpl _$$UsuarioResumenImplFromJson(Map<String, dynamic> json) =>
    _$UsuarioResumenImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      numeroDocumento: json['numero_documento'] as String,
      correoElectronico: json['correo_electronico'] as String,
    );

Map<String, dynamic> _$$UsuarioResumenImplToJson(
  _$UsuarioResumenImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'nombre': instance.nombre,
  'apellido': instance.apellido,
  'numero_documento': instance.numeroDocumento,
  'correo_electronico': instance.correoElectronico,
};
