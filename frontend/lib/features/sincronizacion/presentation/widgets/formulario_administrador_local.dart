import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/mensaje_error.dart';
import 'package:frontend/features/core/widgets/alertas.dart';
import 'package:frontend/features/core/widgets/campo_texto.dart';
import 'package:frontend/features/sincronizacion/data/repositories/local_repository.dart';
import 'package:frontend/features/sincronizacion/presentation/providers/estado_local_provider.dart';

/// Formulario con los datos del administrador de un equipo que trabajará sin servidor.
class FormularioAdministradorLocal extends ConsumerStatefulWidget {
  const FormularioAdministradorLocal({super.key, required this.alCrear});

  /// Se invoca cuando el administrador quedó creado.
  final VoidCallback alCrear;

  @override
  ConsumerState<FormularioAdministradorLocal> createState() =>
      _FormularioAdministradorLocalState();
}

class _FormularioAdministradorLocalState
    extends ConsumerState<FormularioAdministradorLocal> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _documento = TextEditingController();
  final _usuario = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirmar = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    for (final c in [_nombre, _apellido, _documento, _usuario, _correo, _contrasena, _confirmar]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      await ref.read(localRepositoryProvider).configurarSoloLocal({
        'nombre': _nombre.text.trim(),
        'apellido': _apellido.text.trim(),
        'numero_documento': _documento.text.trim(),
        'username': _usuario.text.trim(),
        'correo_electronico': _correo.text.trim(),
        'contrasena': _contrasena.text,
      });
      ref.invalidate(estadoLocalProvider);
      if (mounted) widget.alCrear();
    } catch (error) {
      if (mounted) context.mostrarError(mensajeDeError(error));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CampoTexto(etiqueta: 'Nombre', controlador: _nombre, requerido: true, maxCaracteres: 100),
          const SizedBox(height: 12),
          CampoTexto(etiqueta: 'Apellido', controlador: _apellido, requerido: true, maxCaracteres: 100),
          const SizedBox(height: 12),
          CampoTexto(etiqueta: 'Número de documento', controlador: _documento, requerido: true, maxCaracteres: 20),
          const SizedBox(height: 12),
          CampoTexto(etiqueta: 'Usuario', controlador: _usuario, requerido: true, maxCaracteres: 50),
          const SizedBox(height: 12),
          CampoTexto(
            etiqueta: 'Correo electrónico',
            controlador: _correo,
            requerido: true,
            teclado: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contrasena,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña'),
            validator: (valor) =>
                (valor == null || valor.length < 6) ? 'Mínimo 6 caracteres' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmar,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Repite la contraseña'),
            validator: (valor) =>
                valor != _contrasena.text ? 'Las contraseñas no coinciden' : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _guardando ? null : _crear,
            child: _guardando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Crear administrador'),
          ),
        ],
      ),
    );
  }
}
