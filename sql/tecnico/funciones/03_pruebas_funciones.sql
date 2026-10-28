
USE Panaderia_Tortuga;
GO

/* =========================================================
   PRUEBA 1: ANTIGUEDAD DE LOS CLIENTES
   ========================================================= */

SELECT
    DNI_cliente,
    Nombre,
    Apellido,
    fechaRegistro,
    dbo.fn_CalcularAntiguedadCliente(DNI_cliente)
        AS antiguedad_anios
FROM dbo.Cliente;
GO


/* =========================================================
   PRUEBA 2: TOTAL HISTORICO DE COMPRAS POR CLIENTE
   ========================================================= */

SELECT
    DNI_cliente,
    Nombre,
    Apellido,
    dbo.fn_CalcularTotalComprasCliente(DNI_cliente)
        AS total_compras
FROM dbo.Cliente;
GO


/* =========================================================
   PRUEBA 3: USO DE FUNCION ESCALAR EN WHERE
   Clientes que tienen compras registradas.
   ========================================================= */

SELECT
    DNI_cliente,
    Nombre,
    Apellido
FROM dbo.Cliente
WHERE dbo.fn_CalcularTotalComprasCliente(DNI_cliente) > 0;
GO


/* =========================================================
   PRUEBA 4: RESUMEN DE PRODUCTOS VENDIDOS EN OCTUBRE
   ========================================================= */

SELECT
    id_producto,
    producto,
    cantidad_total_vendida,
    importe_total_vendido
FROM dbo.fn_ResumenProductosVendidos
(
    '2026-10-01',
    '2026-10-31'
)
ORDER BY importe_total_vendido DESC;
GO


/* =========================================================
   PRUEBA 5: USO DE CROSS APPLY
   ========================================================= */

DECLARE @fecha_inicio DATE = '2026-10-01';
DECLARE @fecha_fin DATE = '2026-10-31';

SELECT
    resumen.id_producto,
    resumen.producto,
    resumen.cantidad_total_vendida,
    resumen.importe_total_vendido
FROM
(
    SELECT
        @fecha_inicio AS fecha_inicio,
        @fecha_fin AS fecha_fin
) AS periodo
CROSS APPLY dbo.fn_ResumenProductosVendidos
(
    periodo.fecha_inicio,
    periodo.fecha_fin
) AS resumen
ORDER BY resumen.importe_total_vendido DESC;
GO
