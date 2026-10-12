import logging

from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from app.core.config import configuracion
from app.core.database import es_modo_local, obtener_db
from app.core.dependencias import obtener_usuario_actual
from app.esquemas.auth import (
    CambiarContrasenaRequest,
    CodigoExternoRequest,
    LoginRequest,
    LoginResponse,
    MensajeRespuesta,
    OlvidoContrasenaRequest,
    RestablecerContrasenaRequest,
    UsuarioRespuesta,
)
from app.modelos.usuario import Usuario
from app.servicios import auth_servicio, email_servicio, recuperacion_servicio
from app.servicios.limitador import LimitadorPorClave
from app.servicios.usuario_servicio import obtener_usuario_por_correo
from app.sync import estado_local
from app.sync.cliente_central import ClienteCentral
from app.sync import servicio_local
from app.sync.instancia import obtener_motor
from app.sync.motor import MotorSincronizacion

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/auth", tags=["Autenticacion"])

# Limites del envio de codigos pedidos por equipos con el ejecutable: por correo y en total.
_limite_por_correo = LimitadorPorClave(maximo=3, segundos=15 * 60)
_limite_global = LimitadorPorClave(maximo=60, segundos=60 * 60)
# Intentos de cambio de contrasena por usuario (frena adivinar la actual con una sesion robada).
_limite_cambio_contrasena = LimitadorPorClave(maximo=10, segundos=15 * 60)

MENSAJE_CODIGO = "Si el correo esta registrado, recibiras un codigo de recuperacion."


def _enviar_codigo(usuario: Usuario, codigo: str) -> bool:
    return email_servicio.enviar_correo(
        usuario.correo_electronico,
        "Codigo de recuperacion de contrasena - BiblioGest",
        f"Hola {usuario.nombre},\n\n"
        f"Tu codigo de recuperacion es: {codigo}\n\n"
        f"Vence en {configuracion.CODIGO_RESET_EXPIRACION_MINUTOS} minutos. "
        "Si no lo solicitaste, ignora este correo.",
    )


def _enviar_codigo_por_servidor(url: str, correo: str, codigo: str) -> None:
    """Pide al servidor central que envie el codigo (el equipo local no guarda la clave del correo)."""
    cliente = ClienteCentral(url)
    try:
        cliente.enviar_codigo_recuperacion(correo, codigo)
    except Exception:
        logger.exception("No se pudo pedir al servidor el envio del codigo")
    finally:
        cliente.cerrar()


@router.post("/login", response_model=LoginResponse)
def login(
    datos: LoginRequest,
    request: Request,
    db: Session = Depends(obtener_db),
    motor: MotorSincronizacion = Depends(obtener_motor),
):
    """Iniciar sesion con correo o username y contrasena."""
    ip_address = request.client.host if request.client else None
    user_agent = request.headers.get("user-agent")
    
    usuario = auth_servicio.autenticar_usuario(
        db=db,
        correo_o_usuario=datos.correo_o_usuario,
        contrasena=datos.contrasena,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    
    if usuario is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Correo/usuario o contrasena incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    token = auth_servicio.crear_token_usuario(usuario)

    if es_modo_local():
        # El equipo usara estas credenciales (solo en memoria) para sincronizar con el servidor.
        servicio_local.recordar_inicio_de_sesion(
            db, motor, usuario, datos.correo_o_usuario, datos.contrasena
        )

    return LoginResponse(
        access_token=token,
        usuario=UsuarioRespuesta(
            id=str(usuario.id),
            username=usuario.username,
            correo_electronico=usuario.correo_electronico,
            numero_documento=usuario.numero_documento,
            nombre=usuario.nombre,
            apellido=usuario.apellido,
            rol=usuario.rol,
            telefono=usuario.telefono,
            activo=usuario.activo,
        ),
    )


@router.post("/olvide-contrasena", response_model=MensajeRespuesta)
def olvide_contrasena(
    datos: OlvidoContrasenaRequest,
    request: Request,
    background_tasks: BackgroundTasks,
    db: Session = Depends(obtener_db),
):
    """Enviar un codigo de recuperacion al correo. Responde igual exista o no el correo.

    En el ejecutable de escritorio el codigo se genera en el equipo y el correo lo
    envia el servidor central (el instalador no lleva la clave del correo); eso
    requiere conexion a internet, salvo que el equipo tenga su propia clave.
    """
    url_servidor = None
    if es_modo_local() and not configuracion.SMTP_CLAVE:
        url_servidor = estado_local.servidor_url(db)
        cliente = ClienteCentral(url_servidor) if url_servidor else None
        try:
            hay_servidor = cliente is not None and cliente.hay_conexion()
        finally:
            if cliente is not None:
                cliente.cerrar()
        if not hay_servidor:
            # Se avisa antes de generar nada, asi no depende de que el correo exista.
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Para recibir el codigo necesitas conexion a internet con el servidor.",
            )

    resultado = recuperacion_servicio.solicitar_codigo(
        db=db,
        correo=datos.correo,
        ip_address=request.client.host if request.client else None,
        user_agent=request.headers.get("user-agent"),
    )
    if resultado is not None:
        usuario, codigo = resultado
        if url_servidor:
            background_tasks.add_task(
                _enviar_codigo_por_servidor, url_servidor, usuario.correo_electronico, codigo
            )
        else:
            background_tasks.add_task(_enviar_codigo, usuario, codigo)
    return MensajeRespuesta(mensaje=MENSAJE_CODIGO)


@router.post("/codigo-externo", response_model=MensajeRespuesta)
def enviar_codigo_externo(
    datos: CodigoExternoRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(obtener_db),
):
    """Enviar por correo un codigo generado por un equipo con el ejecutable.

    Solo existe en el servidor central, solo escribe a cuentas activas registradas,
    con un texto fijo y con limites de envio. Responde igual exista o no el correo.
    """
    if es_modo_local():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No disponible")
    correo = datos.correo.lower()
    if not _limite_global.permitir("global") or not _limite_por_correo.permitir(correo):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Demasiadas solicitudes. Intenta de nuevo en unos minutos.",
        )
    usuario = obtener_usuario_por_correo(db, correo)
    if usuario is not None and usuario.activo:
        background_tasks.add_task(_enviar_codigo, usuario, datos.codigo)
    return MensajeRespuesta(mensaje=MENSAJE_CODIGO)


@router.post("/restablecer-contrasena", response_model=MensajeRespuesta)
def restablecer_contrasena(
    datos: RestablecerContrasenaRequest,
    request: Request,
    db: Session = Depends(obtener_db),
):
    """Cambiar la contrasena usando el codigo recibido por correo."""
    ok = recuperacion_servicio.restablecer_contrasena(
        db=db,
        correo=datos.correo,
        codigo=datos.codigo,
        nueva_contrasena=datos.nueva_contrasena,
        ip_address=request.client.host if request.client else None,
        user_agent=request.headers.get("user-agent"),
    )
    if not ok:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Codigo invalido o expirado",
        )
    return MensajeRespuesta(mensaje="Contrasena actualizada correctamente")


@router.post("/cambiar-contrasena", response_model=MensajeRespuesta)
def cambiar_contrasena(
    datos: CambiarContrasenaRequest,
    request: Request,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Cambiar la contrasena de la sesion actual, comprobando la contrasena actual."""
    if not _limite_cambio_contrasena.permitir(str(usuario.id)):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Demasiados intentos. Intenta de nuevo en unos minutos.",
        )
    if datos.nueva_contrasena == datos.contrasena_actual:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La nueva contrasena debe ser distinta de la actual",
        )
    ok = auth_servicio.cambiar_contrasena(
        db=db,
        usuario=usuario,
        contrasena_actual=datos.contrasena_actual,
        nueva_contrasena=datos.nueva_contrasena,
        ip_address=request.client.host if request.client else None,
        user_agent=request.headers.get("user-agent"),
    )
    if not ok:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La contrasena actual no es correcta",
        )
    return MensajeRespuesta(mensaje="Contrasena actualizada correctamente")


@router.get("/yo", response_model=UsuarioRespuesta)
def obtener_usuario_actual_endpoint(
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Obtener informacion del usuario actual."""
    return UsuarioRespuesta(
        id=str(usuario.id),
        username=usuario.username,
        correo_electronico=usuario.correo_electronico,
        numero_documento=usuario.numero_documento,
        nombre=usuario.nombre,
        apellido=usuario.apellido,
        rol=usuario.rol,
        telefono=usuario.telefono,
        activo=usuario.activo,
    )
