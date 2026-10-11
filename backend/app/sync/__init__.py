"""Sincronizacion entre el servidor central y los equipos con el ejecutable.

Idea general:
- Cada transaccion local se guarda como un "lote" de filas cambiadas
  (`captura`). Los lotes pendientes se envian al servidor, que los aplica
  completos o los rechaza completos si alguna fila cambio mientras tanto
  (`recepcion`).
- Despues el equipo descarga lo que cambio en el servidor (`emision`,
  `descarga`).
- `motor` coordina el envio y la descarga; `conflictos` resuelve los rechazos.
"""
