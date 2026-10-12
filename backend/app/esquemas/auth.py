from pydantic import BaseModel, EmailStr, Field


class LoginRequest(BaseModel):
    correo_o_usuario: str
    contrasena: str


class OlvidoContrasenaRequest(BaseModel):
    correo: EmailStr


class CodigoExternoRequest(BaseModel):
    """Codigo que un equipo con el ejecutable pide enviar por correo desde el servidor."""

    correo: EmailStr
    codigo: str = Field(..., min_length=6, max_length=6, pattern=r"^\d{6}$")


class RestablecerContrasenaRequest(BaseModel):
    correo: EmailStr
    codigo: str = Field(..., min_length=6, max_length=6, pattern=r"^\d{6}$")
    nueva_contrasena: str = Field(..., min_length=6)


class CambiarContrasenaRequest(BaseModel):
    """Cambio de contrasena de quien tiene la sesion iniciada."""

    contrasena_actual: str = Field(..., min_length=1)
    nueva_contrasena: str = Field(..., min_length=6, max_length=72)


class MensajeRespuesta(BaseModel):
    mensaje: str


class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    usuario: "UsuarioRespuesta"


class UsuarioRespuesta(BaseModel):
    id: str
    username: str
    correo_electronico: str
    numero_documento: str
    nombre: str
    apellido: str
    rol: str
    telefono: str | None = None
    activo: bool

    class Config:
        from_attributes = True


# Resolver referencia circular
LoginResponse.model_rebuild()
