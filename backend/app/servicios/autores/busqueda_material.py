"""Texto de busqueda de un material: todo lo que una persona podria escribir para encontrarlo."""
from app.core.texto_busqueda import unir_normalizado
from app.modelos.material import Material


def construir_texto(material: Material) -> str:
    """Titulo, autores, codigo, ISBN, editorial, tomo, marca, modelo y serie, sin tildes."""
    return unir_normalizado(
        [
            material.titulo,
            material.codigo,
            *(a.nombre for a in material.autores),
            material.autor if not material.autores else None,
            material.isbn,
            material.editorial,
            f"tomo {material.tomo}" if material.tomo else None,
            material.marca,
            material.modelo,
            material.numero_serie,
        ]
    )


def actualizar_texto(material: Material) -> None:
    """Recalcula `texto_busqueda` y el resumen `autor` a partir de los autores vigentes."""
    autores = material.autores
    if autores:
        material.autor = ", ".join(a.nombre for a in autores)[:255]
    material.texto_busqueda = construir_texto(material)
