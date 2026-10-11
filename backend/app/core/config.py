from pydantic_settings import BaseSettings
from typing import Optional


class Configuracion(BaseSettings):
    # Base de datos
    BASE_DATOS_URL: str = "postgresql+psycopg://bibliogest_user:bibliogest_password@db:5432/bibliogest_db"
    BASE_DATOS_URL_LOCAL: str = "postgresql+psycopg://bibliogest_user:bibliogest_password@localhost:5433/bibliogest_db"
    
    # JWT
    SECRETO_JWT: str = "tu-secreto-super-seguro-cambiar-en-produccion"
    ALGORITMO_JWT: str = "HS256"
    EXPIRACION_TOKEN_MINUTOS: int = 60
    
    # Correo (SMTP) - para Gmail usar una "contrasena de aplicacion"
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PUERTO: int = 587
    SMTP_USUARIO: str = ""
    SMTP_CLAVE: str = ""
    SMTP_REMITENTE: str = ""

    # Recuperacion de contrasena
    CODIGO_RESET_EXPIRACION_MINUTOS: int = 15
    CODIGO_RESET_MAX_INTENTOS: int = 5

    # Reglas de prestamo
    PLAZO_PRESTAMO_HORAS_DEFECTO: int = 168  # 7 dias, si ni el material ni la categoria definen plazo
    MAX_PRESTAMOS_ACTIVOS: int = 3  # items que un usuario puede tener a la vez (reservados o prestados)
    BLOQUEAR_SI_HAY_VENCIDOS: bool = True  # impide nuevas solicitudes si tiene prestamos vencidos
    HORAS_RETIRO_RESERVA: int = 24  # tiempo para retirar una reserva aprobada antes de que expire

    # Multas (opcionales: con MULTAS_HABILITADAS=False el sistema nunca calcula ni muestra multas)
    MULTAS_HABILITADAS: bool = False
    MULTA_POR_DIA_RETRASO: float = 0.0
    MULTA_DANO_MENOR: float = 0.0
    MULTA_DANO_MAYOR: float = 0.0

    # Aplicacion
    NOMBRE_APLICACION: str = "BiblioGest API"
    VERSION: str = "1.0.0"
    MODO_DEBUG: bool = False
    
    class Config:
        env_file = ".env"
        case_sensitive = True


configuracion = Configuracion()
