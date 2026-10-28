

USE Panaderia_Tortuga;
GO

-- =================================================================================================
-- BLOQUE 1: IMPLEMENTACIÓN FÍSICA DE LOS ÍNDICES (DDL)
-- =================================================================================================

-- 1.1 ÍNDICE NO AGRUPADO SOBRE CLAVE FORÁNEA: [Venta](DNI_cliente)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Venta_DNI_cliente' AND object_id = OBJECT_ID(N'dbo.Venta'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Venta_DNI_cliente]
    ON dbo.[Venta] ([DNI_cliente])
    INCLUDE ([fecha], [subtotal]);
    PRINT '>>> [OK] Índice [IX_Venta_DNI_cliente] creado exitosamente en tabla [Venta].';
END
ELSE
BEGIN
    PRINT '>>> [INFO] El índice [IX_Venta_DNI_cliente] ya existe.';
END
GO

-- 1.2 ÍNDICE NO AGRUPADO CRONOLÓGICO: [Movimiento_Stock](fecha_hora)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_MovimientoStock_FechaHora' AND object_id = OBJECT_ID(N'dbo.Movimiento_Stock'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_MovimientoStock_FechaHora]
    ON dbo.[Movimiento_Stock] ([fecha_hora])
    INCLUDE ([tipo_movimiento], [cantidad], [id_stock]);
    PRINT '>>> [OK] Índice [IX_MovimientoStock_FechaHora] creado exitosamente en tabla [Movimiento_Stock].';
END
ELSE
BEGIN
    PRINT '>>> [INFO] El índice [IX_MovimientoStock_FechaHora] ya existe.';
END
GO

-- =================================================================================================
-- BLOQUE 2: POBLADO REPRESENTATIVO DE PRUEBA (DATASET DE BENCHMARKING)
-- =================================================================================================


PRINT '>>> Verificando volumen de datos para demostración de planes de ejecución...';

DECLARE @cant_ventas INT;
SELECT @cant_ventas = COUNT(*) FROM dbo.[Venta];

IF (@cant_ventas < 500)
BEGIN
    PRINT '>>> Generando lote de ventas sintéticas para simular producción...';
    
    -- Inserción de 1500 ventas sintéticas distribuidas entre clientes existentes
    DECLARE @i INT = 3000;
    WHILE (@i < 4500)
    BEGIN
        INSERT INTO dbo.[Venta] (id_venta, subtotal, DNI_cliente, DNI_empleado, fecha)
        VALUES (
            @i,
            CAST((1000 + (@i % 25) * 350) AS DECIMAL(12,2)),
            CASE 
                WHEN @i % 5 = 0 THEN 34936602  -- Lucas Zárate
                WHEN @i % 5 = 1 THEN 46843173  -- Octavio Dorrego
                WHEN @i % 5 = 2 THEN 46717369  -- Kiara Zacarías
                WHEN @i % 5 = 3 THEN 29812401  -- Mariana Benítez
                ELSE NULL                      -- Consumidor Final
            END,
            28456123, -- Martín Gómez
            DATEADD(DAY, -(@i % 30), CAST(GETDATE() AS DATE))
        );
        SET @i = @i + 1;
    END;
    PRINT '>>> [OK] 1500 registros de ventas insertados para pruebas estadísticas.';
END;

DECLARE @cant_movimientos INT;
SELECT @cant_movimientos = COUNT(*) FROM dbo.[Movimiento_Stock];

IF (@cant_movimientos < 500)
BEGIN
    PRINT '>>> Generando lote de movimientos de stock sintéticos...';
    DECLARE @j INT = 2000;
    WHILE (@j < 3500)
    BEGIN
        INSERT INTO dbo.[Movimiento_Stock] ([id_movimiento-Stock], fecha_hora, tipo_movimiento, cantidad, id_stock)
        VALUES (
            @j,
            DATEADD(MINUTE, -(@j * 15), GETDATE()),
            CASE WHEN @j % 2 = 0 THEN 'VENTA' ELSE 'INGRESO' END,
            CAST((5 + (@j % 10)) AS DECIMAL(12,2)),
            101 + (@j % 10)
        );
        SET @j = @j + 1;
    END;
    PRINT '>>> [OK] 1500 registros de movimientos de stock insertados.';
END;
GO

-- =================================================================================================
-- BLOQUE 3: DEMOSTRACIÓN COMPARATIVA Y ANÁLISIS DE PLANES DE EJECUCIÓN
-- =================================================================================================
PRINT '=================================================================================';
PRINT '>>> ACTIVANDO MÉTRICAS DE ENTRADA/SALIDA (STATISTICS IO) Y TIEMPO <<<';
PRINT '=================================================================================';

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- -------------------------------------------------------------------------------------------------
-- CASO 1: CONSULTA DE VENTAS POR CLIENTE (DNI_cliente = 34936602)
-- -------------------------------------------------------------------------------------------------
PRINT '>>> -----------------------------------------------------------------------------';
PRINT '>>> CASO 1.A: CONSULTA FORZANDO BARRIDO SECUENCIAL (CLUSTERED INDEX SCAN)';
PRINT '>>> Simula el comportamiento del motor cuando NO existe índice secundario por DNI.';
PRINT '>>> -----------------------------------------------------------------------------';

SELECT 
    id_venta,
    DNI_cliente,
    fecha,
    subtotal
FROM dbo.[Venta] WITH (INDEX(PK_Venta))
WHERE DNI_cliente = 34936602;
GO

PRINT '>>> -----------------------------------------------------------------------------';
PRINT '>>> CASO 1.B: CONSULTA UTILIZANDO EL ÍNDICE CREADO (INDEX SEEK)';
PRINT '>>> Aprovecha el árbol B+ del índice IX_Venta_DNI_cliente para búsqueda directa.';
PRINT '>>> -----------------------------------------------------------------------------';

SELECT 
    id_venta,
    DNI_cliente,
    fecha,
    subtotal
FROM dbo.[Venta] WITH (INDEX(IX_Venta_DNI_cliente))
WHERE DNI_cliente = 34936602;
GO

-- -------------------------------------------------------------------------------------------------
-- CASO 2: CONSULTA POR RANGO CRONOLÓGICO EN MOVIMIENTOS DE STOCK (48 Horas hasta el último movimiento)
-- -------------------------------------------------------------------------------------------------
-- Se toma el último movimiento registrado (y no GETDATE()) para que el rango nunca quede vacío.
DECLARE @fecha_hasta DATETIME = (SELECT MAX(fecha_hora) FROM dbo.[Movimiento_Stock]);
DECLARE @fecha_desde DATETIME = DATEADD(DAY, -2, @fecha_hasta);

PRINT '>>> -----------------------------------------------------------------------------';
PRINT '>>> CASO 2.A: MOVIMIENTOS - BARRIDO COMPLETO (CLUSTERED INDEX SCAN)';
PRINT '>>> -----------------------------------------------------------------------------';

SELECT 
    [id_movimiento-Stock],
    fecha_hora,
    tipo_movimiento,
    cantidad,
    id_stock
FROM dbo.[Movimiento_Stock] WITH (INDEX(PK_MovimientoStock))
WHERE fecha_hora BETWEEN @fecha_desde AND @fecha_hasta;
GO

DECLARE @fecha_hasta DATETIME = (SELECT MAX(fecha_hora) FROM dbo.[Movimiento_Stock]);
DECLARE @fecha_desde DATETIME = DATEADD(DAY, -2, @fecha_hasta);

PRINT '>>> -----------------------------------------------------------------------------';
PRINT '>>> CASO 2.B: MOVIMIENTOS - BÚSQUEDA POR RANGO (INDEX SEEK)';
PRINT '>>> -----------------------------------------------------------------------------';

SELECT 
    [id_movimiento-Stock],
    fecha_hora,
    tipo_movimiento,
    cantidad,
    id_stock
FROM dbo.[Movimiento_Stock] WITH (INDEX(IX_MovimientoStock_FechaHora))
WHERE fecha_hora BETWEEN @fecha_desde AND @fecha_hasta;
GO

-- =================================================================================================
-- BLOQUE 4: DESACTIVACIÓN DE MÉTRICAS Y CONSULTA DE METADATOS DE ÍNDICES
-- =================================================================================================

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '=================================================================================';
PRINT '>>> RESUMEN DE ÍNDICES ACTIVOS Y SU CONFIGURACIÓN EN EL CATÁLOGO SYS.INDEXES <<<';
PRINT '=================================================================================';

SELECT 
    t.name AS [Tabla],
    i.name AS [Nombre_Indice],
    i.type_desc AS [Tipo_Estructura],
    c.name AS [Columna_Indexada],
    ic.is_included_column AS [Es_Columna_Include]
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE i.name IN (N'IX_Venta_DNI_cliente', N'IX_MovimientoStock_FechaHora')
ORDER BY t.name, i.name, ic.key_ordinal, ic.is_included_column;
GO

PRINT '>>> [FIN] Demostración de optimización física e índices completada.';
GO
