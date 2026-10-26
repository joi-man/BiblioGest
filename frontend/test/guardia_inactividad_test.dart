import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/auth_state.dart';
import 'package:frontend/features/auth/data/models/login_response.dart';
import 'package:frontend/features/auth/data/models/usuario.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/presentation/widgets/guardia_inactividad.dart';

LoginResponse _sesion() => LoginResponse(
  accessToken: 'token',
  tokenType: 'bearer',
  usuario: const Usuario(
    id: '1',
    username: 'ana',
    correoElectronico: 'ana@prueba.com',
    numeroDocumento: '123',
    nombre: 'Ana',
    apellido: 'Lopez',
    rol: 'estudiante',
  ),
);

void main() {
  late DateTime ahora;
  late ProviderContainer contenedor;

  Future<void> montar(WidgetTester tester, {LoginResponse? sesion}) async {
    ahora = DateTime(2026, 10, 26, 9);
    authStateNotifier.avisoAlLogin = null;
    contenedor = ProviderContainer(
      overrides: [sesionRestauradaProvider.overrideWithValue(sesion)],
    );
    addTearDown(contenedor.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: contenedor,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: GuardiaInactividad(
            limite: const Duration(minutes: 10),
            revision: const Duration(seconds: 5),
            ahora: () => ahora,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  /// Deja pasar [tiempo] en el reloj del guardia y en el de la prueba.
  Future<void> pasar(WidgetTester tester, Duration tiempo) async {
    ahora = ahora.add(tiempo);
    await tester.pump(tiempo);
  }

  testWidgets('tras el tiempo sin actividad cierra la sesión y avisa', (tester) async {
    await montar(tester, sesion: _sesion());

    await pasar(tester, const Duration(minutes: 10, seconds: 6));

    expect(contenedor.read(authProvider).value, isNull);
    expect(authStateNotifier.avisoAlLogin, contains('inactividad'));
    expect(authStateNotifier.avisoAlLogin, contains('10 minutos'));
  });

  testWidgets('antes del plazo la sesión sigue abierta', (tester) async {
    await montar(tester, sesion: _sesion());

    await pasar(tester, const Duration(minutes: 9));

    expect(contenedor.read(authProvider).value, isNotNull);
  });

  testWidgets('tocar la pantalla reinicia la cuenta', (tester) async {
    await montar(tester, sesion: _sesion());

    await pasar(tester, const Duration(minutes: 9));
    await tester.tapAt(const Offset(10, 10));
    await pasar(tester, const Duration(minutes: 9));

    expect(contenedor.read(authProvider).value, isNotNull);

    await pasar(tester, const Duration(minutes: 2));

    expect(contenedor.read(authProvider).value, isNull);
  });

  testWidgets('sin sesión iniciada no hay nada que bloquear', (tester) async {
    await montar(tester);

    await pasar(tester, const Duration(minutes: 30));

    expect(authStateNotifier.avisoAlLogin, isNull);
  });
}
