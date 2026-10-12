import 'dart:async';

import 'package:dio/dio.dart';

import 'estado_conexion.dart';
import 'reintento_interceptor.dart';

/// Vigila la conexión mientras hay un problema y avisa cuando vuelve.
///
/// Mientras [EstadoConexion] indique un problema, consulta cada [intervalo] el
/// servidor (`/health`). Si responde, marca la conexión como recuperada y llama
/// a [alRecuperar] para que las pantallas vuelvan a pedir sus datos (así lo que
/// la persona hizo o vio antes del corte se sincroniza solo). Tras
/// [intentosAntesDeAvisar] intentos fallidos pasa al estado `sinConexion`, que
/// es el que muestra el aviso; sigue intentando en silencio hasta lograrlo.
class ReconectorConexion {
  ReconectorConexion({
    required Dio dio,
    required EstadoConexion estado,
    this.intervalo = const Duration(seconds: 10),
    this.intentosAntesDeAvisar = 5,
    this.alRecuperar,
  })  : _dio = dio,
        _estado = estado;

  final Dio _dio;
  final EstadoConexion _estado;
  final Duration intervalo;
  final int intentosAntesDeAvisar;
  final void Function()? alRecuperar;

  Timer? _temporizador;
  int _fallos = 0;
  bool _sondeando = false;
  bool _activo = false;

  /// Empieza a escuchar el estado de la conexión.
  void iniciar() {
    if (_activo) return;
    _activo = true;
    _estado.addListener(_alCambiarEstado);
    _alCambiarEstado();
  }

  void detener() {
    _activo = false;
    _estado.removeListener(_alCambiarEstado);
    _temporizador?.cancel();
    _temporizador = null;
  }

  void _alCambiarEstado() {
    if (_estado.hayProblema) {
      _temporizador ??= Timer.periodic(intervalo, (_) => sondear());
    } else {
      _temporizador?.cancel();
      _temporizador = null;
      _fallos = 0;
    }
  }

  /// Un intento de reconexión (también lo usa el botón "Reintentar ahora").
  Future<void> sondear() async {
    if (_sondeando) return;
    _sondeando = true;
    try {
      await _dio.get(
        '/health',
        options: Options(
          extra: {extraSinReintento: true},
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      _fallos = 0;
      _estado.conectado();
      alRecuperar?.call();
    } on DioException {
      _fallos++;
      if (_fallos >= intentosAntesDeAvisar) {
        _estado.sinConexion();
      } else {
        _estado.reconectando(_fallos, intentosAntesDeAvisar);
      }
    } finally {
      _sondeando = false;
    }
  }
}
