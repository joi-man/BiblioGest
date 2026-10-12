from pydantic import BaseModel


class ResumenMateriales(BaseModel):
    """Cantidad de unidades por estado."""

    total: int
    disponibles: int
    reservados: int
    prestados: int
    vencidos: int
    fuera_de_servicio: int


class ResumenPrestamos(BaseModel):
    """Estado actual de la operacion de prestamos."""

    solicitudes_pendientes: int  # esperan que el personal las revise
    por_retirar: int  # aprobadas, el usuario aun no retira
    activos: int  # entregados y dentro de plazo
    vencidos: int  # entregados y pasados de plazo
    por_vencer_24h: int  # prestamos activos que vencen en las proximas 24 horas
    entregados_hoy: int  # dia en curso, hora de Paraguay
    devueltos_hoy: int  # dia en curso, hora de Paraguay


class ResumenDashboard(BaseModel):
    materiales: ResumenMateriales
    prestamos: ResumenPrestamos
