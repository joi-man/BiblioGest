import 'package:flutter/material.dart';
import 'package:frontend/features/core/widgets/chip_estado.dart';
import 'package:frontend/features/materials/data/models/material.dart';

/// Cómo se le cuenta al estudiante la situación de un material.
///
/// - Disponible: se puede solicitar.
/// - Reservado: ya se le aprobó a otra persona y espera a que lo retire.
/// - En uso: lo tiene alguien (esté o no vencido: eso no le incumbe al estudiante).
/// - Fuera de servicio: no se presta por ahora.
extension EstadoMaterialParaEstudiante on EstadoMaterial {
  /// Estado que decide el color (el del backend, salvo que "vencido" se ve como "en uso").
  String get valorVisible => switch (this) {
        EstadoMaterial.vencido => 'prestado',
        EstadoMaterial.disponible => 'disponible',
        EstadoMaterial.reservado => 'reservado',
        EstadoMaterial.prestado => 'prestado',
        EstadoMaterial.fueraDeServicio => 'fuera_de_servicio',
      };

  String get etiquetaEstudiante => switch (this) {
        EstadoMaterial.disponible => 'Disponible',
        EstadoMaterial.reservado => 'Reservado',
        EstadoMaterial.prestado || EstadoMaterial.vencido => 'En uso',
        EstadoMaterial.fueraDeServicio => 'Fuera de servicio',
      };

  /// Frase que explica por qué no se puede solicitar, o `null` si sí se puede.
  String? get explicacionEstudiante => switch (this) {
        EstadoMaterial.disponible => null,
        EstadoMaterial.reservado =>
          'Otra persona lo tiene reservado y aún no lo retira. Si no lo retira a '
              'tiempo, volverá a estar disponible.',
        EstadoMaterial.prestado || EstadoMaterial.vencido =>
          'Ahora mismo lo tiene otra persona en préstamo.',
        EstadoMaterial.fueraDeServicio => 'Por ahora no se presta.',
      };
}

/// Etiqueta de estado de un material, con los textos pensados para el estudiante.
class ChipEstadoEstudiante extends StatelessWidget {
  const ChipEstadoEstudiante({super.key, required this.estado});

  final EstadoMaterial estado;

  @override
  Widget build(BuildContext context) {
    return ChipEstado(estado: estado.valorVisible, etiqueta: estado.etiquetaEstudiante);
  }
}
