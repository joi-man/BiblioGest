import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:frontend/features/loans/data/models/prestamo.dart';
import 'package:frontend/features/loans/data/repositories/prestamo_repository.dart';
import 'package:frontend/features/materials/presentation/providers/materiales_provider.dart';
import 'package:frontend/features/returns/data/repositories/devolucion_repository.dart';
import 'package:frontend/features/returns/presentation/providers/devoluciones_provider.dart';
import 'package:frontend/features/student/presentation/providers/catalogo_provider.dart';
import 'prestamos_provider.dart';

final accionesPrestamoProvider = Provider<AccionesPrestamo>((ref) {
  return AccionesPrestamo(ref);
});

/// Operaciones que cambian el estado de préstamos y devoluciones.
///
/// Cada método llama a la API y, si sale bien, refresca todas las listas que
/// podían quedar desactualizadas. Los errores se propagan para que la pantalla
/// decida cómo avisarlos (ver `ejecutarAccion`).
class AccionesPrestamo {
  AccionesPrestamo(this._ref);

  final Ref _ref;

  PrestamoRepository get _prestamos => _ref.read(prestamoRepositoryProvider);
  DevolucionRepository get _devoluciones =>
      _ref.read(devolucionRepositoryProvider);

  Future<void> aprobar(String id) =>
      _ejecutarYRefrescar(() => _prestamos.aprobar(id));

  Future<void> rechazar(String id, String motivo) =>
      _ejecutarYRefrescar(() => _prestamos.rechazar(id, motivo));

  Future<void> entregar(String id, {DateTime? fechaDevolucionEsperada}) =>
      _ejecutarYRefrescar(
        () => _prestamos.entregar(
          id,
          fechaDevolucionEsperada: fechaDevolucionEsperada,
        ),
      );

  Future<void> cancelar(String id) =>
      _ejecutarYRefrescar(() => _prestamos.cancelar(id));

  /// Presta una reserva aprobada a otra persona; [motivo] se le informa a quien reservó.
  Future<void> ceder(
    String id, {
    required String usuarioId,
    required String motivo,
    DateTime? fechaDevolucionEsperada,
    bool omitirValidacionesUsuario = false,
  }) => _ejecutarYRefrescar(
    () => _prestamos.ceder(
      id,
      usuarioId: usuarioId,
      motivo: motivo,
      fechaDevolucionEsperada: fechaDevolucionEsperada,
      omitirValidacionesUsuario: omitirValidacionesUsuario,
    ),
  );

  Future<void> crearDirecto({
    required String usuarioId,
    required List<String> materialIds,
    String? observaciones,
    DateTime? fechaDevolucionEsperada,
    bool omitirValidacionesUsuario = false,
  }) => _ejecutarYRefrescar(
    () => _prestamos.crearDirecto(
      usuarioId: usuarioId,
      materialIds: materialIds,
      observaciones: observaciones,
      fechaDevolucionEsperada: fechaDevolucionEsperada,
      omitirValidacionesUsuario: omitirValidacionesUsuario,
    ),
  );

  Future<void> registrarDevolucion(
    String prestamoId,
    List<ItemADevolver> items, {
    DateTime? fechaDevolucion,
    String? motivoFecha,
  }) => _ejecutarYRefrescar(
    () => _devoluciones.registrar(
      prestamoId,
      items,
      fechaDevolucion: fechaDevolucion,
      motivoFecha: motivoFecha,
    ),
  );

  // Acciones del propio usuario (app móvil del estudiante)

  Future<void> solicitar(List<String> materialIds, {String? observaciones}) =>
      _ejecutarYRefrescar(
        () => _prestamos.solicitar(materialIds, observaciones: observaciones),
      );

  Future<void> cancelarPropia(String id) =>
      _ejecutarYRefrescar(() => _prestamos.cancelarPropia(id));

  /// Ejecuta [operacion] y, si no falla, refresca los datos que dependen de ella.
  Future<void> _ejecutarYRefrescar(
    Future<Prestamo> Function() operacion,
  ) async {
    await operacion();
    _refrescarListas();
  }

  void _refrescarListas() {
    _ref.invalidate(prestamosProvider);
    _ref.invalidate(misSolicitudesProvider);
    _ref.invalidate(devolucionesPendientesProvider);
    _ref.invalidate(materialesProvider);
    _ref.invalidate(catalogoEstudianteProvider);
    _ref.invalidate(resumenDashboardProvider);
  }
}
