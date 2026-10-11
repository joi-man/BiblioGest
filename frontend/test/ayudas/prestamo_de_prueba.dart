import 'package:frontend/features/loans/data/models/prestamo.dart';

/// JSON con la forma exacta que devuelve el backend (`PrestamoRespuesta`).
Map<String, dynamic> jsonPrestamo({
  String estado = 'pendiente',
  List<Map<String, dynamic>>? detalles,
}) {
  return {
    'id': 'p-1',
    'estado': estado,
    'usuario': {
      'id': 'u-1',
      'username': 'ana',
      'nombre': 'Ana',
      'apellido': 'Lopez',
      'numero_documento': '123456',
      'correo_electronico': 'ana@prueba.com',
    },
    'detalles': detalles ??
        [
          jsonDetalle(id: 'd-1', titulo: 'Proyector Epson', codigo: 'P-001'),
        ],
    'fecha_solicitud': '2026-10-10T12:00:00Z',
    'fecha_retiro_limite': null,
    'fecha_prestamo': null,
    'fecha_devolucion_esperada': null,
    'fecha_devolucion_real': null,
    'aprobado_por': null,
    'entregado_por': null,
    'observaciones': null,
    'motivo_rechazo': null,
  };
}

Map<String, dynamic> jsonDetalle({
  required String id,
  required String titulo,
  required String codigo,
  bool devuelto = false,
  String? fechaEsperada,
}) {
  return {
    'id': id,
    'material': {
      'id': 'm-$id',
      'codigo': codigo,
      'titulo': titulo,
      'tipo_material': 'proyector',
      'estado': 'disponible',
      'ubicacion': 'Sala de equipos',
    },
    'fecha_devolucion_esperada': fechaEsperada,
    'devuelto': devuelto,
    'devolucion': null,
  };
}

Prestamo prestamoDePrueba({
  String estado = 'pendiente',
  List<Map<String, dynamic>>? detalles,
}) {
  return Prestamo.fromJson(jsonPrestamo(estado: estado, detalles: detalles));
}
