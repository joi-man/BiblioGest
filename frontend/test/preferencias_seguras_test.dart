import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/local/archivo_preferencias_io.dart';
import 'package:frontend/core/local/preferencias_seguras.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('si el archivo de ajustes está dañado, lo aparta y arranca con ajustes vacíos', () async {
    SharedPreferences.setMockInitialValues({});
    var intentos = 0;
    var apartado = false;

    final preferencias = await cargarPreferencias(
      abrir: () async {
        intentos++;
        if (!apartado) throw const FormatException('JSON dañado');
        return SharedPreferences.getInstance();
      },
      apartarDanado: () async => apartado = true,
    );

    expect(intentos, 2);
    expect(preferencias.getKeys(), isEmpty);
  });

  test('si no se puede abrir de ninguna forma, usa ajustes en memoria', () async {
    final preferencias = await cargarPreferencias(
      abrir: () async => throw const FormatException('siempre falla'),
      apartarDanado: () async {},
    );

    await preferencias.setString('a', 'b');
    expect(preferencias.getString('a'), 'b');
  });

  test('un archivo sano no se toca', () async {
    SharedPreferences.setMockInitialValues({'tema': 'oscuro'});

    final preferencias = await cargarPreferencias();

    expect(preferencias.getString('tema'), 'oscuro');
  });

  test('apartarArchivoDanado conserva una copia y deja la carpeta lista', () async {
    final carpeta = await Directory.systemTemp.createTemp('bibliogest_prefs_');
    addTearDown(() => carpeta.delete(recursive: true));
    final archivo = File('${carpeta.path}${Platform.pathSeparator}shared_preferences.json')
      ..writeAsStringSync('{"a":"b"}}');

    await apartarArchivoDanado(carpeta: carpeta.path);

    expect(archivo.existsSync(), isFalse);
    expect(File('${archivo.path}.danado').readAsStringSync(), '{"a":"b"}}');
  });
}
