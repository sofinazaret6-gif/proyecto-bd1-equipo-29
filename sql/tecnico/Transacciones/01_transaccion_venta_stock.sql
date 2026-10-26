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
DECLARE @id_venta_ok INT = 2001;
DECLARE @dni_cliente INT = 34936602;      -- Lucas Zárate
DECLARE @dni_empleado INT = 28456123;     -- Martín Gómez
DECLARE @id_producto INT = 1;             -- Pan Francés
DECLARE @id_stock INT = 101;              -- Stock asociado al Pan Francés
DECLARE @cantidad DECIMAL(10,2) = 5.00;   -- 5 kg de pan
DECLARE @precio_unitario DECIMAL(12,2) = 2200.00;
DECLARE @subtotal_calculado DECIMAL(12,2);
SET @subtotal_calculado = @cantidad * @precio_unitario;

DECLARE @id_mov_ok INT = 100;

BEGIN TRY
    -- Inicio formal de la transacción
    BEGIN TRANSACTION;

    -- Paso 1: Registrar cabecera en Venta
    INSERT INTO [Venta] (id_venta, subtotal, DNI_cliente, DNI_empleado)
    VALUES (@id_venta_ok, @subtotal_calculado, @dni_cliente, @dni_empleado);

    -- Paso 2: Registrar renglón en Detalle-Venta
    INSERT INTO [Detalle_Venta] (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (@id_venta_ok, @id_producto, @cantidad, @precio_unitario);

    -- Paso 3: Descontar existencias físicas en Stock
    UPDATE [Stock]
    SET cantidad_actual = cantidad_actual - @cantidad
    WHERE id_stock = @id_stock;

    -- Paso 4: Asentar auditoría histórica del egreso
    INSERT INTO [Movimiento-Stock] ([id_movimiento-Stock], fecha_hora, tipo_movimiento, cantidad, id_stock)
    VALUES (@id_mov_ok, GETDATE(), 'VENTA', @cantidad, @id_stock);

    -- Si no hubo excepciones, confirmamos la persistencia en disco
    COMMIT TRANSACTION;
    PRINT 'Éxito: Transacción confirmada con COMMIT TRANSACTION.';
END TRY
BEGIN CATCH
    -- Control defensivo: si la transacción quedó abierta ante un error, se revierte
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    PRINT 'Error detectado en Escenario 1. Se ejecutó ROLLBACK.';
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;

-- Verificación de estado de datos persistidos
SELECT 'Venta confirmada' AS Estado, * FROM [Venta] WHERE id_venta = 2001;
SELECT 'Detalle registrado' AS Estado, * FROM [Detalle_Venta] WHERE id_venta = 2001;
SELECT 'Stock actualizado' AS Estado, * FROM [Stock] WHERE id_stock = 101;
