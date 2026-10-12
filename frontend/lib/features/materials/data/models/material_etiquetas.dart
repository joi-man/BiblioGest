import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colores_estado.dart';
import 'material.dart';

/// Textos en español e iconos de los enums de material.
extension TipoMaterialEtiqueta on TipoMaterial {
  /// Valor que entiende el backend.
  String get valor => name;

  String get etiqueta => switch (this) {
    TipoMaterial.libro => 'Libro',
    TipoMaterial.revista => 'Revista',
    TipoMaterial.dvd => 'DVD',
    TipoMaterial.cd => 'CD',
    TipoMaterial.proyector => 'Proyector',
    TipoMaterial.alargador => 'Alargador',
    TipoMaterial.laptop => 'Laptop',
    TipoMaterial.tablet => 'Tablet',
    TipoMaterial.parlante => 'Parlante',
    TipoMaterial.microfono => 'Micrófono',
    TipoMaterial.camara => 'Cámara',
    TipoMaterial.adaptador => 'Adaptador',
    TipoMaterial.otro => 'Otro',
  };

  IconData get icono => switch (this) {
    TipoMaterial.libro => Icons.menu_book_outlined,
    TipoMaterial.revista => Icons.newspaper_outlined,
    TipoMaterial.dvd || TipoMaterial.cd => Icons.album_outlined,
    TipoMaterial.proyector => Icons.videocam_outlined,
    TipoMaterial.alargador => Icons.electrical_services_outlined,
    TipoMaterial.laptop => Icons.laptop_outlined,
    TipoMaterial.tablet => Icons.tablet_android_outlined,
    TipoMaterial.parlante => Icons.speaker_outlined,
    TipoMaterial.microfono => Icons.mic_none_outlined,
    TipoMaterial.camara => Icons.photo_camera_outlined,
    TipoMaterial.adaptador => Icons.cable_outlined,
    TipoMaterial.otro => Icons.inventory_2_outlined,
  };
}

extension EstadoMaterialEtiqueta on EstadoMaterial {
  /// Valor que entiende el backend (`fuera_de_servicio`, no `fueraDeServicio`).
  String get valor =>
      this == EstadoMaterial.fueraDeServicio ? 'fuera_de_servicio' : name;

  String get etiqueta => ColoresEstado.etiqueta(valor);
}

extension CondicionMaterialEtiqueta on CondicionMaterial {
  String get valor => name;

  String get etiqueta => switch (this) {
    CondicionMaterial.nuevo => 'Nuevo',
    CondicionMaterial.bueno => 'Bueno',
    CondicionMaterial.regular => 'Regular',
    CondicionMaterial.malo => 'Malo',
  };
}
