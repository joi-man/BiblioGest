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


class BloqueoPorIntentos:
    """Bloquea una clave durante `minutos` tras `maximo` fallos seguidos (en memoria).

    Un acierto borra el conteo. Mientras dura el bloqueo no se aceptan intentos,
    ni siquiera con la contrasena correcta; al vencer, la clave vuelve a empezar
    con todos sus intentos. Los datos viven en la memoria del servidor: un
    reinicio los borra.
    """

    def __init__(self, maximo: int, minutos: int, reloj=time.monotonic) -> None:
        self._maximo = maximo
        self._segundos = minutos * 60
        self._reloj = reloj
        self._fallos: dict[str, int] = {}
        self._bloqueado_hasta: dict[str, float] = {}
        self._cerrojo = threading.Lock()

    def segundos_restantes(self, clave: str) -> int:
        """Segundos que faltan para poder reintentar; 0 si la clave no esta bloqueada."""
        with self._cerrojo:
            return self._restantes(clave)

    def registrar_fallo(self, clave: str) -> int:
        """Anota un fallo. Devuelve los segundos de bloqueo (0 si todavia quedan intentos)."""
        with self._cerrojo:
            if self._restantes(clave) > 0:
                return self._restantes(clave)
            fallos = self._fallos.get(clave, 0) + 1
            if fallos >= self._maximo:
                self._fallos.pop(clave, None)
                self._bloqueado_hasta[clave] = self._reloj() + self._segundos
                return self._segundos
            self._fallos[clave] = fallos
            return 0

    def intentos_restantes(self, clave: str) -> int:
        with self._cerrojo:
            return max(self._maximo - self._fallos.get(clave, 0), 0)

    def limpiar(self, clave: str) -> None:
        with self._cerrojo:
            self._fallos.pop(clave, None)
            self._bloqueado_hasta.pop(clave, None)

    def _restantes(self, clave: str) -> int:
        hasta = self._bloqueado_hasta.get(clave)
        if hasta is None:
            return 0
        faltan = hasta - self._reloj()
        if faltan <= 0:
            del self._bloqueado_hasta[clave]
            return 0
        return int(faltan) + 1
