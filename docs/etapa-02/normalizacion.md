# Normalización - Panadería Tortuga

## Modelo inicial a partir del DER (Estado Inicial)

Se parte del esquema relacional obtenido tras la conversión directa del Diagrama Entidad-Relación (DER).

* **Problemas detectados (Violaciones de 1FN y diseño):**
  * **En `STOCK`:** Contiene la clave foránea `fk_MOVIMIENTO_STOCK`. Esto impide registrar múltiples movimientos de inventario de forma atómica para un mismo producto (obligaría a guardar listas de valores en una sola celda o a duplicar filas enteras de stock, violando la 1FN).
  * **En `VENTA`:** Contiene una única clave foránea `fk_MEDIO_DE_PAGO`. Impide registrar pagos mixtos (ej. abonar una parte en efectivo y otra con débito) a menos que se dupliquen ventas o se agreguen columnas repetitivas, violando la 1FN.
  * **En `ASOCIA`:** Se mapeó el rombo de relación entre cliente y venta como una tabla intermedia con clave compuesta `(fk_CLIENTE, fk_VENTA)`, cuando en la realidad del negocio una venta pertenece a un único cliente ($id\_venta \rightarrow dni\_Cliente$).

![Modelo inicial](./imagenes/erdplus%20imagen%200.png "Modelo inicial")

## Paso a Primera Forma Normal (1FN)

* **Regla:** Garantizar que cada atributo contenga un único valor atómico, eliminar grupos repetitivos/multivaluados y definir una clave primaria por tabla.
* **Acciones realizadas:**
  1. **Inventario:** Se retira `fk_MOVIMIENTO_STOCK` de `STOCK` y se incorpora `fk_STOCK` dentro de `MOVIMIENTO_STOCK`, permitiendo registrar múltiples movimientos históricos de forma atómica.
  2. **Cobros:** Se retira `fk_MEDIO_DE_PAGO` de `VENTA` y se crea la tabla intermedia **`VENTA_MEDIO_DE_PAGO`** (`id_ventaMedioPago` [PK], `fk_VENTA`, `fk_MEDIO_DE_PAGO`, `importe`) vinculada a la tabla maestra `MEDIO_DE_PAGO` para registrar pagos individuales por venta.

### Esquema Resultante en 1FN

![Primera forma normal](./imagenes/erdplus%20imagen%201.png "Primera forma Normal")

* **Cumple 1FN:** Todas las tablas poseen claves primarias definidas, valores atómicos y se eliminó la imposibilidad de registrar historiales de inventario y pagos múltiples.
* **Pendiente para 2FN (Dependencias parciales):**
  * En **`ASOCIA`**: Al existir la dependencia funcional $id\_venta \rightarrow dni\_Cliente$, la clave compuesta `(fk_CLIENTE, fk_VENTA)` contiene una dependencia funcional parcial (el cliente depende únicamente de la venta y no de la combinación de ambos).

