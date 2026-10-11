import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository.dart';
import 'package:frontend/features/core/widgets/alertas.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? correoInicial;

  const ResetPasswordScreen({super.key, this.correoInicial});

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
  bool _obscure = true;
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

  Future<void> _restablecer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await ref.read(authRepositoryProvider).restablecerContrasena(
            correo: _correoController.text.trim(),
            codigo: _codigoController.text.trim(),
            nuevaContrasena: _contrasenaController.text,
          );
      if (!mounted) return;
      context.mostrarExito('Contrasena actualizada. Inicia sesion');
      context.go('/login');
    } on DioException catch (e) {
      if (!mounted) return;
      context.mostrarError(e.response?.statusCode == 400
          ? 'Codigo invalido o expirado'
          : 'No se pudo cambiar la contrasena. Intenta de nuevo');
    } catch (_) {
      if (mounted) {
        context.mostrarError('No se pudo cambiar la contrasena. Intenta de nuevo');
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.password, size: 64, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text(
                        'Nueva contrasena',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ingresa el codigo que recibiste por correo (vence en 15 minutos).',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _correoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electronico',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'El correo es obligatorio';
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Ingresa un correo valido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _codigoController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Codigo de 6 digitos',
                          prefixIcon: Icon(Icons.pin),
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.length != 6) {
                            return 'El codigo debe tener 6 digitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contrasenaController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Nueva contrasena',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Minimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmarController,
                        obscureText: _obscure,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar contrasena',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != _contrasenaController.text) {
                            return 'Las contrasenas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _cargando ? null : _restablecer,
                          child: _cargando
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Cambiar contrasena'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go('/forgot-password'),
                        child: const Text('Reenviar codigo'),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Volver al inicio de sesion'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
