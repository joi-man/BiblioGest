"""Tipos reutilizables para los esquemas de la API."""
from datetime import datetime, timezone
from typing import Annotated

from pydantic import AfterValidator, PlainSerializer


def _a_utc_sin_zona(valor: datetime) -> datetime:
    """Convierte una fecha recibida a UTC sin zona, que es como la guarda la base.

    Si el cliente envia una hora con zona (por ejemplo "...Z" o "-03:00"), se
    pasa a UTC; si viene sin zona se asume que ya es UTC.
    """
    if valor.tzinfo is None:
        return valor
    return valor.astimezone(timezone.utc).replace(tzinfo=None)


def _a_iso_utc(valor: datetime) -> str:
    """Serializa un datetime (UTC sin zona) como ISO 8601 con sufijo 'Z'.

    Sin la 'Z', los clientes interpretan la fecha como hora local y muestran
    horas desplazadas.
    """
    if valor.tzinfo is None:
        valor = valor.replace(tzinfo=timezone.utc)
    return valor.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


# Fecha y hora en UTC: se recibe normalizada a UTC sin zona y se entrega con 'Z'.
FechaUTC = Annotated[
    datetime,
    AfterValidator(_a_utc_sin_zona),
    PlainSerializer(_a_iso_utc, return_type=str, when_used="json"),
]
