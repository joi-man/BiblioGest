"""El motor de sincronizacion unico de este proceso (solo se usa en modo local)."""
from app.core.database import SesionLocal
from app.sync.motor import MotorSincronizacion

motor = MotorSincronizacion(SesionLocal)


def obtener_motor() -> MotorSincronizacion:
    """Dependency de FastAPI; las pruebas la sustituyen por un motor propio."""
    return motor
