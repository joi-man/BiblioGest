/// Clave pública Ed25519 (en base64) con la que se comprueba que el manifiesto
/// de actualizaciones lo publicó BiblioGest.
///
/// La clave privada NO está en el repositorio: se genera con
/// `dart run tool/generar_clave_actualizaciones.dart`. Si se pierde, los equipos
/// ya instalados dejan de aceptar actualizaciones y habrá que reinstalarlos.
const String clavePublicaActualizaciones = 'EMC/UvJcDCpZwmuiSmzFXPseQTCfRZ5d9Us3nOSeijw=';

/// Dirección del manifiesto. La firma está en la misma dirección más `.sig`.
///
/// Por defecto apunta a los Releases de un repositorio público solo para
/// publicar versiones (el del código es privado). Se puede cambiar al
/// compilar: `--dart-define=URL_ACTUALIZACIONES=https://.../latest.json`.
const String urlManifiestoActualizaciones = String.fromEnvironment(
  'URL_ACTUALIZACIONES',
  defaultValue:
      'https://github.com/joi-man/BiblioGest-releases/releases/latest/download/latest.json',
);
