"""Valores permitidos del dominio de prestamos y devoluciones."""

# Estados de un prestamo (cabecera). El flujo completo esta en
# app.servicios.prestamos.maquina_estados.
PRESTAMO_PENDIENTE = "pendiente"  # el estudiante solicito, espera revision
PRESTAMO_APROBADO = "aprobado"  # reservado, esperando que lo retiren
PRESTAMO_RECHAZADO = "rechazado"
PRESTAMO_CANCELADO = "cancelado"  # cancelado por el usuario o reserva sin retirar
PRESTAMO_ACTIVO = "activo"  # material entregado
PRESTAMO_VENCIDO = "vencido"  # entregado y pasado de plazo
PRESTAMO_DEVUELTO = "devuelto"  # todos los items devueltos

ESTADOS_PRESTAMO = (
    PRESTAMO_PENDIENTE,
    PRESTAMO_APROBADO,
    PRESTAMO_RECHAZADO,
    PRESTAMO_CANCELADO,
    PRESTAMO_ACTIVO,
    PRESTAMO_VENCIDO,
    PRESTAMO_DEVUELTO,
)

# Prestamos con material fisicamente en manos del usuario.
ESTADOS_EN_CURSO = (PRESTAMO_ACTIVO, PRESTAMO_VENCIDO)

# Prestamos que comprometen unidades (reservadas o entregadas) y cuentan para el limite.
ESTADOS_QUE_OCUPAN_UNIDADES = (PRESTAMO_APROBADO, PRESTAMO_ACTIVO, PRESTAMO_VENCIDO)

# Condicion del material al devolverlo.
CONDICION_BUENO = "bueno"
CONDICION_DANO_MENOR = "dano_menor"
CONDICION_DANO_MAYOR = "dano_mayor"
CONDICION_PERDIDO = "perdido"

CONDICIONES_DEVOLUCION = (
    CONDICION_BUENO,
    CONDICION_DANO_MENOR,
    CONDICION_DANO_MAYOR,
    CONDICION_PERDIDO,
)

# Condiciones tras las cuales la unidad ya no se puede volver a prestar.
CONDICIONES_QUE_INHABILITAN = (CONDICION_DANO_MAYOR, CONDICION_PERDIDO)

# Devolucion registrada con una fecha anterior a la de hoy (el material se recibio antes de anotarlo).
# No puede ser futura ni de hace mas de estos dias, y exige un motivo para la auditoria.
MAX_DIAS_DEVOLUCION_RETROACTIVA = 30
MIN_CARACTERES_MOTIVO_FECHA = 10
# Margen para el desfase entre el reloj del equipo y el del servidor.
TOLERANCIA_RELOJ_SEGUNDOS = 120
