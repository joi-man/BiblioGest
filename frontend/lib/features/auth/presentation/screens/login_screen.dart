import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/app/auth_state.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/presentation/widgets/descargas_aplicaciones.dart';
import 'package:frontend/features/auth/presentation/widgets/panel_autenticacion.dart';
import 'package:frontend/features/core/widgets/alertas.dart';

/// Pantalla de inicio de sesión con correo o nombre de usuario.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _ocultarContrasena = true;

  @override
  void initState() {
    super.initState();
    // Si se llegó aquí porque la sesión terminó, se explica el motivo una sola vez.
    final aviso = authStateNotifier.avisoAlLogin;
    if (aviso != null) {
      authStateNotifier.avisoAlLogin = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.mostrarInfo(aviso);
      });
    }
  }

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  /// Valida el formulario e intenta iniciar sesión.
  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .login(_correoController.text.trim(), _contrasenaController.text);

    final estado = ref.read(authProvider);
    if (!mounted) return;
    if (estado.hasValue && estado.value != null) {
      context.mostrarExito('Bienvenido ${estado.value!.usuario.nombre}');
      context.go('/');
    } else if (estado.hasError) {
      // Si el servidor explica el motivo (cuenta suspendida o bloqueada, intentos que
      // quedan) se muestra; si no, mensaje general.
      final error = estado.error;
      final detalle = error is DioException && error.response?.data is Map
          ? (error.response!.data as Map)['detail']
          : null;
      context.mostrarError(
        detalle is String &&
                const [401, 403, 429].contains(
                  (error as DioException).response?.statusCode,
                )
            ? detalle
            : 'Credenciales incorrectas',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = ref.watch(authProvider).isLoading;

    return PanelAutenticacion(
      titulo: 'Iniciar sesión',
      subtitulo: 'Ingresa con tu correo o nombre de usuario.',
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
                labelText: 'Correo o usuario',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (valor) => (valor == null || valor.isEmpty)
                  ? 'El correo o usuario es obligatorio'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contrasenaController,
              obscureText: _ocultarContrasena,
              onFieldSubmitted: (_) => _iniciarSesion(),
              decoration: InputDecoration(
                labelText: 'Contrasena',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _ocultarContrasena
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _ocultarContrasena = !_ocultarContrasena),
                ),
              ),
              validator: (valor) => (valor == null || valor.isEmpty)
                  ? 'La contrasena es obligatoria'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: cargando ? null : _iniciarSesion,
              child: cargando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Iniciar Sesion'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: const Text('¿Olvidaste tu contrasena?'),
            ),
            const DescargasAplicaciones(),
          ],
        ),
      ),
    );
  }
}
