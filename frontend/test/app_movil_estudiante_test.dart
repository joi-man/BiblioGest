import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/estado_conexion.dart';
import 'package:frontend/core/theme/modo_tema_provider.dart';
import 'package:frontend/core/theme/tema_app.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/repositories/material_repository.dart';
import 'package:frontend/features/materials/presentation/providers/materiales_provider.dart';
import 'package:frontend/features/student/data/catalogo_cache.dart';
import 'package:frontend/features/student/presentation/providers/catalogo_provider.dart';
import 'package:frontend/features/student/presentation/providers/novedades_solicitudes.dart';
import 'package:frontend/features/student/presentation/widgets/aviso_conexion.dart';
import 'package:frontend/features/student/presentation/widgets/chip_estado_estudiante.dart';
import 'package:frontend/features/student/presentation/widgets/tarjeta_catalogo.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ayudas/prestamo_de_prueba.dart';

Map<String, dynamic> _jsonMaterial(
  String codigo, {
  String titulo = 'Libro',
  String tipo = 'libro',
  String estado = 'disponible',
  String? autor,
}) =>
    {
      'id': 'm-$codigo',
      'codigo': codigo,
      'titulo': titulo,
      'tipo_material': tipo,
      'estado': estado,
      'categoria_id': 'c-1',
      'autor': autor,
    };

MaterialBiblioteca _material(String codigo, {String titulo = 'Libro', String estado = 'disponible', String? autor}) =>
    MaterialBiblioteca.fromJson(_jsonMaterial(codigo, titulo: titulo, estado: estado, autor: autor));

/// Servidor falso del catálogo: responde la lista o simula que no hay red.
class _ServidorCatalogo implements HttpClientAdapter {
  List<Map<String, dynamic>> catalogo = [];
  bool sinRed = false;
  int peticiones = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? s, Future<void>? c) async {
    peticiones++;
    if (sinRed) {
      throw DioException(requestOptions: options, type: DioExceptionType.connectionError);
    }
    return ResponseBody.fromString(
      jsonEncode(catalogo),
      200,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  group('Estado del material que ve el estudiante', () {
    test('un material en préstamo o vencido se muestra como "En uso"', () {
      expect(EstadoMaterial.prestado.etiquetaEstudiante, 'En uso');
      expect(EstadoMaterial.vencido.etiquetaEstudiante, 'En uso');
    });

    test('cada estado tiene su etiqueta y solo "disponible" se puede solicitar', () {
      expect(EstadoMaterial.disponible.etiquetaEstudiante, 'Disponible');
      expect(EstadoMaterial.reservado.etiquetaEstudiante, 'Reservado');
      expect(EstadoMaterial.fueraDeServicio.etiquetaEstudiante, 'Fuera de servicio');
      expect(EstadoMaterial.disponible.explicacionEstudiante, isNull);
      expect(EstadoMaterial.reservado.explicacionEstudiante, contains('reservado'));
      expect(EstadoMaterial.prestado.explicacionEstudiante, isNotNull);
    });

    testWidgets('la tarjeta del catálogo muestra el estado y el botón de reservar solo si está disponible',
        (tester) async {
      Widget tarjeta(MaterialBiblioteca m) => MaterialApp(
            theme: TemaApp.claro,
            home: Scaffold(
              body: TarjetaCatalogo(
                material: m,
                seleccionado: false,
                alTocar: () {},
                alAlternarSeleccion: () {},
              ),
            ),
          );

      await tester.pumpWidget(tarjeta(_material('L-1', estado: 'disponible')));
      expect(find.text('Disponible'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.pumpWidget(tarjeta(_material('L-1', estado: 'reservado')));
      expect(find.text('Reservado'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);

      await tester.pumpWidget(tarjeta(_material('L-1', estado: 'vencido')));
      expect(find.text('En uso'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
    });
  });

  group('Avisos sobre las reservas', () {
    test('avisa cuando el bibliotecario aprueba una reserva pendiente', () {
      final antes = [prestamoDePrueba(estado: 'pendiente')];
      final ahora = [prestamoDePrueba(estado: 'aprobado')];

      expect(novedadesDeSolicitudes(antes, ahora), ['Tu reserva de «Proyector Epson» fue aprobada. Pasa a retirarla.']);
    });

    test('avisa el rechazo con su motivo', () {
      final antes = [prestamoDePrueba(estado: 'pendiente')];
      final ahora = [prestamoDePrueba(estado: 'rechazado', motivoRechazo: 'Tienes un libro vencido')];

      expect(
        novedadesDeSolicitudes(antes, ahora),
        ['Tu reserva de «Proyector Epson» fue rechazada: Tienes un libro vencido'],
      );
    });

    test('avisa cuando la biblioteca cancela una reserva aprobada (cesión) con el motivo', () {
      final antes = [prestamoDePrueba(estado: 'aprobado')];
      final ahora = [prestamoDePrueba(estado: 'cancelado', motivoRechazo: 'Lo necesita un docente')];

      expect(
        novedadesDeSolicitudes(antes, ahora),
        ['Tu reserva de «Proyector Epson» fue cancelada: Lo necesita un docente'],
      );
    });

    test('no avisa de lo que ya estaba, de reservas nuevas ni de cancelaciones propias', () {
      final antes = [prestamoDePrueba(id: 'p-1', estado: 'aprobado')];
      final ahora = [
        prestamoDePrueba(id: 'p-1', estado: 'aprobado'),
        prestamoDePrueba(id: 'p-2', estado: 'pendiente'),
      ];
      expect(novedadesDeSolicitudes(antes, ahora), isEmpty);

      // El estudiante cancela por su cuenta: no hay motivo, no hay aviso.
      expect(
        novedadesDeSolicitudes(
          [prestamoDePrueba(estado: 'pendiente')],
          [prestamoDePrueba(estado: 'cancelado')],
        ),
        isEmpty,
      );
    });
  });

  group('Catálogo guardado para consultar sin conexión', () {
    late SharedPreferences preferencias;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferencias = await SharedPreferences.getInstance();
      estadoConexion.conectado();
    });

    test('guarda y recupera el catálogo con su fecha', () async {
      final cache = CatalogoCache(preferencias);
      expect(cache.leer(), isNull);

      await cache.guardar([_material('L-1', titulo: 'Rayuela')], ahora: DateTime.utc(2026, 10, 12, 15));

      final guardado = cache.leer()!;
      expect(guardado.materiales.single.titulo, 'Rayuela');
      expect(guardado.fecha, DateTime.utc(2026, 10, 12, 15));
    });

    test('una copia dañada se ignora en vez de romper la app', () async {
      await preferencias.setString('catalogo_cache_materiales', '{no es json');
      await preferencias.setString('catalogo_cache_fecha', DateTime.now().toIso8601String());

      expect(CatalogoCache(preferencias).leer(), isNull);
    });

    test('filtra la copia como lo haría el servidor (texto sin tildes, tipo, disponibles)', () {
      final lista = [
        _material('L-1', titulo: 'Cien años de soledad', autor: 'García Márquez'),
        _material('L-2', titulo: 'El Aleph', estado: 'prestado', autor: 'Borges'),
      ];
      FiltroMateriales filtro({String texto = '', bool soloDisponibles = false}) =>
          (texto: texto, tipo: null, estado: null, soloDisponibles: soloDisponibles);

      expect(filtrarMateriales(lista, filtro(texto: 'garcia')).map((m) => m.codigo), ['L-1']);
      expect(filtrarMateriales(lista, filtro(texto: 'L-2')).map((m) => m.codigo), ['L-2']);
      expect(filtrarMateriales(lista, filtro(soloDisponibles: true)).map((m) => m.codigo), ['L-1']);
      expect(filtrarMateriales(lista, filtro()), hasLength(2));
    });

    ProviderContainer montar(_ServidorCatalogo servidor) {
      final dio = Dio(BaseOptions(baseUrl: 'http://prueba.test'))..httpClientAdapter = servidor;
      final contenedor = ProviderContainer(overrides: [
        preferenciasProvider.overrideWithValue(preferencias),
        tokenSesionProvider.overrideWithValue('token'),
        materialRepositoryProvider.overrideWithValue(MaterialRepository(dio)),
      ]);
      addTearDown(contenedor.dispose);
      return contenedor;
    }

    test('con conexión muestra el catálogo del servidor y lo guarda', () async {
      final servidor = _ServidorCatalogo()..catalogo = [_jsonMaterial('L-1', titulo: 'Rayuela')];
      final contenedor = montar(servidor);

      final resultado = await contenedor.read(catalogoEstudianteProvider(filtroMaterialesVacio).future);

      expect(resultado.desdeCache, isFalse);
      expect(resultado.materiales.single.titulo, 'Rayuela');
      expect(CatalogoCache(preferencias).leer()!.materiales.single.titulo, 'Rayuela');
    });

    test('sin conexión y con copia: muestra la copia al instante y deja que se reconecte', () async {
      await CatalogoCache(preferencias).guardar([_material('L-1', titulo: 'Rayuela')]);
      final servidor = _ServidorCatalogo()..sinRed = true;
      final contenedor = montar(servidor);

      final resultado = await contenedor.read(catalogoEstudianteProvider(filtroMaterialesVacio).future);

      expect(resultado.desdeCache, isTrue);
      expect(resultado.materiales.single.titulo, 'Rayuela');
      expect(servidor.peticiones, 1); // no esperó reintentos
      expect(estadoConexion.fase, FaseConexion.reconectando);
    });

    test('sin conexión y sin copia: el error llega a la pantalla para que ofrezca reintentar', () async {
      final servidor = _ServidorCatalogo()..sinRed = true;
      final contenedor = montar(servidor);

      await expectLater(
        contenedor.read(catalogoEstudianteProvider(filtroMaterialesVacio).future),
        throwsA(isA<DioException>()),
      );
    });

    test('una búsqueda filtrada no pisa la copia completa', () async {
      await CatalogoCache(preferencias).guardar([_material('L-1'), _material('L-2')]);
      final servidor = _ServidorCatalogo()..catalogo = [_jsonMaterial('L-1')];
      final contenedor = montar(servidor);

      const filtro = (texto: 'x', tipo: null, estado: null, soloDisponibles: false);
      await contenedor.read(catalogoEstudianteProvider(filtro).future);

      expect(CatalogoCache(preferencias).leer()!.materiales, hasLength(2));
    });
  });

  group('AvisoConexion', () {
    Widget app() => ProviderScope(
          child: MaterialApp(theme: TemaApp.claro, home: const Scaffold(body: AvisoConexion())),
        );

    setUp(() => estadoConexion.conectado());

    testWidgets('no se ve cuando hay conexión', (tester) async {
      await tester.pumpWidget(app());

      expect(find.textContaining('conexión'), findsNothing);
    });

    testWidgets('mientras reconecta informa el intento, sin alarmar', (tester) async {
      await tester.pumpWidget(app());

      estadoConexion.reconectando(2, 5);
      await tester.pump();

      expect(find.textContaining('Reconectando'), findsOneWidget);
      expect(find.textContaining('intento 2 de 5'), findsOneWidget);
      expect(find.text('Reintentar ahora'), findsNothing);
    });

    testWidgets('tras varios intentos avisa a la persona y ofrece reintentar', (tester) async {
      await tester.pumpWidget(app());

      estadoConexion.sinConexion();
      await tester.pump();

      expect(find.textContaining('No pudimos conectar'), findsOneWidget);
      expect(find.text('Reintentar ahora'), findsOneWidget);

      estadoConexion.conectado();
      await tester.pump();
      expect(find.textContaining('No pudimos conectar'), findsNothing);
    });
  });
}
