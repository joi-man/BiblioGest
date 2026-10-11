import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';

/// Aviso para estudiantes que entran desde la web o el escritorio: su
/// cuenta solo funciona en la aplicación móvil.
class SoloMovilScreen extends ConsumerWidget {
  const SoloMovilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = Theme.of(context).textTheme;
    final colores = context.colores;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smartphone, size: 48, color: colores.acento),
                const SizedBox(height: 20),
                Text(
                  'Usa la aplicación móvil',
                  style: textos.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Las cuentas de estudiante se manejan desde el celular: '
                  'busca materiales y solicítalos desde allí.',
                  style: textos.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                  },
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
