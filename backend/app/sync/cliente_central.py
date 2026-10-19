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


class ErrorDireccionIncorrecta(ErrorServidor):
    """La direccion responde, pero no es el servidor de BiblioGest (por ejemplo, la pagina web)."""


class ClienteCentral:
    """Operaciones del servidor central que necesita la sincronizacion."""

    def __init__(self, url: str, http: Optional[httpx.Client] = None):
        # `http` permite inyectar otro cliente (las pruebas usan uno que habla con una app en memoria).
        self._es_propio = http is None
        # Conectar debe fallar rapido para detectar que no hay red; una vez conectado se
        # espera mas porque el servidor puede tardar en aplicar un lote grande.
        self._http = http or httpx.Client(
            base_url=url.rstrip("/"), timeout=httpx.Timeout(60.0, connect=4.0)
        )
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
        if respuesta.status_code in (404, 405) and not _es_error_de_la_api(respuesta):
            # La API siempre explica sus errores con {"detail": ...}. Un 404 o 405 sin eso viene
            # de otra cosa: tipicamente la pagina web, que no tiene API.
            raise ErrorDireccionIncorrecta(
                f"Esa direccion responde con el codigo {respuesta.status_code} y no parece ser el "
                "servidor de BiblioGest. Si es la direccion de la pagina web, usa la del servidor "
                "(la API), no la de la pagina."
            )
        if respuesta.status_code >= 400:
            detalle = _detalle(respuesta)
            raise ErrorServidor(f"{respuesta.status_code}: {detalle}")
        return respuesta

    def hay_conexion(self) -> bool:
        """True si el servidor contesta."""
        try:
            respuesta = self._llamar("GET", "/health")
        except (ErrorSinConexion, ErrorServidor):
            return False
        # La pagina web tambien contesta 200 a cualquier ruta, pero con HTML: no es el servidor.
        try:
            return respuesta.json().get("estado") == "ok"
        except (ValueError, AttributeError):
            return False

    def enviar_codigo_recuperacion(self, correo: str, codigo: str) -> None:
        """Pide al servidor que envie por correo un codigo de recuperacion (no requiere sesion)."""
        self._llamar("POST", "/api/auth/codigo-externo", json={"correo": correo, "codigo": codigo})

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


def _es_error_de_la_api(respuesta: httpx.Response) -> bool:
    """True si la respuesta tiene la forma de un error de la API de BiblioGest."""
    try:
        cuerpo = respuesta.json()
    except ValueError:
        return False
    return isinstance(cuerpo, dict) and "detail" in cuerpo


def _detalle(respuesta: httpx.Response) -> str:
    try:
        return str(respuesta.json().get("detail", respuesta.text))
    except ValueError:
        return respuesta.text
