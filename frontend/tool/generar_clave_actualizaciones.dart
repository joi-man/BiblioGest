// Genera el par de claves con el que se firman las actualizaciones.
//
//   dart run tool/generar_clave_actualizaciones.dart
//
// La clave PRIVADA se guarda en %USERPROFILE%\.bibliogest\clave_actualizaciones.key
// (fuera del repositorio) y NO se muestra. Haz una copia de seguridad: si se
// pierde, los equipos ya instalados dejan de aceptar actualizaciones.
// Se imprime la clave PÚBLICA, que va en lib/core/actualizaciones/clave_publica.dart.
import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

Future<void> main() async {
  final archivo = rutaClavePrivada();
  if (archivo.existsSync()) {
    stderr.writeln('Ya existe una clave en ${archivo.path}. No se sobrescribe.');
    exit(1);
  }

  final par = await Ed25519().newKeyPair();
  final semilla = await par.extractPrivateKeyBytes();
  final publica = (await par.extractPublicKey()).bytes;

  archivo.parent.createSync(recursive: true);
  archivo.writeAsStringSync(base64Encode(semilla));

  stdout.writeln('Clave privada guardada en: ${archivo.path}');
  stdout.writeln('Clave pública (pégala en clave_publica.dart):');
  stdout.writeln(base64Encode(publica));
}

File rutaClavePrivada() {
  final indicada = Platform.environment['BIBLIOGEST_CLAVE_FIRMA'];
  if (indicada != null && indicada.isNotEmpty) return File(indicada);
  final inicio = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '.';
  return File('$inicio${Platform.pathSeparator}.bibliogest${Platform.pathSeparator}clave_actualizaciones.key');
}
