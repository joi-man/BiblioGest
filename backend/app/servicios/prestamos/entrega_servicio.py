"""Entrega de materiales: desde una solicitud o como prestamo directo en mostrador."""
from datetime import datetime
from typing import Optional
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core import reloj
from app.core.constantes_prestamo import PRESTAMO_ACTIVO, PRESTAMO_PENDIENTE
from app.esquemas.prestamo_cabecera import PrestamoDirectoCrear
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.modelos.usuario import Usuario
from app.servicios.prestamos import (
    aprobacion_servicio,
    auditoria_prestamo,
    consulta_prestamo_servicio,
    estado_prestamo_servicio,
    maquina_estados,
    material_estado_servicio,
    plazo_servicio,
    prestamo_factory,
    reglas_prestamo,
)


def _validar_fecha_limite(fecha: Optional[datetime], ahora: datetime) -> None:
    """Si el personal fija la fecha limite a mano, debe ser futura."""
    if fecha is not None and fecha <= ahora:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La fecha de devolucion debe ser posterior a este momento",
        )


def _fijar_plazos(prestamo: PrestamoCabecera, ahora: datetime, fecha_fija: Optional[datetime]) -> None:
    """Asigna a cada item su fecha limite: la indicada o la calculada segun su plazo."""
    for detalle in prestamo.detalles:
        detalle.fecha_devolucion_esperada = fecha_fija or plazo_servicio.fecha_limite(
            detalle.material, ahora
        )


def entregar(
    db: Session,
    prestamo_id: UUID,
    personal: Usuario,
    fecha_devolucion_esperada: Optional[datetime] = None,
) -> PrestamoCabecera:
    """Entrega al usuario los materiales de una solicitud.

    Funciona sobre una solicitud `aprobada` (el caso normal) y tambien sobre
    una `pendiente`: en ese caso se aprueba y se entrega en un solo paso, para
    que el personal no tenga que hacer dos clics cuando el usuario ya esta en
    el mostrador.
    """
    ahora = reloj.ahora_utc()
    _validar_fecha_limite(fecha_devolucion_esperada, ahora)
    prestamo = consulta_prestamo_servicio.obtener_prestamo_bloqueado(db, prestamo_id)

    if prestamo.estado == PRESTAMO_PENDIENTE:
        aprobacion_servicio.aplicar_aprobacion(db, prestamo, personal, ahora)

    maquina_estados.validar_transicion(prestamo.estado, PRESTAMO_ACTIVO)

    materiales = material_estado_servicio.bloquear_materiales(
        db, [d.material_id for d in prestamo.detalles]
    )
    for material in materiales:
        material_estado_servicio.entregar(material)

    _fijar_plazos(prestamo, ahora, fecha_devolucion_esperada)
    prestamo.fecha_prestamo = ahora
    prestamo.fecha_retiro_limite = None
    prestamo.entregado_por_id = personal.id
    estado_prestamo_servicio.recalcular(prestamo, ahora)

    auditoria_prestamo.registrar(
        db, personal, "PRESTAMO_ENTREGADO", prestamo,
        {"materiales": [d.material.codigo for d in prestamo.detalles]},
    )
    db.commit()
    return consulta_prestamo_servicio.obtener_prestamo(db, prestamo_id)


def registrar_directo(
    db: Session,
    personal: Usuario,
    datos: PrestamoDirectoCrear,
    accion: str = "PRESTAMO_DIRECTO",
    detalles_extra: Optional[dict] = None,
) -> PrestamoCabecera:
    """Registra un prestamo en el mostrador, ya entregado, SIN confirmar la transaccion.

    El personal puede saltarse el limite de items y el bloqueo por vencidos con
    `omitir_validaciones_usuario`; queda anotado en la bitacora. Lo reutiliza la
    cesion de una reserva (ver cesion_servicio) con su propia accion de bitacora.
    """
    ahora = reloj.ahora_utc()
    _validar_fecha_limite(datos.fecha_devolucion_esperada, ahora)

    usuario = db.get(Usuario, datos.usuario_id)
    if usuario is None or usuario.eliminado:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado",
        )

    materiales = material_estado_servicio.bloquear_materiales(db, datos.material_ids)

    if datos.omitir_validaciones_usuario:
        reglas_prestamo.validar_usuario_activo(usuario)
    else:
        reglas_prestamo.validar_usuario_puede_pedir(db, usuario, len(materiales))
    reglas_prestamo.validar_materiales_disponibles(materiales)

    prestamo = prestamo_factory.nuevo_prestamo(
        usuario.id, materiales, PRESTAMO_ACTIVO, ahora, datos.observaciones
    )
    for material in materiales:
        material_estado_servicio.entregar_directo(material)

    _fijar_plazos(prestamo, ahora, datos.fecha_devolucion_esperada)
    prestamo.fecha_prestamo = ahora
    prestamo.aprobado_por_id = personal.id
    prestamo.entregado_por_id = personal.id
    estado_prestamo_servicio.recalcular(prestamo, ahora)

    db.add(prestamo)
    db.flush()
    auditoria_prestamo.registrar(
        db, personal, accion, prestamo,
        {
            "usuario_id": str(usuario.id),
            "materiales": [m.codigo for m in materiales],
            "omitio_validaciones": datos.omitir_validaciones_usuario,
            **(detalles_extra or {}),
        },
    )
    return prestamo


def crear_prestamo_directo(
    db: Session,
    personal: Usuario,
    datos: PrestamoDirectoCrear,
) -> PrestamoCabecera:
    """Registra un prestamo en el mostrador, sin solicitud previa, ya entregado."""
    prestamo = registrar_directo(db, personal, datos)
    db.commit()
    return consulta_prestamo_servicio.obtener_prestamo(db, prestamo.id)
