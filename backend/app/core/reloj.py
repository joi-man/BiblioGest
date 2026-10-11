"""Reloj de la aplicacion.

Centraliza la hora actual para que los servicios no llamen directamente a
`datetime.utcnow()`. Las pruebas pueden sustituir `ahora_utc` para simular
que pasa el tiempo (vencimientos, reservas expiradas, etc.).
"""
from datetime import datetime


def ahora_utc() -> datetime:
    """Devuelve la fecha y hora actual en UTC, sin zona horaria (naive), como el resto de la base."""
    return datetime.utcnow()
