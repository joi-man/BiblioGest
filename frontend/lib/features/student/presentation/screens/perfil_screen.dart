import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/theme/modo_tema_provider.dart';
import 'package:frontend/core/actualizaciones/actualizaciones_provider.dart';
import 'package:frontend/features/actualizaciones/presentation/widgets/tarjeta_actualizaciones.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/presentation/widgets/dialogo_cambiar_contrasena.dart';
import 'package:frontend/features/core/widgets/boton_cerrar_sesion.dart';

/// Datos de la persona y ajustes de la aplicación (modo oscuro, contraseña,
/// actualizaciones y cerrar sesión).
class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authProvider).value?.usuario;
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;
    final esOscuro = ref.watch(modoTemaProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: const [BotonCerrarSesion()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (usuario != null) ...[
            Text('${usuario.nombre} ${usuario.apellido}', style: textos.headlineMedium),
            const SizedBox(height: 4),
            Text('@${usuario.username}', style: textos.bodyMedium),
            const SizedBox(height: 24),
            _Dato(etiqueta: 'Documento', valor: usuario.numeroDocumento),
            _Dato(etiqueta: 'Correo', valor: usuario.correoElectronico),
            if (usuario.telefono != null && usuario.telefono!.isNotEmpty)
              _Dato(etiqueta: 'Teléfono', valor: usuario.telefono!),
          ],
          Divider(height: 40, color: colores.linea),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Modo oscuro'),
            subtitle: const Text('Más cómodo con poca luz'),
            value: esOscuro,
            onChanged: (_) => ref.read(modoTemaProvider.notifier).alternar(),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.key_outlined),
            title: const Text('Cambiar contraseña'),
            onTap: () => cambiarContrasena(context),
          ),
          if (ref.watch(actualizacionesHabilitadasProvider)) ...[
            Divider(height: 40, color: colores.linea),
            const TarjetaActualizaciones(),
          ],
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(etiqueta, style: textos.labelMedium)),
          Expanded(child: Text(valor, style: textos.bodyMedium)),
        ],
      ),
    );
  }
}
