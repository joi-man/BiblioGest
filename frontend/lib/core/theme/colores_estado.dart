import 'package:flutter/material.dart';
import 'colores_app.dart';

/// Traduce el estado de un material o préstamo (texto del backend) a su color.
///
/// Centraliza la decisión para que "vencido" se vea igual en toda la app.
class ColoresEstado {
  ColoresEstado._();

  /// Devuelve el color de [estado] según la paleta [c].
  static Color de(ColoresApp c, String estado) {
    switch (estado) {
      case 'disponible':
      case 'devuelto':
        return c.disponible;
      case 'prestado':
      case 'activo':
      case 'aprobado':
        return c.prestado;
      case 'reservado':
        return c.reservado;
      case 'pendiente':
        return c.pendiente;
      case 'vencido':
      case 'rechazado':
        return c.vencido;
      case 'fuera_de_servicio':
      case 'cancelado':
      default:
        return c.fueraDeServicio;
    }
  }

  /// Texto legible en español para mostrar en pantalla.
  static String etiqueta(String estado) {
    switch (estado) {
      case 'fuera_de_servicio':
        return 'Fuera de servicio';
      case 'disponible':
        return 'Disponible';
      case 'prestado':
        return 'Prestado';
      case 'reservado':
        return 'Reservado';
      case 'pendiente':
        return 'Pendiente';
      case 'aprobado':
        return 'Por retirar';
      case 'activo':
        return 'En préstamo';
      case 'vencido':
        return 'Vencido';
      case 'devuelto':
        return 'Devuelto';
      case 'rechazado':
        return 'Rechazado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado;
    }
  }
}
