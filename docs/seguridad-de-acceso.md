# Seguridad de acceso

Cómo protege BiblioGest el inicio de sesión y la sesión abierta. Vale para la Web, el escritorio y el móvil: las reglas viven en el servidor, salvo el bloqueo por inactividad, que es del cliente.

## Cierre de sesión

El botón **Cerrar sesión** (menú lateral, o *Perfil* en el móvil) borra el token del equipo y vuelve al inicio de sesión. Las rutas protegidas redirigen al login mientras no haya sesión; en la Web también se borra la sesión guardada en el navegador. Con otro token viejo el servidor responde 401.

## Bloqueo temporal por intentos fallidos

| Parámetro | Valor por defecto | Ajuste (variable de entorno) |
|---|---|---|
| Intentos permitidos | 5 fallos seguidos | `LOGIN_MAX_INTENTOS` |
| Duración del bloqueo | 15 minutos | `LOGIN_BLOQUEO_MINUTOS` |

- Se cuenta por el **correo o usuario escrito** (sin distinguir mayúsculas), exista o no la cuenta: así no se revela si existe.
- Cada fallo responde 401 con el mensaje «Correo/usuario o contraseña incorrectos. Te quedan N intentos.».
- El quinto fallo responde **429** con «Demasiados intentos fallidos. Tu acceso está bloqueado temporalmente: intenta de nuevo en 15 minutos.» y la cabecera `Retry-After`.
- Mientras dura el bloqueo se rechaza todo intento, **incluso con la contraseña correcta**. Al vencer, la cuenta vuelve a tener sus 5 intentos.
- Un inicio de sesión correcto borra el conteo de fallos.
- Cada fallo queda en la bitácora (`LOGIN_FALLIDO`).

**Limitaciones:** los contadores están en la memoria del servidor; un reinicio (por ejemplo, cuando Render lo suspende por inactividad) los borra. Alguien que conozca un usuario puede bloquearlo 15 minutos a propósito; es el costo de este tipo de protección. Para demostrarlo con rapidez, basta escribir 5 veces una contraseña incorrecta.

## Bloqueo por inactividad

- Tras **10 minutos** sin tocar la pantalla, mover el puntero, desplazarse ni pulsar teclas, la sesión se **cierra** y se vuelve al inicio de sesión con el aviso «Tu sesión se bloqueó por inactividad (10 minutos). Inicia sesión de nuevo para continuar.».
- Para retomar hay que autenticarse otra vez: el token se borra del equipo.
- Se puede cambiar al compilar: `--dart-define=INACTIVIDAD_MINUTOS=1` (útil para una demostración).
- Es independiente de la vigencia del token (60 minutos) y de la sesión guardada del navegador (55 minutos).
- Implementación: `frontend/lib/features/auth/presentation/widgets/guardia_inactividad.dart`.

## Recuperación de cuentas

1. En el inicio de sesión: **¿Olvidaste tu contraseña?** → se escribe el correo.
2. El servidor envía un **código de 6 dígitos** al correo (Brevo). La respuesta es siempre la misma, exista o no el correo.
3. El código **vence a los 15 minutos**, se puede intentar **5 veces** y es de **un solo uso**; un pedido nuevo invalida los anteriores.
4. Con el código se elige la nueva contraseña. Hay un límite de pedidos por correo (3 cada 15 minutos) y global.

## Otras protecciones de la cuenta

- Contraseñas con hash bcrypt; sesiones con token JWT de 60 minutos.
- **Suspensión:** el administrador puede suspender una cuenta; pierde la sesión en la siguiente petición.
- Cambio de contraseña con límite de intentos (10 cada 15 minutos).
