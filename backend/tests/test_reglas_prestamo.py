"""Reglas de negocio: limite de items, bloqueo por vencidos y maquina de estados."""
import pytest
from fastapi import HTTPException

from app.core.config import configuracion
from app.servicios.prestamos import maquina_estados
from tests.conftest import encabezados


def solicitar(cliente, usuario, *materiales):
    return cliente.post(
        "/api/solicitudes/",
        json={"material_ids": [str(m.id) for m in materiales]},
        headers=encabezados(usuario),
    )


def test_no_se_puede_superar_el_maximo_de_items_simultaneos(
    cliente, estudiante, categoria_libros, crear_material
):
    libros = [crear_material(categoria_libros, f"L-{i}") for i in range(4)]
    maximo = configuracion.MAX_PRESTAMOS_ACTIVOS

    for libro in libros[:maximo]:
        assert solicitar(cliente, estudiante, libro).status_code == 201

    excedido = solicitar(cliente, estudiante, libros[maximo])
    assert excedido.status_code == 409
    assert "maximo" in excedido.json()["detail"]


def test_un_usuario_con_prestamos_vencidos_no_puede_pedir_mas(
    cliente, reloj_prueba, estudiante, bibliotecario, categoria_equipos, categoria_libros,
    crear_material,
):
    proyector = crear_material(categoria_equipos, "P-1", tipo_material="proyector")
    libro = crear_material(categoria_libros, "L-1")
    cliente.post(
        "/api/prestamos/directo",
        json={"usuario_id": str(estudiante.id), "material_ids": [str(proyector.id)]},
        headers=encabezados(bibliotecario),
    )

    reloj_prueba.avanzar(hours=5)  # el proyector tiene 4 h de plazo

    respuesta = solicitar(cliente, estudiante, libro)
    assert respuesta.status_code == 409
    assert "vencidos" in respuesta.json()["detail"]


def test_el_personal_puede_omitir_las_validaciones_del_usuario(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libros = [crear_material(categoria_libros, f"L-{i}") for i in range(5)]

    sin_omitir = cliente.post(
        "/api/prestamos/directo",
        json={"usuario_id": str(estudiante.id), "material_ids": [str(m.id) for m in libros]},
        headers=encabezados(bibliotecario),
    )
    omitiendo = cliente.post(
        "/api/prestamos/directo",
        json={
            "usuario_id": str(estudiante.id),
            "material_ids": [str(m.id) for m in libros],
            "omitir_validaciones_usuario": True,
        },
        headers=encabezados(bibliotecario),
    )

    assert sin_omitir.status_code == 409
    assert omitiendo.status_code == 201


def test_un_usuario_desactivado_no_puede_pedir_ni_omitiendo_validaciones(
    cliente, db, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    estudiante.activo = False
    db.commit()

    respuesta = cliente.post(
        "/api/prestamos/directo",
        json={
            "usuario_id": str(estudiante.id),
            "material_ids": [str(libro.id)],
            "omitir_validaciones_usuario": True,
        },
        headers=encabezados(bibliotecario),
    )

    assert respuesta.status_code == 409


def test_material_inexistente_responde_404(
    cliente, estudiante, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    libro.id  # solo para asegurar que existe
    respuesta = cliente.post(
        "/api/solicitudes/",
        json={"material_ids": ["00000000-0000-0000-0000-000000000000"]},
        headers=encabezados(estudiante),
    )

    assert respuesta.status_code == 404


@pytest.mark.parametrize(
    "origen, destino",
    [
        ("pendiente", "aprobado"),
        ("pendiente", "rechazado"),
        ("aprobado", "activo"),
        ("activo", "vencido"),
        ("vencido", "activo"),
        ("vencido", "devuelto"),
    ],
)
def test_transiciones_validas(origen, destino):
    assert maquina_estados.puede_pasar(origen, destino)


@pytest.mark.parametrize(
    "origen, destino",
    [
        ("pendiente", "activo"),  # se debe aprobar primero
        ("rechazado", "aprobado"),
        ("devuelto", "activo"),
        ("cancelado", "pendiente"),
        ("aprobado", "devuelto"),
    ],
)
def test_transiciones_invalidas(origen, destino):
    assert not maquina_estados.puede_pasar(origen, destino)
    with pytest.raises(HTTPException) as error:
        maquina_estados.validar_transicion(origen, destino)
    assert error.value.status_code == 409
