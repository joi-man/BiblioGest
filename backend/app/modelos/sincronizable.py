from sqlalchemy import Column, Integer


class Sincronizable:
    """Mixin para las tablas que se replican entre el servidor y los equipos.

    `version` cuenta cuantas veces se modifico la fila. Al enviar un cambio, el
    equipo indica sobre que version se basaba; si el servidor ya tiene otra,
    alguien mas la cambio antes y el cambio se rechaza como conflicto.
    La captura de cambios y el incremento viven en `app.sync.captura`.
    """

    version = Column(Integer, nullable=False, default=1, server_default="1")
