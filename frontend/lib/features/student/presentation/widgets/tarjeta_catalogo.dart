import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/theme/tipografia_app.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_etiquetas.dart';
import 'package:frontend/features/materials/data/models/material_presentacion.dart';
import 'package:frontend/features/student/presentation/widgets/chip_estado_estudiante.dart';

/// Un material del catálogo, tal como lo ve el estudiante.
class TarjetaCatalogo extends StatelessWidget {
  const TarjetaCatalogo({
    super.key,
    required this.material,
    required this.seleccionado,
    required this.alTocar,
    required this.alAlternarSeleccion,
  });

  final MaterialBiblioteca material;
  final bool seleccionado;

  /// Abre el detalle del material.
  final VoidCallback alTocar;

  /// Agrega o quita el material de la lista de lo que se va a solicitar.
  final VoidCallback alAlternarSeleccion;

  String get _detalle {
    final partes = <String?>[
      if (material.esBibliografico) ...[
        material.autoresTexto,
        material.etiquetaTomo,
      ],
      if (material.esEquipo) ...[material.marca, material.modelo],
      material.tipoMaterial.etiqueta,
      material.ubicacion,
    ];
    return partes.where((p) => p != null && p.isNotEmpty).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: seleccionado ? colores.acento : colores.linea,
          width: seleccionado ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colores.acentoSuave,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(material.tipoMaterial.icono, color: colores.acento),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.titulo,
                      style: textos.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _detalle,
                      style: textos.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Wrap: en pantallas angostas el código baja a la línea siguiente
                    // en lugar de desbordar la tarjeta.
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ChipEstadoEstudiante(estado: material.estado),
                        if (material.esPrestable &&
                            material.ejemplaresLibres > 0 &&
                            material.cantidadTotal > 1)
                          Text(
                            material.ejemplaresDisponibles,
                            style: textos.labelMedium,
                          ),
                        Text(
                          material.codigo,
                          style: TipografiaApp.codigo(
                            colores.tintaSuave,
                            tamano: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (material.sePuedeSolicitar)
                IconButton.filledTonal(
                  tooltip: seleccionado
                      ? 'Quitar de la solicitud'
                      : 'Agregar a la solicitud',
                  onPressed: alAlternarSeleccion,
                  icon: Icon(seleccionado ? Icons.check : Icons.add),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
