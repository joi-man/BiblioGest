import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/widgets/dialogo_cambiar_contrasena.dart';

/// Botón que abre el cambio de contraseña de quien tiene la sesión iniciada.
class BotonCambiarContrasena extends StatelessWidget {
  const BotonCambiarContrasena({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Cambiar contraseña',
      icon: const Icon(Icons.key_outlined),
      onPressed: () => cambiarContrasena(context),
    );
  }
}
