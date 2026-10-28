
USE Panaderia_Tortuga;
GO

/* =========================================================
   DATOS DE PRUEBA PARA LAS FUNCIONES
   Se modifican fechas de ventas existentes.
   ========================================================= */

UPDATE dbo.Venta
SET fecha = '2026-10-01'
WHERE id_venta = 1001;

UPDATE dbo.Venta
SET fecha = '2026-10-05'
WHERE id_venta = 1002;

UPDATE dbo.Venta
SET fecha = '2026-10-10'
WHERE id_venta = 1003;
GO

-- Verificar las fechas de las ventas.
SELECT
    id_venta,
    subtotal,
    fecha
FROM dbo.Venta
ORDER BY id_venta;
GO
