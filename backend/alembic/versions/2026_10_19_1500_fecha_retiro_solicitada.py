"""Prestamos: fecha de retiro que propone el usuario al reservar

Revision ID: b8c9d0e1f2a3
Revises: a7b8c9d0e1f2
Create Date: 2026-10-19

"""
from typing import Sequence, Union

from alembic import op

from app.core.migracion_retiro import agregar_fecha_retiro_solicitada


revision: str = 'b8c9d0e1f2a3'
down_revision: Union[str, None] = 'a7b8c9d0e1f2'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    agregar_fecha_retiro_solicitada(op.get_bind())


def downgrade() -> None:
    op.drop_column('prestamos_cabecera', 'fecha_retiro_solicitada')
