"""Equipo: configuracion inicial y estado del ejecutable de escritorio."""
from typing import Any, Dict, Optional

from fastapi import HTTPException, status
from sqlalchemy import delete, func, select
from sqlalchemy.orm import Session

from app.core import reloj
from app.core.seguridad import hashear_contrasena
from app.modelos.sincronizacion import ConfiguracionLocal, SyncLote
from app.modelos.usuario import Usuario
from app.sync import estado_local
from app.sync.captura import aplicando_datos_del_servidor
from app.sync.cliente_central import (
    ErrorCredenciales,
    ErrorServidor,
    ErrorSinConexion,
)
from app.sync.motor import MotorSincronizacion, contar_pendientes
from app.sync.tablas import PERSONAL, TABLAS


def hay_usuarios(db: Session) -> bool:
    return db.execute(select(func.count()).select_from(Usuario)).scalar_one() > 0


def estado(db: Session, motor: MotorSincronizacion) -> Dict[str, Any]:
    """Lo que la pantalla necesita saber: configuracion, conexion y trabajo pendiente."""
    pendientes, conflictos = contar_pendientes(db)
    return {
        "modo": "local",
        "configurado": hay_usuarios(db),
        "servidor_url": estado_local.servidor_url(db),
        "conectado": motor.conectado,
        "sincronizando": motor.sincronizando,
        "pendientes": pendientes,
        "conflictos": conflictos,
        "ultima_sincronizacion": estado_local.leer(db, estado_local.CLAVE_ULTIMA_SINCRONIZACION),
        "ultimo_error": estado_local.leer(db, estado_local.CLAVE_ULTIMO_ERROR),
        "requiere_inicio_de_sesion": (
            estado_local.servidor_url(db) is not None and motor.credenciales.obtener() is None
        ),
    }


def configurar_solo_local(db: Session, datos: Dict[str, Any]) -> Usuario:
    """Crea el primer administrador de un equipo que trabajara sin servidor."""
    if hay_usuarios(db):
        raise HTTPException(status.HTTP_409_CONFLICT, "Este equipo ya esta configurado")

    admin = Usuario(
        username=datos["username"],
        correo_electronico=datos["correo_electronico"],
        contrasena_hash=hashear_contrasena(datos["contrasena"]),
        numero_documento=datos["numero_documento"],
        nombre=datos["nombre"],
        apellido=datos["apellido"],
        rol="admin",
        activo=True,
    )
    db.add(admin)
    db.commit()
    return admin


def vaciar_datos(db: Session) -> None:
    """Borra los datos replicados, la bandeja de salida y los cursores de descarga."""
    with aplicando_datos_del_servidor(db):
        for tabla in reversed(TABLAS):
            db.execute(delete(tabla.modelo))
        db.execute(delete(SyncLote))
        db.commit()
    estado_local.borrar_cursores(db)


def conectar_servidor(
    db: Session,
    motor: MotorSincronizacion,
    url: str,
    usuario: str,
    contrasena: str,
    reemplazar_datos_locales: bool,
) -> None:
    """Une este equipo a un servidor y descarga sus datos.

    Los datos que tuviera el equipo se reemplazan por los del servidor, por eso
    hace falta confirmarlo cuando ya hay informacion.
    """
    url = url.strip().rstrip("/")
    if not url.startswith(("http://", "https://")):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "La direccion debe empezar con http:// o https://")

    cliente = motor.crear_cliente(url)
    try:
        datos_usuario = cliente.iniciar_sesion(usuario, contrasena)
    except ErrorSinConexion:
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, "No se pudo conectar con el servidor")
    except ErrorCredenciales:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Usuario o contrasena incorrectos en el servidor")
    except ErrorServidor as error:
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, f"El servidor respondio con un error: {error}")
    finally:
        cliente.cerrar()

    if datos_usuario["rol"] not in PERSONAL:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Solo el personal de la biblioteca puede usar este programa")

    if hay_usuarios(db) and not reemplazar_datos_locales:
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            "Este equipo ya tiene datos propios. Al conectarlo se reemplazaran por los del servidor.",
        )

    vaciar_datos(db)
    estado_local.escribir(db, estado_local.CLAVE_SERVIDOR_URL, url)
    motor.credenciales.recordar(usuario, contrasena)
    motor.sincronizar()


def desconectar_servidor(db: Session, motor: MotorSincronizacion) -> None:
    """El equipo pasa a trabajar solo. Los cambios pendientes dejan de enviarse."""
    estado_local.escribir(db, estado_local.CLAVE_SERVIDOR_URL, None)
    estado_local.escribir(db, estado_local.CLAVE_ULTIMO_ERROR, None)
    motor.credenciales.olvidar()
    motor.conectado = None


def recordar_inicio_de_sesion(
    db: Session, motor: MotorSincronizacion, usuario: Usuario, identificador: str, contrasena: str
) -> None:
    """Guarda (en memoria) las credenciales de quien inicio sesion, para sincronizar con ellas."""
    if estado_local.servidor_url(db) and usuario.rol in PERSONAL:
        motor.credenciales.recordar(identificador, contrasena)
