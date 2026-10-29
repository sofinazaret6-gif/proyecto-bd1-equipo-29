-----------------------------------------------------------------------------------------
-- Archivo: 01_triggers_auditoria.sql
-- Tema: Triggers de Auditoría y Control de Integridad
-- Proyecto: Sistema de Gestión Comercial — Panadería Tortuga
-- Motor: Microsoft SQL Server Express (T-SQL)
-- Responsable: Octavio Dorrego (Integrante 4)
-- Materia: Bases de Datos I — FaCENA (UNNE)
-----------------------------------------------------------------------------------------

USE Panaderia_Tortuga;
GO

-----------------------------------------------------------------------------------------
-- 1. CREACIÓN DE LA TABLA AUXILIAR DE AUDITORÍA
-----------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Auditoria_Producto', 'U') IS NOT NULL
    DROP TABLE dbo.Auditoria_Producto;
GO

CREATE TABLE dbo.Auditoria_Producto (
    id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
    id_producto INT NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),
    accion VARCHAR(10) NOT NULL, -- 'UPDATE' o 'DELETE'
    precio_anterior DECIMAL(12,2) NULL,
    precio_nuevo DECIMAL(12,2) NULL
);
GO

-----------------------------------------------------------------------------------------
-- 2. TRIGGER 1: AUDITORÍA DE MODIFICACIONES Y ELIMINACIONES EN PRODUCTO (AFTER UPDATE, DELETE)
-----------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.trg_Auditoria_Producto', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Auditoria_Producto;
GO

CREATE TRIGGER dbo.trg_Auditoria_Producto
ON dbo.[Producto]
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Caso 1: Actualización de registros (UPDATE)

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO dbo.Auditoria_Producto (id_producto, usuario, fecha_hora, accion, precio_anterior, precio_nuevo)
        SELECT 
            d.id_producto,
            SYSTEM_USER,
            GETDATE(),
            'UPDATE',
            d.precio_unitario,
            i.precio_unitario
        FROM deleted d
        INNER JOIN inserted i ON d.id_producto = i.id_producto
        WHERE d.precio_unitario <> i.precio_unitario; -- Auditoría selectiva ante cambios reales de precio
    END

    -- Caso 2: Eliminación física de registros (DELETE)
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO dbo.Auditoria_Producto (id_producto, usuario, fecha_hora, accion, precio_anterior, precio_nuevo)
        SELECT 
            d.id_producto,
            SYSTEM_USER,
            GETDATE(),
            'DELETE',
            d.precio_unitario,
            NULL
        FROM deleted d;
    END
END;
GO

-----------------------------------------------------------------------------------------
-- 3. TRIGGER 2: BLOQUEO DE SEGURIDAD CONTRA BORRADO DE VENTAS (INSTEAD OF DELETE)
-----------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.trg_Bloqueo_Borrado_Ventas', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Bloqueo_Borrado_Ventas;
GO

CREATE TRIGGER dbo.trg_Bloqueo_Borrado_Ventas
ON dbo.[Venta]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
   
    RAISERROR('OPERACIÓN DENEGADA: Por políticas de seguridad y auditoría contable, está estrictamente prohibido eliminar comprobantes de venta del sistema de la Panadería.', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO

-----------------------------------------------------------------------------------------
-- 4. ESCENARIO DE DEMOSTRACIÓN Y PRUEBAS PRÁCTICAS
-----------------------------------------------------------------------------------------
PRINT '=== INICIO DE PRUEBAS DE TRIGGERS ===';
GO

-- PRUEBA 1: Verificación del funcionamiento del Trigger de Auditoría (UPDATE en Producto)
PRINT '--- Prueba 1: Auditoría de cambio de precio en Producto ---';
SELECT TOP 1 id_producto, precio_unitario FROM dbo.[Producto];

-- Realizamos una modificación de precio sobre el primer producto disponible
UPDATE TOP (1) dbo.[Producto] 
SET precio_unitario = precio_unitario * 1.10;

-- Consultamos la bitácora de auditoría generada automáticamente
SELECT * FROM dbo.Auditoria_Producto;
GO

-- PRUEBA 2: Verificación del Trigger de Bloqueo de Seguridad (INSTEAD OF DELETE en Venta)
PRINT '--- Prueba 2: Bloqueo de borrado físico en Venta ---';
BEGIN TRY
    -- Intentamos eliminar un comprobante de venta existente
    DELETE FROM dbo.[Venta] WHERE id_venta = (SELECT TOP 1 id_venta FROM dbo.[Venta]);
    PRINT 'ERROR: El borrado se permitió de forma indebida.';
END TRY
BEGIN CATCH
    PRINT 'ÉXITO EN LA PRUEBA DE SEGURIDAD: El trigger interceptó y bloqueó la operación.';
    PRINT 'Mensaje capturado del motor: ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '=== FIN DE LAS PRUEBAS DE TRIGGERS ===';
GO