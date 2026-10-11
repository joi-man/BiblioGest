import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/modo_tema_provider.dart';

/// Botón que alterna entre modo claro y oscuro.
class BotonModoTema extends ConsumerWidget {
  const BotonModoTema({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esOscuro = ref.watch(modoTemaProvider) == ThemeMode.dark;

    return IconButton(
      tooltip: esOscuro ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
      icon: Icon(esOscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => ref.read(modoTemaProvider.notifier).alternar(),
    );
  }
}
