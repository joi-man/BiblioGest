import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/network/mensaje_error.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/widgets/panel_autenticacion.dart';
import 'package:frontend/features/core/widgets/alertas.dart';

/// Primer paso de la recuperación: pide el correo y envía el código.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  /// Solicita el código al backend y pasa a la pantalla de restablecimiento.
  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    final correo = _correoController.text.trim();
    try {
      await ref.read(authRepositoryProvider).solicitarRecuperacion(correo);
      if (!mounted) return;
      context.mostrarInfo(
          'Si el correo esta registrado, recibiras un codigo de 6 digitos');
      context.go('/reset-password', extra: correo);
    } catch (error) {
      if (mounted) {
        // 503: el ejecutable no pudo llegar al servidor que envía el código.
        final sinServidor = error is DioException && error.response?.statusCode == 503;
        context.mostrarError(sinServidor
            ? mensajeDeError(error)
            : 'No se pudo enviar la solicitud. Intenta de nuevo');
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PanelAutenticacion(
      titulo: 'Recuperar contrasena',
      subtitulo: 'Ingresa tu correo y te enviaremos un código de 6 dígitos.',
      hijo: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electronico',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: (valor) {
                final texto = valor?.trim() ?? '';
                if (texto.isEmpty) return 'El correo es obligatorio';
                if (!texto.contains('@') || !texto.contains('.')) {
                  return 'Ingresa un correo valido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _cargando ? null : _enviar,
              child: _cargando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enviar codigo'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Volver al inicio de sesion'),
            ),
          ],
        ),
      ),
    );
  }
}
