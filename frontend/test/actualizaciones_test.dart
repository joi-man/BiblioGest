import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/actualizaciones/actualizaciones_provider.dart';
import 'package:frontend/core/actualizaciones/cliente_actualizaciones.dart';
import 'package:frontend/core/actualizaciones/decision.dart';
import 'package:frontend/core/actualizaciones/firma_manifiesto.dart';
import 'package:frontend/core/actualizaciones/instalador_actualizaciones.dart';
import 'package:frontend/core/actualizaciones/manifiesto.dart';
import 'package:frontend/core/actualizaciones/preferencias_actualizacion.dart';
import 'package:frontend/core/actualizaciones/version_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _huella = 'a' * 64;

String _json({String version = '0.9.1', String minima = '0.9.0', String url = 'https://x.test/i.exe'}) {
  return jsonEncode({
    'version': version,
    'minima': minima,
    'url': url,
    'sha256': _huella,
    'tamano': 1000,
    'notas': 'Mejoras',
    'fecha': '2026-10-11',
  });
}

Manifiesto _manifiesto({String version = '0.9.1', String minima = '0.9.0'}) =>
    Manifiesto.desdeTexto(_json(version: version, minima: minima));

/// Firma [texto] con una clave nueva y devuelve la firma y la clave pública (base64).
Future<({String firma, String clavePublica})> _firmar(String texto, {SimpleKeyPair? con}) async {
  final par = con ?? await Ed25519().newKeyPair();
  final firma = await Ed25519().sign(utf8.encode(texto), keyPair: par);
  final publica = await par.extractPublicKey();
  return (firma: base64Encode(firma.bytes), clavePublica: base64Encode(publica.bytes));
}

class _AdaptadorFalso implements HttpClientAdapter {
  _AdaptadorFalso(this.respuestas);

  final Map<String, String> respuestas;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    final cuerpo = respuestas[options.uri.toString()];
    if (cuerpo == null) {
      throw DioException(requestOptions: options, type: DioExceptionType.connectionError);
    }
    return ResponseBody.fromBytes(utf8.encode(cuerpo), 200);
  }

  @override
  void close({bool force = false}) {}
}

class _InstaladorFalso implements InstaladorActualizaciones {
  final llamadas = <String>[];
  Object? falla;

  @override
  bool get disponible => true;

  @override
  Future<void> limpiarDescargas(String versionActual) async => llamadas.add('limpiar $versionActual');

  @override
  Future<String> descargar(Manifiesto manifiesto, {required void Function(double) alProgreso}) async {
    llamadas.add('descargar ${manifiesto.version}');
    if (falla != null) throw falla!;
    alProgreso(0.5);
    return 'C:\\ruta\\${manifiesto.nombreArchivo}';
  }

  @override
  Future<void> instalar(String ruta, {required Future<void> Function() cerrarBackend}) async {
    llamadas.add('instalar $ruta');
    await cerrarBackend();
  }

  @override
  Future<void> salir({required Future<void> Function() cerrarBackend}) async => llamadas.add('salir');
}

void main() {
  group('VersionApp', () {
    test('compara numéricamente, no como texto', () {
      expect(VersionApp.parse('0.10.0') > VersionApp.parse('0.9.9'), isTrue);
      expect(VersionApp.parse('1.0.0') > VersionApp.parse('0.99.99'), isTrue);
      expect(VersionApp.parse('0.9.0') == VersionApp.parse('0.9.0'), isTrue);
    });

    test('ignora el número de compilación y las etiquetas', () {
      expect(VersionApp.parse('0.9.0+3'), VersionApp.parse('0.9.0'));
      expect(VersionApp.parse('v0.9.1-beta'), VersionApp.parse('0.9.1'));
    });

    test('rechaza formatos inválidos', () {
      expect(VersionApp.intentar('0.9'), isNull);
      expect(VersionApp.intentar('abc'), isNull);
      expect(VersionApp.intentar(null), isNull);
    });
  });

  group('Manifiesto', () {
    test('se interpreta con todos sus campos', () {
      final m = _manifiesto();
      expect(m.version, VersionApp.parse('0.9.1'));
      expect(m.minima, VersionApp.parse('0.9.0'));
      expect(m.nombreArchivo, 'BiblioGest-Setup-0.9.1.exe');
      expect(m.notas, 'Mejoras');
    });

    test('el manifiesto de Android apunta a un APK y se guarda con su propio nombre', () {
      final m = Manifiesto.desdeTexto(_json(url: 'https://x.test/v0.9.1/BiblioGest-0.9.1.apk'));

      expect(m.nombreArchivo, 'BiblioGest-0.9.1.apk');
    });

    test('exige https para el instalador', () {
      expect(() => Manifiesto.desdeTexto(_json(url: 'http://x.test/i.exe')), throwsA(isA<ErrorManifiesto>()));
    });

    test('rechaza datos incompletos o incoherentes', () {
      expect(() => Manifiesto.desdeTexto('no es json'), throwsA(isA<ErrorManifiesto>()));
      expect(() => Manifiesto.desdeTexto('{}'), throwsA(isA<ErrorManifiesto>()));
      expect(
        () => Manifiesto.desdeTexto(_json(version: '0.9.0', minima: '0.9.5')),
        throwsA(isA<ErrorManifiesto>()),
      );
      expect(
        () => Manifiesto.desdeTexto(_json().replaceFirst(_huella, 'corta')),
        throwsA(isA<ErrorManifiesto>()),
      );
    });
  });

  group('Firma del manifiesto', () {
    test('acepta un manifiesto firmado con la clave correcta', () async {
      final texto = _json();
      final firmado = await _firmar(texto);
      final m = await verificarManifiesto(
        contenido: Uint8List.fromList(utf8.encode(texto)),
        firmaBase64: firmado.firma,
        clavePublicaBase64: firmado.clavePublica,
      );
      expect(m.version, VersionApp.parse('0.9.1'));
    });

    test('rechaza un manifiesto modificado después de firmarlo', () async {
      final firmado = await _firmar(_json());
      expect(
        verificarManifiesto(
          contenido: Uint8List.fromList(utf8.encode(_json(url: 'https://malo.test/virus.exe'))),
          firmaBase64: firmado.firma,
          clavePublicaBase64: firmado.clavePublica,
        ),
        throwsA(isA<ErrorManifiesto>()),
      );
    });

    test('rechaza una firma hecha con otra clave', () async {
      final texto = _json();
      final ajena = await _firmar(texto);
      final propia = await _firmar(texto);
      expect(
        verificarManifiesto(
          contenido: Uint8List.fromList(utf8.encode(texto)),
          firmaBase64: ajena.firma,
          clavePublicaBase64: propia.clavePublica,
        ),
        throwsA(isA<ErrorManifiesto>()),
      );
    });

    test('rechaza una firma que no es base64', () {
      expect(
        verificarManifiesto(
          contenido: Uint8List.fromList(utf8.encode(_json())),
          firmaBase64: '%%%',
          clavePublicaBase64: 'AAAA',
        ),
        throwsA(isA<ErrorManifiesto>()),
      );
    });
  });

  group('decidir', () {
    final actual = VersionApp.parse('0.9.0');

    test('sin versión nueva no hay nada que hacer', () {
      final d = decidir(actual: actual, manifiesto: _manifiesto(version: '0.9.0'), automatica: false);
      expect(d.urgencia, Urgencia.ninguna);
    });

    test('una versión anterior a la instalada tampoco cuenta', () {
      final d = decidir(actual: VersionApp.parse('0.9.5'), manifiesto: _manifiesto(), automatica: false);
      expect(d.urgencia, Urgencia.ninguna);
    });

    test('una versión nueva es opcional si la instalada alcanza la mínima', () {
      final d = decidir(actual: actual, manifiesto: _manifiesto(), automatica: false);
      expect(d.urgencia, Urgencia.opcional);
      expect(d.instalarSola, isFalse);
    });

    test('es obligatoria si la instalada es anterior a la mínima', () {
      final d = decidir(actual: actual, manifiesto: _manifiesto(version: '0.9.2', minima: '0.9.1'), automatica: false);
      expect(d.urgencia, Urgencia.obligatoria);
    });

    test('omitir una versión opcional la silencia, pero no a la siguiente', () {
      final omitida = VersionApp.parse('0.9.1');
      expect(
        decidir(actual: actual, manifiesto: _manifiesto(), automatica: false, versionOmitida: omitida).urgencia,
        Urgencia.ninguna,
      );
      expect(
        decidir(actual: actual, manifiesto: _manifiesto(version: '0.9.2'), automatica: false, versionOmitida: omitida)
            .urgencia,
        Urgencia.opcional,
      );
    });

    test('una obligatoria no se puede omitir', () {
      final d = decidir(
        actual: actual,
        manifiesto: _manifiesto(version: '0.9.1', minima: '0.9.1'),
        automatica: false,
        versionOmitida: VersionApp.parse('0.9.1'),
      );
      expect(d.urgencia, Urgencia.obligatoria);
    });

    test('la instalación automática se intenta una sola vez por versión', () {
      final nueva = _manifiesto();
      expect(decidir(actual: actual, manifiesto: nueva, automatica: true).instalarSola, isTrue);
      expect(
        decidir(actual: actual, manifiesto: nueva, automatica: true, versionIntentadaSola: nueva.version)
            .instalarSola,
        isFalse,
      );
    });
  });

  group('ActualizacionesNotifier', () {
    late _InstaladorFalso instalador;
    late SharedPreferences preferencias;
    late SimpleKeyPair claves;
    late String clavePublica;
    var backendCerrado = false;

    Future<ActualizacionesNotifier> crear({
      String instalada = '0.9.0',
      Map<String, String>? publicado,
      bool habilitado = true,
    }) async {
      final dio = Dio()..httpClientAdapter = _AdaptadorFalso(publicado ?? {});
      return ActualizacionesNotifier(
        versionInstalada: VersionApp.parse(instalada),
        cliente: ClienteActualizaciones(dio: dio, urlManifiesto: 'https://x.test/latest.json', clavePublica: clavePublica),
        instalador: instalador,
        preferencias: PreferenciasActualizacion(preferencias),
        cerrarBackend: () async => backendCerrado = true,
        habilitado: habilitado,
        clavePublica: clavePublica,
      );
    }

    Future<Map<String, String>> publicar(String texto) async {
      final firmado = await _firmar(texto, con: claves);
      return {
        'https://x.test/latest.json': texto,
        'https://x.test/latest.json.sig': firmado.firma,
      };
    }

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferencias = await SharedPreferences.getInstance();
      instalador = _InstaladorFalso();
      backendCerrado = false;
      claves = await Ed25519().newKeyPair();
      clavePublica = base64Encode((await claves.extractPublicKey()).bytes);
    });

    test('con una versión opcional nueva, pide confirmación y no instala sola', () async {
      final n = await crear(publicado: await publicar(_json()));
      await n.iniciar();

      expect(n.state.fase, FaseActualizacion.disponible);
      expect(n.state.urgencia, Urgencia.opcional);
      expect(n.state.avisoPendiente, isTrue);
      expect(instalador.llamadas, ['limpiar 0.9.0']);
    });

    test('sin versión nueva queda al día y no avisa', () async {
      final n = await crear(instalada: '0.9.1', publicado: await publicar(_json()));
      await n.iniciar();

      expect(n.state.fase, FaseActualizacion.alDia);
      expect(n.state.avisoPendiente, isFalse);
    });

    test('sin conexión la aplicación se usa normalmente', () async {
      final n = await crear(publicado: {});
      await n.iniciar();

      expect(n.state.bloqueaLaApp, isFalse);
      expect(n.state.avisoPendiente, isFalse);
    });

    test('un manifiesto con firma inválida se ignora y no bloquea', () async {
      final n = await crear(publicado: {
        'https://x.test/latest.json': _json(minima: '0.9.5', version: '0.9.5'),
        'https://x.test/latest.json.sig': base64Encode(List.filled(64, 1)),
      });
      await n.iniciar();

      expect(n.state.bloqueaLaApp, isFalse);
      expect(n.state.manifiesto, isNull);
    });

    test('una actualización obligatoria bloquea la aplicación', () async {
      final n = await crear(publicado: await publicar(_json(version: '0.9.2', minima: '0.9.1')));
      await n.iniciar();

      expect(n.state.bloqueaLaApp, isTrue);
      expect(n.state.avisoPendiente, isFalse); // se muestra como pantalla, no como aviso
    });

    test('la obligatoria se sigue exigiendo sin conexión usando el último manifiesto', () async {
      final primera = await crear(publicado: await publicar(_json(version: '0.9.2', minima: '0.9.1')));
      await primera.iniciar();

      final sinRed = await crear(publicado: {});
      await sinRed.iniciar();
      expect(sinRed.state.bloqueaLaApp, isTrue);
    });

    test('un manifiesto guardado con otra clave no bloquea', () async {
      final texto = _json(version: '0.9.2', minima: '0.9.1');
      final ajena = await _firmar(texto);
      await PreferenciasActualizacion(preferencias).guardarManifiesto(texto, ajena.firma);

      final n = await crear(publicado: {});
      await n.iniciar();
      expect(n.state.bloqueaLaApp, isFalse);
    });

    test('"Más tarde" cierra el aviso y no vuelve a preguntar en la sesión', () async {
      final publicado = await publicar(_json());
      final n = await crear(publicado: publicado);
      await n.iniciar();

      n.posponer();
      expect(n.state.avisoPendiente, isFalse);

      await n.comprobar();
      expect(n.state.avisoPendiente, isFalse);
      expect(n.state.urgencia, Urgencia.opcional);
    });

    test('"Omitir esta versión" se recuerda entre sesiones', () async {
      final publicado = await publicar(_json());
      final n = await crear(publicado: publicado);
      await n.iniciar();
      await n.omitir();
      expect(n.state.urgencia, Urgencia.ninguna);

      final otraSesion = await crear(publicado: publicado);
      await otraSesion.iniciar();
      expect(otraSesion.state.avisoPendiente, isFalse);
      expect(otraSesion.state.urgencia, Urgencia.ninguna);
    });

    test('una obligatoria no se puede posponer ni omitir', () async {
      final n = await crear(publicado: await publicar(_json(version: '0.9.2', minima: '0.9.1')));
      await n.iniciar();

      n.posponer();
      await n.omitir();
      expect(n.state.bloqueaLaApp, isTrue);
    });

    test('"Actualizar ahora" descarga, cierra el backend e instala', () async {
      final n = await crear(publicado: await publicar(_json()));
      await n.iniciar();
      await n.descargarEInstalar();

      expect(instalador.llamadas, ['limpiar 0.9.0', 'descargar 0.9.1', 'instalar C:\\ruta\\BiblioGest-Setup-0.9.1.exe']);
      expect(backendCerrado, isTrue);
      expect(n.state.fase, FaseActualizacion.instalando);
    });

    test('con actualización automática instala sola al abrir', () async {
      await PreferenciasActualizacion(preferencias).guardarAutomatica(true);
      final n = await crear(publicado: await publicar(_json()));
      await n.iniciar();

      expect(instalador.llamadas, contains('instalar C:\\ruta\\BiblioGest-Setup-0.9.1.exe'));
    });

    test('si la instalación automática falla, no se repite sola en el próximo inicio', () async {
      await PreferenciasActualizacion(preferencias).guardarAutomatica(true);
      final publicado = await publicar(_json());

      instalador.falla = const ErrorInstalacion('Sin espacio');
      final primera = await crear(publicado: publicado);
      await primera.iniciar();
      expect(primera.state.fase, FaseActualizacion.error);
      expect(primera.state.mensaje, 'Sin espacio');
      expect(primera.state.avisoPendiente, isTrue);

      instalador.llamadas.clear();
      instalador.falla = null;
      final segunda = await crear(publicado: publicado);
      await segunda.iniciar();
      expect(instalador.llamadas, ['limpiar 0.9.0']); // no descargó
      expect(segunda.state.avisoPendiente, isTrue); // pregunta al usuario
    });

    test('un error al descargar permite reintentar', () async {
      final n = await crear(publicado: await publicar(_json()));
      await n.iniciar();

      instalador.falla = const ErrorInstalacion('Sin conexión');
      await n.descargarEInstalar();
      expect(n.state.fase, FaseActualizacion.error);

      instalador.falla = null;
      await n.descargarEInstalar();
      expect(n.state.fase, FaseActualizacion.instalando);
    });

    test('la búsqueda manual informa cuando no hay conexión', () async {
      final n = await crear(publicado: {});
      await n.iniciar();
      await n.comprobar(manual: true);

      expect(n.state.fase, FaseActualizacion.error);
      expect(n.state.mensaje, contains('conectar'));
    });

    test('no hace nada si las actualizaciones no están habilitadas (web, flutter run)', () async {
      final n = await crear(habilitado: false, publicado: await publicar(_json()));
      await n.iniciar();

      expect(n.state.fase, FaseActualizacion.inactiva);
      expect(instalador.llamadas, isEmpty);
    });
  });
}
