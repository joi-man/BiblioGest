// Firma un manifiesto de actualizaciones y escribe la firma junto a él.
//
//   dart run tool/firmar_manifiesto.dart build/instalador/latest.json
//
// Genera <archivo>.sig (base64 de la firma Ed25519 de los bytes exactos del archivo).
// La clave privada se lee de %USERPROFILE%\.bibliogest\clave_actualizaciones.key,
// o de la ruta indicada en la variable BIBLIOGEST_CLAVE_FIRMA.
import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

import 'generar_clave_actualizaciones.dart' show rutaClavePrivada;

Future<void> main(List<String> argumentos) async {
  if (argumentos.length != 1) {
    stderr.writeln('Uso: dart run tool/firmar_manifiesto.dart <latest.json>');
    exit(64);
  }
  final manifiesto = File(argumentos.single);
  final clave = rutaClavePrivada();
  if (!manifiesto.existsSync()) {
    stderr.writeln('No existe ${manifiesto.path}');
    exit(66);
  }
  if (!clave.existsSync()) {
    stderr.writeln('No hay clave de firma en ${clave.path}. Genérala con tool/generar_clave_actualizaciones.dart');
    exit(66);
  }

  final semilla = base64Decode(clave.readAsStringSync().trim());
  final par = await Ed25519().newKeyPairFromSeed(semilla);
  final firma = await Ed25519().sign(manifiesto.readAsBytesSync(), keyPair: par);

  final destino = File('${manifiesto.path}.sig');
  destino.writeAsStringSync(base64Encode(firma.bytes));
  stdout.writeln('Firma escrita en ${destino.path}');
}
