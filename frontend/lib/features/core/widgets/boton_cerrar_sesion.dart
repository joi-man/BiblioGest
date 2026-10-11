import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';

/// Botón que cierra la sesión y vuelve a la pantalla de acceso.
class BotonCerrarSesion extends ConsumerWidget {
  const BotonCerrarSesion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Cerrar sesión',
      icon: const Icon(Icons.logout),
      onPressed: () {
        ref.read(authProvider.notifier).logout();
        context.go('/login');
      },
    );
  }
}
