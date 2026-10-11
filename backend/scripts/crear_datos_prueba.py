"""
Crea categorias y materiales de prueba (libros y equipos) en BiblioGest.

Usa la API, asi que el backend debe estar corriendo. Se puede ejecutar varias
veces: lo que ya existe se omite.

Ejecutar: python scripts/crear_datos_prueba.py
"""
import httpx as requests  # httpx ya es dependencia del proyecto y tiene la misma interfaz

BASE_URL = "http://localhost:8000/api"
CORREO_ADMIN = "admin@bibliogest.com"
CONTRASENA_ADMIN = "admin123"

# Plazo de prestamo en horas: 168 = 7 dias, 4 = una jornada de clase.
CATEGORIAS = [
    {"nombre": "Literatura", "descripcion": "Novelas, cuentos y poesia", "plazo_prestamo_horas": 168},
    {"nombre": "Ciencias", "descripcion": "Fisica, quimica y biologia", "plazo_prestamo_horas": 168},
    {"nombre": "Matematicas", "descripcion": "Algebra, geometria y calculo", "plazo_prestamo_horas": 168},
    {"nombre": "Tecnologia", "descripcion": "Informatica y programacion", "plazo_prestamo_horas": 168},
    {"nombre": "Referencia", "descripcion": "Diccionarios y enciclopedias", "plazo_prestamo_horas": 24},
    {"nombre": "Audiovisual", "descripcion": "Proyectores, parlantes y camaras", "plazo_prestamo_horas": 4},
    {"nombre": "Computo", "descripcion": "Laptops y tablets", "plazo_prestamo_horas": 8},
    {"nombre": "Cables y energia", "descripcion": "Alargadores y adaptadores", "plazo_prestamo_horas": 24},
]


def libro(codigo, titulo, autor, isbn, editorial, anio, paginas, categoria):
    return {
        "codigo": codigo, "titulo": titulo, "tipo_material": "libro", "categoria": categoria,
        "autor": autor, "isbn": isbn, "editorial": editorial,
        "anio_publicacion": anio, "numero_paginas": paginas, "ubicacion": "Estante A",
    }


def equipo(codigo, titulo, tipo, categoria, marca, modelo, serie, ubicacion, accesorios=None, valor=None, **extra):
    return {
        "codigo": codigo, "titulo": titulo, "tipo_material": tipo, "categoria": categoria,
        "marca": marca, "modelo": modelo, "numero_serie": serie, "ubicacion": ubicacion,
        "accesorios": accesorios, "valor_referencial": valor, **extra,
    }


MATERIALES = [
    libro("LIT-001", "Cien anos de soledad", "Gabriel Garcia Marquez", "978-0307474728", "Sudamericana", 1967, 471, "Literatura"),
    libro("LIT-002", "Don Quijote de la Mancha", "Miguel de Cervantes", "978-8424922580", "RAE", 1605, 863, "Literatura"),
    libro("CIEN-001", "El universo en tu mano", "Christophe Galfard", "978-8484288208", "Ediciones B", 2015, 384, "Ciencias"),
    libro("MATH-001", "Algebra de Baldor", "Aurelio Baldor", "978-6074415247", "Patria", 1941, 576, "Matematicas"),
    libro("TEC-001", "Clean Code", "Robert C. Martin", "978-0132350884", "Prentice Hall", 2008, 464, "Tecnologia"),
    # Solo consulta en sala: no se puede solicitar.
    libro("REF-001", "Diccionario de la lengua espanola", "RAE", "978-8467041897", "Espasa", 2014, 2376, "Referencia")
    | {"es_prestable": False},
    {
        "codigo": "DVD-001", "titulo": "Documental: La vida en la Tierra", "tipo_material": "dvd",
        "categoria": "Ciencias", "formato": "DVD", "duracion": "90 min",
    },
    # Dos unidades del mismo proyector: cada una con su serie y su historial.
    equipo("PROY-001", "Proyector Epson PowerLite", "proyector", "Audiovisual", "Epson", "X49",
           "EP-2291", "Sala de equipos", "Cable HDMI, control remoto, maletin", 450),
    equipo("PROY-002", "Proyector Epson PowerLite", "proyector", "Audiovisual", "Epson", "X49",
           "EP-2292", "Sala de equipos", "Cable HDMI, control remoto, maletin", 450),
    equipo("ALAR-001", "Alargador 5 m", "alargador", "Cables y energia", "Philips", "SPN2250", "AL-001",
           "Armario 2", "", 15),
    equipo("ALAR-002", "Alargador 5 m", "alargador", "Cables y energia", "Philips", "SPN2250", "AL-002",
           "Armario 2", "", 15),
    equipo("ALAR-003", "Alargador 10 m", "alargador", "Cables y energia", "Truper", "EXT-10", "AL-003",
           "Armario 2", "", 22),
    equipo("LAP-001", "Laptop Lenovo ThinkPad", "laptop", "Computo", "Lenovo", "E14", "LN-7741",
           "Sala de equipos", "Cargador, mouse", 780, plazo_prestamo_horas=6),
    equipo("PARL-001", "Parlante Bluetooth JBL", "parlante", "Audiovisual", "JBL", "Flip 6", "JB-3310",
           "Sala de equipos", "Cable USB-C", 120),
]


def iniciar_sesion() -> dict:
    """Devuelve las cabeceras con el token del administrador."""
    respuesta = requests.post(f"{BASE_URL}/auth/login", json={
        "correo_o_usuario": CORREO_ADMIN,
        "contrasena": CONTRASENA_ADMIN,
    })
    respuesta.raise_for_status()
    return {"Authorization": f"Bearer {respuesta.json()['access_token']}"}


def asegurar_categorias(cabeceras: dict) -> dict[str, str]:
    """Crea las categorias que falten. Devuelve {nombre: id}."""
    existentes = requests.get(f"{BASE_URL}/categorias/", headers=cabeceras).json()
    ids = {c["nombre"]: c["id"] for c in existentes}

    for datos in CATEGORIAS:
        if datos["nombre"] in ids:
            print(f"  = categoria ya existe: {datos['nombre']}")
            continue
        respuesta = requests.post(f"{BASE_URL}/categorias/", json=datos, headers=cabeceras)
        respuesta.raise_for_status()
        ids[datos["nombre"]] = respuesta.json()["id"]
        print(f"  + categoria: {datos['nombre']} ({datos['plazo_prestamo_horas']} h)")
    return ids


def asegurar_materiales(cabeceras: dict, categorias: dict[str, str]) -> None:
    """Crea los materiales que falten (se identifican por su codigo)."""
    existentes = {m["codigo"] for m in requests.get(f"{BASE_URL}/materiales/", headers=cabeceras).json()}

    for original in MATERIALES:
        if original["codigo"] in existentes:
            print(f"  = material ya existe: {original['codigo']}")
            continue
        datos = {k: v for k, v in original.items() if v not in (None, "")}
        datos["categoria_id"] = categorias[datos.pop("categoria")]
        respuesta = requests.post(f"{BASE_URL}/materiales/", json=datos, headers=cabeceras)
        if respuesta.status_code == 201:
            print(f"  + material: {datos['codigo']} - {datos['titulo']}")
        else:
            print(f"  ! error en {datos['codigo']}: {respuesta.status_code} {respuesta.text}")


if __name__ == "__main__":
    print("=== Datos de prueba de BiblioGest ===")
    try:
        cabeceras = iniciar_sesion()
    except requests.HTTPError as error:
        print(f"No se pudo iniciar sesion como administrador: {error}")
        raise SystemExit(1)

    print("\nCategorias:")
    ids_categorias = asegurar_categorias(cabeceras)
    print("\nMateriales:")
    asegurar_materiales(cabeceras, ids_categorias)
    print("\nListo.")
