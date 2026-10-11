"""Equipo: hilo que sincroniza solo cada cierto tiempo mientras el programa esta abierto."""
import logging
import threading

from sqlalchemy.orm import sessionmaker

from app.core.config import configuracion
from app.sync import estado_local
from app.sync.cliente_central import ErrorCredenciales, ErrorServidor, ErrorSinConexion
from app.sync.motor import MotorSincronizacion, SincronizacionEnCurso, SinSesionCentral

registro = logging.getLogger("bibliogest.sync")


def iniciar_bucle(motor: MotorSincronizacion, fabrica_sesion: sessionmaker) -> threading.Event:
    """Arranca el hilo de sincronizacion. Devuelve el evento que lo detiene al activarse."""
    detener = threading.Event()

    def _trabajar() -> None:
        while not detener.wait(configuracion.SYNC_INTERVALO_SEGUNDOS):
            _intentar(motor, fabrica_sesion)

    threading.Thread(target=_trabajar, name="sincronizacion", daemon=True).start()
    return detener


def _intentar(motor: MotorSincronizacion, fabrica_sesion: sessionmaker) -> None:
    """Una vuelta del ciclo. Los errores esperables solo actualizan el estado visible."""
    with fabrica_sesion() as db:
        url = estado_local.servidor_url(db)
    if not url:
        return

    try:
        motor.sincronizar()
    except SinSesionCentral:
        _comprobar_conexion(motor, url)  # nadie ha iniciado sesion, pero se puede avisar si hay red
    except (SincronizacionEnCurso, ErrorSinConexion, ErrorCredenciales, ErrorServidor):
        pass  # el motor ya dejo el motivo en el estado
    except Exception:  # noqa: BLE001 - el hilo no debe morir por un error inesperado
        registro.exception("Error inesperado al sincronizar")


def _comprobar_conexion(motor: MotorSincronizacion, url: str) -> None:
    cliente = motor.crear_cliente(url)
    try:
        motor.conectado = cliente.hay_conexion()
    finally:
        cliente.cerrar()
