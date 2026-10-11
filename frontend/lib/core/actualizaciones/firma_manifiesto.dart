import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'manifiesto.dart';

/// Comprueba que [contenido] fue firmado con la clave privada que corresponde
/// a [clavePublicaBase64] y devuelve el manifiesto ya interpretado.
///
/// Se verifican los bytes exactos del archivo descargado: no hay que
/// normalizar ni reordenar el JSON.
Future<Manifiesto> verificarManifiesto({
  required Uint8List contenido,
  required String firmaBase64,
  required String clavePublicaBase64,
}) async {
  final Uint8List firma;
  final Uint8List clave;
  try {
    firma = base64Decode(firmaBase64.trim());
    clave = base64Decode(clavePublicaBase64.trim());
  } on FormatException {
    throw const ErrorManifiesto('La firma del manifiesto no es válida');
  }

  final valida = await Ed25519().verify(
    contenido,
    signature: Signature(
      firma,
      publicKey: SimplePublicKey(clave, type: KeyPairType.ed25519),
    ),
  );
  if (!valida) {
    throw const ErrorManifiesto('El manifiesto no está firmado por BiblioGest');
  }
  return Manifiesto.desdeTexto(utf8.decode(contenido));
}
