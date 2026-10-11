"""Usuarios: columna username

El modelo `Usuario` tiene `username` (unico, para iniciar sesion) pero ninguna
migracion anterior lo creaba: en desarrollo la base se armaba con `create_all`.
Una base creada solo con migraciones (como la de produccion) no la tenia.

Es repetible: si la columna ya existe (bases creadas con `create_all`), no hace nada.
Los usuarios que ya existian reciben un username derivado de su correo.

Revision ID: f6a7b8c9d0e1
Revises: e5f6a7b8c9d0
Create Date: 2026-10-11

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'f6a7b8c9d0e1'
down_revision: Union[str, None] = 'e5f6a7b8c9d0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    columnas = {c['name'] for c in sa.inspect(op.get_bind()).get_columns('usuarios')}
    if 'username' in columnas:
        return
    op.add_column('usuarios', sa.Column('username', sa.String(length=50), nullable=True))
    # Parte local del correo + 8 caracteres del id: unico y de hasta 49 caracteres.
    op.execute(
        "UPDATE usuarios SET username = left(split_part(correo_electronico, '@', 1), 40)"
        " || '_' || left(replace(id::text, '-', ''), 8)"
    )
    op.alter_column('usuarios', 'username', nullable=False)
    op.create_index(op.f('ix_usuarios_username'), 'usuarios', ['username'], unique=True)


def downgrade() -> None:
    op.drop_index(op.f('ix_usuarios_username'), table_name='usuarios')
    op.drop_column('usuarios', 'username')
