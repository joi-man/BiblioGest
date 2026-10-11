import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/theme/tipografia_app.dart';
import 'package:frontend/features/core/widgets/chip_estado.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_etiquetas.dart';

/// Hoja inferior con toda la información de un material y el botón para
/// agregarlo a la solicitud.
class DetalleMaterialHoja extends StatelessWidget {
  const DetalleMaterialHoja({
    super.key,
    required this.material,
    required this.seleccionado,
    required this.alAlternarSeleccion,
  });

  final MaterialBiblioteca material;
  final bool seleccionado;
  final VoidCallback alAlternarSeleccion;

  /// Pares etiqueta/valor que aplican a este material, sin los vacíos.
  List<(String, String)> get _datos {
    final datos = <(String, String?)>[
      ('Tipo', material.tipoMaterial.etiqueta),
      if (material.esBibliografico) ...[
        ('Autor', material.autor),
        ('Editorial', material.editorial),
        ('ISBN', material.isbn),
        ('Año', material.anioPublicacion?.toString()),
        ('Páginas', material.numeroPaginas?.toString()),
      ],
      if (material.esMedio) ...[
        ('Formato', material.formato),
        ('Duración', material.duracion),
      ],
      if (material.esEquipo) ...[
        ('Marca', material.marca),
        ('Modelo', material.modelo),
        ('Incluye', material.accesorios),
      ],
      ('Ubicación', material.ubicacion),
      ('Condición', material.condicion.etiqueta),
      if (material.plazoPrestamoHoras != null)
        ('Plazo de préstamo', _plazo(material.plazoPrestamoHoras!)),
    ];
    return [
      for (final (etiqueta, valor) in datos)
        if (valor != null && valor.isNotEmpty) (etiqueta, valor),
    ];
  }

  String _plazo(int horas) {
    if (horas % 24 == 0) {
      final dias = horas ~/ 24;
      return dias == 1 ? '1 día' : '$dias días';
    }
    return '$horas h';
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(material.titulo, style: textos.headlineSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                ChipEstado(estado: material.estado.valor),
                const SizedBox(width: 12),
                Text(
                  material.codigo,
                  style: TipografiaApp.codigo(colores.tintaSuave),
                ),
              ],
            ),
            if (material.descripcion != null && material.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(material.descripcion!, style: textos.bodyMedium),
            ],
            const SizedBox(height: 16),
            Divider(color: colores.linea),
            for (final (etiqueta, valor) in _datos)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(etiqueta, style: textos.labelMedium),
                    ),
                    Expanded(child: Text(valor, style: textos.bodyMedium)),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _boton(context),
          ],
        ),
      ),
    );
  }

  Widget _boton(BuildContext context) {
    if (!material.esPrestable) {
      return const _Aviso('Este material es solo para consulta en la biblioteca.');
    }
    if (!material.sePuedeSolicitar) {
      return _Aviso(
        'Ahora no está disponible (${material.estado.etiqueta.toLowerCase()}).',
      );
    }
    return FilledButton.icon(
      onPressed: () {
        alAlternarSeleccion();
        Navigator.pop(context);
      },
      icon: Icon(seleccionado ? Icons.remove : Icons.add),
      label: Text(seleccionado ? 'Quitar de mi solicitud' : 'Agregar a mi solicitud'),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: context.colores.tintaSuave),
    );
  }
}
