import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/features/core/widgets/boton_cambiar_contrasena.dart';
import 'package:frontend/features/core/widgets/boton_cerrar_sesion.dart';
import 'package:frontend/features/core/widgets/encabezado_pagina.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';
import 'package:frontend/features/dashboard/data/models/resumen_dashboard.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:frontend/features/dashboard/presentation/widgets/panel_estado_materiales.dart';
import 'package:frontend/features/dashboard/presentation/widgets/tarjeta_metrica.dart';

/// Pantalla de inicio del personal: qué requiere atención hoy.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenDashboardProvider);

    return Scaffold(
      body: Column(
        children: [
          EncabezadoPagina(
            titulo: 'Inicio',
            subtitulo: 'Lo que requiere atención en la biblioteca',
            acciones: [
              IconButton(
                tooltip: 'Actualizar',
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(resumenDashboardProvider),
              ),
              const BotonCambiarContrasena(),
              const BotonCerrarSesion(),
            ],
          ),
          Expanded(
            child: ValorAsincrono(
              valor: resumen,
              alReintentar: () => ref.invalidate(resumenDashboardProvider),
              construir: (datos) => datos == null
                  ? const SizedBox.shrink()
                  : _Contenido(resumen: datos),
            ),
          ),
        ],
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.resumen});

  final ResumenDashboard resumen;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final prestamos = resumen.prestamos;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Cuadricula(
            hijos: [
              TarjetaMetrica(
                titulo: 'Solicitudes por revisar',
                valor: prestamos.solicitudesPendientes,
                detalle: 'Esperan aprobación',
                color: colores.pendiente,
                alTocar: () => context.go('/loans'),
              ),
              TarjetaMetrica(
                titulo: 'Reservas por retirar',
                valor: prestamos.porRetirar,
                detalle: 'Aprobadas, sin entregar',
                color: colores.reservado,
                alTocar: () => context.go('/loans'),
              ),
              TarjetaMetrica(
                titulo: 'Préstamos vencidos',
                valor: prestamos.vencidos,
                detalle: 'Pasaron su fecha límite',
                color: colores.vencido,
                alTocar: () => context.go('/returns'),
              ),
              TarjetaMetrica(
                titulo: 'Vencen en 24 horas',
                valor: prestamos.porVencer24h,
                detalle: 'Conviene avisar a los usuarios',
                color: colores.reservado,
                alTocar: () => context.go('/returns'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Cuadricula(
            hijos: [
              TarjetaMetrica(
                titulo: 'En préstamo ahora',
                valor: prestamos.activos + prestamos.vencidos,
                color: colores.prestado,
                alTocar: () => context.go('/loans'),
              ),
              TarjetaMetrica(
                titulo: 'Entregados hoy',
                valor: prestamos.entregadosHoy,
              ),
              TarjetaMetrica(
                titulo: 'Devueltos hoy',
                valor: prestamos.devueltosHoy,
                color: colores.disponible,
              ),
            ],
          ),
          const SizedBox(height: 16),
          PanelEstadoMateriales(materiales: resumen.materiales),
        ],
      ),
    );
  }
}

/// Reparte las tarjetas en columnas iguales, bajando de fila si no caben.
class _Cuadricula extends StatelessWidget {
  const _Cuadricula({required this.hijos});

  final List<Widget> hijos;

  /// Ancho mínimo de cada tarjeta.
  static const double _anchoMinimo = 220;
  static const double _separacion = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final columnas =
            ((restricciones.maxWidth + _separacion) /
                    (_anchoMinimo + _separacion))
                .floor()
                .clamp(1, hijos.length);
        final ancho =
            (restricciones.maxWidth - _separacion * (columnas - 1)) / columnas;

        return Wrap(
          spacing: _separacion,
          runSpacing: _separacion,
          children: [
            for (final hijo in hijos) SizedBox(width: ancho, child: hijo),
          ],
        );
      },
    );
  }
}
