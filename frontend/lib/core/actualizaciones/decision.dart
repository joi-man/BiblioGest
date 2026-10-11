import 'manifiesto.dart';
import 'version_app.dart';

/// Qué tan necesaria es una actualización.
enum Urgencia {
  /// La versión instalada es la última (o se decidió omitir la nueva).
  ninguna,

  /// Hay una versión nueva, pero se puede seguir usando la actual.
  opcional,

  /// La versión instalada ya no es compatible: hay que actualizar para continuar.
  obligatoria,
}

/// Resultado de comparar la versión instalada con el manifiesto.
class Decision {
  const Decision(this.urgencia, {this.instalarSola = false});

  static const ninguna = Decision(Urgencia.ninguna);

  final Urgencia urgencia;

  /// True si el usuario pidió actualizaciones automáticas y esta no falló antes.
  final bool instalarSola;
}

/// Decide qué hacer con una versión publicada. Es una función pura.
///
/// - Una actualización obligatoria no se puede omitir.
/// - Omitir una versión solo silencia el aviso de esa versión: una más nueva avisa de nuevo.
/// - La instalación automática se intenta una sola vez por versión
///   ([versionIntentadaSola]); si no funcionó, se vuelve a preguntar al usuario
///   en lugar de repetir el intento en cada inicio.
Decision decidir({
  required VersionApp actual,
  required Manifiesto manifiesto,
  required bool automatica,
  VersionApp? versionOmitida,
  VersionApp? versionIntentadaSola,
}) {
  if (manifiesto.version <= actual) return Decision.ninguna;

  final obligatoria = actual < manifiesto.minima;
  if (!obligatoria && versionOmitida == manifiesto.version) return Decision.ninguna;

  return Decision(
    obligatoria ? Urgencia.obligatoria : Urgencia.opcional,
    instalarSola: automatica && versionIntentadaSola != manifiesto.version,
  );
}
