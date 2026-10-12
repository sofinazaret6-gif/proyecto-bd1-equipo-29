----------------------------------------------------------------------------------------------------
-- PROYECTO: PANADERÍA TORTUGA
-- ARCHIVO: informe_ventas.sql
-- DIALECTO: Microsoft SQL Server (T-SQL) / ANSI SQL-92 / ANSI SQL-99
-- DESCRIPCIÓN: Consultas de reportería analítica y métricas agregadas de ventas (Etapa IV).
----------------------------------------------------------------------------------------------------
USE Panaderia_Tortuga;
GO

-- =================================================================================================
-- SECCIÓN 1: REPORTE AGREGADO POR VENDEDOR
-- Responsable: Integrante 2
-- Consigna: Total de ventas realizadas por cada vendedor en un rango de fechas.
-- Operaciones SQL:
--   * INNER JOIN entre Empleado, Venta y Detalle_Venta.
--   * Funciones agregadas SUM y COUNT.
--   * Agrupamiento con GROUP BY.
--   * Filtro de rango de fechas en la cláusula WHERE.
-- =================================================================================================

-- Parámetros de entrada para el rango de fechas analizado
DECLARE @fecha_desde DATE = '2026-10-01';
DECLARE @fecha_hasta DATE = '2026-10-31';

SELECT 
    e.DNI_empleado AS dni_empleado,
    CONCAT(e.Apellido, ', ', e.Nombre) AS vendedor,
    e.Turno_Laboral AS turno_empleado,
    
    -- Métricas cuantitativas y agregadas
    COUNT(v.id_venta) AS cantidad_ventas_realizadas,
    COUNT(dv.id_producto) AS cantidad_lineas_despachadas,
    CAST(SUM(dv.cantidad) AS DECIMAL(12,2)) AS total_unidades_despachadas,
    CAST(SUM(dv.cantidad * dv.precio_unitario) AS DECIMAL(12,2)) AS total_ventas_facturado,
    
    -- Ticket promedio por comprobante emitido
    CAST(SUM(dv.cantidad * dv.precio_unitario) / COUNT(v.id_venta) AS DECIMAL(12,2)) AS ticket_promedio

FROM Empleado AS e
INNER JOIN Venta AS v 
    ON e.DNI_empleado = v.DNI_empleado
INNER JOIN Detalle_Venta AS dv 
    ON v.id_venta = dv.id_venta

WHERE v.fecha BETWEEN @fecha_desde AND @fecha_hasta

GROUP BY 
    e.DNI_empleado,
    e.Apellido,
    e.Nombre,
    e.Turno_Laboral

ORDER BY 
    total_ventas_facturado DESC,
    vendedor ASC;

-- =================================================================================================
-- SECCIÓN 2: REPORTE AGREGADO POR CATEGORÍA
-- Responsable: Integrante 3
-- Consigna: Total de ventas realizadas por cada categoría de producto en un rango de fechas.
-- Operaciones SQL:
--   * INNER JOIN entre Categoria, Producto y Detalle_Venta.
--   * Métricas agregadas con SUM y COUNT.
--   * Agrupamiento con GROUP BY y filtro de fechas en WHERE.
-- =================================================================================================
-- (Sección reservada para la implementación correspondiente al Integrante 3)
