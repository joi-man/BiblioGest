import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/sesion/sesion_guardada.dart';
import 'package:frontend/core/utils/formato_fecha.dart';
import 'package:frontend/features/auth/data/models/login_response.dart';
import 'package:frontend/features/auth/data/models/usuario.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  setUpAll(() => initializeDateFormatting('es'));

  group('sesión en el navegador', () {
    late SharedPreferences preferencias;
    var ahora = DateTime(2026, 10, 12, 10);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferencias = await SharedPreferences.getInstance();
      ahora = DateTime(2026, 10, 12, 10);
    });

    SesionGuardada almacen() => SesionGuardada(
          preferencias,
          ahora: () => ahora,
          arranqueSo: () async => null,
          vigencia: vigenciaSesionWeb,
        );

    test('sin consumir, F5 y otras pestañas recuperan la misma sesión', () async {
      await almacen().guardar(_sesion());

      final primera = await almacen().restaurar(consumir: false);
      final otraPestana = await almacen().restaurar(consumir: false);

      expect(primera?.usuario.username, 'ana');
      expect(otraPestana?.usuario.username, 'ana');
    });

    test('vence con el token y entonces se descarta', () async {
      await almacen().guardar(_sesion());
      ahora = ahora.add(vigenciaSesionWeb + const Duration(minutes: 1));

      expect(await almacen().restaurar(consumir: false), isNull);
      expect(preferencias.getString('sesion_guardada'), isNull);
    });

    test('cerrar sesión la borra', () async {
      await almacen().guardar(_sesion());
      await almacen().borrar();

      expect(await almacen().restaurar(consumir: false), isNull);
    });
  });

  test('las fechas se muestran en hora de Paraguay (UTC-3) en cualquier dispositivo', () {
    final utc = DateTime.utc(2026, 10, 12, 18, 49);

    expect(FormatoFecha.soloHora(utc), '15:49');
    expect(FormatoFecha.fechaHora(utc), '12 oct 2026, 15:49');
    // Pasada la medianoche UTC todavía es el día anterior en Paraguay.
    expect(FormatoFecha.soloFecha(DateTime.utc(2026, 10, 13, 1)), '12 oct 2026');
  });
}
