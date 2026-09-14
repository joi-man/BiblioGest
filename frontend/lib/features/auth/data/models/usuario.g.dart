// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UsuarioImpl _$$UsuarioImplFromJson(Map<String, dynamic> json) =>
    _$UsuarioImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      correoElectronico: json['correo_electronico'] as String,
      numeroDocumento: json['numero_documento'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      rol: json['rol'] as String,
      telefono: json['telefono'] as String?,
      activo: json['activo'] as bool? ?? true,
    );

Map<String, dynamic> _$$UsuarioImplToJson(_$UsuarioImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'correo_electronico': instance.correoElectronico,
      'numero_documento': instance.numeroDocumento,
      'nombre': instance.nombre,
      'apellido': instance.apellido,
      'rol': instance.rol,
      'telefono': instance.telefono,
      'activo': instance.activo,
    };
