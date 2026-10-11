"""Crea el primer usuario de personal en una base vacia (por ejemplo, la de produccion).

Solo un admin puede crear usuarios por la API, asi que el primero hay que sembrarlo.
La contrasena se pide por teclado: no se pasa por argumentos ni queda en el historial.

Uso (desde la carpeta backend, con BASE_DATOS_URL apuntando a la base destino):
    $env:BASE_DATOS_URL = "postgresql+psycopg://...?sslmode=require"
    python scripts/crear_admin_inicial.py --usuario admin --correo tu@correo.com \
        --documento 1234567 --nombre Ana --apellido Perez

--rol permite sembrar otro rol (por defecto admin).
"""
import argparse
import getpass
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from sqlalchemy import select  # noqa: E402

from app.core.constantes_roles import ROL_ADMIN  # noqa: E402
from app.core.database import SesionLocal  # noqa: E402
from app.core.seguridad import hashear_contrasena  # noqa: E402
from app.modelos.usuario import Usuario  # noqa: E402

MINIMO_CONTRASENA = 8


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--usuario", required=True)
    p.add_argument("--correo", required=True)
    p.add_argument("--documento", required=True)
    p.add_argument("--nombre", required=True)
    p.add_argument("--apellido", required=True)
    p.add_argument("--rol", default=ROL_ADMIN)
    args = p.parse_args()

    contrasena = getpass.getpass("Contrasena: ")
    if len(contrasena) < MINIMO_CONTRASENA:
        print(f"La contrasena debe tener al menos {MINIMO_CONTRASENA} caracteres.")
        return 1
    if contrasena != getpass.getpass("Repetir contrasena: "):
        print("Las contrasenas no coinciden.")
        return 1

    with SesionLocal() as db:
        existe = db.execute(
            select(Usuario).where(
                (Usuario.username == args.usuario)
                | (Usuario.correo_electronico == args.correo)
                | (Usuario.numero_documento == args.documento)
            )
        ).scalars().first()
        if existe:
            print("Ya existe un usuario con ese usuario, correo o documento. No se creo nada.")
            return 1
        db.add(
            Usuario(
                username=args.usuario,
                correo_electronico=args.correo,
                contrasena_hash=hashear_contrasena(contrasena),
                numero_documento=args.documento,
                nombre=args.nombre,
                apellido=args.apellido,
                rol=args.rol,
                activo=True,
            )
        )
        db.commit()
    print(f"Usuario '{args.usuario}' creado con rol '{args.rol}'.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
