"""Dependencias compartidas por las rutas de prestamos."""
from fastapi import Depends
from sqlalchemy.orm import Session

from app.core.constantes_roles import ROLES_PERSONAL
from app.core.database import obtener_db
from app.core.dependencias import require_role
from app.servicios.prestamos import vencimiento_servicio

# Exige que quien llama sea admin o bibliotecario.
personal_requerido = require_role(list(ROLES_PERSONAL))


def vencimientos_al_dia(db: Session = Depends(obtener_db)) -> None:
    """Expira reservas y marca vencidos antes de atender la peticion.

    Asi cualquier consulta de prestamos ve el estado real sin necesitar una
    tarea programada.
    """
    vencimiento_servicio.actualizar_vencimientos(db)
