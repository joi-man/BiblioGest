import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_app.dart';
import 'package:frontend/core/theme/tipografia_app.dart';
import 'package:frontend/features/core/widgets/chip_estado.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_etiquetas.dart';

enum AccionMaterial { editar, eliminar }

/// Una unidad del inventario dentro del listado de materiales.
class FilaMaterial extends StatelessWidget {
  const FilaMaterial({
    super.key,
    required this.material,
    required this.alElegirAccion,
  });

  final MaterialBiblioteca material;
  final ValueChanged<AccionMaterial> alElegirAccion;

  /// Línea secundaria: autor para libros, marca y modelo para equipos.
  String get _detalle {
    final partes = <String?>[
      if (material.esBibliografico) material.autor,
      if (material.esEquipo) ...[material.marca, material.modelo],
      if (material.esMedio) material.formato,
      material.tipoMaterial.etiqueta,
      material.ubicacion,
    ];
    return partes.where((p) => p != null && p.isNotEmpty).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final textos = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colores.acentoSuave,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(material.tipoMaterial.icono, color: colores.acento, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material.titulo, style: textos.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(_detalle, style: textos.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  material.codigo,
                  style: TipografiaApp.codigo(colores.tintaSuave, tamano: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!material.esPrestable)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Tooltip(
                message: 'Solo consulta en sala',
                child: Icon(Icons.lock_outline, size: 18, color: colores.tintaSuave),
              ),
            ),
          ChipEstado(estado: material.estado.valor),
          PopupMenuButton<AccionMaterial>(
            tooltip: 'Más acciones',
            onSelected: alElegirAccion,
            itemBuilder: (_) => const [
              PopupMenuItem(value: AccionMaterial.editar, child: Text('Editar')),
              PopupMenuItem(value: AccionMaterial.eliminar, child: Text('Eliminar')),
            ],
          ),
        ],
      ),
    );
  }
}
