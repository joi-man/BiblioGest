import 'package:flutter/material.dart';

/// Pide al personal el motivo para rechazar una solicitud.
///
/// Devuelve el motivo escrito, o `null` si se cancela.
Future<String?> pedirMotivoRechazo(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _DialogoRechazo(),
  );
}

class _DialogoRechazo extends StatefulWidget {
  const _DialogoRechazo();

  @override
  State<_DialogoRechazo> createState() => _DialogoRechazoState();
}

class _DialogoRechazoState extends State<_DialogoRechazo> {
  final _formKey = GlobalKey<FormState>();
  final _motivo = TextEditingController();

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _motivo.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rechazar solicitud'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _motivo,
            autofocus: true,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Motivo *',
              helperText: 'El usuario verá este mensaje.',
            ),
            validator: (valor) => (valor == null || valor.trim().length < 3)
                ? 'Escribe al menos 3 caracteres'
                : null,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirmar, child: const Text('Rechazar')),
      ],
    );
  }
}
