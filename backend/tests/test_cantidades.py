"""Ejemplares: reservas y prestamos coherentes con la cantidad disponible, y tomos."""
from datetime import timedelta

from tests.conftest import encabezados
from tests.test_flujo_prestamos import accion, solicitar


def estado_de(cliente, personal, material):
    return cliente.get(f"/api/materiales/{material.id}", headers=encabezados(personal)).json()


def test_un_material_nuevo_tiene_un_ejemplar_disponible_por_defecto(
    cliente, bibliotecario, categoria_libros
):
    respuesta = cliente.post(
        "/api/materiales/",
        json={"codigo": "L-1", "titulo": "Libro", "tipo_material": "libro", "categoria_id": str(categoria_libros.id)},
        headers=encabezados(bibliotecario),
    ).json()

    assert (respuesta["cantidad_total"], respuesta["cantidad_disponible"]) == (1, 1)


def test_se_puede_reservar_mientras_queden_ejemplares(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1", cantidad_total=2)
    primera = solicitar(cliente, estudiante, libro).json()["id"]
    segunda = solicitar(cliente, otro_estudiante, libro).json()["id"]

    assert accion(cliente, bibliotecario, primera, "aprobar").status_code == 200
    # queda 1 de 2: el material sigue disponible
    material = estado_de(cliente, bibliotecario, libro)
    assert (material["cantidad_reservada"], material["cantidad_disponible"], material["estado"]) == (1, 1, "disponible")

    assert accion(cliente, bibliotecario, segunda, "aprobar").status_code == 200
    material = estado_de(cliente, bibliotecario, libro)
    assert (material["cantidad_reservada"], material["cantidad_disponible"], material["estado"]) == (2, 0, "reservado")


def test_sin_ejemplares_libres_no_se_puede_solicitar_ni_aprobar(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1", cantidad_total=1)
    pendiente = solicitar(cliente, otro_estudiante, libro).json()["id"]
    primera = solicitar(cliente, estudiante, libro).json()["id"]
    assert accion(cliente, bibliotecario, primera, "aprobar").status_code == 200

    nueva = solicitar(cliente, otro_estudiante, libro)
    aprobar = accion(cliente, bibliotecario, pendiente, "aprobar")

    assert nueva.status_code == 409
    assert aprobar.status_code == 409
    assert "no tiene ejemplares disponibles" in aprobar.json()["detail"]


def test_cancelar_una_reserva_devuelve_el_ejemplar(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1", cantidad_total=3)
    prestamo = solicitar(cliente, estudiante, libro).json()["id"]
    accion(cliente, bibliotecario, prestamo, "aprobar")

    cliente.post(f"/api/solicitudes/{prestamo}/cancelar", headers=encabezados(estudiante))

    assert estado_de(cliente, bibliotecario, libro)["cantidad_disponible"] == 3


def test_entregar_y_devolver_mueve_los_ejemplares_entre_reservado_prestado_y_disponible(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1", cantidad_total=2)
    prestamo = solicitar(cliente, estudiante, libro).json()["id"]
    accion(cliente, bibliotecario, prestamo, "aprobar")
    entregado = accion(cliente, bibliotecario, prestamo, "entregar").json()

    material = estado_de(cliente, bibliotecario, libro)
    assert (material["cantidad_reservada"], material["cantidad_prestada"], material["cantidad_disponible"]) == (0, 1, 1)

    item = entregado["detalles"][0]["id"]
    cliente.post(
        f"/api/devoluciones/{prestamo}",
        json={"items": [{"prestamo_detalle_id": item, "condicion": "bueno"}]},
        headers=encabezados(bibliotecario),
    )
    material = estado_de(cliente, bibliotecario, libro)
    assert (material["cantidad_prestada"], material["cantidad_disponible"], material["estado"]) == (0, 2, "disponible")


def test_un_ejemplar_perdido_queda_fuera_de_servicio_y_los_demas_siguen_prestables(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1", cantidad_total=2)
    prestamo = solicitar(cliente, estudiante, libro).json()["id"]
    accion(cliente, bibliotecario, prestamo, "aprobar")
    item = accion(cliente, bibliotecario, prestamo, "entregar").json()["detalles"][0]["id"]

    cliente.post(
        f"/api/devoluciones/{prestamo}",
        json={"items": [{"prestamo_detalle_id": item, "condicion": "perdido"}]},
        headers=encabezados(bibliotecario),
    )

    material = estado_de(cliente, bibliotecario, libro)
    assert material["cantidad_fuera_servicio"] == 1
    assert material["cantidad_disponible"] == 1
    assert material["estado"] == "disponible"
    assert material["condicion"] == "bueno"  # con varios ejemplares la condicion general no cambia


def test_un_prestamo_vencido_cuenta_como_ejemplar_vencido(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    libro = crear_material(categoria_libros, "L-1", cantidad_total=2)
    prestamo = solicitar(cliente, estudiante, libro).json()["id"]
    accion(cliente, bibliotecario, prestamo, "aprobar")
    accion(cliente, bibliotecario, prestamo, "entregar")

    reloj_prueba.avanzar(days=30)
    cliente.get("/api/prestamos/", headers=encabezados(bibliotecario))  # el vencimiento se calcula al consultar

    material = estado_de(cliente, bibliotecario, libro)
    assert (material["cantidad_vencida"], material["cantidad_prestada"], material["cantidad_disponible"]) == (1, 0, 1)


def test_una_reserva_sin_retirar_expira_y_libera_el_ejemplar(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    libro = crear_material(categoria_libros, "L-1", cantidad_total=1)
    prestamo = solicitar(cliente, estudiante, libro).json()["id"]
    accion(cliente, bibliotecario, prestamo, "aprobar")

    reloj_prueba.avanzar(hours=25)
    cliente.get("/api/prestamos/", headers=encabezados(bibliotecario))

    assert estado_de(cliente, bibliotecario, libro)["cantidad_disponible"] == 1


def test_no_se_pueden_dejar_menos_ejemplares_que_los_prestados(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1", cantidad_total=3)
    prestamo = solicitar(cliente, estudiante, libro).json()["id"]
    accion(cliente, bibliotecario, prestamo, "aprobar")

    rechazo = cliente.put(f"/api/materiales/{libro.id}", json={"cantidad_total": 0}, headers=encabezados(bibliotecario))
    exceso = cliente.put(
        f"/api/materiales/{libro.id}", json={"cantidad_fuera_servicio": 3}, headers=encabezados(bibliotecario)
    )
    valido = cliente.put(
        f"/api/materiales/{libro.id}", json={"cantidad_total": 5}, headers=encabezados(bibliotecario)
    )

    assert rechazo.status_code == 422
    assert exceso.status_code == 400
    assert valido.json()["cantidad_disponible"] == 4


def test_marcar_fuera_de_servicio_con_estado_antiguo_inhabilita_los_ejemplares_libres(
    cliente, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1", cantidad_total=2)

    cliente.put(f"/api/materiales/{libro.id}", json={"estado": "fuera_de_servicio"}, headers=encabezados(bibliotecario))
    material = estado_de(cliente, bibliotecario, libro)
    assert (material["cantidad_fuera_servicio"], material["estado"]) == (2, "fuera_de_servicio")

    cliente.put(f"/api/materiales/{libro.id}", json={"estado": "disponible"}, headers=encabezados(bibliotecario))
    assert estado_de(cliente, bibliotecario, libro)["estado"] == "disponible"


def test_el_resumen_cuenta_ejemplares(cliente, estudiante, bibliotecario, categoria_libros, crear_material):
    libro = crear_material(categoria_libros, "L-1", cantidad_total=5)
    crear_material(categoria_libros, "L-2", cantidad_total=2)
    prestamo = solicitar(cliente, estudiante, libro).json()["id"]
    accion(cliente, bibliotecario, prestamo, "aprobar")

    resumen = cliente.get("/api/dashboard/resumen", headers=encabezados(bibliotecario)).json()["materiales"]

    assert (resumen["total"], resumen["disponibles"], resumen["reservados"]) == (7, 6, 1)


def test_los_tomos_son_materiales_con_su_propio_codigo_y_cantidad(
    cliente, bibliotecario, categoria_libros
):
    base = {"titulo": "Historia universal", "tipo_material": "libro", "categoria_id": str(categoria_libros.id), "total_tomos": 3}
    for numero in (1, 2, 3):
        cliente.post(
            "/api/materiales/",
            json={**base, "codigo": f"HU-{numero}", "tomo": str(numero), "cantidad_total": numero},
            headers=encabezados(bibliotecario),
        )

    segundo = cliente.get("/api/materiales/buscar", params={"q": "historia tomo 2"}, headers=encabezados(bibliotecario)).json()

    assert [(m["codigo"], m["tomo"], m["total_tomos"], m["cantidad_total"]) for m in segundo["items"]] == [("HU-2", "2", 3, 2)]
