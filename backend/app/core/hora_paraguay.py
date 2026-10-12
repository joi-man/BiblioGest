"""Hora de Paraguay.

La base guarda todo en UTC. Desde octubre de 2024 Paraguay usa UTC-3 todo el ano
(ya no cambia de horario), asi que basta un desfase fijo y no hace falta una base de
zonas horarias (que no viene instalada en Windows ni en la imagen de Docker).
"""
from datetime import date, datetime, time, timedelta, timezone
from typing import Optional

ZONA_PARAGUAY = timezone(timedelta(hours=-3), "PYT")
DESFASE = timedelta(hours=3)
ETIQUETA = "hora de Paraguay"


def a_paraguay(fecha_utc: Optional[datetime]) -> Optional[datetime]:
    """Convierte una fecha UTC (sin zona) a la hora de Paraguay (sin zona)."""
    return None if fecha_utc is None else fecha_utc - DESFASE


def inicio_de_dia_utc(dia: date) -> datetime:
    """Instante UTC en que empieza `dia` en Paraguay (00:00 de Paraguay)."""
    return datetime.combine(dia, time.min) + DESFASE


def inicio_de_hoy_utc(ahora_utc: datetime) -> datetime:
    """Instante UTC en que empezo el dia de hoy en Paraguay."""
    return inicio_de_dia_utc(a_paraguay(ahora_utc).date())
