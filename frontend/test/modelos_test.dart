import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_etiquetas.dart';

import 'ayudas/prestamo_de_prueba.dart';

void main() {
  group('Contrato con la API de prestamos', () {
    test('interpreta una solicitud pendiente', () {
      final prestamo = prestamoDePrueba();

      expect(prestamo.estado, EstadoPrestamo.pendiente);
      expect(prestamo.usuario.nombreCompleto, 'Ana Lopez');
      expect(prestamo.detalles.single.material.titulo, 'Proyector Epson');
      expect(prestamo.itemsPendientes, hasLength(1));
    });

    test('las fechas con Z se leen como UTC', () {
      final prestamo = prestamoDePrueba();

      expect(prestamo.fechaSolicitud.isUtc, isTrue);
      expect(prestamo.fechaSolicitud, DateTime.utc(2026, 10, 10, 12));
    });

    test('un estado desconocido no rompe la app', () {
      final prestamo = prestamoDePrueba(estado: 'algo_nuevo');

      expect(prestamo.estado, EstadoPrestamo.pendiente);
    });

    test('un item vencido es el que no se devolvió y pasó su fecha', () {
      final prestamo = prestamoDePrueba(detalles: [
        jsonDetalle(
            id: 'a', titulo: 'A', codigo: 'A-1', fechaEsperada: '2026-10-10T10:00:00Z'),
        jsonDetalle(
            id: 'b',
            titulo: 'B',
            codigo: 'B-1',
            devuelto: true,
            fechaEsperada: '2026-10-10T10:00:00Z'),
      ]);
      final ahora = DateTime.utc(2026, 10, 10, 12);

      expect(prestamo.detalles[0].estaVencido(ahora: ahora), isTrue);
      expect(prestamo.detalles[1].estaVencido(ahora: ahora), isFalse);
      expect(prestamo.itemsPendientes, hasLength(1));
    });
  });

  group('Material', () {
    final base = {
      'id': 'm-1',
      'codigo': 'P-001',
      'titulo': 'Proyector',
      'tipo_material': 'proyector',
      'estado': 'fuera_de_servicio',
      'categoria_id': 'c-1',
      'marca': 'Epson',
      'condicion': 'regular',
      'es_prestable': true,
      'valor_referencial': 450,
    };

    test('lee los campos de equipo y el estado con guion bajo', () {
      final material = MaterialBiblioteca.fromJson(base);

      expect(material.estado, EstadoMaterial.fueraDeServicio);
      expect(material.esEquipo, isTrue);
      expect(material.marca, 'Epson');
      expect(material.condicion, CondicionMaterial.regular);
      expect(material.valorReferencial, 450.0);
    });

    test('el valor del estado para el backend usa guion bajo', () {
      expect(EstadoMaterial.fueraDeServicio.valor, 'fuera_de_servicio');
      expect(EstadoMaterial.disponible.valor, 'disponible');
    });

    test('solo se puede solicitar lo prestable y disponible', () {
      final disponible = MaterialBiblioteca.fromJson({...base, 'estado': 'disponible'});
      final soloSala = MaterialBiblioteca.fromJson(
          {...base, 'estado': 'disponible', 'es_prestable': false});
      final prestado = MaterialBiblioteca.fromJson({...base, 'estado': 'prestado'});

      expect(disponible.sePuedeSolicitar, isTrue);
      expect(soloSala.sePuedeSolicitar, isFalse);
      expect(prestado.sePuedeSolicitar, isFalse);
    });
  });

  group('FormatoFecha.tiempoRestante', () {
    final ahora = DateTime(2026, 10, 10, 12);

    test('dentro de plazo', () {
      expect(FormatoFecha.tiempoRestante(ahora.add(const Duration(hours: 3)), ahora: ahora),
          'Vence en 3 h');
      expect(FormatoFecha.tiempoRestante(ahora.add(const Duration(minutes: 25)), ahora: ahora),
          'Vence en 25 min');
    });

    test('vencido', () {
      expect(FormatoFecha.tiempoRestante(ahora.subtract(const Duration(days: 2)), ahora: ahora),
          'Vencido hace 2 días');
      expect(FormatoFecha.tiempoRestante(ahora.subtract(const Duration(hours: 1)), ahora: ahora),
          'Vencido hace 1 h');
    });
  });
}
