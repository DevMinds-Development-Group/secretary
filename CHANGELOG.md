# 🚀 Novedades Koinos - Versión 2.0.0

## 🚀 Versión 2.0.0 — Rediseño mayor (2026-06-23)

Esta versión es una **renovación completa de la experiencia de usuario**: una interfaz más
moderna, limpia y consistente en toda la app, navegación repensada para móvil y web, un
nuevo panel de **Supervisión** para liderazgo, y mejoras de rendimiento en la carga de
imágenes. A continuación, el detalle de todo lo nuevo y mejorado. ✨

---

## 🌟 Lo más destacado

- 🎨 **Nuevo diseño en toda la app** — interfaz moderna, ordenada y coherente, con la
  identidad de marca (azul Viento Recio) y tipografías más legibles.
- 🧭 **Navegación renovada** — barra lateral en web que se expande al pasar el cursor y
  barra inferior en móvil, ahora presentes en **todas** las pantallas.
- 👤 **Menú de usuario en la esquina superior** — tu foto, tu nombre y acceso rápido a tu
  perfil, el manual y cerrar sesión.
- 📊 **Nuevo panel de Supervisión** — un tablero ejecutivo para Apóstoles, Pastores y
  Administradores, con exportación a PDF.
- ⚡ **Imágenes más rápidas** — las fotos se muestran al instante gracias a la nueva caché.

---

## 🎨 Diseño y experiencia general

- ✨ Rediseño visual completo siguiendo un sistema de diseño unificado (colores, espaciados,
  tarjetas, sombras y estados consistentes en cada pantalla).
- 🔤 Tipografías más claras y jerarquía de textos mejorada para facilitar la lectura.
- 📐 El contenido ahora se centra y aprovecha mejor el ancho de la pantalla en web (≈90%),
  con márgenes uniformes en **Inicio, Miembros, Redes, Ministerios, Servicios, Asistencia,
  Reportes y Administración**.
- 💀 Pantallas de carga con animación tipo "esqueleto" (shimmer) en lugar de saltos bruscos.
- 🫙 Estados vacíos claros (con ícono y mensaje) cuando aún no hay datos.
- ⚠️ Estados de error amables, con botón de **reintentar** y aviso específico cuando no hay
  conexión.
- 🌀 Animaciones y transiciones suaves al navegar.
- ♿ Mejoras de accesibilidad: mejor contraste, etiquetas para lectores de pantalla y
  estados que combinan color + ícono + texto (no dependen solo del color).

---

## 🧭 Navegación

- 🖥️ **En web:** barra lateral (rail) minimalista que muestra solo íconos y se **expande al
  pasar el cursor** revelando las etiquetas, sin mover el contenido.
- 📱 **En móvil:** barra de navegación inferior con acceso directo a las secciones
  principales y una opción **"Más"** para el resto.
- 🧱 La navegación ahora aparece en **todas las pantallas** (incluidos formularios y
  detalles), para que nunca te quedes sin forma de moverte por la app.
- 🪧 Encabezado superior limpio con el logo de la app.
- 🖼️ La barra lateral y el encabezado se leen como una sola pieza, con una elevación sutil.

---

## 👤 Cuenta y sesión

- 🆕 **Menú de usuario** en la esquina superior derecha: muestra tu **foto** y tu **nombre**,
  y al abrirlo despliega una tarjeta con:
    - 👁️ Tu perfil (nombre y rol).
    - 🙍 **Mi perfil**.
    - 📖 **Manual de usuario**.
    - 🚪 **Cerrar sesión** (con confirmación para evitar salidas accidentales).
- 🔁 Disponible de forma consistente tanto en web como en móvil.

---

## 🏠 Inicio (Dashboard)

- 👋 Saludo personalizado con tu nombre, rol y la fecha del día.
- 🔢 Tarjetas de indicadores clave (miembros totales, activos, inactivos, redes y
  ministerios) con un vistazo rápido del estado de la iglesia.
- 📈 **Gráfico de crecimiento de miembros** con la tendencia del último período y el cambio
  respecto al mes anterior.
- 🍩 Resumen visual de actividad (miembros activos vs. inactivos).
- 🗓️ Lista de **servicios de la semana** con acceso directo.
- ⤵️ Desliza para actualizar (pull-to-refresh).

---

## 👥 Miembros

- 🧑‍🤝‍🧑 Lista de miembros rediseñada con **fotos** (avatares cuadrados con borde), nombre y
  datos de contacto.
- 🟢🟡 **Pastillas de estado** (Activo / Inactivo) fáciles de identificar.
- 🔎 Búsqueda de miembros y **filtros rápidos**: Todos / Activos / Inactivos.
- 🧮 Encabezado tipo tabla en escritorio y diseño compacto en móvil.
- ✏️🗑️ Acciones de **editar** y **eliminar** por miembro (íconos en web, menú en móvil), con
  confirmación al eliminar.
- 📄 Paginación renovada (ver más abajo).
- 🖼️ Las fotos de la lista se cargan al instante gracias a la nueva caché de imágenes.

---

## 🕸️ Redes y Ministerios

- 🃏 Tarjetas de redes y ministerios con líderes, cantidad de miembros y misión.
- ⋮ **Menú por tarjeta** para **editar** o **eliminar** directamente (ya no hace falta una
  pantalla aparte de "gestionar").
- 📱 En móvil, las tarjetas se acomodan en **una sola columna** para mejor lectura.
- 👥 **Detalle de la red** ahora muestra la lista de miembros con el **mismo diseño** que la
  pantalla de Miembros, incluidos los botones de **editar** y **eliminar**.

---

## 📅 Servicios

- 🗂️ Vista tipo "línea de tiempo": cada servicio se ve como una tarjeta con su tipo
  (Culto / Reunión / Otro), descripción, horario, predicadores y ministerio de alabanza.
- 🟦 Los servicios de **hoy** se resaltan.
- ➕ Crear / ✏️ editar / 🗑️ eliminar servicios desde la misma lista.

---

## ✅ Asistencia

- 🗓️ Registros de asistencia presentados como **tarjetas por fecha**, con día destacado,
  evento, desglose (miembros, visitas, red) y total.
- 🔎 Búsqueda por evento o red y filtro por fecha.
- 📲 En móvil, el selector de fecha y el botón **"Tomar Asistencia"** quedan alineados y
  ocupan todo el ancho para un uso más cómodo.
- 📄 Descarga del PDF de cada asistencia.

---

## 📊 Reportes

- 🧾 Pantalla de Reportes con accesos a los distintos informes.
- 📈 **Reportes Generales** con un diseño de lista más limpio: cada fila muestra el evento y
  la fecha, con un **botón directo para descargar el PDF** (sin pasos extra).
- 🗓️ Filtro por rango de fechas y búsqueda por evento.

---

## 🛡️ Supervisión (¡Nuevo!)

- 🆕 Nuevo **panel de Supervisión**, accesible desde Reportes **solo para roles Apóstol,
  Pastor y Administrador**.
- 🗓️ Muestra el período correspondiente (últimos ~30 días).
- 📌 Incluye:
    - 🔢 **Resumen general**: miembros, activos, inactivos, nuevos, redes y ministerios.
    - 📈 **Crecimiento de membresía** (gráfico).
    - ✅ **Asistencia del período**: totales y resumen por red, observaciones y redes sin
      registros.
    - 🕸️ **Estructura**: redes y ministerios, con alertas de los que no tienen líder.
    - 🧑‍🏫 **Trabajo de líderes**: actividad, miembros a cargo y detalle por líder.
    - 🎟️ **Eventos**: asignaciones y definiciones por tipo.
    - 🖥️ **Actividad del sistema**: usuarios más activos y acciones por módulo/tipo.
- 📤 Botón **"Exportar a PDF"** para descargar el informe completo del período.

---

## 📄 Paginación renovada

- ✨ Nuevo control de paginación más claro y moderno: **Anterior / Siguiente**, números de
  página con la página actual resaltada, "…" cuando hay muchas páginas, y selector de
  **elementos por página**.
- 📱 Versión compacta y cómoda en móvil.

---

## 🔐 Bienvenida e inicio de sesión

- 🎨 Pantallas de **bienvenida** y **login** rediseñadas con un fondo de marca (degradado
  azul con formas suaves) y marca de agua del logo.
- 🖥️ En web, diseño de **panel dividido**; en móvil, encabezado con onda.
- 🔘 Botones consistentes y campos de formulario más claros.
- 🏷️ Pie de página con el crédito de desarrollo.

---

## ⚡ Rendimiento y fotos

- 🖼️ **Nueva caché de imágenes** en toda la app: las fotos de perfil y avatares se muestran
  **al instante desde caché** y se descargan del servidor solo cuando es necesario.
- 🔄 Al **actualizar la foto** de un miembro, la imagen se **renueva automáticamente** en
  todas las pantallas (lista, detalle, encabezado), sin fotos "viejas" en caché.
- 📉 Menos consumo de datos y menos parpadeos al navegar.

---

## 🐛 Correcciones y ajustes

- 🧱 Corregido: la barra lateral y el contenido ahora ocupan toda la altura disponible en
  pantallas con poco contenido (Administración, Reportes).
- 📏 Corregidos varios botones que se desbordaban ("Iniciar sesión", "Exportar a PDF",
  "Actualizar servicio").
- 📐 Anchos y márgenes uniformados entre secciones.
- 🎯 Consistencia visual de tarjetas, sombras y resaltados en toda la app.

---

_Gracias por usar Koinos. 🙌 Esta versión está pensada para que administrar la vida de la
iglesia sea más rápido, claro y agradable._
