import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/tema_app.dart';
import 'package:frontend/core/utils/texto_busqueda.dart';
import 'package:frontend/features/authors/data/models/autor.dart';
import 'package:frontend/features/authors/data/repositories/autor_repository.dart';
import 'package:frontend/features/authors/presentation/providers/autores_paginados_provider.dart';
import 'package:frontend/features/authors/presentation/widgets/buscador_autores.dart';
import 'package:frontend/features/authors/presentation/widgets/selector_autores.dart';
import 'package:frontend/features/authors/presentation/widgets/seleccion_autores.dart';
import 'package:frontend/features/materials/data/models/material.dart';
import 'package:frontend/features/materials/data/models/material_presentacion.dart';
import 'package:frontend/features/materials/presentation/providers/inventario_provider.dart';
import 'package:frontend/features/materials/presentation/providers/materiales_provider.dart';
import 'package:frontend/features/materials/presentation/widgets/controladores_material.dart';
import 'package:frontend/features/student/presentation/providers/catalogo_provider.dart';

const _cervantes = Autor(id: 'a-1', nombre: 'Miguel de Cervantes');
const _garcia = Autor(id: 'a-2', nombre: 'García Márquez, Gabriel');

Map<String, dynamic> _json({Map<String, dynamic> extra = const {}}) => {
  'id': 'm-1',
  'codigo': 'L-1',
  'titulo': 'Don Quijote',
  'tipo_material': 'libro',
  'estado': 'disponible',
  'categoria_id': 'c-1',
  ...extra,
};

/// Repositorio de autores que responde con una lista fija, sin red.
class _AutoresFalsos extends AutorRepository {
  _AutoresFalsos(this.autores) : super(Dio());

  final List<Autor> autores;
  final consultas = <String>[];

  @override
  Future<List<Autor>> listar({String texto = '', int limite = 20}) async {
    consultas.add(texto);
    return [
      for (final a in autores)
        if (coincideConTodasLasPalabras(a.nombre, texto)) a,
    ];
  }
}

void main() {
  group('Material con autores, tomo y ejemplares', () {
    test('lee los campos nuevos del servidor', () {
      final material = MaterialBiblioteca.fromJson(
        _json(
          extra: {
            'autor': 'Miguel de Cervantes, Francisco de Quevedo',
            'autores': [
              {'id': 'a-1', 'nombre': 'Miguel de Cervantes'},
              {'id': 'a-3', 'nombre': 'Francisco de Quevedo'},
            ],
            'tomo': '2',
            'total_tomos': 5,
            'cantidad_total': 5,
            'cantidad_reservada': 1,
            'cantidad_prestada': 1,
            'cantidad_vencida': 0,
            'cantidad_fuera_servicio': 1,
            'cantidad_disponible': 2,
          },
        ),
      );

      expect(material.autores.map((a) => a.nombre), [
        'Miguel de Cervantes',
        'Francisco de Quevedo',
      ]);
      expect(material.autoresTexto, 'Miguel de Cervantes, Francisco de Quevedo');
      expect(material.etiquetaTomo, 'Tomo 2 de 5');
      expect(material.tituloConTomo, 'Don Quijote · Tomo 2 de 5');
      expect(material.ejemplaresLibres, 2);
      expect(material.ejemplaresEnUso, 2);
      expect(material.ejemplaresCorto, '2 de 5');
      expect(material.ejemplaresDisponibles, '2 disponibles de 5');
      expect(material.sePuedeSolicitar, isTrue);
    });

    test('una respuesta antigua (sin ejemplares) se entiende como un solo ejemplar', () {
      final libre = MaterialBiblioteca.fromJson(_json(extra: {'autor': 'Borges'}));
      final prestado = MaterialBiblioteca.fromJson(_json(extra: {'estado': 'prestado'}));

      expect(libre.cantidadTotal, 1);
      expect(libre.autores, isEmpty);
      expect(libre.autoresTexto, 'Borges'); // cae al resumen en texto
      expect(libre.etiquetaTomo, isEmpty);
      expect(libre.ejemplaresLibres, 1);
      expect(libre.ejemplaresDisponibles, '1 disponible de 1');
      expect(libre.sePuedeSolicitar, isTrue);
      expect(prestado.ejemplaresLibres, 0);
      expect(prestado.sePuedeSolicitar, isFalse);
    });

    test('sin ejemplares libres no se puede solicitar aunque el estado diga otra cosa', () {
      final agotado = MaterialBiblioteca.fromJson(
        _json(extra: {'cantidad_total': 3, 'cantidad_disponible': 0}),
      );
      final consulta = MaterialBiblioteca.fromJson(
        _json(extra: {'cantidad_disponible': 1, 'es_prestable': false}),
      );

      expect(agotado.sePuedeSolicitar, isFalse);
      expect(consulta.sePuedeSolicitar, isFalse);
    });

    test('el tomo sin total se muestra solo con su número', () {
      final material = MaterialBiblioteca.fromJson(_json(extra: {'tomo': 'II'}));

      expect(material.etiquetaTomo, 'Tomo II');
    });

    test('toJson conserva los autores (la copia sin conexión los necesita)', () {
      final original = MaterialBiblioteca.fromJson(
        _json(extra: {'autores': [{'id': 'a-1', 'nombre': 'Cervantes'}], 'cantidad_total': 4}),
      );

      final copia = MaterialBiblioteca.fromJson(original.toJson());

      expect(copia.autores.single.nombre, 'Cervantes');
      expect(copia.cantidadTotal, 4);
    });
  });

  group('SeleccionAutores', () {
    test('no repite autores aunque cambien las tildes o las mayúsculas', () {
      var seleccion = const SeleccionAutores().agregarExistente(_garcia);
      seleccion = seleccion.agregarNombres('garcia marquez, gabriel');
      seleccion = seleccion.agregarExistente(_garcia);

      expect(seleccion.existentes, [_garcia]);
      expect(seleccion.nuevos, isEmpty);
    });

    test('el punto y coma separa varios autores; la coma no', () {
      final seleccion = const SeleccionAutores().agregarNombres(
        'Borges; García Márquez, Gabriel;  ; Cortázar',
      );

      expect(seleccion.nuevos, ['Borges', 'García Márquez, Gabriel', 'Cortázar']);
    });

    test('arma la petición con los IDs existentes y los nombres nuevos', () {
      final seleccion = const SeleccionAutores()
          .agregarExistente(_cervantes)
          .agregarNombres('Quevedo');

      expect(seleccion.aPeticion(), {
        'autores_ids': ['a-1'],
        'autores_nuevos': ['Quevedo'],
      });
      expect(seleccion.nombres, ['Miguel de Cervantes', 'Quevedo']);
    });

    test('quitar un autor lo saca solo a él', () {
      final seleccion = const SeleccionAutores()
          .agregarExistente(_cervantes)
          .agregarNombres('Quevedo')
          .quitarExistente('a-1');

      expect(seleccion.existentes, isEmpty);
      expect(seleccion.quitarNuevo('Quevedo').vacia, isTrue);
    });
  });

  group('Opciones del buscador de autores', () {
    test('ofrece crear el nombre escrito si ningún autor se llama igual', () {
      final opciones = opcionesParaTexto('Cortazar', [_cervantes], permitirCrear: true);

      expect(opciones.map((o) => o.esNueva), [false, true]);
      expect(opciones.last.texto, 'Cortazar');
    });

    test('no ofrece crear si ya existe uno con ese nombre (sin tildes)', () {
      final opciones = opcionesParaTexto(
        'miguel de cervantes',
        [_cervantes],
        permitirCrear: true,
      );

      expect(opciones.where((o) => o.esNueva), isEmpty);
    });

    test('oculta los ya elegidos y no ofrece crear en un filtro', () {
      final opciones = opcionesParaTexto(
        'miguel',
        [_cervantes],
        permitirCrear: false,
        excluidos: {'a-1'},
      );

      expect(opciones, isEmpty);
    });
  });

  group('Selector de autores en el formulario', () {
    Widget montar(_AutoresFalsos repositorio, SeleccionAutores inicial) {
      return ProviderScope(
        overrides: [autorRepositoryProvider.overrideWithValue(repositorio)],
        child: MaterialApp(
          theme: TemaApp.claro,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: _Anfitrion(inicial: inicial),
            ),
          ),
        ),
      );
    }

    testWidgets('un autor que no existe se crea desde el mismo campo con Enter', (tester) async {
      final repositorio = _AutoresFalsos([_cervantes]);
      await tester.pumpWidget(montar(repositorio, const SeleccionAutores()));

      await tester.enterText(find.byType(TextField), 'Julio Cortázar');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 400)); // termina la espera de la búsqueda

      expect(find.text('Julio Cortázar (nuevo)'), findsOneWidget);
      expect(_Anfitrion.ultima.nuevos, ['Julio Cortázar']);
    });

    testWidgets('el punto y coma agrega el nombre escrito y sigue con el siguiente', (tester) async {
      await tester.pumpWidget(montar(_AutoresFalsos([]), const SeleccionAutores()));

      await tester.enterText(find.byType(TextField), 'Borges; Bioy');
      await tester.pump(const Duration(milliseconds: 400)); // termina la espera de la búsqueda

      expect(find.text('Borges (nuevo)'), findsOneWidget);
      expect(find.text('Bioy'), findsOneWidget); // sigue escrito en el campo
    });

    testWidgets('ofrece los autores que coinciden y permite crear uno nuevo', (tester) async {
      final repositorio = _AutoresFalsos([_cervantes]);
      await tester.pumpWidget(montar(repositorio, const SeleccionAutores()));

      await tester.enterText(find.byType(TextField), 'cervantes');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.text('Miguel de Cervantes'), findsOneWidget);
      expect(find.text('Crear autor «cervantes»'), findsOneWidget);

      await tester.tap(find.text('Miguel de Cervantes'));
      await tester.pump();

      expect(_Anfitrion.ultima.existentes, [_cervantes]);
      expect(find.byType(InputChip), findsOneWidget);
    });

    testWidgets('los autores de un material en edición aparecen como chips y se pueden quitar', (tester) async {
      await tester.pumpWidget(
        montar(_AutoresFalsos([]), const SeleccionAutores(existentes: [_cervantes, _garcia])),
      );

      expect(find.byType(InputChip), findsNWidgets(2));

      await tester.tap(find.byTooltip('Quitar autor').first);
      await tester.pump();

      expect(find.byType(InputChip), findsOneWidget);
      expect(_Anfitrion.ultima.existentes, [_garcia]);
    });
  });

  group('Petición para guardar un material', () {
    late ControladoresMaterial c;

    setUp(() {
      c = ControladoresMaterial(MaterialBiblioteca.fromJson(_json()));
    });

    tearDown(() => c.dispose());

    Map<String, dynamic> peticion({
      required TipoMaterial tipo,
      bool esNuevo = true,
      SeleccionAutores autores = const SeleccionAutores(),
    }) => c.aPeticion(
      autores: autores,
      tipo: tipo,
      categoriaId: 'c-1',
      condicion: CondicionMaterial.bueno,
      esPrestable: true,
      esNuevo: esNuevo,
    );

    test('envía autores, tomo y cantidad, y ya no el texto libre del autor', () {
      c.cantidad.text = '4';
      c.tomo.text = '2';
      c.totalTomos.text = '5';

      final datos = peticion(
        tipo: TipoMaterial.libro,
        autores: const SeleccionAutores(existentes: [_cervantes]).agregarNombres('Quevedo'),
      );

      expect(datos['autores_ids'], ['a-1']);
      expect(datos['autores_nuevos'], ['Quevedo']);
      expect(datos['cantidad_total'], 4);
      expect(datos['tomo'], '2');
      expect(datos['total_tomos'], 5);
      expect(datos.containsKey('autor'), isFalse);
      expect(datos.containsKey('cantidad_fuera_servicio'), isFalse); // solo al editar
    });

    test('un equipo no lleva autores ni tomo, pero sí cantidad', () {
      c.cantidad.text = '3';
      c.tomo.text = '1';

      final datos = peticion(
        tipo: TipoMaterial.proyector,
        autores: const SeleccionAutores(existentes: [_cervantes]),
      );

      expect(datos['autores_ids'], isEmpty);
      expect(datos['autores_nuevos'], isEmpty);
      expect(datos['tomo'], isNull);
      expect(datos['cantidad_total'], 3);
    });

    test('al editar también envía los ejemplares fuera de servicio', () {
      c.fueraServicio.text = '2';

      final datos = peticion(tipo: TipoMaterial.libro, esNuevo: false);

      expect(datos['cantidad_fuera_servicio'], 2);
    });
  });

  group('Búsqueda', () {
    test('sinTildes ignora mayúsculas, tildes y espacios repetidos', () {
      expect(sinTildes('  GARCÍA   Márquez  '), 'garcia marquez');
      expect(sinTildes('Año'), 'ano');
    });

    test('exige todas las palabras, en cualquier orden', () {
      expect(coincideConTodasLasPalabras('Gabriel García Márquez', 'marquez gabriel'), isTrue);
      expect(coincideConTodasLasPalabras('Gabriel García Márquez', 'gabriel borges'), isFalse);
      expect(coincideConTodasLasPalabras('cualquier cosa', '   '), isTrue);
    });

    test('la copia del catálogo se filtra por autor, tomo y todas las palabras', () {
      final lista = [
        MaterialBiblioteca.fromJson(
          _json(extra: {
            'id': 'm-1',
            'codigo': 'L-1',
            'titulo': 'Cien años de soledad',
            'autores': [{'id': 'a-2', 'nombre': 'Gabriel García Márquez'}],
          }),
        ),
        MaterialBiblioteca.fromJson(
          _json(extra: {
            'id': 'm-2',
            'codigo': 'L-2',
            'titulo': 'Historia de Roma',
            'tomo': '3',
            'autor': 'Mommsen',
          }),
        ),
      ];
      FiltroMateriales filtro(String texto) =>
          (texto: texto, tipo: null, estado: null, soloDisponibles: false);

      expect(filtrarMateriales(lista, filtro('marquez gabriel')).map((m) => m.codigo), ['L-1']);
      expect(filtrarMateriales(lista, filtro('roma tomo 3')).map((m) => m.codigo), ['L-2']);
      expect(filtrarMateriales(lista, filtro('mommsen')).map((m) => m.codigo), ['L-2']);
      expect(filtrarMateriales(lista, filtro('marquez mommsen')), isEmpty);
    });

    test('la consulta del inventario distingue el autor filtrado', () {
      const base = ConsultaInventario(pagina: 3);
      final conAutor = base.conFiltros(autor: () => _cervantes);

      expect(conAutor.autor, _cervantes);
      expect(conAutor.pagina, 1); // un filtro nuevo vuelve a la primera página
      expect(conAutor, isNot(base));
      expect(conAutor, base.conFiltros(autor: () => _cervantes));
      expect(conAutor.enPagina(2).autor, _cervantes);
      expect(conAutor.conFiltros(autor: () => null).autor, isNull);
    });

    test('la consulta de autores vuelve a la primera página al buscar', () {
      const consulta = ConsultaAutores(pagina: 4);

      expect(consulta.conTexto('borges').pagina, 1);
      expect(consulta.conTexto('borges'), const ConsultaAutores(texto: 'borges'));
    });
  });

  test('Autor lee la cantidad de materiales del listado y la omite dentro de un material', () {
    final listado = Autor.fromJson({
      'id': 'a-1',
      'nombre': 'Cervantes',
      'cantidad_materiales': 7,
      'fecha_creacion': '2026-10-19T10:00:00',
    });
    final dentroDeMaterial = Autor.fromJson({'id': 'a-1', 'nombre': 'Cervantes'});

    expect(listado.cantidadMateriales, 7);
    expect(dentroDeMaterial.cantidadMateriales, 0);
  });
}

/// Hospeda el [SelectorAutores] guardando la última selección, como lo haría el formulario.
class _Anfitrion extends StatefulWidget {
  const _Anfitrion({required this.inicial});

  final SeleccionAutores inicial;
  static SeleccionAutores ultima = const SeleccionAutores();

  @override
  State<_Anfitrion> createState() => _AnfitrionState();
}

class _AnfitrionState extends State<_Anfitrion> {
  late SeleccionAutores _seleccion = widget.inicial;

  @override
  Widget build(BuildContext context) {
    _Anfitrion.ultima = _seleccion;
    return SelectorAutores(
      seleccion: _seleccion,
      alCambiar: (nueva) => setState(() => _seleccion = nueva),
    );
  }
}
