"""Suspension de usuarios, edicion completa y numero de documento sin puntos."""
from tests.conftest import encabezados


def actualizar(cliente, admin, usuario, **datos):
    return cliente.put(f"/api/usuarios/{usuario.id}", json=datos, headers=encabezados(admin))


def login(cliente, usuario, contrasena="Clave12345"):
    return cliente.post(
        "/api/auth/login", json={"correo_o_usuario": usuario.username, "contrasena": contrasena}
    )


def test_un_usuario_suspendido_pierde_la_sesion_al_instante(cliente, admin, estudiante):
    assert cliente.get("/api/materiales/", headers=encabezados(estudiante)).status_code == 200

    assert actualizar(cliente, admin, estudiante, activo=False).status_code == 200

    respuesta = cliente.get("/api/materiales/", headers=encabezados(estudiante))
    assert respuesta.status_code == 401
    assert "suspendida" in respuesta.json()["detail"]


def test_al_iniciar_sesion_suspendido_se_le_avisa(cliente, admin, estudiante):
    actualizar(cliente, admin, estudiante, activo=False)

    respuesta = login(cliente, estudiante)

    assert respuesta.status_code == 403
    assert "suspendida" in respuesta.json()["detail"]


def test_la_suspension_no_se_revela_con_una_contrasena_incorrecta(cliente, admin, estudiante):
    actualizar(cliente, admin, estudiante, activo=False)

    respuesta = login(cliente, estudiante, "otra-clave")

    assert respuesta.status_code == 401
    assert "suspendida" not in respuesta.json()["detail"]


def test_al_reactivar_vuelve_a_entrar(cliente, admin, estudiante):
    actualizar(cliente, admin, estudiante, activo=False)
    actualizar(cliente, admin, estudiante, activo=True)

    assert login(cliente, estudiante).status_code == 200
    assert cliente.get("/api/materiales/", headers=encabezados(estudiante)).status_code == 200


def test_no_se_puede_suspender_la_propia_cuenta(cliente, admin):
    respuesta = actualizar(cliente, admin, admin, activo=False)

    assert respuesta.status_code == 400


def test_editar_cambia_el_documento_y_la_contrasena(cliente, admin, estudiante):
    respuesta = actualizar(cliente, admin, estudiante, numero_documento="9999999", contrasena="NuevaClave1")

    assert respuesta.status_code == 200
    assert respuesta.json()["numero_documento"] == "9999999"
    assert login(cliente, estudiante).status_code == 401
    assert login(cliente, estudiante, "NuevaClave1").status_code == 200


def test_editar_sin_contrasena_conserva_la_actual(cliente, admin, estudiante):
    actualizar(cliente, admin, estudiante, nombre="Nombre Nuevo")

    assert login(cliente, estudiante).status_code == 200


def test_el_documento_se_guarda_sin_puntos_ni_espacios(cliente, admin):
    nuevo = {
        "username": "pedro", "correo_electronico": "pedro@prueba.com", "numero_documento": "4.111 222",
        "nombre": "Pedro", "apellido": "Gomez", "rol": "estudiante", "contrasena": "Clave12345",
    }

    creado = cliente.post("/api/usuarios/", json=nuevo, headers=encabezados(admin))
    assert creado.status_code == 201
    assert creado.json()["numero_documento"] == "4111222"

    editado = cliente.put(
        f"/api/usuarios/{creado.json()['id']}", json={"numero_documento": "5.222.333"}, headers=encabezados(admin)
    )
    assert editado.json()["numero_documento"] == "5222333"


def test_un_usuario_eliminado_no_aparece_en_ningun_listado(cliente, admin, estudiante):
    cliente.delete(f"/api/usuarios/{estudiante.id}", headers=encabezados(admin))

    buscar = cliente.get("/api/usuarios/buscar", headers=encabezados(admin)).json()
    lista = cliente.get("/api/usuarios/", headers=encabezados(admin)).json()
    exportar = cliente.get("/api/usuarios/exportar", params={"formato": "csv"}, headers=encabezados(admin))

    assert estudiante.username not in [u["username"] for u in buscar["items"]]
    assert estudiante.username not in [u["username"] for u in lista]
    assert login(cliente, estudiante).status_code == 401
    assert exportar.status_code == 200 and estudiante.username.encode() not in exportar.content
