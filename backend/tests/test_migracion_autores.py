"""Conversion de una base creada antes de los autores y las cantidades."""
import uuid

from sqlalchemy import create_engine, text
from sqlalchemy.pool import StaticPool

from app.core.database import Base
from app.core.migracion_autores import actualizar_esquema_materiales, id_de_autor
from app.modelos import Categoria, Material  # noqa: F401  (registra los modelos)

NUEVAS = (
    "tomo", "total_tomos", "cantidad_total", "cantidad_reservada", "cantidad_prestada",
    "cantidad_vencida", "cantidad_fuera_servicio", "texto_busqueda",
)


def _base_antigua():
    """Una base SQLite con el esquema anterior (sin autores ni cantidades) y dos libros."""
    motor = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    Base.metadata.create_all(motor)
    with motor.begin() as c:
        c.execute(text("DROP TABLE materiales_autores"))
        c.execute(text("DROP TABLE autores"))
        categoria = uuid.uuid4().hex  # SQLite guarda los UUID sin guiones
        c.execute(text("INSERT INTO categorias (id, nombre, version, eliminado) VALUES (:i, 'Libros', 1, 0)"), {"i": categoria})
        for columna in NUEVAS:
            c.execute(text(f"ALTER TABLE materiales DROP COLUMN {columna}"))
        for codigo, titulo, autor, estado in (
            ("L-1", "Cien años de soledad", "Gabriel García Márquez", "prestado"),
            ("L-2", "Obra conjunta", "Ana Perez; Gabriel Garcia Marquez", "disponible"),
        ):
            c.execute(
                text(
                    "INSERT INTO materiales (id, codigo, titulo, tipo_material, estado, autor, condicion,"
                    " es_prestable, categoria_id, eliminado, version) VALUES (:i, :c, :t, 'libro', :e, :a,"
                    " 'bueno', 1, :cat, 0, 1)"
                ),
                {"i": uuid.uuid4().hex, "c": codigo, "t": titulo, "e": estado, "a": autor, "cat": categoria},
            )
    return motor


def test_los_autores_de_texto_pasan_a_ser_autores_sin_duplicados():
    motor = _base_antigua()
    with motor.begin() as c:
        actualizar_esquema_materiales(c)

    with motor.connect() as c:
        autores = {f[0] for f in c.execute(text("SELECT nombre FROM autores"))}
        vinculos = c.execute(text("SELECT COUNT(*) FROM materiales_autores")).scalar_one()

    # "Gabriel García Márquez" y "Gabriel Garcia Marquez" son la misma persona
    assert len(autores) == 2
    assert "Ana Perez" in autores
    assert vinculos == 3


def test_las_unidades_que_estaban_prestadas_siguen_contando_como_un_ejemplar_prestado():
    motor = _base_antigua()
    with motor.begin() as c:
        actualizar_esquema_materiales(c)

    with motor.connect() as c:
        filas = {f[0]: f[1:] for f in c.execute(text(
            "SELECT codigo, cantidad_total, cantidad_prestada, texto_busqueda FROM materiales"
        ))}
    assert filas["L-1"][:2] == (1, 1)
    assert filas["L-2"][:2] == (1, 0)
    assert "garcia marquez" in filas["L-1"][2]
    assert "anos de soledad" in filas["L-1"][2]


def test_es_repetible_y_los_ids_dependen_solo_del_nombre():
    motor = _base_antigua()
    for _ in range(2):
        with motor.begin() as c:
            actualizar_esquema_materiales(c)

    with motor.connect() as c:
        assert c.execute(text("SELECT COUNT(*) FROM autores")).scalar_one() == 2
        assert c.execute(text("SELECT COUNT(*) FROM materiales_autores")).scalar_one() == 3
    # Servidor y equipos que migran por separado obtienen el mismo ID para el mismo autor.
    assert id_de_autor("Gabriel García Márquez") == id_de_autor("gabriel garcia  marquez")
