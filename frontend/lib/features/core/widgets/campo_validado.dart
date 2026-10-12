import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CampoValidado extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final int maxLength;
  final String? pattern;
  final String? mensajeErrorPattern;
  final bool requerido;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;

  const CampoValidado({
    super.key,
    required this.label,
    required this.controller,
    this.maxLength = 255,
    this.pattern,
    this.mensajeErrorPattern,
    this.requerido = true,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  State<CampoValidado> createState() => _CampoValidadoState();
}

class _CampoValidadoState extends State<CampoValidado> {
  String? _errorText;
  int _caracteresActuales = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_actualizarContador);
    _caracteresActuales = widget.controller.text.length;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_actualizarContador);
    super.dispose();
  }

  void _actualizarContador() {
    setState(() {
      _caracteresActuales = widget.controller.text.length;
    });
  }

  void _validar(String value) {
    setState(() {
      _errorText = null;

      if (widget.requerido && value.isEmpty) {
        _errorText = '${widget.label} es obligatorio';
        return;
      }

      if (value.length > widget.maxLength) {
        _errorText = 'Maximo ${widget.maxLength} caracteres';
        return;
      }

      if (widget.pattern != null && value.isNotEmpty) {
        final regex = RegExp(widget.pattern!);
        if (!regex.hasMatch(value)) {
          _errorText = widget.mensajeErrorPattern ?? 'Formato invalido';
          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          onChanged: _validar,
          inputFormatters: [LengthLimitingTextInputFormatter(widget.maxLength)],
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            errorText: _errorText,
            counterText: '$_caracteresActuales/${widget.maxLength}',
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
