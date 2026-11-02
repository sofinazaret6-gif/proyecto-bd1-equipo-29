----------------------------------------------------------------------------------------------------
-- PROYECTO: PANADERÍA TORTUGA
-- ETAPA: Etapa V - Temas Técnicos
-- ARCHIVO: sql/tecnico/funciones/02_pruebas_funciones.sql
-- AUTOR: Sofía Ferretti (DNI: 46718162) - Integrante 3
-- FECHA: 2026-11-01
-- DIALECTO: Microsoft SQL Server (T-SQL)
-- TEMA: Funciones definidas por el usuario (UDF): escalares e Inline Table-Valued
-- OBJETIVO: Demostrar el consumo de las funciones de 01_funciones_negocio.sql.
--           Ejecutar después de 01_funciones_negocio.sql.
-- REQUISITOS CUBIERTOS: Uso en SELECT, en WHERE y con CROSS APPLY.
--           Las pruebas son de solo lectura (no modifican datos).
----------------------------------------------------------------------------------------------------
USE Panaderia_Tortuga;
GO

/* =========================================================
   PRUEBA 1: DURACION EN DIAS DE CADA PROMOCION
   Usa fn_CalcularDiasPeriodo sobre las fechas de vigencia.
   ========================================================= */

SELECT
    id_promocion,
    descripcion,
    fecha_inicio,
    fecha_fin,
    dbo.fn_CalcularDiasPeriodo(fecha_inicio, fecha_fin)
        AS duracion_dias
FROM dbo.Promocion;
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
