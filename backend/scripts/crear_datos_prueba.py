"""
Script para crear categorias y materiales de prueba en BiblioGest.
Ejecutar: python scripts/crear_datos_prueba.py
"""
import requests

BASE_URL = "http://localhost:8000/api"

def login_admin():
    response = requests.post(f"{BASE_URL}/auth/login", json={
        "correo_electronico": "admin@bibliogest.com",
        "contrasena": "admin123"
    })
    if response.status_code == 200:
        return response.json()["access_token"]
    return None

def crear_categoria(token, datos):
    response = requests.post(
        f"{BASE_URL}/categorias/",
        json=datos,
        headers={"Authorization": f"Bearer {token}"}
    )
    if response.status_code == 201:
        cat = response.json()
        print(f"Categoria creada: {cat['nombre']}")
        return cat
    else:
        print(f"Error categoria: {response.status_code} - {response.text}")
        return None

def crear_material(token, datos):
    response = requests.post(
        f"{BASE_URL}/materiales/",
        json=datos,
        headers={"Authorization": f"Bearer {token}"}
    )
    if response.status_code == 201:
        mat = response.json()
        print(f"Material creado: {mat['titulo']}")
        return mat
    else:
        print(f"Error material: {response.status_code} - {response.text}")
        return None

CATEGORIAS = [
    {"nombre": "Literatura", "descripcion": "Obras literarias, novelas, cuentos, poesia"},
    {"nombre": "Ciencias", "descripcion": "Libros de ciencias naturales, fisica, quimica, biologia"},
    {"nombre": "Matematicas", "descripcion": "Libros de matematicas, algebra, geometria, calculo"},
    {"nombre": "Tecnologia", "descripcion": "Libros de informatica, programacion, tecnologia"},
    {"nombre": "Historia", "descripcion": "Libros de historia universal y nacional"},
    {"nombre": "Educacion", "descripcion": "Libros educativos, pedagogia, didactica"},
    {"nombre": "Referencia", "descripcion": "Diccionarios, enciclopedias, manuales"},
    {"nombre": "Infantil", "descripcion": "Libros para niños y jóvenes"},
]

if __name__ == "__main__":
    print("=== Creando categorias y materiales de prueba ===\n")
    
    token = login_admin()
    if not token:
        print("Error al obtener token")
        exit(1)
    
    print("Creando categorias...\n")
    categorias_creadas = []
    for cat in CATEGORIAS:
        result = crear_categoria(token, cat)
        if result:
            categorias_creadas.append(result)
    
    if len(categorias_creadas) >= 3:
        print("\nCreando materiales...\n")
        
        MATERIALES = [
            {
                "codigo": "LIT-001",
                "titulo": "Cien anos de soledad",
                "tipo_material": "libro",
                "estado": "disponible",
                "autor": "Gabriel Garcia Marquez",
                "isbn": "978-0307474728",
                "editorial": "Editorial Sudamericana",
                "anio_publicacion": 1967,
                "numero_paginas": 471,
                "idioma": "Espanol",
                "categoria_id": categorias_creadas[0]["id"]
            },
            {
                "codigo": "LIT-002",
                "titulo": "Don Quijote de la Mancha",
                "tipo_material": "libro",
                "estado": "disponible",
                "autor": "Miguel de Cervantes",
                "isbn": "978-8424922580",
                "editorial": "Real Academia Espanola",
                "anio_publicacion": 1605,
                "numero_paginas": 863,
                "idioma": "Espanol",
                "categoria_id": categorias_creadas[0]["id"]
            },
            {
                "codigo": "CIEN-001",
                "titulo": "El universo en tu mano",
                "tipo_material": "libro",
                "estado": "disponible",
                "autor": "Christophe Galfard",
                "isbn": "978-8484288208",
                "editorial": "Ediciones B",
                "anio_publicacion": 2015,
                "numero_paginas": 384,
                "idioma": "Espanol",
                "categoria_id": categorias_creadas[1]["id"]
            },
            {
                "codigo": "MATH-001",
                "titulo": "Algebra de Baldor",
                "tipo_material": "libro",
                "estado": "disponible",
                "autor": "Aurelio Baldor",
                "isbn": "978-6074415247",
                "editorial": "Grupo Editorial Patria",
                "anio_publicacion": 1941,
                "numero_paginas": 576,
                "idioma": "Espanol",
                "categoria_id": categorias_creadas[2]["id"]
            },
            {
                "codigo": "TEC-001",
                "titulo": "Clean Code",
                "tipo_material": "libro",
                "estado": "disponible",
                "autor": "Robert C. Martin",
                "isbn": "978-0132350884",
                "editorial": "Prentice Hall",
                "anio_publicacion": 2008,
                "numero_paginas": 464,
                "idioma": "Ingles",
                "categoria_id": categorias_creadas[3]["id"]
            },
            {
                "codigo": "PROY-001",
                "titulo": "Proyector Epson PowerLite",
                "tipo_material": "proyector",
                "estado": "disponible",
                "descripcion": "Proyector portatil para presentaciones",
                "ubicacion": "Sala de conferencias",
                "cantidad_disponible": 2,
                "categoria_id": categorias_creadas[6]["id"]
            },
            {
                "codigo": "DVD-001",
                "titulo": "Documental: La vida en la Tierra",
                "tipo_material": "dvd",
                "estado": "disponible",
                "formato": "DVD",
                "duracion": "90 minutos",
                "descripcion": "Documental sobre la naturaleza",
                "categoria_id": categorias_creadas[1]["id"]
            },
        ]
        
        for mat in MATERIALES:
            crear_material(token, mat)
    
    print("\n=== Datos de prueba creados ===")
    print("\nResumen:")
    print(f"- {len(CATEGORIAS)} categorias")
    print(f"- 7 materiales (5 libros, 1 proyector, 1 dvd)")
    print(f"- 6 usuarios (1 admin, 2 bibliotecarios, 3 estudiantes)")
