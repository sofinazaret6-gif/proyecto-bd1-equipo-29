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

## Paso a Segunda Forma Normal (2FN)

* **Regla:** Cumplir con 1FN y eliminar las **dependencias funcionales parciales** (todo atributo no clave debe depender de la totalidad de la clave primaria en aquellas tablas con clave compuesta).
* **Acciones realizadas:**
  1. **Resolución de `ASOCIA` (Cliente - Venta):** Dado que cada venta pertenece a un único cliente ($id\_venta \rightarrow dni\_Cliente$), la tabla intermedia generaba una dependencia parcial sobre su clave compuesta. Se elimina la tabla `ASOCIA` y se incorpora la clave foránea `fk_CLIENTE` directamente en la tabla `VENTA` para representar fielmente la relación $1:N$.

### Esquema Resultante en 2FN

![Segunda forma normal](./imagenes/erdplus%20imagen%202.png "Segunda forma Normal")

* **Cumple 2FN:** Todas las tablas con clave compuesta (`INCLUYE`, `PARTICIPA_EN`, `TIENE`) tienen atributos que dependen de la totalidad de dicha clave. Las tablas con clave simple cumplen 2FN por definición.
* **Pendiente para 3FN (Dependencias transitivas y depuración):**
  * En **`PROMOCION`**: Existen atributos no clave que determinan otros atributos (`tipoPromocion` $\rightarrow$ `Valor`), generando una dependencia transitiva.
  * En **`TIENE`**: Falta definir la clave subrogada y el factor de equivalencia (`conversión`) para las unidades de medida.
  * Estandarización final de los nombres de relaciones a entidades definitivas del dominio.

## Paso a Tercera Forma Normal (3FN)
Regla: Cumplir con 2FN y eliminar las dependencias funcionales transitivas (ningún atributo no clave debe depender de otro atributo no clave: $X \rightarrow Y \rightarrow Z$).
Acciones realizadas:
Depuración de Promocion: Se eliminan los atributos transitivos tipoPromocion y Valor, dejando únicamente los datos directos de la promoción (descripcion, fecha_inicio, fecha_fin).
Estructuración de Producto-Unidad: La relación TIENE se formaliza como Producto-Unidad, asignándole su clave primaria subrogada id_productoUnidad e incorporando el atributo conversión.
Estandarización formal de nombres: Se formalizan las tablas intermedias y entidades al modelo final del negocio (Detalle-Venta, Producto-Unidad, Categoria-Promocion).

### Esquema Resultante en 3FN (Modelo Final)
![Tercera forma normal](./imagenes/erdplus%20imagen%203.png "Tercera forma Normal")

Cumple 3FN: El 100% de las tablas del esquema cumple con 1FN, 2FN y 3FN. No existen grupos repetitivos, dependencias parciales ni dependencias transitivas, logrando un modelo relacional íntegro, consistente y libre de redundancias.

