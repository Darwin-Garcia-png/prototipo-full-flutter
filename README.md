# 💊 FarmaBook POS - Guía de Estructura (Equipo de Trabajo)

Este repositorio contiene el frontend del sistema de gestión farmacéutica. A continuación, se detalla la función de cada directorio y archivo del proyecto para facilitar la navegación del equipo.

---

## 📂 Estructura de Directorios (`lib/`)

- **`controllers/`**: Contiene la lógica de negocio y gestión de estado (15 controladores: Ventas, Almacén, Inicio, etc.). Se encargan de procesar datos y hablar con los servicios.
- **`screens/`**: Contiene las 14 pantallas principales de la interfaz de usuario (Dashboard, Inventario, Punto de Venta, etc.).
- **`services/`**: Capa de comunicación con la API, autenticación JWT y servicios de notificaciones flotantes.
- **`router/`**: Configuración de rutas de navegación mediante el paquete `GoRouter`.
- **`theme/`**: Definición del sistema de diseño global (Colores, Tipografías, Sombras) para modo Claro y Oscuro.
- **`models/`**: Estructuras de datos (clases) que definen los objetos del sistema (ej: `Producto`).
- **`utils/`**: Funciones de ayuda y cuadros de diálogo complejos (Modales de inventario).
- **`widgets/`**: Componentes reutilizables segregados por módulos (Ventas, Almacén) y botones personalizados.
- **`main.dart`**: Punto de entrada de la aplicación e inyección de todos los proveedores de estado.

---

## 📄 Archivos de Configuración

- **`.env`**: Archivo de variables de entorno para la URL de la API y tokens de acceso.
- **`pubspec.yaml`**: Gestión de dependencias y activos (imágenes/fuentes) del proyecto.
- **`README_TECNICO.md`**: Manual técnico avanzado con detalles línea a línea para el propietario.

---

*FarmaBook POS - Eficiencia y Precisión Farmacéutica.*
