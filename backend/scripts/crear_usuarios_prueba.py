"""
Script para crear usuarios de prueba en BiblioGest.
Ejecutar: python scripts/crear_usuarios_prueba.py
"""
import requests

BASE_URL = "http://localhost:8000/api"

def login_admin():
    response = requests.post(f"{BASE_URL}/auth/login", json={
        "correo_o_usuario": "admin@bibliogest.com",
        "contrasena": "admin123"
    })
    if response.status_code == 200:
        data = response.json()
        print(f"Login admin exitoso: {data['usuario']['nombre']} {data['usuario']['apellido']}")
        return data["access_token"]
    else:
        print(f"Error login: {response.status_code} - {response.text}")
        return None

def crear_usuario(token, datos):
    response = requests.post(
        f"{BASE_URL}/usuarios/",
        json=datos,
        headers={"Authorization": f"Bearer {token}"}
    )
    if response.status_code == 201:
        usuario = response.json()
        print(f"Creado: {usuario['username']} - {usuario['nombre']} {usuario['apellido']} ({usuario['rol']})")
        return usuario
    else:
        print(f"Error: {response.status_code} - {response.text}")
        return None

USUARIOS_PRUEBA = [
    {
        "username": "maria.gonzalez",
        "correo_electronico": "bibliotecario@bibliogest.com",
        "contrasena": "biblio123",
        "numero_documento": "4567890",
        "nombre": "Maria",
        "apellido": "Gonzalez",
        "rol": "bibliotecario",
        "telefono": "0981234567"
    },
    {
        "username": "juan.perez",
        "correo_electronico": "estudiante1@bibliogest.com",
        "contrasena": "estudiante123",
        "numero_documento": "1234567",
        "nombre": "Juan",
        "apellido": "Perez",
        "rol": "estudiante",
        "telefono": "0991234567"
    },
    {
        "username": "ana.lopez",
        "correo_electronico": "estudiante2@bibliogest.com",
        "contrasena": "estudiante123",
        "numero_documento": "7654321",
        "nombre": "Ana",
        "apellido": "Lopez",
        "rol": "estudiante",
        "telefono": "0987654321"
    },
    {
        "username": "carlos.martinez",
        "correo_electronico": "estudiante3@bibliogest.com",
        "contrasena": "estudiante123",
        "numero_documento": "1122334",
        "nombre": "Carlos",
        "apellido": "Martinez",
        "rol": "estudiante",
        "telefono": "0971234567"
    },
    {
        "username": "laura.fernandez",
        "correo_electronico": "bibliotecario2@bibliogest.com",
        "contrasena": "biblio123",
        "numero_documento": "9988776",
        "nombre": "Laura",
        "apellido": "Fernandez",
        "rol": "bibliotecario",
        "telefono": "0961234567"
    },
]

if __name__ == "__main__":
    print("=== Creando usuarios de prueba en BiblioGest ===\n")
    
    token = login_admin()
    if not token:
        print("No se pudo obtener token de admin.")
        exit(1)
    
    print(f"\nToken obtenido correctamente.\n")
    print("Creando usuarios...\n")
    
    for usuario in USUARIOS_PRUEBA:
        crear_usuario(token, usuario)
    
    print("\n=== Usuarios creados ===")
    print("\nCredenciales para probar:")
    print("-" * 60)
    print(f"{'Rol':<15} {'Username':<20} {'Contrasena':<15}")
    print("-" * 60)
    print(f"{'Admin':<15} {'admin':<20} {'admin123':<15}")
    print(f"{'Bibliotecario':<15} {'maria.gonzalez':<20} {'biblio123':<15}")
    print(f"{'Estudiante':<15} {'juan.perez':<20} {'estudiante123':<15}")
    print(f"{'Estudiante':<15} {'ana.lopez':<20} {'estudiante123':<15}")
    print(f"{'Estudiante':<15} {'carlos.martinez':<20} {'estudiante123':<15}")
    print(f"{'Bibliotecario':<15} {'laura.fernandez':<20} {'biblio123':<15}")
    print("-" * 60)
    print("\nTambien puedes usar el correo electronico para iniciar sesion.")
