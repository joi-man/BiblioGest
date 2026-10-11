"""Punto de entrada del backend dentro del ejecutable de escritorio.

La aplicacion Flutter lo inicia como proceso hijo:

    bibliogest-backend.exe --puerto 8765

Usa SQLite en la carpeta de datos del usuario y escucha solo en 127.0.0.1.
Se cierra solo cuando la aplicacion que lo inicio termina (ver `_vigilar_padre`).
"""
import argparse
import os
import secrets
import sys
import threading
from pathlib import Path


def carpeta_de_datos(indicada: str | None) -> Path:
    """Carpeta donde viven la base de datos y el secreto de sesion de este equipo."""
    if indicada:
        carpeta = Path(indicada)
    elif os.name == "nt":
        carpeta = Path(os.environ.get("LOCALAPPDATA", Path.home())) / "BiblioGest"
    else:
        carpeta = Path.home() / ".bibliogest"
    carpeta.mkdir(parents=True, exist_ok=True)
    return carpeta


def secreto_de_sesion(carpeta: Path) -> str:
    """Secreto con el que se firman las sesiones. Se genera una vez por equipo."""
    archivo = carpeta / "secreto.txt"
    if not archivo.exists():
        archivo.write_text(secrets.token_hex(32), encoding="utf-8")
    return archivo.read_text(encoding="utf-8").strip()


def _vigilar_padre() -> None:
    """Termina este proceso cuando la aplicacion que lo inicio se cierra.

    La aplicacion deja abierta nuestra entrada estandar; al cerrarse (o morir)
    la lectura termina y salimos, asi no quedan procesos huerfanos.
    """
    try:
        sys.stdin.read()
    finally:
        os._exit(0)


def main() -> None:
    parser = argparse.ArgumentParser(description="Backend local de BiblioGest")
    parser.add_argument("--puerto", type=int, default=8765)
    parser.add_argument("--datos", default=None, help="Carpeta de datos (por defecto, la del usuario)")
    parser.add_argument("--sin-vigilar-padre", action="store_true", help="Para ejecutarlo a mano en desarrollo")
    argumentos = parser.parse_args()

    carpeta = carpeta_de_datos(argumentos.datos)
    # Debe fijarse antes de importar la aplicacion: la configuracion se lee al importarla.
    os.environ["MODO_APLICACION"] = "local"
    os.environ["BASE_DATOS_URL"] = f"sqlite:///{(carpeta / 'bibliogest.db').as_posix()}"
    os.environ["SECRETO_JWT"] = secreto_de_sesion(carpeta)

    if not argumentos.sin_vigilar_padre:
        threading.Thread(target=_vigilar_padre, daemon=True).start()

    import uvicorn

    from main import app

    uvicorn.run(app, host="127.0.0.1", port=argumentos.puerto, log_level="warning")


if __name__ == "__main__":
    main()
