"""Metricas del panel de inicio. Solo lee datos."""
from datetime import datetime, timedelta

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core import reloj
from app.core.hora_paraguay import inicio_de_hoy_utc
from app.core.constantes_inventario import (
    ESTADO_DISPONIBLE,
    ESTADO_FUERA_DE_SERVICIO,
    ESTADO_PRESTADO,
    ESTADO_RESERVADO,
    ESTADO_VENCIDO,
)
from app.core.constantes_prestamo import (
    PRESTAMO_ACTIVO,
    PRESTAMO_APROBADO,
    PRESTAMO_PENDIENTE,
    PRESTAMO_VENCIDO,
)
from app.esquemas.dashboard import ResumenDashboard, ResumenMateriales, ResumenPrestamos
from app.modelos.devolucion import Devolucion
from app.modelos.material import Material
from app.modelos.prestamo_cabecera import PrestamoCabecera


def _contar_por(db: Session, columna, *condiciones) -> dict[str, int]:
    """Cuenta filas agrupadas por el valor de `columna`."""
    consulta = select(columna, func.count()).where(*condiciones).group_by(columna)
    return {valor: cantidad for valor, cantidad in db.execute(consulta).all()}


def _resumen_materiales(db: Session) -> ResumenMateriales:
    por_estado = _contar_por(db, Material.estado, Material.eliminado == False)  # noqa: E712
    return ResumenMateriales(
        total=sum(por_estado.values()),
        disponibles=por_estado.get(ESTADO_DISPONIBLE, 0),
        reservados=por_estado.get(ESTADO_RESERVADO, 0),
        prestados=por_estado.get(ESTADO_PRESTADO, 0),
        vencidos=por_estado.get(ESTADO_VENCIDO, 0),
        fuera_de_servicio=por_estado.get(ESTADO_FUERA_DE_SERVICIO, 0),
    )


def _contar_prestamos(db: Session, *condiciones) -> int:
    consulta = select(func.count(PrestamoCabecera.id)).where(
        PrestamoCabecera.eliminado == False,  # noqa: E712
        *condiciones,
    )
    return db.execute(consulta).scalar_one()


def _resumen_prestamos(db: Session, ahora: datetime) -> ResumenPrestamos:
    inicio_dia = inicio_de_hoy_utc(ahora)  # el dia en Paraguay

    devueltos_hoy = db.execute(
        select(func.count(Devolucion.id)).where(
            Devolucion.fecha_devolucion >= inicio_dia,
            Devolucion.eliminado == False,  # noqa: E712
        )
    ).scalar_one()

    return ResumenPrestamos(
        solicitudes_pendientes=_contar_prestamos(db, PrestamoCabecera.estado == PRESTAMO_PENDIENTE),
        por_retirar=_contar_prestamos(db, PrestamoCabecera.estado == PRESTAMO_APROBADO),
        activos=_contar_prestamos(db, PrestamoCabecera.estado == PRESTAMO_ACTIVO),
        vencidos=_contar_prestamos(db, PrestamoCabecera.estado == PRESTAMO_VENCIDO),
        por_vencer_24h=_contar_prestamos(
            db,
            PrestamoCabecera.estado == PRESTAMO_ACTIVO,
            PrestamoCabecera.fecha_devolucion_esperada <= ahora + timedelta(hours=24),
        ),
        entregados_hoy=_contar_prestamos(db, PrestamoCabecera.fecha_prestamo >= inicio_dia),
        devueltos_hoy=devueltos_hoy,
    )


def obtener_resumen(db: Session) -> ResumenDashboard:
    """Arma las metricas de materiales y prestamos para el panel de inicio."""
    ahora = reloj.ahora_utc()
    return ResumenDashboard(
        materiales=_resumen_materiales(db),
        prestamos=_resumen_prestamos(db, ahora),
    )
