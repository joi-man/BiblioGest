@TestOn('windows')
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/actualizaciones/instalador_actualizaciones.dart';
import 'package:frontend/core/actualizaciones/manifiesto.dart';
import 'package:frontend/core/actualizaciones/version_app.dart';

/// Prueba el instalador real de Windows (descarga, verificación y limpieza)
/// contra un servidor HTTP local, usando una carpeta temporal propia.
void main() {
  late HttpServer servidor;
  late Directory carpeta;
  late List<int> contenido;
  var pedidos = 0;

  Manifiesto manifiestoDe(List<int> bytes, {String version = '0.10.1', String? huella, int? tamano}) {
    return Manifiesto(
      version: VersionApp.parse(version),
      minima: VersionApp.parse('0.0.0'),
      url: Uri.parse('http://127.0.0.1:${servidor.port}/instalador.exe'),
      sha256: huella ?? sha256.convert(bytes).toString(),
      tamano: tamano ?? bytes.length,
    );
  }

  setUp(() async {
    pedidos = 0;
    contenido = List.generate(300000, (i) => i % 251);
    carpeta = await Directory.systemTemp.createTemp('bibliogest_act_');
    servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    servidor.listen((peticion) async {
      pedidos++;
      peticion.response
        ..headers.contentLength = contenido.length
        ..add(contenido);
      await peticion.response.close();
    });
  });

  tearDown(() async {
    await servidor.close(force: true);
    await carpeta.delete(recursive: true);
  });

  InstaladorActualizaciones crear() => crearInstaladorActualizaciones(carpetaDescargas: carpeta.path);

  test('descarga el instalador, informa el avance y lo deja con su nombre final', () async {
    final avances = <double>[];
    final ruta = await crear().descargar(manifiestoDe(contenido), alProgreso: avances.add);

    expect(ruta.endsWith('BiblioGest-Setup-0.10.1.exe'), isTrue);
    expect(File(ruta).readAsBytesSync(), contenido);
    expect(avances, isNotEmpty);
    expect(avances.last, 1);
    expect(File('$ruta.parcial').existsSync(), isFalse);
  });

  test('rechaza y borra un archivo cuya huella no coincide (posible manipulación)', () async {
    final manifiesto = manifiestoDe(contenido, huella: 'b' * 64);

    await expectLater(
      crear().descargar(manifiesto, alProgreso: (_) {}),
      throwsA(isA<ErrorInstalacion>()),
    );
    expect(carpeta.listSync(), isEmpty); // ni el instalador ni el parcial quedan
  });

  test('rechaza un archivo con un tamaño distinto al publicado', () async {
    final manifiesto = manifiestoDe(contenido, tamano: contenido.length + 1);

    await expectLater(
      crear().descargar(manifiesto, alProgreso: (_) {}),
      throwsA(isA<ErrorInstalacion>()),
    );
    expect(carpeta.listSync(), isEmpty);
  });

  test('reutiliza un instalador ya descargado y verificado sin volver a bajarlo', () async {
    final instalador = crear();
    final manifiesto = manifiestoDe(contenido);
    await instalador.descargar(manifiesto, alProgreso: (_) {});
    expect(pedidos, 1);

    await instalador.descargar(manifiesto, alProgreso: (_) {});
    expect(pedidos, 1);
  });

  test('vuelve a descargar si el instalador guardado está dañado', () async {
    final instalador = crear();
    final manifiesto = manifiestoDe(contenido);
    final ruta = await instalador.descargar(manifiesto, alProgreso: (_) {});
    File(ruta).writeAsBytesSync([1, 2, 3]);

    await instalador.descargar(manifiesto, alProgreso: (_) {});
    expect(pedidos, 2);
    expect(File(ruta).readAsBytesSync(), contenido);
  });

  test('informa un error entendible si no hay servidor', () async {
    final manifiesto = manifiestoDe(contenido);
    await servidor.close(force: true);

    await expectLater(
      crear().descargar(manifiesto, alProgreso: (_) {}),
      throwsA(isA<ErrorInstalacion>().having((e) => e.mensaje, 'mensaje', contains('conexión'))),
    );
  });

  test('limpia instaladores de versiones ya instaladas y archivos parciales, y conserva los más nuevos', () async {
    for (final nombre in [
      'BiblioGest-Setup-0.9.0.exe',
      'BiblioGest-Setup-0.10.0.exe',
      'BiblioGest-Setup-0.10.1.exe.parcial',
      'BiblioGest-Setup-0.10.2.exe',
    ]) {
      File('${carpeta.path}${Platform.pathSeparator}$nombre').writeAsStringSync('x');
    }

    await crear().limpiarDescargas('0.10.0');

    final quedan = carpeta.listSync().map((e) => e.uri.pathSegments.last).toList();
    expect(quedan, ['BiblioGest-Setup-0.10.2.exe']);
  });

  test('un manifiesto admite http solo hacia este equipo', () {
    String json(String url) => jsonEncode({
          'version': '0.10.1',
          'minima': '0.0.0',
          'url': url,
          'sha256': 'a' * 64,
          'tamano': 10,
        });

    expect(Manifiesto.desdeTexto(json('http://127.0.0.1:8000/i.exe')).url.port, 8000);
    expect(() => Manifiesto.desdeTexto(json('http://ejemplo.com/i.exe')), throwsA(isA<ErrorManifiesto>()));
    expect(() => Manifiesto.desdeTexto(json('http://127.0.0.1.ejemplo.com/i.exe')), throwsA(isA<ErrorManifiesto>()));
  });
}
