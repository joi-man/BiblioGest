import 'package:shared_preferences/shared_preferences.dart';

import 'archivo_preferencias_stub.dart' if (dart.library.io) 'archivo_preferencias_io.dart';

/// Abre los ajustes de la aplicación sin que un archivo dañado impida arrancar.
///
/// Si el archivo no se puede leer (por ejemplo, quedó a medias al cerrarse la
/// aplicación mientras escribía), se aparta una copia y se empieza con ajustes
/// vacíos. Si ni así se puede, la sesión corre con ajustes en memoria.
Future<SharedPreferences> cargarPreferencias({
  Future<SharedPreferences> Function()? abrir,
  Future<void> Function()? apartarDanado,
}) async {
  final abrirPreferencias = abrir ?? SharedPreferences.getInstance;
  try {
    return await abrirPreferencias();
  } catch (_) {
    try {
      await (apartarDanado ?? apartarArchivoDanado)();
      return await abrirPreferencias();
    } catch (_) {
      SharedPreferences.setMockInitialValues({});
      return SharedPreferences.getInstance();
    }
  }
}
