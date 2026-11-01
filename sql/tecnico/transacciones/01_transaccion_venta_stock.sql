----------------------------------------------------------------------------------------------------
-- PROYECTO: PANADERÍA TORTUGA
-- ETAPA: Etapa V - Temas Técnicos
-- ARCHIVO: sql/tecnico/transacciones/01_transaccion_venta_stock.sql
-- AUTOR: Lucas Martín Zárate (DNI: 34936602) - Integrante 1
-- DIALECTO: Microsoft SQL Server (T-SQL)
-- TEMA: Manejo de Transacciones y Control de Concurrencia (ACID)
----------------------------------------------------------------------------------------------------
USE Panaderia_Tortuga;


-- =================================================================================================
-- ESCENARIO 1: TRANSACCIÓN EXITOSA DE VENTA CON DESCUENTO DE STOCK (COMMIT)
-- Objetivo: Ejecutar una unidad lógica que inserte cabecera de venta, detalle, descuente stock
--           y asiente la trazabilidad en Movimiento-Stock de manera atómica y consistente.
-- =================================================================================================
PRINT '>>> EJECUTANDO ESCENARIO 1: TRANSACCIÓN DE VENTA EXITOSA <<<';

-- Parámetros de la transacción
-- Ids calculados para que el script se pueda volver a ejecutar sin violar la PK
DECLARE @id_venta_ok INT = (SELECT ISNULL(MAX(id_venta), 0) + 1 FROM [Venta]);
DECLARE @dni_cliente INT = 34936602;      -- Lucas Zárate
DECLARE @dni_empleado INT = 28456123;     -- Martín Gómez
DECLARE @id_producto INT = 1;             -- Pan Francés
DECLARE @id_stock INT = 101;              -- Stock asociado al Pan Francés
DECLARE @cantidad DECIMAL(10,2) = 5.00;   -- 5 kg de pan
DECLARE @precio_unitario DECIMAL(12,2) = 2200.00;
DECLARE @subtotal_calculado DECIMAL(12,2);
SET @subtotal_calculado = CAST((@cantidad * @precio_unitario) AS DECIMAL(12,2));

DECLARE @id_mov_ok INT = (SELECT ISNULL(MAX([id_movimiento-Stock]), 0) + 1 FROM [Movimiento_Stock]);

BEGIN TRY
    -- Inicio formal de la transacción
    BEGIN TRANSACTION;

    -- Paso 1: Registrar cabecera en Venta explicitando la columna fecha
    INSERT INTO [Venta] (id_venta, subtotal, DNI_cliente, DNI_empleado, fecha)
    VALUES (@id_venta_ok, @subtotal_calculado, @dni_cliente, @dni_empleado, CAST(GETDATE() AS DATE));

    -- Paso 2: Registrar renglón en Detalle-Venta
    INSERT INTO [Detalle_Venta] (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (@id_venta_ok, @id_producto, @cantidad, @precio_unitario);

    -- Paso 3: Descontar existencias físicas en Stock
    UPDATE [Stock]
    SET cantidad_actual = cantidad_actual - @cantidad
    WHERE id_stock = @id_stock;

    -- Paso 4: Asentar auditoría histórica del egreso
    INSERT INTO [Movimiento_Stock] ([id_movimiento-Stock], fecha_hora, tipo_movimiento, cantidad, id_stock)
    VALUES (@id_mov_ok, GETDATE(), 'VENTA', @cantidad, @id_stock);

    -- Confirmación de cambios
    COMMIT TRANSACTION;
    PRINT 'Éxito: Transacción confirmada con COMMIT TRANSACTION.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    PRINT 'Error detectado en Escenario 1. Se ejecutó ROLLBACK.';
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;


-- Verificación de estado de datos persistidos
SELECT 'Venta confirmada' AS Estado, * FROM [Venta] WHERE id_venta = @id_venta_ok;
SELECT 'Detalle registrado' AS Estado, * FROM [Detalle_Venta] WHERE id_venta = @id_venta_ok;
SELECT 'Stock actualizado' AS Estado, * FROM [Stock] WHERE id_stock = @id_stock;
SELECT 'Movimiento registrado' AS Estado, * FROM [Movimiento_Stock] WHERE [id_movimiento-Stock] = @id_mov_ok;


-- =================================================================================================
-- ESCENARIO 2: DEMOSTRACIÓN DE ATOMICIDAD MEDIANTE ERROR INTENCIONAL (ROLLBACK)
-- Consigna: Provocar deliberadamente un fallo después de un INSERT y verificar consistencia.
-- =================================================================================================
PRINT '>>> INICIANDO ESCENARIO 2: ERROR INTENCIONAL TRAS INSERT (DEMOSTRACIÓN ROLLBACK) <<<';

DECLARE @id_venta_error INT = (SELECT ISNULL(MAX(id_venta), 0) + 1 FROM [Venta]);
DECLARE @dni_cliente_err INT = 34936602;
DECLARE @dni_empleado_err INT = 28456123;
DECLARE @id_producto_err INT = 1;
DECLARE @id_stock_err INT = 101;
DECLARE @cantidad_err DECIMAL(10,2) = 2.00;
DECLARE @precio_err DECIMAL(12,2) = 2200.00;
DECLARE @subtotal_err DECIMAL(12,2);
SET @subtotal_err = CAST((@cantidad_err * @precio_err) AS DECIMAL(12,2));

BEGIN TRY
    BEGIN TRANSACTION;

    -- Paso 1: Inserción de cabecera en Venta
    INSERT INTO [Venta] (id_venta, subtotal, DNI_cliente, DNI_empleado, fecha)
    VALUES (@id_venta_error, @subtotal_err, @dni_cliente_err, @dni_empleado_err, CAST(GETDATE() AS DATE));

    PRINT 'Paso 1: Venta insertada en memoria de transacción (id: ' + CAST(@id_venta_error AS VARCHAR(10)) + ').';

    -- Paso 2: Error forzado en tiempo de ejecución (división por cero)
    DECLARE @divisor_cero INT = 0;
    DECLARE @fallo_forzado INT;
    SET @fallo_forzado = 1 / @divisor_cero;

    -- Pasos omitidos por el desvío al bloque CATCH
    INSERT INTO [Detalle_Venta] (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (@id_venta_error, @id_producto_err, @cantidad_err, @precio_err);

    UPDATE [Stock]
    SET cantidad_actual = cantidad_actual - @cantidad_err
    WHERE id_stock = @id_stock_err;

    COMMIT TRANSACTION;
    PRINT 'Transacción completada (no esperado).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Excepción capturada con éxito en bloque CATCH.';
        PRINT 'Código de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Descripción del Error: ' + ERROR_MESSAGE();
        PRINT 'Acción ejecutada: ROLLBACK TRANSACTION (Atomicidad demostrada).';
    END;
END CATCH;


-- =================================================================================================
-- VERIFICACIÓN EMPÍRICA DE ATOMICIDAD (Comprobación de ausencia de registros parciales)
-- =================================================================================================
PRINT '>>> VERIFICACIÓN: Comprobando que la venta del escenario 2 NO existe en la base de datos <<<';

-- Debe devolver 0 filas: el primer INSERT fue revertido íntegramente
SELECT * FROM [Venta] WHERE id_venta = @id_venta_error;

-- Debe devolver 0 filas:
SELECT * FROM [Detalle_Venta] WHERE id_venta = @id_venta_error;
