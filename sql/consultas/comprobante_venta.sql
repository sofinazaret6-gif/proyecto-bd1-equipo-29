USE Panaderia_Tortuga;
GO

-- Parámetro de entrada para emitir el comprobante de venta específico
DECLARE @id_venta_consulta INT = 1001;

SELECT 
    v.id_venta AS nro_comprobante,
    
    -- Manejo estándar ANSI de nulos (COALESCE)
    COALESCE(CONCAT(c.Apellido, ', ', c.Nombre), 'Consumidor Final / Anónimo') AS cliente,
    COALESCE(CAST(c.DNI_cliente AS VARCHAR(20)), 'S/D') AS dni_cliente,
    
    -- Atributos de auditoría de personal
    CONCAT(e.Apellido, ', ', e.Nombre) AS atendido_por,
    e.Turno_Laboral AS turno_empleado,
    
    -- Renglón del detalle de productos
    p.id_producto AS cod_producto,
    p.nombre AS descripcion_articulo,
    dv.cantidad AS cantidad,
    dv.precio_unitario AS precio_unitario_historico,
    
    -- Cálculo de subtotal con casteo numérico estándar
    CAST((dv.cantidad * dv.precio_unitario) AS DECIMAL(12,2)) AS subtotal_renglon,
    
    -- Subconsulta escalar correlacionada estándar ANSI para el total acumulado
    (
        SELECT CAST(SUM(d2.cantidad * d2.precio_unitario) AS DECIMAL(12,2))
        FROM [Detalle_Venta] AS d2
        WHERE d2.id_venta = v.id_venta
    ) AS total_comprobante

-- Declaración explícita de alias con 'AS' en el origen y combinaciones
FROM [Venta] AS v
INNER JOIN [Detalle_Venta] AS dv 
    ON v.id_venta = dv.id_venta
INNER JOIN [Producto] AS p 
    ON dv.id_producto = p.id_producto
INNER JOIN [Empleado] AS e 
    ON v.DNI_empleado = e.DNI_empleado
LEFT JOIN [Cliente] AS c 
    ON v.DNI_cliente = c.DNI_cliente
WHERE v.id_venta = @id_venta_consulta;
GO