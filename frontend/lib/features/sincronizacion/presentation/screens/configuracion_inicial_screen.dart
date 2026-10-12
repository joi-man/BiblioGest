import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/local/modo_local.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/auth/presentation/widgets/panel_autenticacion.dart';
import 'package:frontend/features/core/widgets/alertas.dart';
import 'package:frontend/features/sincronizacion/presentation/widgets/formulario_administrador_local.dart';
import 'package:frontend/features/sincronizacion/presentation/widgets/formulario_servidor.dart';

enum _Paso { elegir, soloLocal, conServidor }

/// Primera pantalla de un equipo recién instalado: usarlo solo o unirlo a un servidor.
class ConfiguracionInicialScreen extends StatefulWidget {
  const ConfiguracionInicialScreen({super.key});

  @override
  State<ConfiguracionInicialScreen> createState() =>
      _ConfiguracionInicialScreenState();
}

class _ConfiguracionInicialScreenState
    extends State<ConfiguracionInicialScreen> {
  _Paso _paso = _Paso.elegir;

  /// El equipo quedó listo: se pasa al inicio de sesión.
  void _terminar(String mensaje) {
    modoLocalNotifier.configuracionTerminada();
    context.mostrarExito(mensaje);
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return switch (_paso) {
      _Paso.elegir => PanelAutenticacion(
        titulo: 'Configura este equipo',
        subtitulo:
            'Elige cómo se usará BiblioGest aquí. Podrás cambiarlo después.',
        hijo: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OpcionConfiguracion(
              icono: Icons.computer_outlined,
              titulo: 'Usar solo en este equipo',
              detalle:
                  'Funciona sin internet ni red. Los datos quedan en esta computadora.',
              alPulsar: () => setState(() => _paso = _Paso.soloLocal),
            ),
            const SizedBox(height: 12),
            _OpcionConfiguracion(
              icono: Icons.sync_outlined,
              titulo: 'Conectar con un servidor',
              detalle:
                  'Comparte los datos con otros equipos, en internet o en una red '
                  'local. Sigue funcionando si se corta la conexión.',
              alPulsar: () => setState(() => _paso = _Paso.conServidor),
            ),
          ],
        ),
      ),
      _Paso.soloLocal => PanelAutenticacion(
        titulo: 'Administrador de este equipo',
        subtitulo: 'Será la primera persona en iniciar sesión.',
        hijo: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormularioAdministradorLocal(
              alCrear: () => _terminar('Equipo configurado. Inicia sesión.'),
            ),
            _botonVolver(),
          ],
        ),
      ),
      _Paso.conServidor => PanelAutenticacion(
        titulo: 'Conectar con un servidor',
        subtitulo: 'Usa una cuenta del personal de la biblioteca.',
        hijo: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormularioServidor(
              alConectar: () => _terminar('Datos descargados. Inicia sesión.'),
            ),
            _botonVolver(),
          ],
        ),
      ),
    };
  }

  Widget _botonVolver() {
    return TextButton(
      onPressed: () => setState(() => _paso = _Paso.elegir),
      child: const Text('Volver'),
    );
  }
}

/// Tarjeta grande y pulsable para elegir un modo de uso.
class _OpcionConfiguracion extends StatelessWidget {
  const _OpcionConfiguracion({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.alPulsar,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icono, size: 28, color: colores.acento),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: textos.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      detalle,
                      style: textos.bodySmall?.copyWith(
                        color: colores.tintaSuave,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
