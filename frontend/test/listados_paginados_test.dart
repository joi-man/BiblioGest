import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
import 'package:frontend/core/theme/tema_app.dart';
import 'package:frontend/features/auth/data/models/usuario.dart';
import 'package:frontend/features/auth/presentation/providers/usuarios_paginados_provider.dart';
import 'package:frontend/features/auth/presentation/screens/usuarios_screen.dart';
import 'package:frontend/features/core/widgets/controles_paginacion.dart';

PaginaResultado<int> _pagina({int pagina = 1, int tamano = 10, int total = 53, int filas = 10}) {
  return PaginaResultado<int>(
    items: List.generate(filas, (i) => i),
    total: total,
    pagina: pagina,
    tamano: tamano,
    totalPaginas: (total / tamano).ceil(),
  );
}

Widget _app(Widget hijo, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(theme: TemaApp.claro, home: Scaffold(body: hijo)),
  );
}

void main() {
  group('PaginaResultado', () {
    test('calcula el rango de filas mostradas', () {
      final pagina = _pagina(pagina: 2, filas: 10);

      expect(pagina.desde, 11);
      expect(pagina.hasta, 20);
      expect(pagina.hayAnterior, isTrue);
      expect(pagina.haySiguiente, isTrue);
    });

    test('lee el JSON del backend', () {
      final pagina = PaginaResultado<String>.desdeJson(
        {
          'items': [
            {'nombre': 'Ana'},
            {'nombre': 'Luis'},
          ],
          'total': 2,
          'pagina': 1,
          'tamano': 10,
          'total_paginas': 1,
        },
        (fila) => fila['nombre'] as String,
      );

      expect(pagina.items, ['Ana', 'Luis']);
      expect(pagina.haySiguiente, isFalse);
    });

    test('tras borrar la única fila de la última página propone la anterior', () {
      const vacia = PaginaResultado<int>(
          items: [], total: 10, pagina: 2, tamano: 10, totalPaginas: 1);

      expect(vacia.paginaValida, 1);
    });
  });

  group('ConsultaUsuarios', () {
    test('cambiar un filtro vuelve a la primera página', () {
      final consulta = const ConsultaUsuarios(pagina: 4).conFiltros(texto: 'ana');

      expect(consulta.pagina, 1);
      expect(consulta.texto, 'ana');
    });

    test('quitar un filtro es distinto de no tocarlo', () {
      const base = ConsultaUsuarios(rol: 'admin');

      expect(base.conFiltros(texto: 'x').rol, 'admin');
      expect(base.conFiltros(rol: () => null).rol, isNull);
    });

    test('cambiar de página conserva los filtros y tiene igualdad por valor', () {
      const base = ConsultaUsuarios(texto: 'a', rol: 'estudiante');

      expect(base.enPagina(3), const ConsultaUsuarios(texto: 'a', rol: 'estudiante', pagina: 3));
      expect(base.enPagina(3).hashCode,
          const ConsultaUsuarios(texto: 'a', rol: 'estudiante', pagina: 3).hashCode);
    });
  });

  group('ControlesPaginacion', () {
    testWidgets('muestra el rango y avanza a la página siguiente', (tester) async {
      int? destino;
      await tester.pumpWidget(_app(ControlesPaginacion(
        pagina: _pagina(pagina: 2),
        alCambiarPagina: (n) => destino = n,
        alCambiarTamano: (_) {},
      )));

      expect(find.text('11–20 de 53'), findsOneWidget);
      await tester.tap(find.byTooltip('Página siguiente'));
      expect(destino, 3);
      await tester.tap(find.byTooltip('Primera página'));
      expect(destino, 1);
    });

    testWidgets('en la primera página no se puede retroceder', (tester) async {
      await tester.pumpWidget(_app(ControlesPaginacion(
        pagina: _pagina(),
        alCambiarPagina: (_) {},
        alCambiarTamano: (_) {},
      )));

      final anterior = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.chevron_left));
      expect(anterior.onPressed, isNull);
    });

    testWidgets('en la última página no se puede avanzar', (tester) async {
      await tester.pumpWidget(_app(ControlesPaginacion(
        pagina: _pagina(pagina: 6, filas: 3),
        alCambiarPagina: (_) {},
        alCambiarTamano: (_) {},
      )));

      final siguiente = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.chevron_right));
      expect(siguiente.onPressed, isNull);
      expect(find.text('51–53 de 53'), findsOneWidget);
    });
  });

  group('UsuariosScreen', () {
    const ana = Usuario(
      id: '1',
      username: 'ana',
      correoElectronico: 'ana@test.com',
      numeroDocumento: '111',
      nombre: 'Ana',
      apellido: 'Lopez',
      rol: 'estudiante',
    );

    testWidgets('dibuja la grilla con búsqueda, filtros y exportar', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(
        const UsuariosScreen(),
        overrides: [
          usuariosPaginadosProvider.overrideWith(
            (ref, consulta) async => const PaginaResultado(
              items: [ana],
              total: 1,
              pagina: 1,
              tamano: 10,
              totalPaginas: 1,
            ),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Ana Lopez'), findsOneWidget);
      expect(find.text('ana@test.com'), findsOneWidget);
      expect(find.text('Estudiante'), findsWidgets);
      expect(find.text('Exportar'), findsOneWidget);
      expect(find.text('1 usuarios'), findsOneWidget);
      expect(find.text('1–1 de 1'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
