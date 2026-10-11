import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';

/// Un número destacado con su descripción. Si recibe [alTocar] funciona como
/// atajo hacia la pantalla donde se atiende ese tema.
class TarjetaMetrica extends StatelessWidget {
  const TarjetaMetrica({
    super.key,
    required this.titulo,
    required this.valor,
    this.detalle,
    this.color,
    this.alTocar,
  });

  final String titulo;
  final int valor;
  final String? detalle;

  /// Color del número; por defecto el de la tinta.
  final Color? color;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;
    // Un valor en cero no necesita llamar la atención.
    final colorNumero = valor == 0 ? colores.tintaSuave : (color ?? colores.tinta);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: textos.labelMedium),
              const SizedBox(height: 8),
              Text(
                '$valor',
                style: textos.displaySmall?.copyWith(color: colorNumero),
              ),
              if (detalle != null) ...[
                const SizedBox(height: 4),
                Text(detalle!, style: textos.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
