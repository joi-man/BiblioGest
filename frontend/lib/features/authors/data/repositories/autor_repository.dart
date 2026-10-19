import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
import 'package:frontend/core/network/dio_client.dart';
import '../models/autor.dart';

final autorRepositoryProvider = Provider<AutorRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AutorRepository(dioClient.dio);
});

/// Acceso a la API de autores. El token lo agrega el cliente HTTP.
class AutorRepository {
  AutorRepository(this._dio);

  final Dio _dio;

  /// Autores cuyo nombre contiene [texto] (sin importar tildes), para elegirlos al cargar un material.
  Future<List<Autor>> listar({String texto = '', int limite = 20}) async {
    final respuesta = await _dio.get(
      '/api/autores/',
      queryParameters: {
        if (texto.trim().isNotEmpty) 'q': texto.trim(),
        'limite': limite,
      },
    );
    return (respuesta.data as List)
        .map((json) => Autor.fromJson(json))
        .toList();
  }

  /// Una página de autores con búsqueda por nombre.
  Future<PaginaResultado<Autor>> buscar({
    String texto = '',
    int pagina = 1,
    int tamano = 10,
  }) async {
    final respuesta = await _dio.get(
      '/api/autores/buscar',
      queryParameters: {
        if (texto.trim().isNotEmpty) 'q': texto.trim(),
        'pagina': pagina,
        'tamano': tamano,
      },
    );
    return PaginaResultado.desdeJson(respuesta.data, Autor.fromJson);
  }

  Future<Autor> crear(String nombre) async {
    final respuesta = await _dio.post(
      '/api/autores/',
      data: {'nombre': nombre},
    );
    return Autor.fromJson(respuesta.data);
  }

  Future<Autor> actualizar(String id, String nombre) async {
    final respuesta = await _dio.put(
      '/api/autores/$id',
      data: {'nombre': nombre},
    );
    return Autor.fromJson(respuesta.data);
  }

  Future<void> eliminar(String id) async {
    await _dio.delete('/api/autores/$id');
  }
}
