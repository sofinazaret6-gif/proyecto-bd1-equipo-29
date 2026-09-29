## Pruebas-Validaciones

## Validación Estructural de Integridad Referencial y Reglas CHECK (Nivel 3)
* **Comprobación de Claves Foráneas:** Se verificó que el motor relacional bloquee cualquier intento de inserción de un registro dependiente (`Detalle-Venta` o `Movimiento-Stock`) cuyo identificador foráneo no se encuentre previamente insertado en su tabla padre (`Venta`, `Producto` o `Stock`).
* **Validación de Restricciones CHECK:** Se ejecutaron pruebas negativas intentando registrar movimientos con tipos incompatibles (ej. `'DEVOLUCION'`), comprobando que SQL Server emite el error `Msg 547 (Conflicto con la restricción CHECK)` cancelando la transacción.

## Pruebas de Carga y Validación DML (Tablas Maestras)

Se ejecutaron pruebas de consistencia sobre las tablas maestras para verificar el rechazo de tuplas no conformes:

* *Prueba de Inserción Negativa en Stock:* Se intentó forzar la carga de un registro con cantidad negativa (cantidad_actual = -10.00). El motor Microsoft SQL Server abortó la operación emitiendo un conflicto con la restricción CK_Stock_CantidadActual.
* *Prueba de Clave Primaria Duplicada en Empleado:* Se ejecutó una sentencia INSERT con un DNI preexistente, confirmando la activación del error de violación de clave primaria PK_Empleado.
* *Verificación de Datos Válidos:* Las inserciones de prueba de 4 registros por tabla se realizaron sin conflictos, dejando la base en un estado consistente para la vinculación con las tablas transaccionales.


## Pruebas Transaccionales y Verificación de Consistencia (DML Final)

Se llevaron a cabo pruebas funcionales para asegurar la robustez de las reglas transaccionales:

* **Prueba de Venta Mostrador Anónima:** Se insertó exitosamente una venta con `DNI_cliente = NULL`, verificando que la participación del cliente es opcional y no produce bloqueos en la facturación rápida de mostrador.
* **Prueba de Violación de Clave Compuesta en Detalle:** Se ejecutó un `INSERT` intentando repetir el mismo `id_producto` en una misma venta (`id_venta = 1001, id_producto = 1`), siendo rechazado de inmediato por el motor relacional debido a infracción de la clave primaria compuesta `PK_DetalleVenta`.
* **Prueba de Inserción Foránea Inválida:** Se intentó cargar un detalle de venta haciendo referencia a un producto inexistente (`id_producto = 999`), provocando la interrupción de la operación con error `Msg 547 (Conflicto con la restricción FOREIGN KEY)`.
* **Verificación de Cobro Combinado:** Se validó la venta número 1001 con un subtotal de $11.600,00, registrando dos transacciones de pago: $5.000,00 en Efectivo y $6.600,00 mediante Transferencia/QR, garantizando la consistencia financiera del comprobante.