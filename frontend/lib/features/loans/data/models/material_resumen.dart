import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/features/materials/data/models/material.dart';

part 'material_resumen.freezed.dart';
part 'material_resumen.g.dart';

/// Datos mínimos de un material, tal como vienen dentro de un préstamo.
@freezed
class MaterialResumen with _$MaterialResumen {
  const factory MaterialResumen({
    required String id,
    required String codigo,
    required String titulo,
    @JsonKey(name: 'tipo_material', unknownEnumValue: TipoMaterial.otro)
    required TipoMaterial tipoMaterial,
    @JsonKey(unknownEnumValue: EstadoMaterial.disponible)
    required EstadoMaterial estado,
    String? ubicacion,
  }) = _MaterialResumen;

  factory MaterialResumen.fromJson(Map<String, dynamic> json) =>
      _$MaterialResumenFromJson(json);
}
