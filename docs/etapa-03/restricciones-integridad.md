## Restricciones de Dominio e Identidad (Nivel 1)

Para garantizar la consistencia y robustez de los datos en este primer nivel, se aplicaron las siguientes reglas de integridad:

* **Nomenclatura Explícita:** Se asignó un nombre formal y descriptivo a cada restricción (por ejemplo, `PK_Categoria`). Esto evita que el gestor asigne identificadores aleatorios, facilitando las labores de mantenimiento mediante sentencias `ALTER TABLE`.

* **Validaciones CHECK:** Se integraron restricciones de verificación para blindar la integridad de dominio. Estas reglas evalúan condiciones lógicas de tipo booleano; por ejemplo, se asegura que el stock cumpla con la condición `cantidad_actual >= 0`, cancelando de inmediato cualquier transacción que intente registrar valores negativos.