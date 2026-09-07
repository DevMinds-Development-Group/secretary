# 🚀 Novedades Koinos - Versión 2.1.0

## 🚀 Versión 2.1.0 — Koinos para todo el Ministerio (2026-09-07)

Hasta ahora Koinos servía a **una** congregación. Esta versión abre la aplicación a **todas
las iglesias del Ministerio**: cada una trabaja con sus propios datos, sin ver ni mezclar
los de las demás, y el **Ministerio** puede asomarse a cualquiera de ellas o mirarlas todas
juntas. 🏛️

Si eres de una iglesia, no tienes que hacer nada: verás lo mismo de siempre, sólo tuyo. 💙

---

## 🌟 Lo más destacado

- ⛪ **Cada iglesia, su propia casa** — miembros, redes, ministerios, servicios, asistencias,
  usuarios y registros quedan separados por iglesia. Nadie ve lo de nadie.
- 🔀 **Selector de iglesia** — el Ministerio elige desde la barra superior si mira el
  **Consolidado** (todas juntas) o una iglesia en concreto.
- 🏗️ **Alta de iglesias** — nueva pantalla en **Administración → Iglesias** para dar de alta
  una congregación con su administrador inicial, editarla y darla de baja.
- 📊 **Informe consolidado** — el panel del Ministerio suma todas las iglesias y muestra
  además el **desglose de cada una**.
- 👀 **Modo consulta** — el Ministerio supervisa pero no toca: donde no puede modificar, los
  botones sencillamente no aparecen.

---

## 🏛️ El Ministerio y sus iglesias

- 🔀 **Selector en la barra superior** (sólo para el Ministerio): **Consolidado** o la iglesia
  que elijas. La opción «Consolidado» está siempre a la vista, para que en todo momento sepas
  qué estás mirando.
- 🔎 **Buscador en el selector** — con más de ocho iglesias, el diálogo incluye un buscador.
- 🔄 **Al cambiar de iglesia, la pantalla se actualiza** — si estabas en Miembros, sigues en
  Miembros, ahora con los de la otra iglesia. No hace falta salir y volver a entrar.
- 👀 **Modo consulta del Ministerio** — supervisa la información de las congregaciones, pero
  no la modifica: los botones de **crear**, **editar** y **eliminar** no se muestran, para no
  ofrecer algo que va a fallar. Administrar las iglesias sí es cosa suya.

---

## ⛪ Administración de iglesias

Nueva pantalla **Administración → Iglesias**, visible sólo para el Ministerio.

- ➕ **Dar de alta una iglesia** — nombre, nombre corto (el que se ve en la barra y en el
  selector), identificador, teléfono, dirección y correo.
- 🔑 **Administrador inicial** — al crear la iglesia se crea también su usuario administrador,
  con una **contraseña de un solo uso** que se muestra **una única vez**: cópiala en ese
  momento, no se puede volver a ver. A partir de ahí, cada iglesia gestiona sus propios
  usuarios.
- ✏️ **Editar una iglesia** — se pueden corregir el nombre y los datos de contacto. El
  identificador corto no se cambia: viaja en enlaces ya repartidos.
- 🚫 **Habilitar y deshabilitar** — al deshabilitar una iglesia sus usuarios dejan de poder
  entrar, pero **su histórico se conserva** y sigue contando en los informes del Ministerio.
  La aplicación te avisa de esto antes de confirmar.
- 🔎 **Búsqueda** por nombre o identificador en la lista de iglesias.

---

## 📊 Informes

- 🧮 **Consolidado del Ministerio** — el panel suma las cifras de todas las iglesias y añade
  el **desglose por iglesia**, para ver de un vistazo cuánto aporta cada una.
- 🎯 **Descender a una iglesia** — con el selector, el mismo panel muestra sólo esa
  congregación, sin cambiar de pantalla.

---

## 🔒 Seguridad y datos

- 🧱 **La separación se aplica en la base de datos**, no sólo en la pantalla: aunque una
  petición pidiera datos de otra iglesia, no los recibiría.
- 🧑‍💼 **Cada usuario pertenece a una iglesia** y sólo ve la suya. Los usuarios del Ministerio
  ven todas.
- 🗂️ **Los registros de actividad** también quedan separados: cada iglesia ve los suyos.

---

## 🐛 Correcciones

- 💥 **Pantalla roja al estrechar la ventana** — al reducir mucho el ancho del navegador la
  aplicación podía quedarse en una pantalla de error. Corregido en los paneles de **Inicio** y
  **Supervisión**. 🎉
- 📱 **El selector se montaba sobre el logotipo en móvil** — ahora el logotipo cede sitio y el
  nombre de la iglesia se recorta con puntos suspensivos cuando no cabe.
- 🏷️ **La barra decía «Consolidado» sin serlo** — al recargar la página se mantenía la iglesia
  elegida, pero la barra mostraba «Consolidado». Ahora dice siempre lo que estás mirando.
- 🧭 **El Ministerio no veía Administración** — el menú no aparecía para el usuario del
  Ministerio.
- 👥 **No se podían crear usuarios nuevos** — el alta de usuarios fallaba desde la pantalla de
  Administración. Corregido: cada quien crea usuarios en su propia iglesia.
- 🔐 **Usuarios, Roles y Registros para el Ministerio** — esas tres pantallas rechazaban al
  usuario del Ministerio. Ya puede abrirlas.
- ⏰ **La hora del cierre de asistencia** — el aviso anunciaba una hora que no era la real. El
  plazo para registrar la asistencia de un servicio termina a la **1:00 PM** del día
  siguiente, y ahora el mensaje lo dice así.

---

_Gracias por usar Koinos. 🙌_
