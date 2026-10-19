"""Fecha y hora de retiro que propone el estudiante al reservar."""
from datetime import timedelta

from sqlalchemy import create_engine, text
from sqlalchemy.pool import StaticPool

from app.core.database import Base
from app.core.migracion_retiro import agregar_fecha_retiro_solicitada
from app.modelos import Categoria  # noqa: F401  (registra los modelos)
from tests.conftest import INSTANTE_BASE, encabezados
from tests.test_flujo_prestamos import accion


def solicitar_para(cliente, usuario, material, retiro=None):
    cuerpo = {"material_ids": [str(material.id)]}
    if retiro is not None:
        cuerpo["fecha_retiro_solicitada"] = retiro.isoformat() + "Z"
    return cliente.post("/api/solicitudes/", json=cuerpo, headers=encabezados(usuario))


def iso(instante):
    return instante.isoformat() + "Z"


def test_sin_fecha_de_retiro_todo_funciona_como_antes(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")

    solicitud = solicitar_para(cliente, estudiante, libro)
    aprobada = accion(cliente, bibliotecario, solicitud.json()["id"], "aprobar").json()

    assert solicitud.status_code == 201
    assert solicitud.json()["fecha_retiro_solicitada"] is None
    assert aprobada["fecha_retiro_limite"] == iso(INSTANTE_BASE + timedelta(hours=24))


def test_la_fecha_de_retiro_se_guarda_y_la_ve_el_personal(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    retiro = INSTANTE_BASE + timedelta(days=2, hours=3)

    solicitud = solicitar_para(cliente, estudiante, libro, retiro)

    assert solicitud.status_code == 201
    assert solicitud.json()["fecha_retiro_solicitada"] == iso(retiro)
    pendientes = cliente.get("/api/prestamos/", headers=encabezados(bibliotecario)).json()
    assert pendientes[0]["fecha_retiro_solicitada"] == iso(retiro)


def test_al_aprobar_la_reserva_se_sostiene_hasta_la_hora_propuesta_mas_un_margen(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    retiro = INSTANTE_BASE + timedelta(days=2)
    solicitud = solicitar_para(cliente, estudiante, libro, retiro).json()

    aprobada = accion(cliente, bibliotecario, solicitud["id"], "aprobar").json()

    assert aprobada["fecha_retiro_limite"] == iso(retiro + timedelta(hours=4))


def test_si_se_aprueba_despues_de_la_hora_propuesta_el_margen_cuenta_desde_la_aprobacion(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    libro = crear_material(categoria_libros, "L-1")
    solicitud = solicitar_para(cliente, estudiante, libro, INSTANTE_BASE + timedelta(hours=1)).json()
    reloj_prueba.avanzar(hours=5)

    aprobada = accion(cliente, bibliotecario, solicitud["id"], "aprobar").json()

    assert aprobada["fecha_retiro_limite"] == iso(reloj_prueba() + timedelta(hours=4))


def test_una_reserva_no_retirada_vence_pasado_el_margen_y_libera_el_ejemplar(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    libro = crear_material(categoria_libros, "L-1", cantidad_total=1)
    solicitud = solicitar_para(cliente, estudiante, libro, INSTANTE_BASE + timedelta(hours=2)).json()
    accion(cliente, bibliotecario, solicitud["id"], "aprobar")

    reloj_prueba.avanzar(hours=7)  # 2 h hasta la hora propuesta + 4 h de margen + 1
    cliente.get("/api/prestamos/", headers=encabezados(bibliotecario))

    material = cliente.get(f"/api/materiales/{libro.id}", headers=encabezados(bibliotecario)).json()
    assert material["cantidad_disponible"] == 1


def test_una_fecha_de_retiro_pasada_se_rechaza_con_un_mensaje_claro(
    cliente, estudiante, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")

    respuesta = solicitar_para(cliente, estudiante, libro, INSTANTE_BASE - timedelta(hours=1))

    assert respuesta.status_code == 400
    assert "posteriores a este momento" in respuesta.json()["detail"]


def test_no_se_puede_reservar_con_mas_de_siete_dias_de_anticipacion(
    cliente, estudiante, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")

    respuesta = solicitar_para(cliente, estudiante, libro, INSTANTE_BASE + timedelta(days=8))

    assert respuesta.status_code == 400
    assert "7 dias de anticipacion" in respuesta.json()["detail"]
    # y un dia dentro del limite si se acepta
    assert solicitar_para(cliente, estudiante, libro, INSTANTE_BASE + timedelta(days=6)).status_code == 201


def test_la_solicitud_con_fecha_invalida_no_deja_nada_guardado(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")

    solicitar_para(cliente, estudiante, libro, INSTANTE_BASE - timedelta(days=1))

    assert cliente.get("/api/prestamos/", headers=encabezados(bibliotecario)).json() == []


def test_la_columna_se_agrega_a_una_base_anterior_y_es_repetible():
    motor = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    Base.metadata.create_all(motor)
    with motor.begin() as c:
        c.execute(text("ALTER TABLE prestamos_cabecera DROP COLUMN fecha_retiro_solicitada"))
    for _ in range(2):
        with motor.begin() as c:
            agregar_fecha_retiro_solicitada(c)

    with motor.connect() as c:
        columnas = {fila[1] for fila in c.execute(text("PRAGMA table_info(prestamos_cabecera)"))}
    assert "fecha_retiro_solicitada" in columnas
