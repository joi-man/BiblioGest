import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/widgets/panel_autenticacion.dart';
import 'package:frontend/features/core/widgets/alertas.dart';

/// Segundo paso de la recuperación: código recibido y nueva contraseña.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.correoInicial});

  /// Correo ya escrito en el paso anterior, para no pedirlo otra vez.
  final String? correoInicial;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _correoController;
  final _codigoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _ocultar = true;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _correoController = TextEditingController(text: widget.correoInicial ?? '');
  }

  @override
  void dispose() {
    _correoController.dispose();
    _codigoController.dispose();
    _contrasenaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  /// Envía el código y la nueva contraseña al backend.
  Future<void> _restablecer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .restablecerContrasena(
            correo: _correoController.text.trim(),
            codigo: _codigoController.text.trim(),
            nuevaContrasena: _contrasenaController.text,
          );
      if (!mounted) return;
      context.mostrarExito('Contraseña actualizada. Inicia sesión');
      context.go('/login');
    } on DioException catch (e) {
      if (!mounted) return;
      context.mostrarError(
        e.response?.statusCode == 400
            ? 'Código inválido o expirado'
            : 'No se pudo cambiar la contraseña. Intenta de nuevo',
      );
    } catch (_) {
      if (mounted) {
        context.mostrarError(
          'No se pudo cambiar la contraseña. Intenta de nuevo',
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PanelAutenticacion(
      titulo: 'Nueva contraseña',
      subtitulo:
          'Ingresa el código que recibiste por correo (vence en 15 minutos).',
      hijo: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: (valor) {
                final texto = valor?.trim() ?? '';
                if (texto.isEmpty) return 'El correo es obligatorio';
                if (!texto.contains('@') || !texto.contains('.')) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codigoController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Código de 6 dígitos',
                prefixIcon: Icon(Icons.pin_outlined),
                counterText: '',
              ),
              validator: (valor) => (valor == null || valor.length != 6)
                  ? 'El código debe tener 6 dígitos'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contrasenaController,
              obscureText: _ocultar,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _ocultar
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _ocultar = !_ocultar),
                ),
              ),
              validator: (valor) => (valor == null || valor.length < 6)
                  ? 'Minimo 6 caracteres'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmarController,
              obscureText: _ocultar,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (valor) => valor != _contrasenaController.text
                  ? 'Las contraseñas no coinciden'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _cargando ? null : _restablecer,
              child: _cargando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Cambiar contraseña'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: const Text('Reenviar código'),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Volver al inicio de sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
