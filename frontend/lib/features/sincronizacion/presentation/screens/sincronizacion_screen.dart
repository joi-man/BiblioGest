import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/auth_state.dart';
import 'package:frontend/core/network/mensaje_error.dart';
import 'package:frontend/features/core/widgets/alertas.dart';
import 'package:frontend/features/core/widgets/confirmacion.dart';
import 'package:frontend/features/core/widgets/ejecutar_accion.dart';
import 'package:frontend/features/core/widgets/encabezado_pagina.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';
import 'package:frontend/features/sincronizacion/data/models/estado_local.dart';
import 'package:frontend/features/sincronizacion/data/repositories/local_repository.dart';
import 'package:frontend/features/sincronizacion/presentation/providers/estado_local_provider.dart';
import 'package:frontend/features/sincronizacion/presentation/widgets/formulario_servidor.dart';
import 'package:frontend/features/sincronizacion/presentation/widgets/lista_conflictos.dart';
import 'package:frontend/features/sincronizacion/presentation/widgets/tarjeta_estado_sincronizacion.dart';

/// Estado de la sincronización del equipo, conexión con el servidor y cambios por revisar.
class SincronizacionScreen extends ConsumerStatefulWidget {
  const SincronizacionScreen({super.key});

  @override
  ConsumerState<SincronizacionScreen> createState() => _SincronizacionScreenState();
}

class _SincronizacionScreenState extends ConsumerState<SincronizacionScreen> {
  bool _sincronizando = false;

  Future<void> _sincronizarAhora() async {
    setState(() => _sincronizando = true);
    try {
      final resumen = await ref.read(localRepositoryProvider).sincronizar();
      if (!mounted) return;
      context.mostrarExito(
        'Enviados: ${resumen.enviados} · Recibidos: ${resumen.recibidos}'
        '${resumen.conflictos > 0 ? ' · Por revisar: ${resumen.conflictos}' : ''}',
      );
    } catch (error) {
      if (mounted) context.mostrarError(mensajeDeError(error));
    } finally {
      ref.invalidate(estadoLocalProvider);
      ref.invalidate(conflictosProvider);
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  Future<void> _desconectar() async {
    final confirmado = await confirmarAccion(
      context,
      titulo: 'Trabajar solo en este equipo',
      mensaje: 'El equipo dejará de sincronizar con el servidor. Los cambios que '
          'aún no se enviaron se perderán para el servidor. ¿Continuar?',
      etiquetaConfirmar: 'Desconectar',
    );
    if (!confirmado || !mounted) return;

    final exito = await ejecutarAccion(
      context,
      () => ref.read(localRepositoryProvider).desconectar(),
      exito: 'El equipo trabaja ahora por su cuenta',
    );
    if (exito) ref.invalidate(estadoLocalProvider);
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(estadoLocalProvider);
    final tieneServidor = estado.valueOrNull?.tieneServidor ?? false;

    return Scaffold(
      body: Column(
        children: [
          EncabezadoPagina(
            titulo: 'Sincronización',
            subtitulo: 'Estado de este equipo y su servidor',
            acciones: [
              if (tieneServidor)
                FilledButton.icon(
                  onPressed: _sincronizando ? null : _sincronizarAhora,
                  icon: _sincronizando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: const Text('Sincronizar ahora'),
                ),
            ],
          ),
          Expanded(
            child: ValorAsincrono(
              valor: estado,
              alReintentar: () => ref.invalidate(estadoLocalProvider),
              construir: _contenido,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido(EstadoLocal estado) {
    final conflictos = ref.watch(conflictosProvider).valueOrNull ?? const [];
    final esAdmin = authStateNotifier.rol == 'admin';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TarjetaEstadoSincronizacion(estado: estado),
        if (conflictos.isNotEmpty) ...[
          const SizedBox(height: 24),
          ListaConflictos(conflictos: conflictos),
        ],
        if (esAdmin) ...[
          const SizedBox(height: 24),
          _seccionServidor(estado),
        ],
      ],
    );
  }

  /// Conectar con un servidor o dejar de usarlo (solo administradores).
  Widget _seccionServidor(EstadoLocal estado) {
    final textos = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              estado.tieneServidor ? 'Servidor' : 'Conectar con un servidor',
              style: textos.titleLarge,
            ),
            const SizedBox(height: 12),
            if (estado.tieneServidor)
              OutlinedButton.icon(
                onPressed: _desconectar,
                icon: const Icon(Icons.link_off),
                label: const Text('Trabajar solo en este equipo'),
              )
            else
              FormularioServidor(
                hayDatosLocales: true,
                alConectar: () => context
                    .mostrarExito('Conectado. Los datos del servidor se descargaron.'),
              ),
          ],
        ),
      ),
    );
  }
}
