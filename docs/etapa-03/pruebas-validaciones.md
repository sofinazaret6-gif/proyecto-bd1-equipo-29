## Pruebas-Validaciones

## Validación Estructural de Integridad Referencial y Reglas CHECK (Nivel 3)
* **Comprobación de Claves Foráneas:** Se verificó que el motor relacional bloquee cualquier intento de inserción de un registro dependiente (`Detalle-Venta` o `Movimiento-Stock`) cuyo identificador foráneo no se encuentre previamente insertado en su tabla padre (`Venta`, `Producto` o `Stock`).
* **Validación de Restricciones CHECK:** Se ejecutaron pruebas negativas intentando registrar movimientos con tipos incompatibles (ej. `'DEVOLUCION'`), comprobando que SQL Server emite el error `Msg 547 (Conflicto con la restricción CHECK)` cancelando la transacción.