"""Reportes de prestamos, prestamos vencidos (RFC-G1) y devoluciones, con exportacion."""
from tests.conftest import encabezados
from tests.test_devoluciones_y_vencimientos import devolver
from tests.test_flujo_prestamos import accion, solicitar


def reporte(cliente, usuario, tipo, **params):
    return cliente.get(f"/api/reportes/{tipo}", params=params, headers=encabezados(usuario))


def exportar(cliente, usuario, tipo, **params):
    return cliente.get(f"/api/reportes/{tipo}/exportar", params=params, headers=encabezados(usuario))


def entregar(cliente, personal, estudiante, material):
    """Solicita y entrega un material: queda un prestamo activo."""
    prestamo_id = solicitar(cliente, estudiante, material).json()["id"]
    return accion(cliente, personal, prestamo_id, "entregar").json()


# ---------------------------------------------------------------------------
# Prestamos
# ---------------------------------------------------------------------------
def test_el_reporte_de_prestamos_lista_columnas_y_filas(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1", titulo="Rayuela")
    entregar(cliente, bibliotecario, estudiante, libro)

    respuesta = reporte(cliente, bibliotecario, "prestamos")

    assert respuesta.status_code == 200
    cuerpo = respuesta.json()
    assert cuerpo["columnas"][:3] == ["Solicitud", "Persona", "Documento"]
    assert cuerpo["total"] == 1
    fila = cuerpo["filas"][0]
    assert fila[1] == "Ana Prueba" and "Rayuela (L-1)" in fila[3] and fila[4] == "En préstamo"


def test_el_reporte_de_prestamos_filtra_por_estado_y_por_rango_de_fechas(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    solicitar(cliente, estudiante, crear_material(categoria_libros, "L-1"))  # 10/10, pendiente
    reloj_prueba.avanzar(days=5)
    entregar(cliente, bibliotecario, otro_estudiante, crear_material(categoria_libros, "L-2"))  # 15/10, activo

    pendientes = reporte(cliente, bibliotecario, "prestamos", estado="pendiente").json()
    assert [f[1] for f in pendientes["filas"]] == ["Ana Prueba"]

    desde_el_14 = reporte(cliente, bibliotecario, "prestamos", desde="2026-10-14").json()
    assert [f[1] for f in desde_el_14["filas"]] == ["Luis Prueba"]

    hasta_el_10 = reporte(cliente, bibliotecario, "prestamos", hasta="2026-10-10").json()
    assert [f[1] for f in hasta_el_10["filas"]] == ["Ana Prueba"]  # el dia 'hasta' se incluye completo

    sin_nada = reporte(cliente, bibliotecario, "prestamos", desde="2026-11-01").json()
    assert sin_nada["total"] == 0 and sin_nada["filas"] == []


def test_el_reporte_busca_por_persona_o_material_y_pagina(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material
):
    entregar(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1", titulo="Rayuela"))
    entregar(cliente, bibliotecario, otro_estudiante, crear_material(categoria_libros, "L-2", titulo="El Aleph"))

    por_material = reporte(cliente, bibliotecario, "prestamos", q="aleph").json()
    assert [f[1] for f in por_material["filas"]] == ["Luis Prueba"]

    primera = reporte(cliente, bibliotecario, "prestamos", tamano=1, pagina=1).json()
    assert primera["total"] == 2 and primera["total_paginas"] == 2 and len(primera["filas"]) == 1


# ---------------------------------------------------------------------------
# Prestamos vencidos (RFC-G1)
# ---------------------------------------------------------------------------
def test_vencidos_muestra_solo_los_atrasados_con_sus_dias_de_atraso(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    entregar(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1", titulo="Rayuela"))
    reloj_prueba.avanzar(days=6)
    entregar(cliente, bibliotecario, otro_estudiante, crear_material(categoria_libros, "L-2"))  # vence el 23/10
    reloj_prueba.avanzar(days=3)  # 19/10: el primero (limite 17/10) ya vencio, el segundo no

    cuerpo = reporte(cliente, bibliotecario, "vencidos").json()

    assert cuerpo["columnas"][-2:] == ["Fecha límite", "Días de atraso"]
    assert [f[0] for f in cuerpo["filas"]] == ["Ana Prueba"]
    assert cuerpo["filas"][0][4] == "Rayuela (L-1)"
    assert cuerpo["filas"][0][6] == "2"  # 17/10 12:00 -> 19/10 12:00


def test_vencidos_se_filtra_por_rango_de_fechas_limite(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    entregar(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))  # limite 17/10
    reloj_prueba.avanzar(days=2)
    entregar(cliente, bibliotecario, otro_estudiante, crear_material(categoria_libros, "L-2"))  # limite 19/10
    reloj_prueba.avanzar(days=10)  # 22/10: los dos vencidos

    todos = reporte(cliente, bibliotecario, "vencidos").json()
    assert todos["total"] == 2

    solo_el_primero = reporte(cliente, bibliotecario, "vencidos", desde="2026-10-16", hasta="2026-10-17").json()
    assert [f[0] for f in solo_el_primero["filas"]] == ["Ana Prueba"]

    solo_el_segundo = reporte(cliente, bibliotecario, "vencidos", desde="2026-10-18").json()
    assert [f[0] for f in solo_el_segundo["filas"]] == ["Luis Prueba"]


def test_vencidos_exporta_a_csv_con_el_filtro_aplicado(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    entregar(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1", titulo="Rayuela"))
    reloj_prueba.avanzar(days=2)
    entregar(cliente, bibliotecario, otro_estudiante, crear_material(categoria_libros, "L-2"))
    reloj_prueba.avanzar(days=10)

    respuesta = exportar(cliente, bibliotecario, "vencidos", formato="csv", desde="2026-10-16", hasta="2026-10-17")

    assert respuesta.status_code == 200
    assert respuesta.headers["content-type"].startswith("text/csv")
    assert "prestamos_vencidos_" in respuesta.headers["content-disposition"]
    assert respuesta.headers["content-disposition"].endswith('.csv"')
    assert respuesta.content.startswith(b"\xef\xbb\xbf")  # BOM: Excel respeta las tildes
    lineas = respuesta.content.decode("utf-8-sig").strip().split("\r\n")
    assert lineas[0] == "Persona;Documento;Correo;Teléfono;Materiales pendientes;Fecha límite;Días de atraso"
    assert len(lineas) == 2  # encabezado + el unico vencido del rango
    assert lineas[1].startswith("Ana Prueba;D-003;ana@prueba.com;;Rayuela (L-1);17/10/2026 12:00;")


def test_los_reportes_tambien_se_exportan_a_excel_y_pdf(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    entregar(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))

    excel = exportar(cliente, bibliotecario, "prestamos", formato="xlsx")
    pdf = exportar(cliente, bibliotecario, "prestamos", formato="pdf")

    assert excel.status_code == 200 and excel.content[:2] == b"PK"
    assert pdf.status_code == 200 and pdf.content[:4] == b"%PDF"


# ---------------------------------------------------------------------------
# Devoluciones
# ---------------------------------------------------------------------------
def test_el_reporte_de_devoluciones_muestra_condicion_y_dias_de_retraso(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    prestamo_a = entregar(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1", titulo="Rayuela"))
    prestamo_b = entregar(cliente, bibliotecario, otro_estudiante, crear_material(categoria_libros, "L-2", titulo="El Aleph"))
    reloj_prueba.avanzar(days=9)  # ambos pasan el limite de 7 dias
    devolver(cliente, bibliotecario, prestamo_a, (0, "bueno"))
    devolver(cliente, bibliotecario, prestamo_b, (0, "dano_menor"))

    todas = reporte(cliente, bibliotecario, "devoluciones").json()
    assert todas["total"] == 2
    assert todas["columnas"][:7] == ["Fecha", "Persona", "Documento", "Material", "Código", "Condición", "Días de retraso"]
    assert "Multa" not in todas["columnas"]  # el sistema de multas esta desactivado por defecto

    con_dano = reporte(cliente, bibliotecario, "devoluciones", condicion="dano_menor").json()
    assert len(con_dano["filas"]) == 1
    fila = con_dano["filas"][0]
    assert fila[1] == "Luis Prueba" and fila[3] == "El Aleph" and fila[5] == "Daño menor" and fila[6] == "2"
    assert fila[-1] == "Biblio Prueba"


def test_devoluciones_filtra_por_fechas_y_exporta(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    prestamo = entregar(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    reloj_prueba.avanzar(days=3)
    devolver(cliente, bibliotecario, prestamo, (0, "bueno"))  # 13/10

    assert reporte(cliente, bibliotecario, "devoluciones", desde="2026-10-14").json()["total"] == 0
    assert reporte(cliente, bibliotecario, "devoluciones", desde="2026-10-13", hasta="2026-10-13").json()["total"] == 1

    csv = exportar(cliente, bibliotecario, "devoluciones", formato="csv").content.decode("utf-8-sig")
    assert csv.splitlines()[0].startswith("Fecha;Persona;Documento;Material;Código;Condición")
    assert len(csv.strip().splitlines()) == 2


# ---------------------------------------------------------------------------
# Validaciones y permisos
# ---------------------------------------------------------------------------
def test_un_estudiante_no_puede_ver_ni_exportar_reportes(cliente, estudiante):
    assert reporte(cliente, estudiante, "prestamos").status_code == 403
    assert exportar(cliente, estudiante, "vencidos", formato="csv").status_code == 403


def test_los_reportes_exigen_sesion(cliente):
    assert cliente.get("/api/reportes/prestamos").status_code in (401, 403)


def test_parametros_invalidos_se_rechazan_con_un_mensaje_claro(cliente, bibliotecario):
    assert reporte(cliente, bibliotecario, "inventado").status_code == 404
    assert reporte(cliente, bibliotecario, "prestamos", desde="2026-10-20", hasta="2026-10-10").status_code == 400
    assert reporte(cliente, bibliotecario, "prestamos", estado="volando").status_code == 422
    assert reporte(cliente, bibliotecario, "devoluciones", condicion="roto").status_code == 422
    assert exportar(cliente, bibliotecario, "prestamos", formato="docx").status_code == 400
