----------------------------------------------------------------------------------------------------
-- PROYECTO: PANADERÍA TORTUGA
-- ETAPA: Etapa V - Temas Técnicos
-- ARCHIVO: sql/tecnico/funciones/01_funciones_negocio.sql
-- AUTOR: Sofía Ferretti (DNI: 46718162) - Integrante 3
-- FECHA: 2026-11-01
-- DIALECTO: Microsoft SQL Server (T-SQL)
-- TEMA: Funciones definidas por el usuario (UDF): escalares e Inline Table-Valued
-- OBJETIVO: Modularizar cálculos repetitivos del negocio (total de compras por cliente,
--           duración de períodos, resumen de ventas por producto) sin duplicar lógica.
-- REQUISITOS CUBIERTOS: 2 funciones escalares (fn_CalcularTotalComprasCliente,
--           fn_CalcularDiasPeriodo) + 1 Inline Table-Valued Function
--           (fn_ResumenProductosVendidos). Script idempotente (CREATE OR ALTER).
----------------------------------------------------------------------------------------------------
USE Panaderia_Tortuga;
GO

/* =========================================================
   FUNCION 1: TOTAL HISTORICO DE COMPRAS DEL CLIENTE
   Tipo: Escalar
   Devuelve el importe total de las compras de un cliente.
   ========================================================= */

CREATE OR ALTER FUNCTION dbo.fn_CalcularTotalComprasCliente
(
    @DNI_cliente INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @total DECIMAL(12,2);

    SELECT @total = COALESCE(SUM(subtotal), 0)
    FROM dbo.Venta
    WHERE DNI_cliente = @DNI_cliente;

    RETURN @total;
END;
GO


/* =========================================================
   FUNCION 2: CALCULAR DIAS ENTRE DOS FECHAS
   Tipo: Escalar
   Devuelve la cantidad de dias entre dos fechas.
   ========================================================= */

CREATE OR ALTER FUNCTION dbo.fn_CalcularDiasPeriodo
(
    @fecha_inicio DATE,
    @fecha_fin DATE
)
RETURNS INT
AS
BEGIN
    IF @fecha_inicio IS NULL OR @fecha_fin IS NULL
        RETURN NULL;

    RETURN DATEDIFF(DAY, @fecha_inicio, @fecha_fin);
END;
GO


/* =========================================================
   FUNCION 3: RESUMEN DE PRODUCTOS VENDIDOS POR PERIODO
   Tipo: Inline Table-Valued Function
   Devuelve cantidad e importe vendido por producto.
   ========================================================= */

CREATE OR ALTER FUNCTION dbo.fn_ResumenProductosVendidos
(
    @fecha_inicio DATE,
    @fecha_fin DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.id_producto,
        p.nombre AS producto,
        SUM(dv.cantidad) AS cantidad_total_vendida,
        SUM(dv.cantidad * dv.precio_unitario)
            AS importe_total_vendido
    FROM dbo.Detalle_Venta AS dv
    INNER JOIN dbo.Venta AS v
        ON dv.id_venta = v.id_venta
    INNER JOIN dbo.Producto AS p
        ON dv.id_producto = p.id_producto
    WHERE v.fecha >= @fecha_inicio
      AND v.fecha < DATEADD(DAY, 1, @fecha_fin)
    GROUP BY
        p.id_producto,
        p.nombre
);
GO
