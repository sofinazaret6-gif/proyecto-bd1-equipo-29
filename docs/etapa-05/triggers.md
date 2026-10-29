# Etapa V — Temas Técnicos: Triggers de Auditoría y Control de Integridad

## 1. Identificación y Metadatos
- **Proyecto:** Sistema de Gestión Comercial — Panadería Tortuga
- **Materia:** Bases de Datos I — FaCENA (UNNE)
- **Etapa:** Etapa V — Temas Técnicos Avanzados
- **Tema Especializado:** Triggers de Auditoría y Control de Integridad
- **Responsable:** Octavio Dorrego 
- **Motor:** Microsoft SQL Server Express (T-SQL)
- **Script Asociado:** `sql/tecnico/triggers/01_triggers_auditoria.sql`

---

## 2. Fundamentos Teóricos y Justificación de Negocio

En un entorno comercial de alta rotación como la panadería *Tortuga*, las restricciones estándar a nivel de esquema (`CHECK`, `FOREIGN KEY`, `UNIQUE`) son fundamentales pero insuficientes para garantizar la seguridad ante operaciones destructivas o modificaciones silenciosas. Para cubrir estas brechas, se implementan **Triggers (Disparadores)** a nivel de base de datos, los cuales operan de forma automática e imperceptible para cualquier aplicación cliente.

Los mecanismos implementados responden a dos pilares críticos:
1. **Trazabilidad Histórica y No Repudiación:** Ante modificaciones de precios o bajas de artículos en el catálogo, es indispensable contar con una bitácora automatizada que registre quién realizó la modificación, en qué momento exacto y cuáles eran los valores anteriores.
2. **Blindaje contra Borrados Destructivos (Data Integrity):** Los comprobantes de venta oficiales constituyen documentos fiscales e históricos inalterables. Los operadores del sistema (incluso con privilegios operativos) no deben tener la capacidad de ejecutar un borrado físico (`DELETE`) sobre la tabla de ventas, evitando así la pérdida de consistencia financiera.

---

## 3. Diseño de Componentes Implementados

### 3.1. Tabla Auxiliar de Auditoría (`Auditoria_Producto`)
Se diseñó una tabla satélite orientada a almacenar el registro histórico de eventos sobre la entidad `Producto`:
* `id_auditoria`: Identificador autoincremental (Clave Primaria).
* `id_producto`: Clave de referencia al producto afectado.
* `usuario`: Captura automática del login de SQL Server (`SYSTEM_USER`) que ejecutó la acción.
* `fecha_hora`: Sello temporal automático (`GETDATE()`).
* `accion`: Etiqueta delimitadora (`'UPDATE'` o `'DELETE'`).
* `precio_anterior` / `precio_nuevo`: Valores monetarios para auditar la fluctuación de precios.

### 3.2. Trigger 1: Auditoría de Modificaciones y Eliminaciones (`trg_Auditoria_Producto`)
* **Tabla Afectada:** `dbo.Producto`
* **Momento y Evento:** `AFTER UPDATE, DELETE`
* **Funcionamiento:** Hace uso de las tablas virtuales transaccionales de SQL Server:
  * En caso de un `UPDATE`, evalúa la intersección entre las tablas `deleted` y `inserted`, registrando en la bitácora únicamente si el campo `precio` sufrió alteraciones efectivas.
  * En caso de un `DELETE`, captura el estado previo del registro desde la tabla `deleted` antes de su desaparición física del maestro.

### 3.3. Trigger 2: Bloqueo de Seguridad contra Borrado de Ventas (`trg_Bloqueo_Borrado_Ventas`)
* **Tabla Afectada:** `dbo.Venta`
* **Momento y Evento:** `INSTEAD OF DELETE`
* **Funcionamiento:** Intercepta preventivamente cualquier intento de sentencia `DELETE` sobre la cabecera de las ventas. Cancela inmediatamente la ejecución mediante un `ROLLBACK TRANSACTION` y emite un mensaje formal de advertencia (`RAISERROR` con nivel de severidad 16), protegiendo la integridad contable del negocio.

---

## 4. Pruebas y Validación Empírica
El script de pruebas valida los siguientes escenarios:
1. **Auditoría de Actualización:** Modificación del precio de un producto existente y consulta de la tabla `Auditoria_Producto` para corroborar el almacenamiento del usuario, fecha y valores previos/nuevos.
2. **Bloqueo de Seguridad:** Intento explícito de eliminar un registro de la tabla `Venta`, interceptado con éxito por el trigger `INSTEAD OF DELETE`, capturando el error controlado en un bloque `TRY...CATCH`.