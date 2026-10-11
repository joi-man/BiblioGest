import threading
import time
from collections import defaultdict, deque


class LimitadorPorClave:
    """Permite como maximo `maximo` eventos por clave en cada ventana de `segundos` (en memoria)."""

    def __init__(self, maximo: int, segundos: int) -> None:
        self._maximo = maximo
        self._segundos = segundos
        self._eventos: dict[str, deque[float]] = defaultdict(deque)
        self._cerrojo = threading.Lock()

    def permitir(self, clave: str) -> bool:
        ahora = time.monotonic()
        with self._cerrojo:
            cola = self._eventos[clave]
            while cola and ahora - cola[0] > self._segundos:
                cola.popleft()
            if len(cola) >= self._maximo:
                return False
            cola.append(ahora)
            return True
