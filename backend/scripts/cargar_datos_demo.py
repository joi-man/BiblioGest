"""Carga datos de demostracion en un servidor BiblioGest (local o en la nube) usando solo la API.

Crea categorias, libros, revistas y equipos, usuarios de prueba (bibliotecarios y
estudiantes) y prestamos en todos los estados: pendientes, una reserva aprobada,
vigentes, rechazado, devueltos (uno con dano) y vencidos.

Se puede ejecutar mas de una vez: lo que ya existe se omite y los prestamos solo se
crean si todavia no hay ninguno.

Los vencidos se logran entregando con una fecha limite de pocos minutos; el script
espera a que pase y, entonces, el sistema los marca como vencidos al consultarlos.

Los correos de los usuarios de prueba usan la direccion `+alias` de un correo real
(Gmail entrega `tu+juan@gmail.com` en `tu@gmail.com`), asi los avisos de las reservas
llegan a una bandeja de verdad y no rebotan.

Uso:
    python scripts/cargar_datos_demo.py --url https://bibliogest-6j8f.onrender.com \
        --admin admin --correo-base tu@gmail.com
    (la contrasena del administrador se toma de la variable BIBLIOGEST_CLAVE_ADMIN
     o se pide por teclado)
"""
import argparse
import getpass
import os
import sys
import time
from datetime import datetime, timedelta, timezone

import httpx

CATEGORIAS = [
    ("Literatura", 168),
    ("Ciencias y tecnología", 168),
    ("Informática", 168),
    ("Revistas", 72),
    ("Equipos", 4),
]

LIBROS = [
    ("L-001", "Cien años de soledad", "Gabriel García Márquez", "Literatura", "Sudamericana", "978-0307474728"),
    ("L-002", "El Aleph", "Jorge Luis Borges", "Literatura", "Emecé", "978-8420633381"),
    ("L-003", "Rayuela", "Julio Cortázar", "Literatura", "Alfaguara", "978-8420471891"),
    ("L-004", "Don Quijote de la Mancha", "Miguel de Cervantes", "Literatura", "RAE", "978-8420412146"),
    ("L-005", "Yo el Supremo", "Augusto Roa Bastos", "Literatura", "Siglo XXI", "978-9682301131"),
    ("L-006", "Hijo de hombre", "Augusto Roa Bastos", "Literatura", "Alfaguara", "978-9500740715"),
    ("L-007", "Breve historia del tiempo", "Stephen Hawking", "Ciencias y tecnología", "Crítica", "978-8498929416"),
    ("L-008", "Cosmos", "Carl Sagan", "Ciencias y tecnología", "Planeta", "978-8408111061"),
    ("L-009", "Clean Code", "Robert C. Martin", "Informática", "Prentice Hall", "978-0132350884"),
    ("L-010", "Ingeniería del Software", "Ian Sommerville", "Informática", "Pearson", "978-6073206044"),
    ("L-011", "Bases de datos", "Abraham Silberschatz", "Informática", "McGraw-Hill", "978-8448190330"),
    ("L-012", "Introducción a los algoritmos", "Thomas H. Cormen", "Informática", "MIT Press", "978-0262033848"),
    ("L-013", "Estadística aplicada", "Douglas Montgomery", "Ciencias y tecnología", "Limusa", "978-9681861889"),
    ("L-014", "Redes de computadoras", "Andrew Tanenbaum", "Informática", "Pearson", "978-6073216234"),
    ("L-015", "Pedro Páramo", "Juan Rulfo", "Literatura", "Fondo de Cultura Económica", "978-9681632724"),
    ("L-016", "Arquitectura de software", "Mark Richards", "Informática", "O'Reilly", "978-1492043454"),
]
REVISTAS = [
    ("R-001", "National Geographic en español", "Varios"),
    ("R-002", "Muy Interesante", "Varios"),
    ("R-003", "IEEE Software", "IEEE Computer Society"),
]
EQUIPOS = [
    ("P-001", "Proyector Epson", "proyector", "Epson", "PowerLite X49"),
    ("P-002", "Laptop Dell", "laptop", "Dell", "Latitude 3420"),
    ("P-003", "Parlante JBL", "parlante", "JBL", "Flip 6"),
]

# (usuario, nombre, apellido, documento, rol, contrasena)
PERSONAS = [
    ("maria.gonzalez", "María", "González", "2.345.678", "bibliotecario", "biblio123"),
    ("laura.fernandez", "Laura", "Fernández", "2.456.789", "bibliotecario", "biblio123"),
    ("juan.perez", "Juan", "Pérez", "4.111.222", "estudiante", "estudiante123"),
    ("ana.lopez", "Ana", "López", "4.222.333", "estudiante", "estudiante123"),
    ("carlos.martinez", "Carlos", "Martínez", "4.333.444", "estudiante", "estudiante123"),
    ("sofia.benitez", "Sofía", "Benítez", "4.444.555", "estudiante", "estudiante123"),
    ("diego.acosta", "Diego", "Acosta", "4.555.666", "estudiante", "estudiante123"),
    ("lucia.ramirez", "Lucía", "Ramírez", "4.666.777", "estudiante", "estudiante123"),
]

MINUTOS_PARA_VENCER = 3


class Cliente:
    def __init__(self, url: str):
        self.http = httpx.Client(base_url=url.rstrip("/"), timeout=120)

    def llamar(self, metodo, ruta, token=None, json=None, esperado=(200, 201), tolerar=()):
        r = self.http.request(
            metodo, ruta, json=json,
            headers={"Authorization": f"Bearer {token}"} if token else None,
        )
        if r.status_code in tolerar:
            return None
        if r.status_code not in esperado:
            raise SystemExit(f"{metodo} {ruta} -> {r.status_code}: {r.text[:300]}")
        return r.json() if r.content else None

    def entrar(self, usuario, clave):
        return self.llamar("POST", "/api/auth/login", json={"correo_o_usuario": usuario, "contrasena": clave})["access_token"]


def correo_con_alias(base: str, alias: str) -> str:
    usuario, dominio = base.split("@", 1)
    return f"{usuario}+{alias}@{dominio}"


def main():
    pa = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    pa.add_argument("--url", required=True, help="Direccion del servidor, por ejemplo https://tu-api.onrender.com")
    pa.add_argument("--admin", default="admin", help="Usuario administrador")
    pa.add_argument("--correo-base", required=True, help="Correo real que recibira los avisos (se usan alias +nombre)")
    pa.add_argument("--sin-vencidos", action="store_true", help="No crea prestamos vencidos (no espera)")
    args = pa.parse_args()

    clave_admin = os.environ.get("BIBLIOGEST_CLAVE_ADMIN") or getpass.getpass("Contraseña del administrador: ")
    api = Cliente(args.url)
    print("Conectando (el servidor gratuito puede tardar en despertar)...")
    token = api.entrar(args.admin, clave_admin)
    print("Sesión iniciada.")

    # ------------------------------------------------------------- categorias
    existentes = {c["nombre"]: c["id"] for c in api.llamar("GET", "/api/categorias/", token)}
    categorias = dict(existentes)
    for nombre, horas in CATEGORIAS:
        if nombre not in categorias:
            categorias[nombre] = api.llamar(
                "POST", "/api/categorias/", token, {"nombre": nombre, "plazo_prestamo_horas": horas}
            )["id"]
            print(f"  categoría creada: {nombre}")

    # -------------------------------------------------------------- materiales
    materiales = {m["codigo"]: m["id"] for m in api.llamar("GET", "/api/materiales/", token)}
    nuevos = 0
    for cod, titulo, autor, cat, editorial, isbn in LIBROS:
        if cod in materiales:
            continue
        materiales[cod] = api.llamar("POST", "/api/materiales/", token, {
            "codigo": cod, "titulo": titulo, "tipo_material": "libro", "autor": autor, "editorial": editorial,
            "isbn": isbn, "categoria_id": categorias[cat], "ubicacion": f"Estante {int(cod[-3:]) % 6 + 1}",
        })["id"]
        nuevos += 1
    for cod, titulo, autor in REVISTAS:
        if cod in materiales:
            continue
        materiales[cod] = api.llamar("POST", "/api/materiales/", token, {
            "codigo": cod, "titulo": titulo, "tipo_material": "revista", "autor": autor,
            "categoria_id": categorias["Revistas"], "ubicacion": "Hemeroteca",
        })["id"]
        nuevos += 1
    for cod, titulo, tipo, marca, modelo in EQUIPOS:
        if cod in materiales:
            continue
        materiales[cod] = api.llamar("POST", "/api/materiales/", token, {
            "codigo": cod, "titulo": titulo, "tipo_material": tipo, "marca": marca, "modelo": modelo,
            "categoria_id": categorias["Equipos"], "ubicacion": "Sala de equipos",
        })["id"]
        nuevos += 1
    print(f"  materiales creados: {nuevos}")

    # ---------------------------------------------------------------- usuarios
    usuarios = {u["username"]: u["id"] for u in api.llamar("GET", "/api/usuarios/", token)}
    for usuario, nombre, apellido, doc, rol, clave in PERSONAS:
        if usuario in usuarios:
            continue
        usuarios[usuario] = api.llamar("POST", "/api/usuarios/", token, {
            "username": usuario, "correo_electronico": correo_con_alias(args.correo_base, usuario.split(".")[0]),
            "numero_documento": doc, "nombre": nombre, "apellido": apellido, "rol": rol, "contrasena": clave,
        })["id"]
        print(f"  usuario creado: {usuario} ({rol})")

    # --------------------------------------------------------------- prestamos
    if api.llamar("GET", "/api/prestamos/", token):
        print("Ya hay préstamos: no se crean más (el script solo siembra una vez).")
        return

    def solicitar(usuario, codigos):
        clave = next(p[5] for p in PERSONAS if p[0] == usuario)
        return api.llamar("POST", "/api/solicitudes/", api.entrar(usuario, clave),
                          {"material_ids": [materiales[c] for c in codigos]})["id"]

    def entregar(pid, limite=None):
        return api.llamar("POST", f"/api/prestamos/{pid}/entregar", token,
                          {"fecha_devolucion_esperada": limite.isoformat()} if limite else {})

    def devolver(pid, condicion="bueno"):
        detalle = api.llamar("GET", f"/api/prestamos/{pid}", token)["detalles"]
        api.llamar("POST", f"/api/devoluciones/{pid}", token, {
            "items": [{"prestamo_detalle_id": d["id"], "condicion": condicion} for d in detalle]})

    print("Creando préstamos...")
    # Historial: entregados y devueltos
    for usuario, codigos, condicion in [
        ("juan.perez", ["L-001"], "bueno"), ("ana.lopez", ["L-009"], "bueno"),
        ("carlos.martinez", ["L-007"], "dano_menor"), ("sofia.benitez", ["L-003"], "bueno"),
        ("diego.acosta", ["L-010", "L-012"], "bueno"), ("lucia.ramirez", ["R-002"], "bueno"),
    ]:
        pid = solicitar(usuario, codigos)
        entregar(pid)
        devolver(pid, condicion)

    # Vigentes
    for usuario, codigos in [("ana.lopez", ["L-008"]), ("diego.acosta", ["R-003"])]:
        entregar(solicitar(usuario, codigos))

    # Vencidos: fecha limite de pocos minutos
    if not args.sin_vencidos:
        limite = datetime.now(timezone.utc) + timedelta(minutes=MINUTOS_PARA_VENCER)
        for usuario, codigos in [("juan.perez", ["L-004"]), ("carlos.martinez", ["L-011"]), ("sofia.benitez", ["L-006"])]:
            entregar(solicitar(usuario, codigos), limite)

    # Reserva aprobada, rechazada, pendientes y un prestamo directo de equipo
    api.llamar("POST", f"/api/prestamos/{solicitar('lucia.ramirez', ['L-002'])}/aprobar", token)
    api.llamar("POST", f"/api/prestamos/{solicitar('lucia.ramirez', ['L-015'])}/rechazar", token,
               {"motivo": "El libro está en revisión por daños"})
    solicitar("ana.lopez", ["L-005"])
    solicitar("carlos.martinez", ["R-001"])
    api.llamar("POST", "/api/prestamos/directo", token, {"usuario_id": usuarios["laura.fernandez"], "material_ids": [materiales["P-001"]]})

    if not args.sin_vencidos:
        espera = MINUTOS_PARA_VENCER * 60 + 20
        print(f"Esperando {espera} s a que venzan los préstamos de prueba...")
        time.sleep(espera)
        api.llamar("GET", "/api/reportes/vencidos", token)  # el sistema los marca como vencidos al consultar

    resumen = api.llamar("GET", "/api/dashboard/resumen", token)
    print("Listo.", resumen)


if __name__ == "__main__":
    sys.exit(main())
