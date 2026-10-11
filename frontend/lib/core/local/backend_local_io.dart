import 'dart:async';
import 'dart:io';

import 'backend_local_base.dart';

/// Ruta del ejecutable del backend, para pruebas y desarrollo:
/// `--dart-define=BACKEND_LOCAL_EXE=C:\ruta\bibliogest-backend.exe`.
const String _rutaIndicada = String.fromEnvironment('BACKEND_LOCAL_EXE');

/// Tiempo máximo de espera a que el backend empiece a responder.
const Duration _esperaMaxima = Duration(seconds: 60);

/// Inicia el backend empaquetado junto a la aplicación de Windows.
///
/// Devuelve `null` si no corresponde (otra plataforma) o si el programa no
/// trae el backend (por ejemplo, al desarrollar con `flutter run`); en ese caso
/// la aplicación usa el servidor configurado.
///
/// El backend se cierra solo cuando esta aplicación termina, porque vigila la
/// entrada estándar que se le deja abierta.
Future<BackendLocal?> iniciarBackendLocal() async {
  if (!Platform.isWindows) return null;

  final ejecutable = File(_rutaIndicada.isNotEmpty ? _rutaIndicada : _rutaEmpaquetada());
  if (!await ejecutable.exists()) return null;

  final puerto = await _puertoLibre();
  final proceso = await Process.start(
    ejecutable.path,
    ['--puerto', '$puerto'],
    workingDirectory: ejecutable.parent.path,
  );
  // Si nadie lee su salida, el proceso puede bloquearse al llenarse el búfer.
  unawaited(proceso.stdout.drain<void>());
  unawaited(proceso.stderr.drain<void>());

  final url = 'http://127.0.0.1:$puerto';
  try {
    await _esperarQueResponda(url, proceso);
  } catch (_) {
    proceso.kill();
    rethrow;
  }
  return BackendLocal(url: url, detener: () async => proceso.kill());
}

/// `<carpeta del programa>\backend\bibliogest-backend.exe`
String _rutaEmpaquetada() {
  final carpeta = File(Platform.resolvedExecutable).parent.path;
  final s = Platform.pathSeparator;
  return '$carpeta${s}backend${s}bibliogest-backend.exe';
}

/// Pide al sistema un puerto libre y lo suelta para que lo use el backend.
Future<int> _puertoLibre() async {
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final puerto = socket.port;
  await socket.close();
  return puerto;
}

/// Consulta `/health` hasta que responda, o falla si el proceso termina o se acaba el tiempo.
Future<void> _esperarQueResponda(String url, Process proceso) async {
  var terminado = false;
  unawaited(proceso.exitCode.then((_) => terminado = true));

  final cliente = HttpClient()..connectionTimeout = const Duration(seconds: 2);
  final limite = DateTime.now().add(_esperaMaxima);
  try {
    while (DateTime.now().isBefore(limite)) {
      if (terminado) {
        throw const ErrorBackendLocal('El servicio interno de BiblioGest se cerró al iniciar.');
      }
      try {
        final peticion = await cliente.getUrl(Uri.parse('$url/health'));
        final respuesta = await peticion.close();
        await respuesta.drain<void>();
        if (respuesta.statusCode == 200) return;
      } on SocketException {
        // Aún no está escuchando.
      } on HttpException {
        // Conexión cortada mientras arrancaba.
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    throw const ErrorBackendLocal('El servicio interno de BiblioGest tardó demasiado en iniciar.');
  } finally {
    cliente.close(force: true);
  }
}
