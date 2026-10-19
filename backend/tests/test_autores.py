"""Autores: gestion aparte, carga junto al material y busqueda por autor."""
from tests.conftest import encabezados


def crear_autor(cliente, personal, nombre):
    return cliente.post("/api/autores/", json={"nombre": nombre}, headers=encabezados(personal))


def crear_libro(cliente, personal, categoria, codigo="L-1", **datos):
    base = {
        "codigo": codigo,
        "titulo": f"Libro {codigo}",
        "tipo_material": "libro",
        "categoria_id": str(categoria.id),
    }
    base.update(datos)
    return cliente.post("/api/materiales/", json=base, headers=encabezados(personal))


def nombres(material_json):
    return [a["nombre"] for a in material_json["autores"]]


def test_crear_autor_y_no_repetirlo_aunque_cambien_tildes_o_mayusculas(cliente, bibliotecario):
    assert crear_autor(cliente, bibliotecario, "Gabriel García Márquez").status_code == 201

    repetido = crear_autor(cliente, bibliotecario, "gabriel garcia marquez")

    assert repetido.status_code == 400
    assert "Ya existe" in repetido.json()["detail"]


def test_un_estudiante_no_gestiona_autores(cliente, estudiante):
    assert crear_autor(cliente, estudiante, "Cervantes").status_code == 403


def test_un_libro_puede_tener_varios_autores_y_un_autor_varios_libros(
    cliente, bibliotecario, categoria_libros
):
    borges = crear_autor(cliente, bibliotecario, "Jorge Luis Borges").json()
    bioy = crear_autor(cliente, bibliotecario, "Adolfo Bioy Casares").json()

    uno = crear_libro(cliente, bibliotecario, categoria_libros, "L-1", autores_ids=[borges["id"], bioy["id"]])
    dos = crear_libro(cliente, bibliotecario, categoria_libros, "L-2", autores_ids=[borges["id"]])

    assert uno.status_code == 201
    assert nombres(uno.json()) == ["Jorge Luis Borges", "Adolfo Bioy Casares"]
    assert uno.json()["autor"] == "Jorge Luis Borges, Adolfo Bioy Casares"
    assert nombres(dos.json()) == ["Jorge Luis Borges"]

    listado = cliente.get("/api/autores/", headers=encabezados(bibliotecario)).json()
    por_nombre = {a["nombre"]: a["cantidad_materiales"] for a in listado}
    assert por_nombre == {"Jorge Luis Borges": 2, "Adolfo Bioy Casares": 1}


def test_los_autores_se_crean_al_cargar_el_material_sin_pasar_por_la_seccion_de_autores(
    cliente, bibliotecario, categoria_libros
):
    existente = crear_autor(cliente, bibliotecario, "Julio Cortázar").json()

    respuesta = crear_libro(
        cliente, bibliotecario, categoria_libros, "L-1",
        autores_ids=[existente["id"]], autores_nuevos=["Carol Dunlop", "julio cortazar"],
    )

    assert respuesta.status_code == 201
    # "julio cortazar" ya existia (sin tildes): se reutiliza, no se duplica.
    assert nombres(respuesta.json()) == ["Julio Cortázar", "Carol Dunlop"]
    todos = cliente.get("/api/autores/", headers=encabezados(bibliotecario)).json()
    assert len(todos) == 2


def test_un_cliente_antiguo_puede_enviar_el_autor_como_texto(cliente, bibliotecario, categoria_libros):
    respuesta = crear_libro(cliente, bibliotecario, categoria_libros, autor="Cervantes; Quevedo y Lope de Vega")

    assert nombres(respuesta.json()) == ["Cervantes", "Quevedo", "Lope de Vega"]


def test_un_cliente_antiguo_que_reenvia_el_resumen_no_rompe_los_autores(cliente, bibliotecario, categoria_libros):
    libro = crear_libro(cliente, bibliotecario, categoria_libros, autores_nuevos=["Ana", "Beto"]).json()

    respuesta = cliente.put(
        f"/api/materiales/{libro['id']}", json={"autor": libro["autor"], "titulo": "Nuevo"},
        headers=encabezados(bibliotecario),
    )

    assert nombres(respuesta.json()) == ["Ana", "Beto"]


def test_un_autor_con_formato_apellido_coma_nombre_no_se_parte(cliente, bibliotecario, categoria_libros):
    respuesta = crear_libro(cliente, bibliotecario, categoria_libros, autor="Cortázar, Julio")

    assert nombres(respuesta.json()) == ["Cortázar, Julio"]


def test_editar_los_autores_de_un_material_quita_y_agrega(cliente, bibliotecario, categoria_libros):
    libro = crear_libro(cliente, bibliotecario, categoria_libros, autores_nuevos=["Ana", "Beto"]).json()
    beto = next(a for a in libro["autores"] if a["nombre"] == "Beto")

    respuesta = cliente.put(
        f"/api/materiales/{libro['id']}",
        json={"autores_ids": [beto["id"]], "autores_nuevos": ["Carla"]},
        headers=encabezados(bibliotecario),
    )

    assert respuesta.status_code == 200
    assert nombres(respuesta.json()) == ["Beto", "Carla"]
    assert respuesta.json()["autor"] == "Beto, Carla"


def test_editar_un_material_sin_mencionar_autores_los_conserva(cliente, bibliotecario, categoria_libros):
    libro = crear_libro(cliente, bibliotecario, categoria_libros, autores_nuevos=["Ana"]).json()

    respuesta = cliente.put(
        f"/api/materiales/{libro['id']}", json={"titulo": "Otro titulo"}, headers=encabezados(bibliotecario)
    )

    assert nombres(respuesta.json()) == ["Ana"]


def test_renombrar_un_autor_actualiza_sus_libros(cliente, bibliotecario, categoria_libros):
    libro = crear_libro(cliente, bibliotecario, categoria_libros, autores_nuevos=["G. G. Marquez"]).json()
    autor_id = libro["autores"][0]["id"]

    cliente.put(f"/api/autores/{autor_id}", json={"nombre": "Gabriel García Márquez"}, headers=encabezados(bibliotecario))

    actualizado = cliente.get(f"/api/materiales/{libro['id']}", headers=encabezados(bibliotecario)).json()
    assert actualizado["autor"] == "Gabriel García Márquez"
    # y ahora se encuentra por el nombre nuevo, sin tildes
    encontrados = cliente.get("/api/materiales/?q=garcia marquez", headers=encabezados(bibliotecario)).json()
    assert [m["id"] for m in encontrados] == [libro["id"]]


def test_no_se_elimina_un_autor_con_materiales_pero_si_uno_libre(cliente, bibliotecario, categoria_libros):
    libro = crear_libro(cliente, bibliotecario, categoria_libros, autores_nuevos=["Ana"]).json()
    ana = libro["autores"][0]["id"]
    libre = crear_autor(cliente, bibliotecario, "Sin libros").json()

    bloqueado = cliente.delete(f"/api/autores/{ana}", headers=encabezados(bibliotecario))
    permitido = cliente.delete(f"/api/autores/{libre['id']}", headers=encabezados(bibliotecario))

    assert bloqueado.status_code == 400
    assert "materiales asociados" in bloqueado.json()["detail"]
    assert permitido.status_code == 200


def test_la_busqueda_encuentra_por_autor_sin_importar_tildes_y_con_varias_palabras(
    cliente, bibliotecario, categoria_libros
):
    a = crear_libro(cliente, bibliotecario, categoria_libros, "L-1", titulo="Cien años de soledad",
                    autores_nuevos=["Gabriel García Márquez"]).json()
    b = crear_libro(cliente, bibliotecario, categoria_libros, "L-2", titulo="El Aleph",
                    autores_nuevos=["Jorge Luis Borges"]).json()

    def buscar(q):
        respuesta = cliente.get("/api/materiales/buscar", params={"q": q}, headers=encabezados(bibliotecario))
        return [m["id"] for m in respuesta.json()["items"]]

    assert buscar("garcia") == [a["id"]]
    assert buscar("MARQUEZ gabriel") == [a["id"]]  # palabras en cualquier orden
    assert buscar("borges aleph") == [b["id"]]  # autor y titulo a la vez
    assert buscar("borges soledad") == []  # todas las palabras deben coincidir
    assert buscar("anos soledad") == [a["id"]]  # la ñ tambien se normaliza


def test_filtrar_materiales_por_autor(cliente, bibliotecario, categoria_libros):
    uno = crear_libro(cliente, bibliotecario, categoria_libros, "L-1", autores_nuevos=["Ana", "Beto"]).json()
    crear_libro(cliente, bibliotecario, categoria_libros, "L-2", autores_nuevos=["Carla"])
    ana = next(a for a in uno["autores"] if a["nombre"] == "Ana")

    respuesta = cliente.get(
        "/api/materiales/buscar", params={"autor_id": ana["id"]}, headers=encabezados(bibliotecario)
    ).json()

    assert [m["id"] for m in respuesta["items"]] == [uno["id"]]


def test_un_estudiante_ve_los_autores_en_el_catalogo(
    cliente, estudiante, bibliotecario, categoria_libros
):
    crear_libro(cliente, bibliotecario, categoria_libros, autores_nuevos=["Ana"])

    catalogo = cliente.get("/api/materiales/?q=ana", headers=encabezados(estudiante)).json()

    assert nombres(catalogo[0]) == ["Ana"]
