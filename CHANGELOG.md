### 🚀 Novedades version 1.1.2

-   **Gestión de Redes:** Ahora puedes añadir nuevos miembros directamente desde el módulo de Redes.

-   **Navegación mejorada:** Se habilitó el acceso directo (`onTap`) desde el Dashboard hacia las secciones de **Redes**, **Ministerios** , **Miembros** y **Servicios**.

-   **Actualizaciones In-App:** Se añadió soporte para detectar y descargar nuevas versiones sin salir de la aplicación.


### 🛠️ Correcciones y Mejoras

-   **Paginación:** * Implementada la paginación en el listado de **Usuarios** para mejorar el rendimiento.

    -   Corregido el error que impedía navegar correctamente entre páginas en el módulo de **Asistencia**.

    -   Se aumentó el límite de visualización del número miembros en la tarjeta en Redes y Miembros.

-   **Interfaz de Usuario (UI):**

    -   **Tablas Responsivas:** Se corrigió el tamaño fijo en la tabla de "Gestionar Redes"; ahora los botones de acción son visibles en pantallas grandes.

    -   **Input de Datos:** Se reemplazó el contador (`counter`) por un campo de texto estándar para facilitar la entrada manual de datos.


### 🔐 Seguridad y Permisos

-   **Gestión de Sesión:** Implementado control de errores **401**. Si el token de acceso expira, la sesión se destruye automáticamente y se redirige al usuario al Login para proteger los datos.

-   **Ajuste de Roles:**

    -   Se restringió la visibilidad del botón **"Gestionar Ministerio"** para usuarios con rol de Líder.

    -   Se corrigieron los permisos de acceso: los **Líderes** ahora tienen el acceso correspondiente al módulo de **Miembros**.


----------

### Notas técnicas

> El archivo `app-release.apk` adjunto incluye todas estas correcciones. Si experimentas problemas con el inicio de sesión, asegúrate de limpiar la caché de la aplicación debido al cambio en el manejo de tokens.