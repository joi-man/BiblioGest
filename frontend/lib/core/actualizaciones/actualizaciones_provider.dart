import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/modo_local.dart';
import '../platform/plataforma.dart';
import '../theme/modo_tema_provider.dart';
import 'clave_publica.dart';
import 'cliente_actualizaciones.dart';
import 'decision.dart';
import 'firma_manifiesto.dart';
import 'instalador_actualizaciones.dart';
import 'manifiesto.dart';
import 'preferencias_actualizacion.dart';
import 'version_app.dart';

/// Versión instalada. `main` la lee del programa y la reemplaza al arrancar.
final versionAppProvider = Provider<String>((ref) {
  throw UnimplementedError('Debe sobrescribirse en main() antes de runApp');
});

/// Cierra el backend local antes de instalar. `main` lo reemplaza por el real.
final cerrarBackendProvider = Provider<Future<void> Function()>((ref) => () async {});

/// Si las actualizaciones aplican a esta ejecución: el ejecutable instalado
/// (con backend propio) y la app de Android; no `flutter run` en escritorio ni la web.
final actualizacionesHabilitadasProvider =
    Provider<bool>((ref) => modoLocalNotifier.activo || esAndroid);

final instaladorActualizacionesProvider =
    Provider<InstaladorActualizaciones>((ref) => crearInstaladorActualizaciones());

final clienteActualizacionesProvider = Provider<ClienteActualizaciones>((ref) {
  return ClienteActualizaciones(
    dio: Dio(),
    urlManifiesto: esAndroid ? urlManifiestoActualizacionesAndroid : urlManifiestoActualizaciones,
    clavePublica: clavePublicaActualizaciones,
  );
});

final actualizacionesProvider =
    StateNotifierProvider<ActualizacionesNotifier, EstadoActualizacion>((ref) {
  return ActualizacionesNotifier(
    versionInstalada: VersionApp.parse(ref.watch(versionAppProvider)),
    cliente: ref.watch(clienteActualizacionesProvider),
    instalador: ref.watch(instaladorActualizacionesProvider),
    preferencias: PreferenciasActualizacion(ref.watch(preferenciasProvider)),
    cerrarBackend: ref.watch(cerrarBackendProvider),
    habilitado: ref.watch(actualizacionesHabilitadasProvider),
    clavePublica: clavePublicaActualizaciones,
  );
});

enum FaseActualizacion { inactiva, comprobando, alDia, disponible, descargando, instalando, error }

class EstadoActualizacion {
  const EstadoActualizacion({
    this.fase = FaseActualizacion.inactiva,
    this.urgencia = Urgencia.ninguna,
    this.manifiesto,
    this.progreso = 0,
    this.mensaje,
    this.avisoPendiente = false,
    this.automatica = false,
  });

  final FaseActualizacion fase;
  final Urgencia urgencia;

  /// Última versión publicada que conoce la aplicación.
  final Manifiesto? manifiesto;

  /// Avance de la descarga, de 0 a 1.
  final double progreso;

  /// Motivo del último error (o aviso) para mostrar al usuario.
  final String? mensaje;

  /// True mientras haya que preguntarle al usuario si actualiza (aviso opcional).
  final bool avisoPendiente;

  /// El usuario eligió instalar actualizaciones sin preguntar.
  final bool automatica;

  bool get bloqueaLaApp => urgencia == Urgencia.obligatoria;
  bool get ocupado =>
      fase == FaseActualizacion.comprobando ||
      fase == FaseActualizacion.descargando ||
      fase == FaseActualizacion.instalando;

  EstadoActualizacion copyWith({
    FaseActualizacion? fase,
    Urgencia? urgencia,
    Manifiesto? manifiesto,
    double? progreso,
    String? mensaje,
    bool quitarMensaje = false,
    bool? avisoPendiente,
    bool? automatica,
  }) {
    return EstadoActualizacion(
      fase: fase ?? this.fase,
      urgencia: urgencia ?? this.urgencia,
      manifiesto: manifiesto ?? this.manifiesto,
      progreso: progreso ?? this.progreso,
      mensaje: quitarMensaje ? null : (mensaje ?? this.mensaje),
      avisoPendiente: avisoPendiente ?? this.avisoPendiente,
      automatica: automatica ?? this.automatica,
    );
  }
}

/// Busca, descarga e instala actualizaciones del ejecutable de Windows y de la app de Android.
class ActualizacionesNotifier extends StateNotifier<EstadoActualizacion> {
  ActualizacionesNotifier({
    required this.versionInstalada,
    required this.cliente,
    required this.instalador,
    required this.preferencias,
    required this.cerrarBackend,
    required this.habilitado,
    required this.clavePublica,
  }) : super(EstadoActualizacion(automatica: preferencias.automatica));

  final VersionApp versionInstalada;
  final ClienteActualizaciones cliente;
  final InstaladorActualizaciones instalador;
  final PreferenciasActualizacion preferencias;
  final Future<void> Function() cerrarBackend;
  final bool habilitado;
  final String clavePublica;

  /// Versiones cuyo aviso se pospuso en esta sesión: no se vuelve a preguntar hasta reabrir.
  final Set<VersionApp> _pospuestas = {};
  bool _iniciado = false;

  bool get _activo => habilitado && instalador.disponible;

  /// Se llama al abrir la aplicación. No bloquea: la búsqueda corre en segundo plano.
  Future<void> iniciar() async {
    if (!_activo || _iniciado) return;
    _iniciado = true;

    await instalador.limpiarDescargas(versionInstalada.toString());
    await _aplicarGuardado();
    await comprobar();
  }

  /// Vuelve a evaluar el último manifiesto verificado, sin red. Así una
  /// actualización obligatoria sigue exigiéndose aunque el equipo no tenga internet.
  Future<void> _aplicarGuardado() async {
    final guardado = preferencias.manifiestoGuardado;
    if (guardado == null) return;
    try {
      final manifiesto = await _verificar(guardado.contenido, guardado.firma);
      _aplicar(manifiesto, confirmadoEnLinea: false);
    } on ErrorManifiesto {
      // Dañado o de otra clave: se ignora y se espera a la consulta real.
    }
  }

  Future<Manifiesto> _verificar(String contenido, String firma) {
    return verificarManifiesto(
      contenido: Uint8List.fromList(utf8.encode(contenido)),
      firmaBase64: firma,
      clavePublicaBase64: clavePublica,
    );
  }

  /// Busca una versión nueva. Con [manual] informa también cuando no hay nada
  /// o no se pudo consultar; en el arranque falla en silencio.
  Future<void> comprobar({bool manual = false}) async {
    if (!_activo || state.ocupado) return;
    final anterior = state;
    if (manual) {
      state = state.copyWith(fase: FaseActualizacion.comprobando, quitarMensaje: true);
    }

    try {
      final consultado = await cliente.consultar();
      await preferencias.guardarManifiesto(consultado.contenido, consultado.firma);
      _aplicar(consultado.manifiesto, confirmadoEnLinea: true);
      // Instalación automática: solo con una versión confirmada en línea.
      final decision = _decidir(consultado.manifiesto);
      if (decision.instalarSola && decision.urgencia != Urgencia.ninguna) {
        await descargarEInstalar(automatica: true);
      }
    } on SinConexionActualizaciones catch (error) {
      state = manual
          ? anterior.copyWith(
              fase: FaseActualizacion.error,
              mensaje: 'No se pudo conectar. Revisa tu conexión a internet.'
                  '${error.detalle.isEmpty ? '' : ' (${error.detalle})'}',
            )
          : anterior;
    } on ErrorManifiesto {
      state = manual
          ? anterior.copyWith(
              fase: FaseActualizacion.error,
              mensaje: 'No se pudo verificar la información de la actualización.',
            )
          : anterior;
    }
  }

  Decision _decidir(Manifiesto manifiesto) {
    return decidir(
      actual: versionInstalada,
      manifiesto: manifiesto,
      automatica: preferencias.automatica,
      versionOmitida: VersionApp.intentar(preferencias.versionOmitida),
      versionIntentadaSola: VersionApp.intentar(preferencias.versionIntentadaSola),
    );
  }

  void _aplicar(Manifiesto manifiesto, {required bool confirmadoEnLinea}) {
    final decision = _decidir(manifiesto);
    final hay = decision.urgencia != Urgencia.ninguna;
    state = EstadoActualizacion(
      fase: hay ? FaseActualizacion.disponible : FaseActualizacion.alDia,
      urgencia: decision.urgencia,
      manifiesto: manifiesto,
      // El aviso opcional solo se muestra con datos recién consultados, para no
      // preguntar dos veces (primero con los guardados y luego con los nuevos).
      avisoPendiente: decision.urgencia == Urgencia.opcional &&
          confirmadoEnLinea &&
          !_pospuestas.contains(manifiesto.version),
      automatica: preferencias.automatica,
    );
  }

  /// Descarga el instalador y lo ejecuta; la aplicación se cierra y se vuelve a abrir sola.
  Future<void> descargarEInstalar({bool automatica = false}) async {
    final manifiesto = state.manifiesto;
    if (!_activo || manifiesto == null || state.ocupado) return;

    // Se anota antes de intentar: si algo falla, el próximo inicio pregunta en vez de repetir.
    if (automatica) await preferencias.guardarIntentoAutomatico(manifiesto.version.toString());

    state = state.copyWith(
      fase: FaseActualizacion.descargando,
      progreso: 0,
      quitarMensaje: true,
    );
    try {
      final ruta = await instalador.descargar(
        manifiesto,
        alProgreso: (valor) => state = state.copyWith(progreso: valor),
      );
      state = state.copyWith(fase: FaseActualizacion.instalando, progreso: 1);
      await instalador.instalar(ruta, cerrarBackend: cerrarBackend);
      // En Windows la aplicación se cierra al instalar. En Android el instalador del
      // sistema se abre encima: si la persona lo cancela, la app debe poder reintentar.
      if (instalador is ContinuaTrasInstalar) {
        state = state.copyWith(fase: FaseActualizacion.disponible, avisoPendiente: false);
      }
    } on ErrorInstalacion catch (error) {
      state = state.copyWith(
        fase: FaseActualizacion.error,
        mensaje: error.mensaje,
        avisoPendiente: true,
      );
    } catch (_) {
      state = state.copyWith(
        fase: FaseActualizacion.error,
        mensaje: 'No se pudo instalar la actualización. Inténtalo de nuevo.',
        avisoPendiente: true,
      );
    }
  }

  /// "Más tarde": no vuelve a preguntar hasta la próxima vez que se abra la aplicación.
  void posponer() {
    final manifiesto = state.manifiesto;
    if (manifiesto == null || state.bloqueaLaApp) return;
    _pospuestas.add(manifiesto.version);
    state = state.copyWith(avisoPendiente: false, fase: FaseActualizacion.disponible, quitarMensaje: true);
  }

  /// "Omitir esta versión": no avisa de ella; sí de las siguientes. No aplica si es obligatoria.
  Future<void> omitir() async {
    final manifiesto = state.manifiesto;
    if (manifiesto == null || state.bloqueaLaApp) return;
    await preferencias.guardarVersionOmitida(manifiesto.version.toString());
    state = state.copyWith(
      urgencia: Urgencia.ninguna,
      fase: FaseActualizacion.alDia,
      avisoPendiente: false,
      quitarMensaje: true,
    );
  }

  Future<void> fijarAutomatica(bool valor) async {
    await preferencias.guardarAutomatica(valor);
    state = state.copyWith(automatica: valor);
  }

  /// Muestra otra vez el aviso de una versión pendiente (botón "Instalar" de Ajustes).
  void mostrarAviso() {
    if (state.manifiesto == null || state.urgencia == Urgencia.ninguna) return;
    state = state.copyWith(avisoPendiente: true, quitarMensaje: true);
  }
}
