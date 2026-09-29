## Restricciones de Dominio e Identidad (Nivel 1)

Para garantizar la consistencia y robustez de los datos en este primer nivel, se aplicaron las siguientes reglas de integridad:

* **Nomenclatura Explícita:** Se asignó un nombre formal y descriptivo a cada restricción (por ejemplo, `PK_Categoria`). Esto evita que el gestor asigne identificadores aleatorios, facilitando las labores de mantenimiento mediante sentencias `ALTER TABLE`.

* **Validaciones CHECK:** Se integraron restricciones de verificación para blindar la integridad de dominio. Estas reglas evalúan condiciones lógicas de tipo booleano; por ejemplo, se asegura que el stock cumpla con la condición `cantidad_actual >= 0`, cancelando de inmediato cualquier transacción que intente registrar valores negativos.

## Restricciones Referenciales y de Unicidad (Nivel 2)
* **Integridad Referencial (FOREIGN KEY):** La clave foránea establece la integridad referencial al vincular una tabla dependiente con la clave primaria de la tabla principal. Esto se aplicó vinculando Producto con Categoria y Stock.

* **Restricciones UNIQUE:**  Se utilizó la restricción de unicidad para imponer cardinalidad 1 a 1 sobre valores no nulos. Por ejemplo, UQ_Producto_Stock garantiza que un mismo stock no sea asignado a más de un producto, actuando como clave candidata o alternativa. Asimismo, UQ_Producto_UnidadMedida previene la duplicidad de la combinación de producto y unidad.

