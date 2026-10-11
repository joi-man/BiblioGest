import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/local/backend_local.dart';
import 'package:frontend/core/local/modo_local.dart';

/// Datos que la aplicación necesita conocer antes de dibujar su primera pantalla.
class ResultadoArranque {
  const ResultadoArranque({required this.urlApi, this.backend});

  /// Dirección de la API: el backend local en el ejecutable, el servidor en la web.
  final String urlApi;

  /// Backend iniciado junto a la aplicación, o null si no corresponde.
  final BackendLocal? backend;
}

/// Prepara lo que la aplicación necesita para funcionar.
///
/// En el ejecutable de escritorio inicia el backend local y consulta si el
/// equipo ya fue configurado; en la web solo usa el servidor de siempre.
Future<ResultadoArranque> prepararArranque() async {
  final backend = await iniciarBackendLocal();

  if (backend == null) {
    modoLocalNotifier.iniciar(activo: false, requiereConfiguracion: false);
    return const ResultadoArranque(urlApi: ApiConstants.baseUrl);
  }

  final cliente = Dio(BaseOptions(baseUrl: backend.url));
  final respuesta = await cliente.get('/api/local/estado');
  modoLocalNotifier.iniciar(
    activo: true,
    requiereConfiguracion: respuesta.data['configurado'] != true,
  );
  return ResultadoArranque(urlApi: backend.url, backend: backend);
}
