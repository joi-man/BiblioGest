"""Inventario extendido: equipos, busqueda y edicion parcial."""
from tests.conftest import encabezados


def crear(cliente, personal, categoria, **datos):
    base = {
        "codigo": "P-001",
        "titulo": "Proyector Epson",
        "tipo_material": "proyector",
        "categoria_id": str(categoria.id),
    }
    base.update(datos)
    return cliente.post("/api/materiales/", json=base, headers=encabezados(personal))


def test_crear_un_equipo_guarda_los_campos_especificos(
    cliente, bibliotecario, categoria_equipos
):
    respuesta = crear(
        cliente, bibliotecario, categoria_equipos,
        marca="Epson", modelo="X49", numero_serie="SN-123", ubicacion="Sala de equipos",
        accesorios="Cable HDMI, control remoto", valor_referencial=450.5,
        plazo_prestamo_horas=3,
    )

    assert respuesta.status_code == 201
    cuerpo = respuesta.json()
    assert cuerpo["marca"] == "Epson"
    assert cuerpo["numero_serie"] == "SN-123"
    assert cuerpo["accesorios"] == "Cable HDMI, control remoto"
    assert cuerpo["valor_referencial"] == 450.5
    assert cuerpo["plazo_prestamo_horas"] == 3
    assert cuerpo["condicion"] == "bueno"
    assert cuerpo["es_prestable"] is True
    assert cuerpo["estado"] == "disponible"


def test_los_tipos_de_equipo_son_validos_y_uno_desconocido_se_rechaza(
    cliente, bibliotecario, categoria_equipos
):
    assert crear(cliente, bibliotecario, categoria_equipos, tipo_material="alargador").status_code == 201
    invalido = crear(cliente, bibliotecario, categoria_equipos, codigo="X-1", tipo_material="nave")
    assert invalido.status_code == 422


def test_un_estudiante_no_puede_crear_materiales(cliente, estudiante, categoria_equipos):
    assert crear(cliente, estudiante, categoria_equipos).status_code == 403


def test_el_codigo_de_inventario_no_se_puede_repetir(cliente, bibliotecario, categoria_equipos):
    crear(cliente, bibliotecario, categoria_equipos)

    repetido = crear(cliente, bibliotecario, categoria_equipos)

    assert repetido.status_code == 400


def test_buscar_por_texto_encuentra_por_serie_marca_o_titulo(
    cliente, bibliotecario, categoria_equipos
):
    crear(cliente, bibliotecario, categoria_equipos, numero_serie="SN-777", marca="Epson")
    crear(cliente, bibliotecario, categoria_equipos, codigo="A-1", titulo="Alargador 5 m",
          tipo_material="alargador")

    def buscar(**params):
        return cliente.get("/api/materiales/", params=params, headers=encabezados(bibliotecario)).json()

    assert [m["codigo"] for m in buscar(q="SN-777")] == ["P-001"]
    assert [m["codigo"] for m in buscar(q="epson")] == ["P-001"]
    assert [m["codigo"] for m in buscar(q="alargador")] == ["A-1"]
    assert [m["codigo"] for m in buscar(tipo="alargador")] == ["A-1"]


def test_filtro_disponible_excluye_prestados_y_los_solo_sala(
    cliente, bibliotecario, estudiante, categoria_libros, crear_material
):
    crear_material(categoria_libros, "L-1")
    crear_material(categoria_libros, "L-2", estado="prestado")
    crear_material(categoria_libros, "L-3", es_prestable=False)

    disponibles = cliente.get(
        "/api/materiales/", params={"disponible": True}, headers=encabezados(estudiante)
    ).json()

    assert [m["codigo"] for m in disponibles] == ["L-1"]


def test_actualizar_solo_cambia_los_campos_enviados(
    cliente, bibliotecario, categoria_equipos
):
    material = crear(cliente, bibliotecario, categoria_equipos, marca="Epson", ubicacion="B3").json()

    actualizado = cliente.put(
        f"/api/materiales/{material['id']}",
        json={"ubicacion": "Estante A"},
        headers=encabezados(bibliotecario),
    ).json()

    assert actualizado["ubicacion"] == "Estante A"
    assert actualizado["marca"] == "Epson"


def test_un_campo_opcional_se_puede_vaciar_pero_uno_obligatorio_no(
    cliente, bibliotecario, categoria_equipos
):
    material = crear(cliente, bibliotecario, categoria_equipos, accesorios="Cable").json()

    actualizado = cliente.put(
        f"/api/materiales/{material['id']}",
        json={"accesorios": None, "titulo": None},
        headers=encabezados(bibliotecario),
    ).json()

    assert actualizado["accesorios"] is None  # opcional: se vacia
    assert actualizado["titulo"] == "Proyector Epson"  # obligatorio: se ignora el null


def test_las_categorias_guardan_el_plazo_por_defecto(cliente, admin):
    respuesta = cliente.post(
        "/api/categorias/",
        json={"nombre": "Audio", "plazo_prestamo_horas": 6},
        headers=encabezados(admin),
    )

    assert respuesta.status_code == 201
    assert respuesta.json()["plazo_prestamo_horas"] == 6
