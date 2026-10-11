"""Cliente HTTP con el que el equipo habla con el servidor central."""
from datetime import datetime
from typing import Any, Dict, List, Optional

import httpx


class ErrorSinConexion(Exception):
    """No se pudo llegar al servidor (sin red, apagado o direccion incorrecta)."""


class ErrorCredenciales(Exception):
    """El servidor no acepto el usuario o la contrasena."""


class ErrorServidor(Exception):
    """El servidor respondio con un error."""


class ClienteCentral:
    """Operaciones del servidor central que necesita la sincronizacion."""

    def __init__(self, url: str, http: Optional[httpx.Client] = None, timeout: float = 15.0):
        # `http` permite inyectar otro cliente (las pruebas usan uno que habla con una app en memoria).
        self._es_propio = http is None
        self._http = http or httpx.Client(base_url=url.rstrip("/"), timeout=timeout)
        self._token: Optional[str] = None

    def cerrar(self) -> None:
        """Cierra la conexion, salvo que el cliente HTTP se haya recibido de fuera."""
        if self._es_propio:
            self._http.close()

    # ---------------------------------------------------------------- llamadas
    def _llamar(self, metodo: str, ruta: str, **kwargs) -> httpx.Response:
        cabeceras = kwargs.pop("headers", {})
        if self._token:
            cabeceras["Authorization"] = f"Bearer {self._token}"
        try:
            respuesta = self._http.request(metodo, ruta, headers=cabeceras, **kwargs)
        except httpx.TransportError as error:
            raise ErrorSinConexion(str(error)) from error

        if respuesta.status_code == 401:
            raise ErrorCredenciales("El servidor rechazo las credenciales")
        if respuesta.status_code >= 400:
            detalle = _detalle(respuesta)
            raise ErrorServidor(f"{respuesta.status_code}: {detalle}")
        return respuesta

    def hay_conexion(self) -> bool:
        """True si el servidor contesta."""
        try:
            self._llamar("GET", "/health")
            return True
        except (ErrorSinConexion, ErrorServidor):
            return False

    def iniciar_sesion(self, usuario: str, contrasena: str) -> Dict[str, Any]:
        """Inicia sesion y guarda el token. Devuelve los datos del usuario."""
        respuesta = self._llamar(
            "POST",
            "/api/auth/login",
            json={"correo_o_usuario": usuario, "contrasena": contrasena},
        )
        cuerpo = respuesta.json()
        self._token = cuerpo["access_token"]
        return cuerpo["usuario"]

    def enviar_lotes(self, lotes: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        respuesta = self._llamar("POST", "/api/sync/lotes", json={"lotes": lotes})
        return respuesta.json()["resultados"]

    def obtener_cambios(
        self,
        tabla: str,
        desde: Optional[datetime],
        despues_de_id: Optional[str],
        limite: int,
    ) -> Dict[str, Any]:
        parametros: Dict[str, Any] = {"tabla": tabla, "limite": limite}
        if desde is not None:
            parametros["desde"] = desde.isoformat()
        if despues_de_id is not None:
            parametros["despues_de_id"] = despues_de_id
        return self._llamar("GET", "/api/sync/cambios", params=parametros).json()

    def obtener_filas(self, tabla: str, ids: List[str]) -> List[Dict[str, Any]]:
        respuesta = self._llamar("POST", "/api/sync/filas", json={"tabla": tabla, "ids": ids})
        return respuesta.json()["filas"]


def _detalle(respuesta: httpx.Response) -> str:
    try:
        return str(respuesta.json().get("detail", respuesta.text))
    except ValueError:
        return respuesta.text
