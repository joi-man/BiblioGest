import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/core/widgets/barra_busqueda.dart';
import 'package:frontend/features/core/widgets/encabezado_pagina.dart';
import 'package:frontend/features/core/widgets/estado_vacio.dart';
import 'package:frontend/features/core/widgets/valor_asincrono.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'package:frontend/features/loans/presentation/widgets/tarjeta_prestamo.dart';
import 'package:frontend/features/returns/presentation/providers/devoluciones_provider.dart';
import 'package:frontend/features/returns/presentation/widgets/dialogo_devolver.dart';

/// Recepción de materiales: lista lo que está en manos de los usuarios y
/// permite registrar la devolución. Solo la usa el personal.
class DevolucionesScreen extends ConsumerStatefulWidget {
  const DevolucionesScreen({super.key, this.textoInicial = ''});

  /// Búsqueda con la que se abre la pantalla (por ejemplo, el documento de
  /// quien llega a devolver, enviado desde la pantalla de préstamos).
  final String textoInicial;

  @override
  ConsumerState<DevolucionesScreen> createState() => _DevolucionesScreenState();
}

class _DevolucionesScreenState extends ConsumerState<DevolucionesScreen> {
  late String _texto = widget.textoInicial;

  void _abrirDevolucion(Prestamo prestamo) {
    showDialog(
      context: context,
      builder: (_) => DialogoDevolver(prestamo: prestamo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendientes = ref.watch(devolucionesPendientesProvider(_texto));

    return Scaffold(
      body: Column(
        children: [
          EncabezadoPagina(
            titulo: 'Devoluciones',
            subtitulo: pendientes.whenOrNull(
              data: (lista) => lista.isEmpty
                  ? 'No hay materiales pendientes de devolver'
                  : '${lista.length} préstamos con material por recibir',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: BarraBusqueda(
              // Se recrea si cambia el texto inicial, para mostrarlo en el campo.
              key: ValueKey(widget.textoInicial),
              sugerencia:
                  'Buscar por nombre, documento, usuario o código del material',
              alCambiar: (texto) => setState(() => _texto = texto),
              textoInicial: widget.textoInicial,
            ),
          ),
          Expanded(
            child: ValorAsincrono(
              valor: pendientes,
              alReintentar: () =>
                  ref.invalidate(devolucionesPendientesProvider),
              construir: _lista,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lista(List<Prestamo> prestamos) {
    if (prestamos.isEmpty) {
      return const EstadoVacio(
        titulo: 'Nada por recibir',
        detalle:
            'Aquí aparecen los préstamos entregados que aún no se devuelven.',
        icono: Icons.assignment_turned_in_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: prestamos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, indice) {
        final prestamo = prestamos[indice];
        return TarjetaPrestamo(
          prestamo: prestamo,
          botonesPersonalizados: FilledButton.icon(
            onPressed: () => _abrirDevolucion(prestamo),
            icon: const Icon(Icons.assignment_return_outlined, size: 18),
            label: const Text('Registrar devolución'),
          ),
        );
      },
    );
  }
}
