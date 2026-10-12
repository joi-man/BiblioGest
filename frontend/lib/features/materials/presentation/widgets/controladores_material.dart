import 'package:flutter/material.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_etiquetas.dart';

/// Agrupa los controladores de texto del formulario de material y sabe armar
/// el cuerpo de la petición. Así el diálogo solo se ocupa de dibujar.
class ControladoresMaterial {
  ControladoresMaterial([MaterialBiblioteca? material])
    : codigo = TextEditingController(text: material?.codigo),
      titulo = TextEditingController(text: material?.titulo),
      autor = TextEditingController(text: material?.autor),
      isbn = TextEditingController(text: material?.isbn),
      editorial = TextEditingController(text: material?.editorial),
      anio = TextEditingController(text: material?.anioPublicacion?.toString()),
      paginas = TextEditingController(
        text: material?.numeroPaginas?.toString(),
      ),
      descripcion = TextEditingController(text: material?.descripcion),
      formato = TextEditingController(text: material?.formato),
      duracion = TextEditingController(text: material?.duracion),
      marca = TextEditingController(text: material?.marca),
      modelo = TextEditingController(text: material?.modelo),
      numeroSerie = TextEditingController(text: material?.numeroSerie),
      ubicacion = TextEditingController(text: material?.ubicacion),
      accesorios = TextEditingController(text: material?.accesorios),
      valor = TextEditingController(
        text: material?.valorReferencial?.toString(),
      ),
      plazoHoras = TextEditingController(
        text: material?.plazoPrestamoHoras?.toString(),
      );

  final TextEditingController codigo;
  final TextEditingController titulo;
  final TextEditingController autor;
  final TextEditingController isbn;
  final TextEditingController editorial;
  final TextEditingController anio;
  final TextEditingController paginas;
  final TextEditingController descripcion;
  final TextEditingController formato;
  final TextEditingController duracion;
  final TextEditingController marca;
  final TextEditingController modelo;
  final TextEditingController numeroSerie;
  final TextEditingController ubicacion;
  final TextEditingController accesorios;
  final TextEditingController valor;
  final TextEditingController plazoHoras;

  void dispose() {
    for (final c in [
      codigo,
      titulo,
      autor,
      isbn,
      editorial,
      anio,
      paginas,
      descripcion,
      formato,
      duracion,
      marca,
      modelo,
      numeroSerie,
      ubicacion,
      accesorios,
      valor,
      plazoHoras,
    ]) {
      c.dispose();
    }
  }

  /// Cuerpo de la petición para crear o actualizar.
  ///
  /// Los campos que no corresponden al [tipo] elegido (por ejemplo "autor"
  /// en un proyector) se envían vacíos para que no queden datos viejos.
  /// El código solo se envía al crear: no se puede cambiar después.
  Map<String, dynamic> aPeticion({
    required TipoMaterial tipo,
    required String categoriaId,
    required CondicionMaterial condicion,
    required bool esPrestable,
    required bool esNuevo,
  }) {
    final bibliografico =
        tipo == TipoMaterial.libro || tipo == TipoMaterial.revista;
    final medio = tipo == TipoMaterial.dvd || tipo == TipoMaterial.cd;
    final equipo = !bibliografico && !medio;

    return {
      if (esNuevo) 'codigo': codigo.text.trim(),
      'titulo': titulo.text.trim(),
      'tipo_material': tipo.valor,
      'categoria_id': categoriaId,
      'condicion': condicion.valor,
      'es_prestable': esPrestable,
      'descripcion': _texto(descripcion),
      'ubicacion': _texto(ubicacion),
      'valor_referencial': _decimal(valor),
      'plazo_prestamo_horas': _entero(plazoHoras),
      'autor': bibliografico ? _texto(autor) : null,
      'isbn': bibliografico ? _texto(isbn) : null,
      'editorial': bibliografico ? _texto(editorial) : null,
      'anio_publicacion': bibliografico ? _entero(anio) : null,
      'numero_paginas': bibliografico ? _entero(paginas) : null,
      'formato': medio ? _texto(formato) : null,
      'duracion': medio ? _texto(duracion) : null,
      'marca': equipo ? _texto(marca) : null,
      'modelo': equipo ? _texto(modelo) : null,
      'numero_serie': equipo ? _texto(numeroSerie) : null,
      'accesorios': equipo ? _texto(accesorios) : null,
    };
  }

  String? _texto(TextEditingController c) {
    final texto = c.text.trim();
    return texto.isEmpty ? null : texto;
  }

  int? _entero(TextEditingController c) => int.tryParse(c.text.trim());

  double? _decimal(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));
}
