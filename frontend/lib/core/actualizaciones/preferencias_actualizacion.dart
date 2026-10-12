import 'package:shared_preferences/shared_preferences.dart';

/// Lo que la aplicación recuerda entre una sesión y otra sobre actualizaciones.
class PreferenciasActualizacion {
  PreferenciasActualizacion(this._preferencias);

  final SharedPreferences _preferencias;

  static const _claveAutomatica = 'actualizacion_automatica';
  static const _claveOmitida = 'actualizacion_version_omitida';
  static const _claveIntentoAutomatico = 'actualizacion_intento_automatico';
  static const _claveManifiesto = 'actualizacion_manifiesto';
  static const _claveFirma = 'actualizacion_firma';

  /// El usuario aceptó instalar las actualizaciones sin preguntar.
  bool get automatica => _preferencias.getBool(_claveAutomatica) ?? false;
  Future<void> guardarAutomatica(bool valor) =>
      _preferencias.setBool(_claveAutomatica, valor);

  /// Versión cuyo aviso el usuario decidió ignorar (solo si es opcional).
  String? get versionOmitida => _preferencias.getString(_claveOmitida);
  Future<void> guardarVersionOmitida(String version) =>
      _preferencias.setString(_claveOmitida, version);

  /// Última versión que se intentó instalar sin preguntar.
  String? get versionIntentadaSola =>
      _preferencias.getString(_claveIntentoAutomatico);
  Future<void> guardarIntentoAutomatico(String version) =>
      _preferencias.setString(_claveIntentoAutomatico, version);

  /// Último manifiesto verificado, con su firma. Permite seguir exigiendo una
  /// actualización obligatoria aunque el equipo se abra sin conexión.
  ({String contenido, String firma})? get manifiestoGuardado {
    final contenido = _preferencias.getString(_claveManifiesto);
    final firma = _preferencias.getString(_claveFirma);
    if (contenido == null || firma == null) return null;
    return (contenido: contenido, firma: firma);
  }

  Future<void> guardarManifiesto(String contenido, String firma) async {
    await _preferencias.setString(_claveManifiesto, contenido);
    await _preferencias.setString(_claveFirma, firma);
  }
}
