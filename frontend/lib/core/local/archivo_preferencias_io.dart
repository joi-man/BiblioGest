import 'dart:io';

/// Renombra el archivo de ajustes de Windows a `shared_preferences.json.danado`
/// para conservarlo y poder empezar con uno nuevo. [carpeta] solo cambia en pruebas.
Future<void> apartarArchivoDanado({String? carpeta}) async {
  final base =
      carpeta ??
      (Platform.isWindows && Platform.environment['APPDATA'] != null
          ? '${Platform.environment['APPDATA']}\com.bibliogest\BiblioGest'
          : null);
  if (base == null) return;
  final archivo = File('$base${Platform.pathSeparator}shared_preferences.json');
  if (!archivo.existsSync()) return;
  final apartado = File('${archivo.path}.danado');
  if (apartado.existsSync()) apartado.deleteSync();
  archivo.renameSync(apartado.path);
}
