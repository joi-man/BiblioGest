from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from app.core.database import obtener_db
from app.core.dependencias import obtener_usuario_actual
from app.esquemas.auth import LoginRequest, LoginResponse, UsuarioRespuesta
from app.modelos.usuario import Usuario
from app.servicios import auth_servicio

router = APIRouter(prefix="/api/auth", tags=["Autenticacion"])


@router.post("/login", response_model=LoginResponse)
def login(
    datos: LoginRequest,
    request: Request,
    db: Session = Depends(obtener_db),
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
