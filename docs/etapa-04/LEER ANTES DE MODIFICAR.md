# Organización del Trabajo en Equipo (5 Integrantes)
### Integrante 1 (Lucas Martín Zárate):

* **Requerimiento:** 1. Factura/Comprobante de Venta.

* **Archivos a modificar/crear:** comprobante_venta.sql y comprobante-venta.md.

## Distribución de Tareas - Etapa IV: Consultas y Casos de Uso (Integrantes 2 al 5)

---

### Integrante 2: Reporte Agregado por Vendedor
* **Consigna asignada:** Reporte Agregado (variante por vendedor). Total de ventas realizadas por cada vendedor en un rango de fechas.
* **Operaciones SQL:** `INNER JOIN` entre `Empleado`, `Venta` y `Detalle_Venta`, funciones agregadas `SUM` y `COUNT`, agrupamiento por `GROUP BY` y filtro de rango de fechas en `WHERE`.
* **Archivos a modificar:**
  * `sql/consultas/informe_ventas.sql` (sección 1: Reporte por Vendedor)

---

### Integrante 3: Reporte Agregado por Categoría y Documentación
* **Consigna asignada:** Reporte Agregado (variante por categoría). Total de ventas realizadas por cada categoría de producto en un rango de fechas, junto con la documentación técnica consolidada del informe de ventas.
* **Operaciones SQL:** `INNER JOIN` entre `Categoria`, `Producto` y `Detalle_Venta`, métricas agregadas con `SUM` y `COUNT`, agrupamiento por `GROUP BY` y filtro de fechas en `WHERE`.
* **Archivos a modificar:**
  * `sql/consultas/informe_ventas.sql` (sección 2: Reporte por Categoría)
  * `docs/etapa-04/informe-ventas.md`

---

### Integrante 4: Consulta de Negocio Avanzada
* **Consigna asignada:** Consulta de Negocio Avanzada. Consulta analítica que combina al menos 3 tablas mediante `JOIN` y aplica filtros condicionales mediante `HAVING` o subconsultas.
* **Operaciones SQL:** `JOIN` entre `Cliente`, `Venta` y `Detalle_Venta` (o `Producto`, `Detalle_Venta` y `Categoria`), agrupamiento con `GROUP BY`, agregaciones cuantitativas y restricción de post-agrupado mediante `HAVING` o filtros basados en subconsultas no triviales.
* **Archivos a modificar:**
  * `sql/consultas/consulta_avanzada.sql`
  * `docs/etapa-04/consulta-avanzada.md`

---

### Integrante 5: Definición y Mapeo de Casos de Uso
* **Consigna asignada:** Mapeo integral de los casos de uso del sistema comercial, vinculando los requerimientos funcionales del punto de venta con la trazabilidad técnica de las consultas implementadas en la etapa.
* **Operaciones SQL:** Validación funcional y verificación cruzada de resultados de las consultas frente a las especificaciones del negocio.
* **Archivos a modificar:**
  * `docs/etapa-04/casos-uso.md`