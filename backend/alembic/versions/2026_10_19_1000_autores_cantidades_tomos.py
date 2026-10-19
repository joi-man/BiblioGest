"""Autores, cantidad de ejemplares, tomos y texto de busqueda

- Tablas `autores` y `materiales_autores` (un autor tiene varios materiales y un
  material varios autores). El texto libre `materiales.autor` se convierte en autores.
- `materiales`: cantidad_total y contadores de reservados, prestados, vencidos y
  fuera de servicio; tomo y total_tomos; texto_busqueda (sin tildes).

Es repetible: la logica vive en `app.core.migracion_autores`, que tambien usa el
ejecutable de escritorio, y no repite lo que ya esta hecho.

Revision ID: a7b8c9d0e1f2
Revises: f6a7b8c9d0e1
Create Date: 2026-10-19

"""
from typing import Sequence, Union

from alembic import op

from app.core.migracion_autores import actualizar_esquema_materiales


revision: str = 'a7b8c9d0e1f2'
down_revision: Union[str, None] = 'f6a7b8c9d0e1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    actualizar_esquema_materiales(op.get_bind())
    op.create_index('ix_autores_nombre_normalizado', 'autores', ['nombre_normalizado'], if_not_exists=True)


def downgrade() -> None:
    op.drop_table('materiales_autores')
    op.drop_table('autores')
    for columna in (
        'texto_busqueda', 'cantidad_fuera_servicio', 'cantidad_vencida', 'cantidad_prestada',
        'cantidad_reservada', 'cantidad_total', 'total_tomos', 'tomo',
    ):
        op.drop_column('materiales', columna)
