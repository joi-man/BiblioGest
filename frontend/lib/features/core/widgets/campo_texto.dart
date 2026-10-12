import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de texto de formulario con las opciones más comunes.
///
/// A diferencia de `CampoValidado`, es un `TextFormField`: participa de
/// `Form.validate()` y por eso impide guardar si hay errores.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.requerido = false,
    this.maxCaracteres,
    this.maxLineas = 1,
    this.teclado = TextInputType.text,
    this.soloDigitos = false,
    this.ayuda,
    this.habilitado = true,
    this.mayusculas = false,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final bool requerido;
  final int? maxCaracteres;
  final int maxLineas;
  final TextInputType teclado;

  /// Acepta solo números enteros positivos.
  final bool soloDigitos;

  /// Texto de ayuda bajo el campo.
  final String? ayuda;
  final bool habilitado;
  final bool mayusculas;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      enabled: habilitado,
      maxLines: maxLineas,
      keyboardType: soloDigitos ? TextInputType.number : teclado,
      textCapitalization: mayusculas
          ? TextCapitalization.characters
          : TextCapitalization.sentences,
      inputFormatters: [
        if (soloDigitos) FilteringTextInputFormatter.digitsOnly,
        if (maxCaracteres != null)
          LengthLimitingTextInputFormatter(maxCaracteres),
      ],
      decoration: InputDecoration(
        labelText: requerido ? '$etiqueta *' : etiqueta,
        helperText: ayuda,
        helperMaxLines: 2,
      ),
      validator: (valor) {
        if (requerido && (valor == null || valor.trim().isEmpty)) {
          return '$etiqueta es obligatorio';
        }
        return null;
      },
    );
  }
}
