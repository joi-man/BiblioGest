import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/actualizaciones/actualizaciones_provider.dart';

/// Overrides para las pruebas que montan la aplicación completa: define la
/// versión instalada y evita que busquen actualizaciones por la red.
final List<Override> sinActualizaciones = [
  versionAppProvider.overrideWithValue('0.10.0'),
  actualizacionesHabilitadasProvider.overrideWithValue(false),
];
