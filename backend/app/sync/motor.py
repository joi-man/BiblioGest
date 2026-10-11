"""Equipo: coordina el envio de cambios pendientes y la descarga de novedades."""
import threading
from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Set, Tuple

from sqlalchemy import select
from sqlalchemy.orm import Session, sessionmaker

from app.core import reloj
from app.core.config import configuracion
from app.modelos.sincronizacion import LOTE_CONFLICTO, LOTE_PENDIENTE, SyncLote
from app.sync import descarga, estado_local
from app.sync.cliente_central import (
    ClienteCentral,
    ErrorCredenciales,
    ErrorServidor,
    ErrorSinConexion,
)
from app.sync.tablas import TABLAS_POR_NOMBRE

Clave = Tuple[str, str]


class SinSesionCentral(Exception):
    """No hay credenciales para hablar con el servidor (nadie inicio sesion en este equipo)."""


class SincronizacionEnCurso(Exception):
    """Ya hay una sincronizacion corriendo."""


@dataclass
class ResumenSincronizacion:
    enviados: int = 0  # lotes aceptados por el servidor
    conflictos: int = 0  # lotes rechazados
    recibidos: int = 0  # filas descargadas


class CredencialesCentrales:
    """Usuario y contrasena con los que este equipo habla con el servidor.

    Se toman del inicio de sesion de la persona y viven solo en memoria: nunca
    se guardan en disco.
    """

    def __init__(self) -> None:
        self._candado = threading.Lock()
        self._valor: Optional[Tuple[str, str]] = None

    def recordar(self, usuario: str, contrasena: str) -> None:
        with self._candado:
            self._valor = (usuario, contrasena)

    def olvidar(self) -> None:
        with self._candado:
            self._valor = None

    def obtener(self) -> Optional[Tuple[str, str]]:
        with self._candado:
            return self._valor


FabricaCliente = Callable[[str], ClienteCentral]


class MotorSincronizacion:
    """Sincroniza la base local con el servidor central.

    Orden de una ronda: 1) enviar lotes pendientes, 2) descargar cambios del
    servidor (sin pisar lo que aun no se envio), 3) refrescar filas de lotes
    automaticos que el servidor rechazo.
    """

    def __init__(
        self,
        fabrica_sesion: sessionmaker,
        credenciales: Optional[CredencialesCentrales] = None,
        fabrica_cliente: FabricaCliente = ClienteCentral,
    ) -> None:
        self._fabrica_sesion = fabrica_sesion
        self.credenciales = credenciales or CredencialesCentrales()
        self._fabrica_cliente = fabrica_cliente
        self._candado = threading.Lock()

        # Estado visible para la pantalla
        self.sincronizando = False
        self.conectado: Optional[bool] = None  # None = aun no se sabe

    def crear_cliente(self, url: str) -> ClienteCentral:
        """Cliente para hablar con el servidor de `url`."""
        return self._fabrica_cliente(url)

    # ------------------------------------------------------------------ rondas
    def sincronizar(self) -> ResumenSincronizacion:
        """Ejecuta una ronda completa. Lanza una excepcion si no pudo terminarla."""
        if not self._candado.acquire(blocking=False):
            raise SincronizacionEnCurso()
        self.sincronizando = True
        try:
            with self._fabrica_sesion() as db:
                return self._ronda(db)
        finally:
            self.sincronizando = False
            self._candado.release()

    def _ronda(self, db: Session) -> ResumenSincronizacion:
        url = estado_local.servidor_url(db)
        if not url:
            raise SinSesionCentral("Este equipo no esta conectado a ningun servidor")
        credenciales = self.credenciales.obtener()
        if credenciales is None:
            raise SinSesionCentral("Inicia sesion para sincronizar con el servidor")

        cliente = self._fabrica_cliente(url)
        try:
            cliente.iniciar_sesion(*credenciales)
            self.conectado = True
            resumen = ResumenSincronizacion()
            a_refrescar = self._enviar_pendientes(db, cliente, resumen)
            resumen.recibidos = descarga.descargar_cambios(
                db, cliente, estado_local.claves_sin_sincronizar(db)
            )
            self._refrescar(db, cliente, a_refrescar)
            estado_local.marcar_sincronizado(db, reloj.ahora_utc())
            return resumen
        except ErrorSinConexion as error:
            self.conectado = False
            self._guardar_error(db, "Sin conexion con el servidor")
            raise error
        except ErrorCredenciales as error:
            self.conectado = True
            self._guardar_error(db, "El servidor rechazo tu usuario o contrasena; vuelve a iniciar sesion")
            raise error
        except ErrorServidor as error:
            self._guardar_error(db, f"El servidor respondio con un error: {error}")
            raise error
        finally:
            cliente.cerrar()

    @staticmethod
    def _guardar_error(db: Session, mensaje: str) -> None:
        db.rollback()
        estado_local.escribir(db, estado_local.CLAVE_ULTIMO_ERROR, mensaje)

    # ------------------------------------------------------------------- envio
    def _enviar_pendientes(
        self, db: Session, cliente: ClienteCentral, resumen: ResumenSincronizacion
    ) -> Dict[str, Set[str]]:
        """Envia los lotes pendientes en orden. Devuelve filas a refrescar {tabla: {ids}}."""
        a_refrescar: Dict[str, Set[str]] = {}
        consulta = (
            select(SyncLote)
            .where(SyncLote.estado == LOTE_PENDIENTE)
            .order_by(SyncLote.creado_en, SyncLote.id)
        )
        pendientes = list(db.execute(consulta).scalars().all())
        por_envio = configuracion.SYNC_LOTES_POR_ENVIO

        for inicio in range(0, len(pendientes), por_envio):
            tanda = pendientes[inicio : inicio + por_envio]
            resultados = cliente.enviar_lotes([{"id": str(l.id), "filas": l.filas} for l in tanda])
            por_id = {str(l.id): l for l in tanda}

            for resultado in resultados:
                lote = por_id[resultado["id"]]
                if resultado["estado"] == "aplicado":
                    db.delete(lote)
                    resumen.enviados += 1
                elif resultado["estado"] == "conflicto":
                    resumen.conflictos += 1
                    self._resolver_rechazo(db, lote, resultado.get("mensaje"), a_refrescar)
                else:
                    lote.intentos += 1
                    lote.mensaje = resultado.get("mensaje")
                    db.commit()
                    raise ErrorServidor(resultado.get("mensaje") or "Error al aplicar un lote")
            db.commit()
        return a_refrescar

    @staticmethod
    def _resolver_rechazo(
        db: Session, lote: SyncLote, mensaje: Optional[str], a_refrescar: Dict[str, Set[str]]
    ) -> None:
        """Un lote automatico rechazado se descarta; uno hecho por una persona espera su decision."""
        if lote.automatico:
            for tabla, id_texto in estado_local.claves_de(lote):
                a_refrescar.setdefault(tabla, set()).add(id_texto)
            db.delete(lote)
        else:
            lote.estado = LOTE_CONFLICTO
            lote.mensaje = mensaje

    def _refrescar(self, db: Session, cliente: ClienteCentral, a_refrescar: Dict[str, Set[str]]) -> None:
        """Trae del servidor la version actual de filas cuyo lote automatico se descarto."""
        protegidas = estado_local.claves_sin_sincronizar(db)
        for tabla_nombre, ids in a_refrescar.items():
            tabla = TABLAS_POR_NOMBRE[tabla_nombre]
            filas = cliente.obtener_filas(tabla_nombre, sorted(ids))
            descarga.aplicar_filas(db, tabla, filas, protegidas)


def contar_pendientes(db: Session) -> Tuple[int, int]:
    """(lotes pendientes de enviar, lotes en conflicto)."""
    return (
        estado_local.contar_lotes(db, LOTE_PENDIENTE),
        estado_local.contar_lotes(db, LOTE_CONFLICTO),
    )
