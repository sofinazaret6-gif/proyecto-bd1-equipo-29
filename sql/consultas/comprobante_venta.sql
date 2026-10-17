----------------------------------------------------------------------------------------------------
-- PROYECTO: PANADERÍA TORTUGA
-- ETAPA: Etapa IV - Consultas y Casos de Uso
-- ARCHIVO: sql/consultas/comprobante_venta.sql
-- AUTOR: Lucas Martín Zárate (DNI: 34936602) - Integrante 1
-- DIALECTO: Microsoft SQL Server (T-SQL) bajo Estándar ANSI SQL (SQL-92 / SQL:1999)
-- REQUERIMIENTO 1: Factura / Comprobante de Venta Consolidado
-- DESCRIPCIÓN:
--   Consulta relacional que consolida los datos de cabecera y detalle de un comprobante
--   específico (@id_venta_consulta).
--   - Vincula Venta, Detalle_Venta, Producto, Empleado y Cliente.
--   - Aplica COALESCE para la sustitución estándar de valores nulos (ventas de mostrador).
--   - Subtotal por renglón y total acumulado blindados aritméticamente frente a nulos.
--   - Pre-agregación en el FROM (tabla derivada) para optimizar el cómputo del total en 1 lectura.
--   - Orden determinista por código de producto.
----------------------------------------------------------------------------------------------------
USE Panaderia_Tortuga;
GO

-- Parámetro de entrada para emitir el comprobante de venta específico
DECLARE @id_venta_consulta INT = 1001;

SELECT 
    v.id_venta AS nro_comprobante,
    
    -- Encabezado: Tratamiento estándar ANSI de valores nulos (COALESCE)
    COALESCE(CONCAT(c.Apellido, ', ', c.Nombre), 'Consumidor Final / Anónimo') AS cliente,
    COALESCE(CAST(c.DNI_cliente AS VARCHAR(20)), 'S/D') AS dni_cliente,
    
    -- Encabezado: Atributos de auditoría del personal de despacho
    CONCAT(e.Apellido, ', ', e.Nombre) AS atendido_por,
    e.Turno_Laboral AS turno_empleado,
    
    -- Detalle: Renglón de artículos
    p.id_producto AS cod_producto,
    p.nombre AS descripcion_articulo,
    dv.cantidad AS cantidad,
    dv.precio_unitario AS precio_unitario_historico,
    
    -- Subtotal por renglón con casteo numérico y protección ante nulos
    CAST((COALESCE(dv.cantidad, 0) * COALESCE(dv.precio_unitario, 0)) AS DECIMAL(12,2)) AS subtotal_renglon,
    
    -- Total acumulado obtenido de la tabla derivada (calculado una sola vez en memoria)
    tot.total_comprobante

-- Origen relacional y combinaciones explícitas con AS
FROM [Venta] AS v
INNER JOIN [Detalle_Venta] AS dv 
    ON v.id_venta = dv.id_venta
INNER JOIN [Producto] AS p 
    ON dv.id_producto = p.id_producto
INNER JOIN [Empleado] AS e 
    ON v.DNI_empleado = e.DNI_empleado
LEFT JOIN [Cliente] AS c 
    ON v.DNI_cliente = c.DNI_cliente

-- Optimización: Pre-agregación en el FROM que evita re-escanear la tabla fila a fila
INNER JOIN (
    SELECT 
        d2.id_venta, 
        CAST(SUM(COALESCE(d2.cantidad, 0) * COALESCE(d2.precio_unitario, 0)) AS DECIMAL(12,2)) AS total_comprobante
    FROM [Detalle_Venta] AS d2
    WHERE d2.id_venta = @id_venta_consulta
    GROUP BY d2.id_venta
) AS tot 
    ON v.id_venta = tot.id_venta

WHERE v.id_venta = @id_venta_consulta
ORDER BY p.id_producto ASC;
GO