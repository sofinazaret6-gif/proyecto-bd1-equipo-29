----------------------------------------------------------------------------------------------------
-- PROYECTO: PANADERÍA TORTUGA
-- ARCHIVO: consulta_avanzada.sql
-- RESPONSABLE: Integrante 4 - Dorrego Octavio
-- DESCRIPCIÓN: Análisis de facturación y compras acumuladas por cliente.
----------------------------------------------------------------------------------------------------

USE Panaderia_Tortuga;
GO

-- Parámetros del análisis
DECLARE @fecha_desde DATE = '2026-10-01';
DECLARE @fecha_hasta DATE = '2026-10-31';
DECLARE @facturacion_minima DECIMAL(12,2) = 10000.00;

SELECT
    c.DNI_cliente AS dni_cliente,
    CONCAT(c.Apellido, ', ', c.Nombre) AS cliente,

    COUNT(DISTINCT v.id_venta) AS cantidad_compras,

    COUNT(dv.id_producto) AS cantidad_lineas_compradas,

    CAST(
        SUM(dv.cantidad)
        AS DECIMAL(12,2)
    ) AS total_unidades_compradas,

    CAST(
        SUM(dv.cantidad * dv.precio_unitario)
        AS DECIMAL(12,2)
    ) AS total_facturado

FROM Cliente AS c

INNER JOIN Venta AS v
    ON c.DNI_cliente = v.DNI_cliente

INNER JOIN Detalle_Venta AS dv
    ON v.id_venta = dv.id_venta

WHERE v.fecha >= @fecha_desde
  AND v.fecha < DATEADD(DAY, 1, @fecha_hasta)

GROUP BY
    c.DNI_cliente,
    c.Nombre,
    c.Apellido

HAVING
    SUM(dv.cantidad * dv.precio_unitario) >= @facturacion_minima

ORDER BY
    total_facturado DESC,
    cliente ASC;
GO