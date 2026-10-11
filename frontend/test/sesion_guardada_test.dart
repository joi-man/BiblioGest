import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/sesion/sesion_guardada.dart';
import 'package:frontend/core/theme/modo_tema_provider.dart';
import 'package:frontend/features/auth/data/models/login_response.dart';
import 'package:frontend/features/auth/data/models/usuario.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/presentation/widgets/guardia_cierre_ventana.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sesion = LoginResponse(
  accessToken: 'token-abc',
  usuario: Usuario(
    id: 'u-1',
    username: 'ana',
    correoElectronico: 'ana@prueba.com',
    numeroDocumento: '123',
    nombre: 'Ana',
    apellido: 'Lopez',
    rol: 'admin',
  ),
);

void main() {
  late SharedPreferences preferencias;
  var ahora = DateTime(2026, 10, 11, 12);
  int? arranque = 1000000;

  SesionGuardada crear() => SesionGuardada(
        preferencias,
        ahora: () => ahora,
        arranqueSo: () async => arranque,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferencias = await SharedPreferences.getInstance();
    ahora = DateTime(2026, 10, 11, 12);
    arranque = 1000000;
  });

  group('SesionGuardada', () {
    test('recupera la sesión si se vuelve dentro de 30 minutos', () async {
      await crear().guardar(_sesion);
      ahora = ahora.add(const Duration(minutes: 29));

      final restaurada = await crear().restaurar();
      expect(restaurada?.accessToken, 'token-abc');
      expect(restaurada?.usuario.nombre, 'Ana');
    });

    test('no la recupera pasados 30 minutos', () async {
      await crear().guardar(_sesion);
      ahora = ahora.add(const Duration(minutes: 31));

      expect(await crear().restaurar(), isNull);
    });

    test('se puede recuperar una sola vez', () async {
      await crear().guardar(_sesion);

      expect(await crear().restaurar(), isNotNull);
      expect(await crear().restaurar(), isNull);
    });

    test('no la recupera si el equipo se reinició', () async {
      await crear().guardar(_sesion);
      arranque = 1000000 + const Duration(minutes: 10).inMilliseconds;

      expect(await crear().restaurar(), isNull);
    });

    test('tolera pequeños ajustes del reloj al comparar el arranque', () async {
      await crear().guardar(_sesion);
      arranque = 1000000 + 3000;

      expect(await crear().restaurar(), isNotNull);
    });

    test('borrar elimina la sesión guardada', () async {
      final sesiones = crear();
      await sesiones.guardar(_sesion);
      await sesiones.borrar();

      expect(await sesiones.restaurar(), isNull);
    });

    test('ignora datos dañados', () async {
      await preferencias.setString('sesion_guardada', '{no es json');

      expect(await crear().restaurar(), isNull);
    });
  });

  group('GuardiaCierreVentana', () {
    final navegador = GlobalKey<NavigatorState>();

    Future<ProviderContainer> mostrar(WidgetTester tester, {LoginResponse? sesion}) async {
      late ProviderContainer contenedor;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferenciasProvider.overrideWithValue(preferencias),
            sesionRestauradaProvider.overrideWithValue(sesion),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              contenedor = ProviderScope.containerOf(context);
              return MaterialApp(
                navigatorKey: navegador,
                home: GuardiaCierreVentana(
                  navegadorKey: navegador,
                  habilitado: true,
                  child: const Scaffold(body: Text('Inicio')),
                ),
              );
            },
          ),
        ),
      );
      return contenedor;
    }

    testWidgets('sin sesión se sale sin preguntar', (tester) async {
      await mostrar(tester);

      final respuesta = await tester.binding.handleRequestAppExit();
      await tester.pump();

      expect(respuesta.name, 'exit');
      expect(find.text('¿Cerrar sesión al salir?'), findsNothing);
    });

    testWidgets('con sesión pregunta y "No cerrar sesión" la guarda', (tester) async {
      await mostrar(tester, sesion: _sesion);

      final futuro = tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();
      expect(find.text('¿Cerrar sesión al salir?'), findsOneWidget);

      await tester.tap(find.text('No cerrar sesión'));
      await tester.pumpAndSettle();

      expect((await futuro).name, 'exit');
      expect(preferencias.getString('sesion_guardada'), isNotNull);
    });

    testWidgets('"Cerrar sesión" sale sin guardar nada', (tester) async {
      await mostrar(tester, sesion: _sesion);

      final futuro = tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
      await tester.pumpAndSettle();

      expect((await futuro).name, 'exit');
      expect(preferencias.getString('sesion_guardada'), isNull);
    });

    testWidgets('"Cancelar" mantiene abierta la aplicación', (tester) async {
      await mostrar(tester, sesion: _sesion);

      final futuro = tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect((await futuro).name, 'cancel');
      expect(preferencias.getString('sesion_guardada'), isNull);
    });
  });
}
