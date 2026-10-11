from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from app.core.config import configuracion
from app.core.database import es_modo_local, obtener_db
from app.core.dependencias import obtener_usuario_actual
from app.esquemas.auth import (
    LoginRequest,
    LoginResponse,
    MensajeRespuesta,
    OlvidoContrasenaRequest,
    RestablecerContrasenaRequest,
    UsuarioRespuesta,
)
from app.modelos.usuario import Usuario
from app.servicios import auth_servicio, email_servicio, recuperacion_servicio
from app.sync import servicio_local
from app.sync.instancia import obtener_motor
from app.sync.motor import MotorSincronizacion

router = APIRouter(prefix="/api/auth", tags=["Autenticacion"])


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
    """Enviar un codigo de recuperacion al correo. Responde igual exista o no el correo."""
    resultado = recuperacion_servicio.solicitar_codigo(
        db=db,
        correo=datos.correo,
        ip_address=request.client.host if request.client else None,
        user_agent=request.headers.get("user-agent"),
    )
    if resultado is not None:
        usuario, codigo = resultado
        background_tasks.add_task(
            email_servicio.enviar_correo,
            usuario.correo_electronico,
            "Codigo de recuperacion de contrasena - BiblioGest",
            f"Hola {usuario.nombre},\n\n"
            f"Tu codigo de recuperacion es: {codigo}\n\n"
            f"Vence en {configuracion.CODIGO_RESET_EXPIRACION_MINUTOS} minutos. "
            "Si no lo solicitaste, ignora este correo.",
        )
    return MensajeRespuesta(
        mensaje="Si el correo esta registrado, recibiras un codigo de recuperacion."
    )


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
