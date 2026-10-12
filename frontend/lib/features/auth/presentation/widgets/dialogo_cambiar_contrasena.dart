import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';

/// Pide la contraseña actual y la nueva, y cambia la contraseña de la sesión.
///
/// Sirve en todas las plataformas y para todos los roles. Si el servidor dice
/// que la contraseña actual no coincide, el aviso lo explica y el diálogo sigue abierto.
Future<void> cambiarContrasena(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _DialogoCambiarContrasena(),
  );
}

class _DialogoCambiarContrasena extends ConsumerStatefulWidget {
  const _DialogoCambiarContrasena();

  @override
  ConsumerState<_DialogoCambiarContrasena> createState() => _DialogoCambiarContrasenaState();
}

class _DialogoCambiarContrasenaState extends ConsumerState<_DialogoCambiarContrasena> {
  final _formKey = GlobalKey<FormState>();
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmacion = TextEditingController();
  bool _ocultar = true;
  bool _guardando = false;

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final cambiada = await ejecutarAccion(
      context,
      () => ref.read(authRepositoryProvider).cambiarContrasena(
            contrasenaActual: _actual.text,
            nuevaContrasena: _nueva.text,
          ),
      exito: 'Contraseña actualizada',
    );

    if (!mounted) return;
    if (cambiada) {
      Navigator.pop(context);
    } else {
      setState(() => _guardando = false);
    }
  }

  InputDecoration _decoracion(String etiqueta, {Widget? sufijo}) => InputDecoration(
        labelText: etiqueta,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: sufijo,
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar contraseña'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _actual,
                  obscureText: _ocultar,
                  autofocus: true,
                  decoration: _decoracion(
                    'Contraseña actual',
                    sufijo: IconButton(
                      tooltip: _ocultar ? 'Mostrar contraseñas' : 'Ocultar contraseñas',
                      icon: Icon(_ocultar
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _ocultar = !_ocultar),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Escribe tu contraseña actual' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nueva,
                  obscureText: _ocultar,
                  decoration: _decoracion('Contraseña nueva'),
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Debe tener al menos 6 caracteres';
                    if (v == _actual.text) return 'Debe ser distinta de la actual';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmacion,
                  obscureText: _ocultar,
                  onFieldSubmitted: (_) => _guardar(),
                  decoration: _decoracion('Repite la contraseña nueva'),
                  validator: (v) => v != _nueva.text ? 'Las contraseñas no coinciden' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Cambiar contraseña'),
        ),
      ],
    );
  }
}
