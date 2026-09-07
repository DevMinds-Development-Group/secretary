# Multiinquilino en la app

Cada iglesia del ministerio es un inquilino y el Ministerio es el inquilino de clase superior, que
consulta a todas. El servidor impone el aislamiento; esta app se limita a enseñar lo que
corresponde y a no ofrecer lo que va a ser rechazado.

## Una sola URL base

`lib/config/api_config.dart` centraliza la URL de la API. Existe porque estaba escrita a mano en
tres sitios y **habían divergido**: `auth_service` apuntaba a producción mientras `api_client`
apuntaba a develop, así que el login se validaba contra una base de datos y los datos venían de
otra. Se puede sobrescribir al compilar:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

## El alcance de la sesión

`TenantScope` guarda a qué iglesia pertenece quien ha entrado y, si es del Ministerio, cuál está
consultando. Lo lee de los claims del token (`tenant_id`, `tenant_slug`, `tenant_type`), que el
servidor emite al iniciar sesión.

Es información **informativa**: el servidor resuelve el inquilino en cada petición contra su base de
datos, así que la app no puede ampliar su alcance manipulando nada de esto. Sólo sirve para saber
qué enseñar sin una llamada extra.

Es estático porque el interceptor de Dio se construye en cada `ApiClient` y no alcanza a un provider.

La iglesia seleccionada se guarda entre sesiones, y **se borra al cerrar sesión**: si sobreviviera,
la sesión siguiente arrancaría mirando la iglesia de quien usó la aplicación antes.

## El selector de iglesia

Aparece en la barra superior **sólo para el Ministerio**: una iglesia se ve siempre a sí misma y no
tiene nada que elegir. «Consolidado» es una opción explícita y no la ausencia de selección, para que
se vea en todo momento qué se está mirando. A partir de ocho iglesias el diálogo incluye buscador.

Al elegir una iglesia, el interceptor añade `X-Tenant-Id` a cada petición; sin selección, el
servidor entrega el consolidado.

En móvil la barra la comparten el logotipo, el selector y el menú de usuario, y no caben los tres a
su gusto: el logotipo reserva menos sitio cuando hay selector y el nombre de la iglesia se queda con
lo que sobre del ancho de pantalla, recortado con puntos suspensivos. Con anchos fijos el botón
crecía hasta montarse encima del logotipo.

Ese «hay selector» se consulta en `TenantScope`, que es estático, y no en el proveedor: sólo cambia
al entrar o salir —cuando el árbol se rehace entero— y suscribir el `NavShell` al proveedor lo hacía
reconstruirse justo mientras `TenantScopedPage` destruye ese mismo subárbol.

El selector pide la lista de iglesias al montarse si aún no la tiene. Al recargar, el alcance se
restaura del almacenamiento pero los nombres no vienen con él, y la barra decía «Consolidado»
mientras la aplicación miraba de verdad una iglesia.

## Modo consulta

El Ministerio supervisa y no opera: el servidor rechaza sus escrituras de datos de congregación con
403. Para que la interfaz no ofrezca lo que va a fallar, la comprobación vive en los **dos widgets
compartidos** en lugar de en cada pantalla:

- `AddButton` no se dibuja (cubre las 8 pantallas que dan de alta).
- `ActionButtons` conserva «ver» y oculta editar y borrar (4 pantallas).

Ponerlo ahí y no en cada pantalla es lo que evita que se olvide en la próxima que se añada.

## Administración de iglesias

`screens/admin/churches.dart`, accesible desde Administración y sólo visible para el Ministerio.
Permite dar de alta una iglesia con su administrador inicial, editar sus datos y habilitarlas o
deshabilitarlas.

El alta y la edición comparten formulario (`church_form_dialog.dart`) porque comparten campos. Lo
que sólo existe al dar de alta es el **identificador corto** —al editar se muestra pero no se toca,
porque viaja en enlaces y en la cabecera con la que el Ministerio consulta una iglesia— y el
usuario administrador inicial.

Al editar, los campos opcionales se mandan como cadena vacía y no como nulo: el servidor ignora los
nulos al actualizar, así que mandar nulo haría imposible borrar un teléfono o una dirección.

La **contraseña de un solo uso** del administrador se muestra una vez, en un diálogo que hay que
cerrar a conciencia: no se guarda en claro en ningún sitio y el servidor no la puede volver a
enseñar.

Deshabilitar avisa de lo que implica: sus usuarios dejan de poder entrar, pero su histórico se
conserva y sigue contando en los informes del Ministerio.

## El informe consolidado

`ChurchBreakdownTable` muestra el desglose por iglesia dentro del dashboard de supervisión. Sólo
aparece cuando el servidor lo manda, es decir en la lectura consolidada: al descender a una iglesia
el informe ya es el de esa congregación y un desglose de una sola fila no diría nada.

## La pantalla pública de anuncios

`announcement_provider` llama sin autenticación, así que el servidor no puede deducir la iglesia y
hay que nombrarla con `?church=<slug>`. Por defecto `casa-de-restauracion`; para una instalación
dedicada a otra congregación:

```bash
flutter build --dart-define=PUBLIC_CHURCH_SLUG=nueva-esperanza
```

## Lo que no se hizo, y por qué

Para un usuario de iglesia no se muestra el nombre de su congregación en la barra superior: sólo
pertenece a una, así que no hay ambigüedad que resolver, y el nombre no viaja en el token —haría
falta añadirlo a la respuesta del perfil. Si se quiere, es un campo en `UserResponse` y una etiqueta
aquí.
