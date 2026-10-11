"""Convierte filas de la base a JSON y de vuelta, columna por columna."""
from datetime import datetime
from decimal import Decimal
from typing import Any, Dict
from uuid import UUID

from sqlalchemy import inspect


def _columnas(modelo):
    return inspect(modelo).columns


def valor_a_json(valor: Any) -> Any:
    """Convierte un valor de columna a algo que JSON entienda."""
    if valor is None:
        return None
    if isinstance(valor, UUID):
        return str(valor)
    if isinstance(valor, datetime):
        return valor.isoformat()
    if isinstance(valor, Decimal):
        return str(valor)
    return valor


def valor_desde_json(columna, valor: Any) -> Any:
    """Inverso de `valor_a_json`, segun el tipo de la columna."""
    if valor is None:
        return None
    try:
        tipo_python = columna.type.python_type
    except NotImplementedError:
        return valor
    if tipo_python is UUID:
        return UUID(valor)
    if tipo_python is datetime:
        return datetime.fromisoformat(valor)
    if tipo_python is Decimal:
        return Decimal(valor)
    return valor


def fila_a_json(fila) -> Dict[str, Any]:
    """Todas las columnas de una fila como diccionario JSON."""
    return {c.key: valor_a_json(getattr(fila, c.key)) for c in _columnas(type(fila))}


def datos_desde_json(modelo, datos: Dict[str, Any]) -> Dict[str, Any]:
    """Diccionario JSON -> valores Python listos para asignar al modelo.

    Ignora claves que el modelo no conoce, asi una version vieja del programa
    no se rompe si el servidor agrega columnas.
    """
    columnas = {c.key: c for c in _columnas(modelo)}
    return {
        clave: valor_desde_json(columnas[clave], valor)
        for clave, valor in datos.items()
        if clave in columnas
    }
