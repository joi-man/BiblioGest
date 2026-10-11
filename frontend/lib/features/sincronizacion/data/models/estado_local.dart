/// Estado del equipo (ejecutable de escritorio) respecto a su servidor.
class EstadoLocal {
  const EstadoLocal({
    required this.configurado,
    required this.servidorUrl,
    required this.conectado,
    required this.sincronizando,
    required this.pendientes,
    required this.conflictos,
    required this.ultimaSincronizacion,
    required this.ultimoError,
    required this.requiereInicioDeSesion,
  });

  /// Ya hay al menos un usuario: se puede iniciar sesión.
  final bool configurado;

  /// Dirección del servidor, o null si el equipo trabaja solo.
  final String? servidorUrl;

  /// True/false según el último intento; null si todavía no se sabe.
  final bool? conectado;
  final bool sincronizando;

  /// Cambios hechos en este equipo que aún no llegaron al servidor.
  final int pendientes;

  /// Cambios que el servidor rechazó y esperan una decisión.
  final int conflictos;
  final DateTime? ultimaSincronizacion;
  final String? ultimoError;

  /// Hay servidor pero nadie ha iniciado sesión aún, así que no puede sincronizar.
  final bool requiereInicioDeSesion;

  bool get tieneServidor => servidorUrl != null;

  factory EstadoLocal.fromJson(Map<String, dynamic> json) {
    return EstadoLocal(
      configurado: json['configurado'] as bool,
      servidorUrl: json['servidor_url'] as String?,
      conectado: json['conectado'] as bool?,
      sincronizando: json['sincronizando'] as bool,
      pendientes: json['pendientes'] as int,
      conflictos: json['conflictos'] as int,
      ultimaSincronizacion: _fechaUtc(json['ultima_sincronizacion'] as String?),
      ultimoError: json['ultimo_error'] as String?,
      requiereInicioDeSesion: json['requiere_inicio_de_sesion'] as bool,
    );
  }
}

/// Un cambio hecho sin conexión que el servidor rechazó.
class ConflictoLocal {
  const ConflictoLocal({
    required this.id,
    required this.creadoEn,
    required this.descripcion,
    required this.mensaje,
  });

  final String id;
  final DateTime creadoEn;

  /// Qué se había hecho, por ejemplo "Prestamo «activo» nuevo · Material «PROY-1» modificado".
  final String descripcion;

  /// Por qué lo rechazó el servidor.
  final String? mensaje;

  factory ConflictoLocal.fromJson(Map<String, dynamic> json) {
    return ConflictoLocal(
      id: json['id'] as String,
      creadoEn: _fechaUtc(json['creado_en'] as String?) ?? DateTime.now(),
      descripcion: json['descripcion'] as String,
      mensaje: json['mensaje'] as String?,
    );
  }
}

/// Resultado de pedir una sincronización inmediata.
class ResumenSincronizacion {
  const ResumenSincronizacion({
    required this.enviados,
    required this.conflictos,
    required this.recibidos,
  });

  final int enviados;
  final int conflictos;
  final int recibidos;

  factory ResumenSincronizacion.fromJson(Map<String, dynamic> json) {
    return ResumenSincronizacion(
      enviados: json['enviados'] as int,
      conflictos: json['conflictos'] as int,
      recibidos: json['recibidos'] as int,
    );
  }
}

/// El backend guarda fechas UTC sin sufijo; se interpretan como UTC.
DateTime? _fechaUtc(String? texto) {
  if (texto == null) return null;
  final sufijo = texto.endsWith('Z') ? '' : 'Z';
  return DateTime.parse('$texto$sufijo');
}
