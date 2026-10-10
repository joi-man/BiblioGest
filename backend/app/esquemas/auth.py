from pydantic import BaseModel, EmailStr, Field


class LoginRequest(BaseModel):
    correo_o_usuario: str
    contrasena: str


class OlvidoContrasenaRequest(BaseModel):
    correo: EmailStr


class RestablecerContrasenaRequest(BaseModel):
    correo: EmailStr
    codigo: str = Field(..., min_length=6, max_length=6, pattern=r"^\d{6}$")
    nueva_contrasena: str = Field(..., min_length=6)


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
