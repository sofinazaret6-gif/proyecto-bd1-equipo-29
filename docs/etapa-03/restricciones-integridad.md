## Restricciones de Dominio e Identidad (Nivel 1)

Para garantizar la consistencia y robustez de los datos en este primer nivel, se aplicaron las siguientes reglas de integridad:

* **Nomenclatura Explícita:** Se asignó un nombre formal y descriptivo a cada restricción (por ejemplo, `PK_Categoria`). Esto evita que el gestor asigne identificadores aleatorios, facilitando las labores de mantenimiento mediante sentencias `ALTER TABLE`.

* **Validaciones CHECK:** Se integraron restricciones de verificación para blindar la integridad de dominio. Estas reglas evalúan condiciones lógicas de tipo booleano; por ejemplo, se asegura que el stock cumpla con la condición `cantidad_actual >= 0`, cancelando de inmediato cualquier transacción que intente registrar valores negativos.

## Restricciones Referenciales y de Unicidad (Nivel 2)
* **Integridad Referencial (FOREIGN KEY):** La clave foránea establece la integridad referencial al vincular una tabla dependiente con la clave primaria de la tabla principal. Esto se aplicó vinculando Producto con Categoria y Stock.

* **Restricciones UNIQUE:**  Se utilizó la restricción de unicidad para imponer cardinalidad 1 a 1 sobre valores no nulos. Por ejemplo, UQ_Producto_Stock garantiza que un mismo stock no sea asignado a más de un producto, actuando como clave candidata o alternativa. Asimismo, UQ_Producto_UnidadMedida previene la duplicidad de la combinación de producto y unidad.



## Restricciones de Reglas de Negocio e Integridad Referencial (Nivel 3)
* **Integridad Referencial Cruzada:** Se definieron restricciones `FOREIGN KEY` explícitas (ej. `FK_DetalleVenta_Venta` y `FK_DetalleVenta_Producto`) que vinculan las transacciones dependientes con las entidades fuertes de nivel 1 y 2, impidiendo la creación de registros huérfanos o transacciones sobre productos y ventas inexistentes.
* **Validaciones CHECK Transaccionales:** Se implementaron compuertas de dominio a nivel de fila mediante `CHECK`:
  - En `Detalle-Venta`: `cantidad > 0` y `precio_unitario >= 0`, asegurando que no existan cantidades nulas ni precios negativos.
  - En `Venta-MedioDePago`: `importe > 0`, obligando a registrar pagos con valores positivos.
  - En `Movimiento-Stock`: `cantidad > 0` y restricción de dominio categórico `UPPER(tipo_movimiento) IN ('INGRESO', 'EGRESO', 'COMPRA', 'VENTA', 'AJUSTE')`, bloqueando cualquier clasificación fuera del estándar operativo.
* **Unicidad en Asociaciones Múltiples:** En la tabla `Categoria-Promocion`, se añadió la restricción `CONSTRAINT UQ_CategoriaPromocion UNIQUE (id_categoria, id_promocion)` para evitar duplicaciones lógicas al vincular una promoción con una misma categoría.
A incorporar en docs/etapa-03/pruebas-validaciones.md
Markdown
## Validación Estructural de Integridad Referencial y Reglas CHECK (Nivel 3)
* **Comprobación de Claves Foráneas:** Se verificó que el motor relacional bloquee cualquier intento de inserción de un registro dependiente (`Detalle-Venta` o `Movimiento-Stock`) cuyo identificador foráneo no se encuentre previamente insertado en su tabla padre (`Venta`, `Producto` o `Stock`).
* **Validación de Restricciones CHECK:** Se ejecutaron pruebas negativas intentando registrar movimientos con tipos incompatibles (ej. `'DEVOLUCION'`), comprobando que SQL Server emite el error `Msg 547 (Conflicto con la restricción CHECK)` cancelando la transacción.

## Validación de Reglas e Integridad en Tablas Maestras (Fase DML 1)

Durante la carga inicial de registros en las tablas maestras, se validó el comportamiento de las restricciones declaradas en el DDL:

* *Restricciones de Dominio CHECK:*
  - En la tabla Stock: se constató que los valores numéricos ingresados en cantidad_actual y stock_minimo satisfagan la condición booleana de no negatividad (>= 0).
  - En Unidad_Medida y Categoria: se verificó que las cadenas de texto ingresadas no contengan espacios vacíos mediante la función LEN(TRIM(...)) > 0.
* *Unicidad e Identificadores Primarios (PRIMARY KEY):*
  - Se confirmó que no existan duplicados en los códigos identificadores de categorías, stock ni medios de pago.
  - En Cliente y Empleado, las claves primarias naturales basadas en el DNI garantizaron que no se registren personas duplicadas dentro de la misma entidad.