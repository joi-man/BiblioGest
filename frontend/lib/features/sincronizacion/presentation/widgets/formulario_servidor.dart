import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/mensaje_error.dart';
import 'package:frontend/features/core/widgets/alertas.dart';
import 'package:frontend/features/core/widgets/confirmacion.dart';
import 'package:frontend/features/sincronizacion/data/repositories/local_repository.dart';
import 'package:frontend/features/sincronizacion/presentation/providers/estado_local_provider.dart';

/// Formulario para unir el equipo a un servidor (en internet o en la red local).
class FormularioServidor extends ConsumerStatefulWidget {
  const FormularioServidor({
    super.key,
    required this.alConectar,
    this.hayDatosLocales = false,
    this.etiquetaBoton = 'Conectar y descargar datos',
  });

  /// Se invoca cuando el equipo quedó unido al servidor.
  final VoidCallback alConectar;

  /// El equipo ya tiene datos propios: se pide confirmar que serán reemplazados.
  final bool hayDatosLocales;
  final String etiquetaBoton;

  @override
  ConsumerState<FormularioServidor> createState() => _FormularioServidorState();
}

class _FormularioServidorState extends ConsumerState<FormularioServidor> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController(text: 'http://');
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _conectando = false;

  @override
  void dispose() {
    _urlController.dispose();
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _conectar() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.hayDatosLocales && !await _confirmarReemplazo()) return;

    setState(() => _conectando = true);
    try {
      await ref.read(localRepositoryProvider).conectar(
            servidorUrl: _urlController.text.trim(),
            usuario: _usuarioController.text.trim(),
            contrasena: _contrasenaController.text,
            reemplazarDatosLocales: widget.hayDatosLocales,
          );
      ref.invalidate(estadoLocalProvider);
      if (mounted) widget.alConectar();
    } catch (error) {
      if (mounted) context.mostrarError(mensajeDeError(error));
    } finally {
      if (mounted) setState(() => _conectando = false);
    }
  }

  Future<bool> _confirmarReemplazo() {
    return confirmarAccion(
      context,
      titulo: 'Reemplazar los datos de este equipo',
      mensaje: 'Este equipo ya tiene información propia. Al conectarlo con el '
          'servidor se reemplazará por la del servidor. ¿Continuar?',
      etiquetaConfirmar: 'Reemplazar',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Dirección del servidor',
              hintText: 'http://192.168.1.10:8000',
              helperText: 'En una red local sin internet usa la IP del servidor.',
              prefixIcon: Icon(Icons.dns_outlined),
            ),
            validator: (valor) {
              final texto = valor?.trim() ?? '';
              if (!texto.startsWith('http://') && !texto.startsWith('https://')) {
                return 'Debe empezar con http:// o https://';
              }
              return texto.length > 8 ? null : 'Escribe la dirección completa';
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usuarioController,
            decoration: const InputDecoration(
              labelText: 'Usuario o correo del personal',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (valor) =>
                (valor == null || valor.trim().isEmpty) ? 'Obligatorio' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contrasenaController,
            obscureText: true,
            onFieldSubmitted: (_) => _conectar(),
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (valor) =>
                (valor == null || valor.isEmpty) ? 'Obligatoria' : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _conectando ? null : _conectar,
            child: _conectando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.etiquetaBoton),
          ),
        ],
      ),
    );
  }
}
