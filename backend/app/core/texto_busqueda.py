"""Normalizacion de texto para buscar sin importar mayusculas ni tildes."""
import re
import unicodedata
from typing import Iterable, List, Optional

_ESPACIOS = re.compile(r"\s+")


def normalizar(texto: Optional[str]) -> str:
    """Minusculas, sin tildes y con espacios simples: "García  Márquez" -> "garcia marquez"."""
    if not texto:
        return ""
    sin_tildes = "".join(
        c for c in unicodedata.normalize("NFD", texto) if unicodedata.category(c) != "Mn"
    )
    return _ESPACIOS.sub(" ", sin_tildes.lower()).strip()


def palabras(texto: Optional[str]) -> List[str]:
    """Las palabras de una busqueda, normalizadas y sin repetidos."""
    return list(dict.fromkeys(normalizar(texto).split(" "))) if normalizar(texto) else []


def unir_normalizado(partes: Iterable[Optional[str]]) -> str:
    """Une varios textos en uno solo normalizado (lo que se guarda para buscar)."""
    return normalizar(" ".join(p for p in partes if p))
