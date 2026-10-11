"""Rutas propias del ejecutable de escritorio: configuracion, estado y sincronizacion."""
from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import obtener_db
from app.core.dependencias import obtener_usuario_opcional, require_role
from app.esquemas.local import (
    ConectarServidor,
    ConfigurarSoloLocal,
    ConflictoRespuesta,
    EstadoLocal,
    ResumenSincronizacionRespuesta,
)
from app.modelos.usuario import Usuario
from app.sync import conflictos, estado_local, servicio_local
from app.sync.cliente_central import (
    ErrorCredenciales,
    ErrorServidor,
    ErrorSinConexion,
)
from app.sync.instancia import obtener_motor
from app.sync.motor import (
    MotorSincronizacion,
    SincronizacionEnCurso,
    SinSesionCentral,
)
from app.sync.tablas import PERSONAL

router = APIRouter(prefix="/api/local", tags=["Equipo local"])


def _exigir_admin_si_ya_configurado(db: Session, usuario: Optional[Usuario]) -> None:
    """Un equipo recien instalado se configura sin sesion; despues solo un administrador."""
    if servicio_local.hay_usuarios(db) and (usuario is None or usuario.rol != "admin"):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Solo un administrador puede hacer esto")


@router.get("/estado", response_model=EstadoLocal)
def obtener_estado(db: Session = Depends(obtener_db), motor: MotorSincronizacion = Depends(obtener_motor)):
    """Estado del equipo. No pide sesion: la pantalla de inicio lo necesita antes de entrar."""
    return servicio_local.estado(db, motor)


@router.post("/configurar-solo-local", response_model=EstadoLocal)
def configurar_solo_local(
    datos: ConfigurarSoloLocal,
    db: Session = Depends(obtener_db),
    motor: MotorSincronizacion = Depends(obtener_motor),
):
    """Crea el administrador de un equipo que trabajara sin servidor (solo si esta vacio)."""
    servicio_local.configurar_solo_local(db, datos.model_dump())
    return servicio_local.estado(db, motor)


@router.post("/conectar", response_model=EstadoLocal)
def conectar(
    datos: ConectarServidor,
    db: Session = Depends(obtener_db),
    motor: MotorSincronizacion = Depends(obtener_motor),
    usuario: Optional[Usuario] = Depends(obtener_usuario_opcional),
):
    """Une el equipo a un servidor central y descarga sus datos."""
    _exigir_admin_si_ya_configurado(db, usuario)
    servicio_local.conectar_servidor(
        db, motor, datos.servidor_url, datos.usuario, datos.contrasena, datos.reemplazar_datos_locales
    )
    return servicio_local.estado(db, motor)


@router.post("/desconectar", response_model=EstadoLocal)
def desconectar(
    db: Session = Depends(obtener_db),
    motor: MotorSincronizacion = Depends(obtener_motor),
    usuario: Usuario = Depends(require_role(["admin"])),
):
    """El equipo deja de sincronizar y trabaja solo."""
    servicio_local.desconectar_servidor(db, motor)
    return servicio_local.estado(db, motor)


@router.post("/sincronizar", response_model=ResumenSincronizacionRespuesta)
def sincronizar(
    db: Session = Depends(obtener_db),
    motor: MotorSincronizacion = Depends(obtener_motor),
    usuario: Usuario = Depends(require_role(list(PERSONAL))),
):
    """Sincroniza ahora, sin esperar al ciclo automatico."""
    try:
        resumen = motor.sincronizar()
    except SinSesionCentral as error:
        raise HTTPException(status.HTTP_409_CONFLICT, str(error))
    except SincronizacionEnCurso:
        raise HTTPException(status.HTTP_409_CONFLICT, "Ya hay una sincronizacion en curso")
    except ErrorSinConexion:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "Sin conexion con el servidor")
    except (ErrorCredenciales, ErrorServidor) as error:
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, str(error))
    return ResumenSincronizacionRespuesta(**resumen.__dict__, estado=servicio_local.estado(db, motor))


@router.get("/conflictos", response_model=List[ConflictoRespuesta])
def listar_conflictos(
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(list(PERSONAL))),
):
    """Cambios hechos sin conexion que el servidor rechazo y esperan una decision."""
    return [
        ConflictoRespuesta(
            id=lote.id, creado_en=lote.creado_en, descripcion=lote.descripcion, mensaje=lote.mensaje
        )
        for lote in conflictos.listar(db)
    ]


@router.post("/conflictos/{lote_id}/reintentar", response_model=EstadoLocal)
def reintentar_conflicto(
    lote_id: UUID,
    db: Session = Depends(obtener_db),
    motor: MotorSincronizacion = Depends(obtener_motor),
    usuario: Usuario = Depends(require_role(list(PERSONAL))),
):
    """Vuelve a poner el cambio en la bandeja de salida."""
    conflictos.reintentar(db, lote_id)
    return servicio_local.estado(db, motor)


@router.post("/conflictos/{lote_id}/descartar", response_model=EstadoLocal)
def descartar_conflicto(
    lote_id: UUID,
    db: Session = Depends(obtener_db),
    motor: MotorSincronizacion = Depends(obtener_motor),
    usuario: Usuario = Depends(require_role(list(PERSONAL))),
):
    """Deshace el cambio local y recupera la version del servidor (requiere conexion)."""
    url = estado_local.servidor_url(db)
    credenciales = motor.credenciales.obtener()
    if not url or credenciales is None:
        raise HTTPException(status.HTTP_409_CONFLICT, "Inicia sesion con conexion al servidor para descartar")

    cliente = motor.crear_cliente(url)
    try:
        cliente.iniciar_sesion(*credenciales)
        conflictos.descartar(db, cliente, lote_id)
    except ErrorSinConexion:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "Se necesita conexion con el servidor para descartar")
    except (ErrorCredenciales, ErrorServidor) as error:
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, str(error))
    finally:
        cliente.cerrar()
    return servicio_local.estado(db, motor)
