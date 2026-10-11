"""Servicios del ciclo de vida de los prestamos.

Cada modulo tiene una sola responsabilidad:

- maquina_estados: que cambios de estado son validos.
- reglas_prestamo: validaciones de negocio (limites, disponibilidad).
- plazo_servicio: calculo de la fecha limite de devolucion.
- material_estado_servicio: bloqueo y cambio de estado de las unidades.
- estado_prestamo_servicio: recalculo del estado segun los items pendientes.
- solicitud_servicio, aprobacion_servicio, entrega_servicio,
  devolucion_servicio: los pasos del flujo.
- multa_servicio: calculo de multas (opcional).
- vencimiento_servicio: expiracion de reservas y marca de vencidos.
- consulta_prestamo_servicio: lecturas y filtros.
- auditoria_prestamo: registro en la bitacora.
"""
