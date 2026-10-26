# 📋 Plan de Trabajo y Asignación de Roles - Etapa V: Temas Técnicos
**Proyecto:** Sistema de Gestión Comercial — Panadería Tortuga  
**Materia:** Bases de Datos I — FaCENA (UNNE)  
**Motor de Base de Datos:** Microsoft SQL Server Express (T-SQL)  

---

## 🎯 Objetivo General de la Etapa V
Investigar, implementar y validar en el motor de base de datos SQL Server mecanismos avanzados que aporten robustez, velocidad, seguridad transaccional y mantenibilidad a largo plazo sobre el sistema de ventas desarrollado.

Cada integrante tiene a su cargo un componente técnico especializado, debiendo entregar:
1. **Descripción conceptual y fundamentos:** Breve justificación de negocio/técnica en Markdown.
2. **Script SQL de Implementación:** Creación de los objetos en `sql/tecnico/`.
3. **Script SQL de Demostración y Pruebas:** Ejecución práctica demostrando funcionamiento y control de errores.
4. **Manifiesto Individual:** Archivo `docs/etapa-05/equipoXX_etapa05_DNI.md`.

---

## 👥 Asignación Equitativa de Roles

### 📌 Participante: Integrante 1 (Inicio / Transacciones)
* **Asignado a:** **Zárate Lucas Martín** (DNI: 34936602)
* **Tema Técnico:** **Manejo de Transacciones y Control de Concurrencia (ACID)**
* **Objetivo:** Garantizar la atomicidad y consistencia en el circuito crítico de ventas y control de stock, asegurando que un fallo imprevisto no deje datos corruptos ni incompletos.
* **Entregables:**
  * Documentación: `docs/etapa-05/transacciones.md`
  * Script SQL Implementación/Demostración: `sql/tecnico/transacciones/01_transaccion_venta_stock.sql`
* **Requerimientos y Código Base a utilizar:**
  * Implementar una transacción compuesta que afecte al menos a 3 tablas (`Venta`, `Detalle_Venta`, `Movimiento-Stock` / `Stock`).
  * Emplear bloques `BEGIN TRY ... BEGIN TRANSACTION ... COMMIT TRANSACTION ... END TRY ... BEGIN CATCH ... ROLLBACK TRANSACTION ... END CATCH`.
  * Diseñar una prueba con un **error intencional** (ej. violación de restricción `CHECK` o división por cero) inmediatamente después de un `INSERT` para demostrar empíricamente el `ROLLBACK` y que ningún registro quede persistido.

---

### 📌 Participante: Integrante 2 (A elección)
* **Asignado a:** *[Pendiente de selección: Octavio Dorrego / Nicolás Pini / Sofía Ferretti / Kiara Zacarías]*
* **Tema Técnico:** **Procedimientos Almacenados (Stored Procedures)**
* **Objetivo:** Encapsular la lógica del negocio dentro del servidor para reducir tráfico de red, evitar inyecciones SQL y optimizar el plan de ejecución en la gestión de registros.
* **Entregables:**
  * Documentación: `docs/etapa-05/procedimientos.md`
  * Script SQL Implementación/Demostración: `sql/tecnico/procedimientos/01_sp_operaciones_crud.sql`
* **Requerimientos y Código Base a utilizar:**
  * Desarrollar un mínimo de **3 procedimientos CRUD** (ej. `sp_InsertarProducto`, `sp_ModificarPrecioProducto`, `sp_EliminarClienteLogico`).
  * Incluir parámetros de entrada/salida y validación preventiva de reglas de negocio (`IF EXISTS`, `RAISERROR` o `THROW`).
  * Ejecutar una **prueba comparativa de eficiencia/lote**: comparar el tiempo y plan de ejecución de 100 inserciones directas frente a 100 ejecuciones mediante Stored Procedure.

---

### 📌 Participante: Integrante 3 (A elección)
* **Asignado a:** *[Pendiente de selección: Octavio Dorrego / Nicolás Pini / Sofía Ferretti / Kiara Zacarías]*
* **Tema Técnico:** **Funciones Almacenadas (UDF - Scalar & Table-Valued)**
* **Objetivo:** Modularizar cálculos repetitivos del negocio y transformar datos al vuelo sin duplicar lógica en las consultas.
* **Entregables:**
  * Documentación: `docs/etapa-05/funciones.md`
  * Script SQL Implementación/Demostración: `sql/tecnico/funciones/01_funciones_negocio.sql`
* **Requerimientos y Código Base a utilizar:**
  * Desarrollar un mínimo de **3 funciones de usuario (UDF)**:
    1. Función Escalar de cálculo comercial (ej. `fn_CalcularDescuentoCliente` según antigüedad o volumen).
    2. Función Escalar temporal/utilitaria (ej. `fn_CalcularEdad` o `fn_FormatoMoneda`).
    3. Función con Valores de Tabla en línea (Inline Table-Valued) que retorne el resumen de productos vendidos por período.
  * Demostrar su consumo mediante sentencias `SELECT` simples y cláusulas `WHERE` / `CROSS APPLY`.

---

### 📌 Participante: Integrante 4 (A elección)
* **Asignado a:** *[Pendiente de selección: Octavio Dorrego / Nicolás Pini / Sofía Ferretti / Kiara Zacarías]*
* **Tema Técnico:** **Triggers de Auditoría y Control de Integridad**
* **Objetivo:** Automatizar el registro de trazabilidad histórica ante eventos DML y blindar la base de datos contra borrados accidentales o maliciosos.
* **Entregables:**
  * Documentación: `docs/etapa-05/triggers.md`
  * Script SQL Implementación/Demostración: `sql/tecnico/triggers/01_triggers_auditoria.sql`
* **Requerimientos y Código Base a utilizar:**
  * Crear la tabla auxiliar de auditoría (ej. `Auditoria_Producto` con columnas: `id_auditoria`, `usuario`, `fecha_hora`, `accion`, `precio_anterior`, `precio_nuevo`).
  * **Trigger 1 (Auditoría UPDATE/DELETE):** Disparador `AFTER UPDATE, DELETE` que capture los valores previos utilizando las pseudo-tablas `deleted` e `inserted`.
  * **Trigger 2 (Bloqueo de seguridad):** Disparador `INSTEAD OF DELETE` que impida la eliminación física de registros críticos (ej. comprobantes de ventas o productos con stock activo), cancelando la operación y emitiendo un mensaje formal de advertencia (`RAISERROR`).

---

### 📌 Participante: Integrante 5 (A elección)
* **Asignado a:** *[Pendiente de selección: Octavio Dorrego / Nicolás Pini / Sofía Ferretti / Kiara Zacarías]*
* **Tema Técnico:** **Seguridad (Usuarios/Roles) e Índices (Optimización Física)**
* **Objetivo:** Proteger el acceso a los datos según el principio de mínimo privilegio y optimizar los tiempos de respuesta de las consultas más pesadas mediante estructuras de acceso rápido.
* **Entregables:**
  * Documentación: `docs/etapa-05/seguridad-e-indices.md`
  * Script SQL Implementación/Demostración: `sql/tecnico/seguridad/01_usuarios_roles.sql` e `sql/tecnico/indices/02_indices_optimizacion.sql`
* **Requerimientos y Código Base a utilizar:**
  * **Seguridad:**
    - Crear `LOGIN`, `USER` y un `ROLE` específico para el puesto de caja (ej. `Rol_Cajero`).
    - Asignar permisos granulares (`GRANT SELECT, INSERT ON Venta TO Rol_Cajero; DENY DELETE ON Detalle_Venta TO Rol_Cajero;`).
    - Demostrar la restricción mediante simulación de sesión (`EXECUTE AS USER = 'cajero_pos';`).
  * **Índices:**
    - Crear índices No Clustered (`NONCLUSTERED INDEX`) sobre columnas de búsqueda frecuente y claves foráneas (`fecha_hora`, `DNI_cliente`).
    - Demostrar el impacto comparativo analizando el Plan de Ejecución (`Index Seek` vs. `Table/Clustered Index Scan`).



---



## 🗂️ Estructura de Carpetas en el Repositorio (Temporal o sujeta a cambios)
```text
proyecto-bd1-equipo-XX/
├── docs/
│   └── etapa-05/
│       ├── plan-trabajo.md
│       ├── transacciones.md
│       ├── procedimientos.md
│       ├── funciones.md
│       ├── triggers.md
│       └── seguridad-e-indices.md (esta junto pero puede ir separado, queda en su criterio)
└── sql/
    └── tecnico/
        ├── transacciones/
        ├── procedimientos/
        ├── funciones/
        ├── triggers/
        ├── seguridad/
        └── indices/
```



# Manejo de la Carpeta sql/tecnico/: Funcionamiento y Contenido
La carpeta sql/tecnico/ centraliza todos los mecanismos avanzados del motor (SQL Server Express / T-SQL) que transforman el esquema relacional pasivo en una solución robusta, segura y mantenible.   

A diferencia de sql/ddl/ (tablas) o sql/dml/ (datos de prueba), en sql/tecnico/ el código se divide por mecanismos de funcionalidad:

```text
└── tecnico/
    ├── transacciones/
    │   └── 01_transaccion_venta_stock.sql
    ├── procedimientos/
    │   └── 01_sp_operaciones_crud.sql
    ├── funciones/
    │   └── 01_funciones_negocio.sql
    ├── triggers/
    │   └── 01_triggers_auditoria.sql
    ├── seguridad/
    │   └── 01_usuarios_roles.sql
    └── indices/
        └── 02_indices_optimizacion.sql 
```


## ¿Qué debe contener cada script dentro de estas subcarpetas?

Cada archivo .sql debe ser autocontenido y reproducible, siguiendo una estructura en tres bloques:   

1. Encabezado y Metadatos: Encabezado y Metadatos: Autor, DNI, fecha, objetivo y requisitos técnicos cumplidos.   

2. Implementación Física: Sentencias DDL de creación de objetos (CREATE PROCEDURE, CREATE FUNCTION, CREATE TRIGGER, CREATE ROLE, etc.) bajo sentencias GO.   

3. Escenario de Demostración/Prueba: Bloque ejecutable que demuestre su utilización real en el caso de la panadería.

* En Transacciones: Demostración con COMMIT y con ROLLBACK forzado mediante error intencional.

* En Stored Procedures: Invocación con EXEC de operaciones de alta/baja/modificación.   

* En Funciones: Consultas SELECT o llamadas dentro de filtros WHERE evaluando resultados.

* En Triggers: Un UPDATE/DELETE que active la inserción en la tabla de auditoría, o un intento de borrado bloqueado.

* En Seguridad: Comprobación de permisos mediante suplantación de usuario (EXECUTE AS USER = '...').

* En Índices: Consultas antes y después de crear el índice con el análisis de costo o tiempo de respuesta.