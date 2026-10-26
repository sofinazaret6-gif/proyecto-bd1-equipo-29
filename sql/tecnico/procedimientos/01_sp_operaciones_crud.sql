----------------------------------------------------------------------------------------------------
-- PROYECTO: PANADERÍA TORTUGA
-- ETAPA: Etapa V - Mecanismos Técnicos Avanzados
-- TEMA: Procedimientos Almacenados (Stored Procedures) y Lógica de Servidor


USE Panaderia_Tortuga;
GO

-- =================================================================================================
-- BLOQUE 1: PROCEDIMIENTOS CRUD - ENTIDAD 1: PRODUCTO (CON STOCK ATÓMICO)
-- =================================================================================================

-- 1.1 CREATE: Alta atómica de Producto y su ficha de Stock vinculada (Relación 1:1)
CREATE OR ALTER PROCEDURE dbo.sp_InsertarProducto
    @nombre VARCHAR(100),
    @precio_unitario DECIMAL(12,2),
    @id_categoria INT,
    @stock_inicial DECIMAL(12,2) = 0.00,
    @stock_minimo DECIMAL(12,2) = 5.00,
    @nuevo_id_producto INT OUTPUT,
    @nuevo_id_stock INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones preventivas de negocio
    IF @precio_unitario <= 0
    BEGIN
        THROW 50001, 'El precio unitario del producto debe ser estrictamente mayor a cero.', 1;
    END

    IF @stock_inicial < 0 OR @stock_minimo < 0
    BEGIN
        THROW 50002, 'Las cantidades de stock inicial y mínimo no pueden ser valores negativos.', 1;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Categoria WHERE id_categoria = @id_categoria AND activo = 1)
    BEGIN
        THROW 50003, 'La categoría especificada no existe o se encuentra inactiva.', 1;
    END

    IF EXISTS (SELECT 1 FROM dbo.Producto WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(@nombre)))
    BEGIN
        THROW 50004, 'Ya existe un producto registrado con esa denominación en el catálogo.', 1;
    END

    -- Transacción atómica: Creación de Stock + Producto
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Generación de ID de Stock independiente (Nivel 1)
        SELECT @nuevo_id_stock = COALESCE(MAX(id_stock), 100) + 1 FROM dbo.Stock;

        INSERT INTO dbo.Stock (id_stock, cantidad_actual, stock_minimo)
        VALUES (@nuevo_id_stock, @stock_inicial, @stock_minimo);

        -- Generación de ID de Producto (Nivel 2)
        SELECT @nuevo_id_producto = COALESCE(MAX(id_producto), 0) + 1 FROM dbo.Producto;

        INSERT INTO dbo.Producto (id_producto, nombre, precio_unitario, id_categoria, id_stock, activo)
        VALUES (@nuevo_id_producto, TRIM(@nombre), @precio_unitario, @id_categoria, @nuevo_id_stock, 1);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 1.2 READ: Consulta detallada de producto con categoría y estado de inventario
CREATE OR ALTER PROCEDURE dbo.sp_ConsultarProducto
    @id_producto INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Producto WHERE id_producto = @id_producto)
    BEGIN
        THROW 50005, 'El identificador del producto consultado no existe en el catálogo.', 1;
    END

    SELECT 
        p.id_producto,
        p.nombre,
        p.precio_unitario,
        c.id_categoria,
        c.[descripción] AS categoria,
        s.id_stock,
        s.cantidad_actual AS stock_disponible,
        s.stock_minimo,
        CASE 
            WHEN s.cantidad_actual <= s.stock_minimo THEN 'ALERTA: STOCK CRÍTICO'
            ELSE 'STOCK SUFICIENTE'
        END AS estado_stock,
        p.activo AS estado_producto
    FROM dbo.Producto AS p
    INNER JOIN dbo.Categoria AS c ON p.id_categoria = c.id_categoria
    INNER JOIN dbo.Stock AS s ON p.id_stock = s.id_stock
    WHERE p.id_producto = @id_producto;
END;
GO

-- 1.3 UPDATE: Modificación de precio de lista con auditoría de variación
CREATE OR ALTER PROCEDURE dbo.sp_ModificarPrecioProducto
    @id_producto INT,
    @nuevo_precio DECIMAL(12,2),
    @precio_anterior DECIMAL(12,2) OUTPUT,
    @porcentaje_variacion DECIMAL(6,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Producto WHERE id_producto = @id_producto)
    BEGIN
        THROW 50006, 'El producto a modificar no existe.', 1;
    END

    IF @nuevo_precio <= 0
    BEGIN
        THROW 50007, 'El nuevo precio de lista debe ser mayor a cero.', 1;
    END

    SELECT @precio_anterior = precio_unitario 
    FROM dbo.Producto 
    WHERE id_producto = @id_producto;

    SET @porcentaje_variacion = CAST(((@nuevo_precio - @precio_anterior) / @precio_anterior) * 100.0 AS DECIMAL(6,2));

    UPDATE dbo.Producto
    SET precio_unitario = @nuevo_precio
    WHERE id_producto = @id_producto;
END;
GO

-- 1.4 DELETE (LÓGICO): Baja lógica de producto
CREATE OR ALTER PROCEDURE dbo.sp_EliminarProductoLogico
    @id_producto INT,
    @lineas_historicas INT OUTPUT,
    @resultado VARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Producto WHERE id_producto = @id_producto)
    BEGIN
        THROW 50008, 'El producto a dar de baja no existe en el catálogo.', 1;
    END

    IF (SELECT activo FROM dbo.Producto WHERE id_producto = @id_producto) = 0
    BEGIN
        THROW 50009, 'El producto especificado ya se encuentra dado de baja (inactivo).', 1;
    END

    -- Cuantificar referencias históricas en ventas
    SELECT @lineas_historicas = COUNT(*)
    FROM dbo.Detalle_Venta
    WHERE id_producto = @id_producto;

    UPDATE dbo.Producto
    SET activo = 0
    WHERE id_producto = @id_producto;

    SET @resultado = 'BAJA_LOGICA_EXITOSA';
END;
GO

-- =================================================================================================
-- BLOQUE 2: PROCEDIMIENTOS CRUD - ENTIDAD 2: CLIENTE
-- =================================================================================================

-- 2.1 CREATE: Alta de cliente con verificación preventiva de DNI
CREATE OR ALTER PROCEDURE dbo.sp_InsertarCliente
    @DNI_cliente INT,
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @filas_afectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @DNI_cliente <= 0
    BEGIN
        THROW 50010, 'El número de DNI del cliente debe ser un entero positivo.', 1;
    END

    IF LEN(TRIM(@Nombre)) = 0 OR LEN(TRIM(@Apellido)) = 0
    BEGIN
        THROW 50011, 'El nombre y el apellido del cliente son campos obligatorios y no pueden estar vacíos.', 1;
    END

    IF EXISTS (SELECT 1 FROM dbo.Cliente WHERE DNI_cliente = @DNI_cliente)
    BEGIN
        THROW 50012, 'Ya se encuentra registrado un cliente con el DNI ingresado.', 1;
    END

    INSERT INTO dbo.Cliente (DNI_cliente, Nombre, Apellido, activo)
    VALUES (@DNI_cliente, TRIM(@Nombre), TRIM(@Apellido), 1);

    SET @filas_afectadas = @@ROWCOUNT;
END;
GO

-- 2.2 READ: Consulta de cliente por DNI con métricas de compras acumuladas
CREATE OR ALTER PROCEDURE dbo.sp_ConsultarCliente
    @DNI_cliente INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Cliente WHERE DNI_cliente = @DNI_cliente)
    BEGIN
        THROW 50013, 'El cliente con el DNI indicado no se encuentra registrado.', 1;
    END

    SELECT 
        c.DNI_cliente,
        c.Nombre,
        c.Apellido,
        c.activo AS estado_cliente,
        COUNT(v.id_venta) AS compras_totales_registradas,
        COALESCE(SUM(v.subtotal), 0.00) AS total_facturado_historico
    FROM dbo.Cliente AS c
    LEFT JOIN dbo.Venta AS v ON c.DNI_cliente = v.DNI_cliente
    WHERE c.DNI_cliente = @DNI_cliente
    GROUP BY c.DNI_cliente, c.Nombre, c.Apellido, c.activo;
END;
GO

-- 2.3 UPDATE: Modificación de datos personales de cliente
CREATE OR ALTER PROCEDURE dbo.sp_ModificarCliente
    @DNI_cliente INT,
    @NuevoNombre VARCHAR(100),
    @NuevoApellido VARCHAR(100),
    @filas_afectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Cliente WHERE DNI_cliente = @DNI_cliente)
    BEGIN
        THROW 50014, 'El cliente a modificar no existe.', 1;
    END

    IF LEN(TRIM(@NuevoNombre)) = 0 OR LEN(TRIM(@NuevoApellido)) = 0
    BEGIN
        THROW 50015, 'Los nuevos valores de nombre y apellido no pueden ser cadenas vacías.', 1;
    END

    UPDATE dbo.Cliente
    SET Nombre = TRIM(@NuevoNombre),
        Apellido = TRIM(@NuevoApellido)
    WHERE DNI_cliente = @DNI_cliente;

    SET @filas_afectadas = @@ROWCOUNT;
END;
GO

-- 2.4 DELETE (LÓGICO): Baja lógica de cliente con auditoría de ventas vinculadas
CREATE OR ALTER PROCEDURE dbo.sp_EliminarClienteLogico
    @DNI_cliente INT,
    @ventas_asociadas INT OUTPUT,
    @estado_resultado VARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Cliente WHERE DNI_cliente = @DNI_cliente)
    BEGIN
        THROW 50016, 'El cliente indicado no se encuentra registrado.', 1;
    END

    IF (SELECT activo FROM dbo.Cliente WHERE DNI_cliente = @DNI_cliente) = 0
    BEGIN
        THROW 50017, 'El cliente ya se encuentra inhabilitado (baja lógica aplicada previamente).', 1;
    END

    -- Cuantificar ventas históricas para proteger la integridad del comprobante fiscal
    SELECT @ventas_asociadas = COUNT(*)
    FROM dbo.Venta
    WHERE DNI_cliente = @DNI_cliente;

    UPDATE dbo.Cliente
    SET activo = 0
    WHERE DNI_cliente = @DNI_cliente;

    SET @estado_resultado = 'BAJA_LOGICA_APLICADA';
END;
GO

-- =================================================================================================
-- BLOQUE 3: PROCEDIMIENTOS CRUD - ENTIDAD 3: EMPLEADO
-- =================================================================================================

-- 3.1 CREATE: Alta de empleado de mostrador
CREATE OR ALTER PROCEDURE dbo.sp_InsertarEmpleado
    @DNI_empleado INT,
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @Turno_Laboral VARCHAR(50),
    @filas_afectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @DNI_empleado <= 0
    BEGIN
        THROW 50020, 'El DNI del empleado debe ser mayor a cero.', 1;
    END

    IF LEN(TRIM(@Nombre)) = 0 OR LEN(TRIM(@Apellido)) = 0 OR LEN(TRIM(@Turno_Laboral)) = 0
    BEGIN
        THROW 50021, 'Nombre, apellido y turno laboral son obligatorios.', 1;
    END

    IF EXISTS (SELECT 1 FROM dbo.Empleado WHERE DNI_empleado = @DNI_empleado)
    BEGIN
        THROW 50022, 'Ya existe un empleado dado de alta con ese número de documento.', 1;
    END

    INSERT INTO dbo.Empleado (DNI_empleado, Nombre, Apellido, Turno_Laboral, activo)
    VALUES (@DNI_empleado, TRIM(@Nombre), TRIM(@Apellido), TRIM(@Turno_Laboral), 1);

    SET @filas_afectadas = @@ROWCOUNT;
END;
GO

-- 3.2 READ: Consulta de empleado por DNI
CREATE OR ALTER PROCEDURE dbo.sp_ConsultarEmpleado
    @DNI_empleado INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE DNI_empleado = @DNI_empleado)
    BEGIN
        THROW 50023, 'El empleado consultado no existe.', 1;
    END

    SELECT 
        e.DNI_empleado,
        e.Nombre,
        e.Apellido,
        e.Turno_Laboral,
        e.activo AS estado_empleado,
        COUNT(v.id_venta) AS ventas_atendidas
    FROM dbo.Empleado AS e
    LEFT JOIN dbo.Venta AS v ON e.DNI_empleado = v.DNI_empleado
    WHERE e.DNI_empleado = @DNI_empleado
    GROUP BY e.DNI_empleado, e.Nombre, e.Apellido, e.Turno_Laboral, e.activo;
END;
GO

-- 3.3 UPDATE: Modificación de turno laboral de empleado
CREATE OR ALTER PROCEDURE dbo.sp_ModificarEmpleadoTurno
    @DNI_empleado INT,
    @NuevoTurno VARCHAR(50),
    @filas_afectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE DNI_empleado = @DNI_empleado)
    BEGIN
        THROW 50024, 'El empleado a modificar no existe.', 1;
    END

    IF LEN(TRIM(@NuevoTurno)) = 0
    BEGIN
        THROW 50025, 'El turno laboral no puede ser una cadena vacía.', 1;
    END

    UPDATE dbo.Empleado
    SET Turno_Laboral = TRIM(@NuevoTurno)
    WHERE DNI_empleado = @DNI_empleado;

    SET @filas_afectadas = @@ROWCOUNT;
END;
GO

-- 3.4 DELETE (LÓGICO): Baja lógica de empleado
CREATE OR ALTER PROCEDURE dbo.sp_EliminarEmpleadoLogico
    @DNI_empleado INT,
    @ventas_auditadas INT OUTPUT,
    @estado_resultado VARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE DNI_empleado = @DNI_empleado)
    BEGIN
        THROW 50026, 'El empleado no se encuentra registrado.', 1;
    END

    IF (SELECT activo FROM dbo.Empleado WHERE DNI_empleado = @DNI_empleado) = 0
    BEGIN
        THROW 50027, 'El empleado ya se encuentra inactivo.', 1;
    END

    SELECT @ventas_auditadas = COUNT(*)
    FROM dbo.Venta
    WHERE DNI_empleado = @DNI_empleado;

    UPDATE dbo.Empleado
    SET activo = 0
    WHERE DNI_empleado = @DNI_empleado;

    SET @estado_resultado = 'BAJA_LOGICA_APLICADA';
END;
GO

-- =================================================================================================
-- BLOQUE 4: PROCEDIMIENTOS CRUD - ENTIDAD 4: CATEGORÍA
-- =================================================================================================

-- 4.1 CREATE: Alta de categoría comercial
CREATE OR ALTER PROCEDURE dbo.sp_InsertarCategoria
    @descripcion VARCHAR(100),
    @nueva_id_categoria INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(TRIM(@descripcion)) = 0
    BEGIN
        THROW 50030, 'La descripción de la categoría no puede ser vacía.', 1;
    END

    IF EXISTS (SELECT 1 FROM dbo.Categoria WHERE LOWER(TRIM([descripción])) = LOWER(TRIM(@descripcion)))
    BEGIN
        THROW 50031, 'Ya existe una categoría registrada con esa denominación.', 1;
    END

    SELECT @nueva_id_categoria = COALESCE(MAX(id_categoria), 0) + 1 FROM dbo.Categoria;

    INSERT INTO dbo.Categoria (id_categoria, [descripción], activo)
    VALUES (@nueva_id_categoria, TRIM(@descripcion), 1);
END;
GO

-- 4.2 READ: Consulta de categoría y total de productos asignados
CREATE OR ALTER PROCEDURE dbo.sp_ConsultarCategoria
    @id_categoria INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Categoria WHERE id_categoria = @id_categoria)
    BEGIN
        THROW 50032, 'La categoría solicitada no existe.', 1;
    END

    SELECT 
        c.id_categoria,
        c.[descripción] AS descripcion_categoria,
        c.activo AS estado_categoria,
        COUNT(p.id_producto) AS productos_asignados
    FROM dbo.Categoria AS c
    LEFT JOIN dbo.Producto AS p ON c.id_categoria = p.id_categoria
    WHERE c.id_categoria = @id_categoria
    GROUP BY c.id_categoria, c.[descripción], c.activo;
END;
GO

-- 4.3 UPDATE: Modificación de descripción de categoría
CREATE OR ALTER PROCEDURE dbo.sp_ModificarCategoria
    @id_categoria INT,
    @nueva_descripcion VARCHAR(100),
    @filas_afectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Categoria WHERE id_categoria = @id_categoria)
    BEGIN
        THROW 50033, 'La categoría a modificar no existe.', 1;
    END

    IF LEN(TRIM(@nueva_descripcion)) = 0
    BEGIN
        THROW 50034, 'La nueva descripción no puede ser vacía.', 1;
    END

    UPDATE dbo.Categoria
    SET [descripción] = TRIM(@nueva_descripcion)
    WHERE id_categoria = @id_categoria;

    SET @filas_afectadas = @@ROWCOUNT;
END;
GO

-- 4.4 DELETE (LÓGICO): Baja lógica de categoría
CREATE OR ALTER PROCEDURE dbo.sp_EliminarCategoriaLogica
    @id_categoria INT,
    @productos_vinculados INT OUTPUT,
    @resultado VARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Categoria WHERE id_categoria = @id_categoria)
    BEGIN
        THROW 50035, 'La categoría a eliminar no existe.', 1;
    END

    IF (SELECT activo FROM dbo.Categoria WHERE id_categoria = @id_categoria) = 0
    BEGIN
        THROW 50036, 'La categoría ya se encuentra inactiva.', 1;
    END

    SELECT @productos_vinculados = COUNT(*)
    FROM dbo.Producto
    WHERE id_categoria = @id_categoria AND activo = 1;

    -- Si tiene productos activos vinculados, alertar pero aplicar baja lógica
    UPDATE dbo.Categoria
    SET activo = 0
    WHERE id_categoria = @id_categoria;

    SET @resultado = 'BAJA_LOGICA_CATEGORIA_EXITOSA';
END;
GO

-- =================================================================================================
-- BLOQUE 5: PROCEDIMIENTOS CRUD - ENTIDAD 5: PROMOCIÓN
-- =================================================================================================

-- 5.1 CREATE: Alta de promoción comercial temporal
CREATE OR ALTER PROCEDURE dbo.sp_InsertarPromocion
    @descripcion VARCHAR(150),
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @nueva_id_promocion INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(TRIM(@descripcion)) = 0
    BEGIN
        THROW 50040, 'La descripción de la promoción es obligatoria.', 1;
    END

    IF @fecha_fin < @fecha_inicio
    BEGIN
        THROW 50041, 'La fecha de fin de la promoción no puede ser anterior a la fecha de inicio.', 1;
    END

    SELECT @nueva_id_promocion = COALESCE(MAX(id_promocion), 0) + 1 FROM dbo.Promocion;

    INSERT INTO dbo.Promocion (id_promocion, descripcion, fecha_inicio, fecha_fin, activo)
    VALUES (@nueva_id_promocion, TRIM(@descripcion), @fecha_inicio, @fecha_fin, 1);
END;
GO

-- 5.2 READ: Consulta de promoción y vigencia
CREATE OR ALTER PROCEDURE dbo.sp_ConsultarPromocion
    @id_promocion INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Promocion WHERE id_promocion = @id_promocion)
    BEGIN
        THROW 50042, 'La promoción consultada no existe.', 1;
    END

    SELECT 
        id_promocion,
        descripcion,
        fecha_inicio,
        fecha_fin,
        activo AS estado_promocion,
        CASE 
            WHEN CAST(GETDATE() AS DATE) BETWEEN fecha_inicio AND fecha_fin AND activo = 1 THEN 'VIGENTE'
            WHEN CAST(GETDATE() AS DATE) < fecha_inicio AND activo = 1 THEN 'PROGRAMADA'
            ELSE 'VENCIDA / INACTIVA'
        END AS estado_vigencia
    FROM dbo.Promocion
    WHERE id_promocion = @id_promocion;
END;
GO

-- 5.3 UPDATE: Extensión o ajuste del período de vigencia de una promoción
CREATE OR ALTER PROCEDURE dbo.sp_ModificarPromocionFechas
    @id_promocion INT,
    @nueva_fecha_inicio DATE,
    @nueva_fecha_fin DATE,
    @filas_afectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Promocion WHERE id_promocion = @id_promocion)
    BEGIN
        THROW 50043, 'La promoción a modificar no existe.', 1;
    END

    IF @nueva_fecha_fin < @nueva_fecha_inicio
    BEGIN
        THROW 50044, 'La fecha final no puede ser previa a la fecha inicial.', 1;
    END

    UPDATE dbo.Promocion
    SET fecha_inicio = @nueva_fecha_inicio,
        fecha_fin = @nueva_fecha_fin
    WHERE id_promocion = @id_promocion;

    SET @filas_afectadas = @@ROWCOUNT;
END;
GO

-- 5.4 DELETE (LÓGICO): Baja lógica de promoción
CREATE OR ALTER PROCEDURE dbo.sp_EliminarPromocionLogica
    @id_promocion INT,
    @resultado VARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Promocion WHERE id_promocion = @id_promocion)
    BEGIN
        THROW 50045, 'La promoción a deshabilitar no existe.', 1;
    END

    IF (SELECT activo FROM dbo.Promocion WHERE id_promocion = @id_promocion) = 0
    BEGIN
        THROW 50046, 'La promoción ya se encuentra inactiva.', 1;
    END

    UPDATE dbo.Promocion
    SET activo = 0
    WHERE id_promocion = @id_promocion;

    SET @resultado = 'PROMOCION_INACTIVADA_EXITOSAMENTE';
END;
GO

-- =================================================================================================
-- BLOQUE 6: PROCEDIMIENTOS CRUD - ENTIDAD 6: MEDIO DE PAGO
-- =================================================================================================

-- 6.1 CREATE: Alta de medio de pago
CREATE OR ALTER PROCEDURE dbo.sp_InsertarMedioDePago
    @descripcion VARCHAR(50),
    @nuevo_id_medioDePago INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(TRIM(@descripcion)) = 0
    BEGIN
        THROW 50050, 'La denominación del medio de pago no puede estar vacía.', 1;
    END

    IF EXISTS (SELECT 1 FROM dbo.MedioDePago WHERE LOWER(TRIM(descripcion)) = LOWER(TRIM(@descripcion)))
    BEGIN
        THROW 50051, 'Ya existe ese medio de pago registrado en el catálogo.', 1;
    END

    SELECT @nuevo_id_medioDePago = COALESCE(MAX(id_medioDePago), 0) + 1 FROM dbo.MedioDePago;

    INSERT INTO dbo.MedioDePago (id_medioDePago, descripcion, activo)
    VALUES (@nuevo_id_medioDePago, TRIM(@descripcion), 1);
END;
GO

-- 6.2 READ: Consulta de medio de pago con estadísticas de recaudación
CREATE OR ALTER PROCEDURE dbo.sp_ConsultarMedioDePago
    @id_medioDePago INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.MedioDePago WHERE id_medioDePago = @id_medioDePago)
    BEGIN
        THROW 50052, 'El medio de pago solicitado no existe.', 1;
    END

    SELECT 
        m.id_medioDePago,
        m.descripcion,
        m.activo AS estado_medio,
        COUNT(vmp.[id_venta-MedioDePago]) AS cobros_realizados,
        COALESCE(SUM(vmp.importe), 0.00) AS total_recaudado
    FROM dbo.MedioDePago AS m
    LEFT JOIN dbo.Venta_MedioDePago AS vmp ON m.id_medioDePago = vmp.id_medioDePago
    WHERE m.id_medioDePago = @id_medioDePago
    GROUP BY m.id_medioDePago, m.descripcion, m.activo;
END;
GO

-- 6.3 UPDATE: Modificación de descripción de medio de pago
CREATE OR ALTER PROCEDURE dbo.sp_ModificarMedioDePago
    @id_medioDePago INT,
    @nueva_descripcion VARCHAR(50),
    @filas_afectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.MedioDePago WHERE id_medioDePago = @id_medioDePago)
    BEGIN
        THROW 50053, 'El medio de pago a modificar no existe.', 1;
    END

    IF LEN(TRIM(@nueva_descripcion)) = 0
    BEGIN
        THROW 50054, 'La nueva descripción no puede ser una cadena vacía.', 1;
    END

    UPDATE dbo.MedioDePago
    SET descripcion = TRIM(@nueva_descripcion)
    WHERE id_medioDePago = @id_medioDePago;

    SET @filas_afectadas = @@ROWCOUNT;
END;
GO

-- 6.4 DELETE (LÓGICO): Baja lógica de medio de pago
CREATE OR ALTER PROCEDURE dbo.sp_EliminarMedioDePagoLogico
    @id_medioDePago INT,
    @pagos_historicos INT OUTPUT,
    @resultado VARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.MedioDePago WHERE id_medioDePago = @id_medioDePago)
    BEGIN
        THROW 50055, 'El medio de pago a inactivar no existe.', 1;
    END

    IF (SELECT activo FROM dbo.MedioDePago WHERE id_medioDePago = @id_medioDePago) = 0
    BEGIN
        THROW 50056, 'El medio de pago ya se encuentra inactivo.', 1;
    END

    SELECT @pagos_historicos = COUNT(*)
    FROM dbo.Venta_MedioDePago
    WHERE id_medioDePago = @id_medioDePago;

    UPDATE dbo.MedioDePago
    SET activo = 0
    WHERE id_medioDePago = @id_medioDePago;

    SET @resultado = 'MEDIO_DE_PAGO_INACTIVADO';
END;
GO

-- =================================================================================================
-- BLOQUE 7: DEMOSTRACIÓN PRÁCTICA Y SUITE DE PRUEBAS UNITARIAS
-- =================================================================================================

PRINT '====================================================================================================';
PRINT 'INICIANDO SUITE DE PRUEBAS UNITARIAS DE PROCEDIMIENTOS ALMACENADOS CRUD';
PRINT '====================================================================================================';

-- 7.1 Prueba: Alta de Producto con Stock Atómico (Éxito y Captura de OUTPUT)
DECLARE @id_prod_test INT, @id_stock_test INT;
EXEC dbo.sp_InsertarProducto
    @nombre = 'Pan de Centeno Artesanal Especial',
    @precio_unitario = 3200.00,
    @id_categoria = 1,
    @stock_inicial = 50.00,
    @stock_minimo = 10.00,
    @nuevo_id_producto = @id_prod_test OUTPUT,
    @nuevo_id_stock = @id_stock_test OUTPUT;

PRINT CONCAT('✔ [EXITO sp_InsertarProducto] Nuevo Producto ID: ', @id_prod_test, ' | Stock ID: ', @id_stock_test);

-- 7.2 Prueba: Consulta de Producto
EXEC dbo.sp_ConsultarProducto @id_producto = @id_prod_test;

-- 7.3 Prueba: Modificación de Precio con Variación Porcentual
DECLARE @p_ant DECIMAL(12,2), @p_var DECIMAL(6,2);
EXEC dbo.sp_ModificarPrecioProducto
    @id_producto = @id_prod_test,
    @nuevo_precio = 3680.00,
    @precio_anterior = @p_ant OUTPUT,
    @porcentaje_variacion = @p_var OUTPUT;

PRINT CONCAT('✔ [EXITO sp_ModificarPrecioProducto] Precio Ant: $', @p_ant, ' -> Var: ', @p_var, '%');

-- 7.4 Prueba: Baja Lógica de Producto
DECLARE @lineas_hist INT, @res_baja VARCHAR(50);
EXEC dbo.sp_EliminarProductoLogico
    @id_producto = @id_prod_test,
    @lineas_historicas = @lineas_hist OUTPUT,
    @resultado = @res_baja OUTPUT;

PRINT CONCAT('✔ [EXITO sp_EliminarProductoLogico] Estado: ', @res_baja, ' | Líneas en Venta: ', @lineas_hist);

-- 7.5 Prueba: Validación Preventiva de Error (Precio negativo)
BEGIN TRY
    EXEC dbo.sp_InsertarProducto
        @nombre = 'Producto Invalido',
        @precio_unitario = -500.00,
        @id_categoria = 1,
        @nuevo_id_producto = @id_prod_test OUTPUT,
        @nuevo_id_stock = @id_stock_test OUTPUT;
END TRY
BEGIN CATCH
    PRINT CONCAT('✔ [TEST CONTROLADO PREVENTIVO] Error capturado correctamente: ', ERROR_MESSAGE());
END CATCH;

-- 7.6 Prueba: Baja Lógica de Cliente existente con ventas históricas
DECLARE @v_asoc INT, @est_res VARCHAR(50);
EXEC dbo.sp_EliminarClienteLogico
    @DNI_cliente = 34936602,
    @ventas_asociadas = @v_asoc OUTPUT,
    @estado_resultado = @est_res OUTPUT;

PRINT CONCAT('✔ [EXITO sp_EliminarClienteLogico] Cliente 34936602 -> Ventas Protegidas: ', @v_asoc, ' | Res: ', @est_res);

-- Revertir el cliente a activo para no alterar el dataset de los demás compañeros
UPDATE dbo.Cliente SET activo = 1 WHERE DNI_cliente = 34936602;
GO

-- =================================================================================================
-- BLOQUE 8: PRUEBA COMPARATIVA DE EFICIENCIA / LOTE (BENCHMARK 100 INSERCIONES)
-- Requerimiento formal: Comparar tiempo y plan de ejecución de 100 inserciones directas
--                      frente a 100 ejecuciones mediante Stored Procedure.
-- =================================================================================================

PRINT '====================================================================================================';
PRINT 'INICIANDO BENCHMARK COMPARATIVO: 100 INSERCIONES DIRECTAS VS 100 VÍA STORED PROCEDURE';
PRINT '====================================================================================================';

-- 1. Tabla de aislamiento para el benchmark
IF OBJECT_ID('dbo.Prueba_Benchmark_SP', 'U') IS NOT NULL
    DROP TABLE dbo.Prueba_Benchmark_SP;
GO

CREATE TABLE dbo.Prueba_Benchmark_SP (
    id INT NOT NULL PRIMARY KEY,
    concepto VARCHAR(100) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    fecha DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 2. Stored Procedure compilado para el benchmark
CREATE OR ALTER PROCEDURE dbo.sp_InsertarLoteBenchmark
    @id INT,
    @concepto VARCHAR(100),
    @monto DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Prueba_Benchmark_SP (id, concepto, monto)
    VALUES (@id, @concepto, @monto);
END;
GO

-- 3. Experimento A: 100 Inserciones Directas (T-SQL Ad-hoc)
TRUNCATE TABLE dbo.Prueba_Benchmark_SP;

DECLARE @inicio_directo DATETIME2 = SYSDATETIME();
DECLARE @i INT = 1;

WHILE @i <= 100
BEGIN
    INSERT INTO dbo.Prueba_Benchmark_SP (id, concepto, monto)
    VALUES (@i, CONCAT('Registro AdHoc Lote ', @i), @i * 15.50);
    SET @i = @i + 1;
END;

DECLARE @fin_directo DATETIME2 = SYSDATETIME();
DECLARE @ms_directo INT = DATEDIFF(MILLISECOND, @inicio_directo, @fin_directo);

-- 4. Experimento B: 100 Inserciones mediante Stored Procedure compilado
TRUNCATE TABLE dbo.Prueba_Benchmark_SP;

DECLARE @inicio_sp DATETIME2 = SYSDATETIME();
DECLARE @j INT = 1;

WHILE @j <= 100
BEGIN
    EXEC dbo.sp_InsertarLoteBenchmark
        @id = @j,
        @concepto = 'Registro Vía SP Compilado',
        @monto = 150.00;
    SET @j = @j + 1;
END;

DECLARE @fin_sp DATETIME2 = SYSDATETIME();
DECLARE @ms_sp INT = DATEDIFF(MILLISECOND, @inicio_sp, @fin_sp);

-- 5. Publicación de resultados comparativos
SELECT 
    '100 Inserciones Directas (T-SQL Ad-hoc)' AS Metodo_Ejecucion,
    @ms_directo AS Tiempo_Milisegundos,
    'Requiere análisis sintáctico y compilación/evaluación repetida en motor' AS Comportamiento_Motor
UNION ALL
SELECT 
    '100 Inserciones con Stored Procedure',
    @ms_sp,
    'Reutiliza el Plan Cache precompilado y minimiza sobrecarga de procesamiento';

-- 6. Limpieza del entorno de benchmark
DROP TABLE dbo.Prueba_Benchmark_SP;
DROP PROCEDURE dbo.sp_InsertarLoteBenchmark;
GO

PRINT '====================================================================================================';
PRINT 'BENCHMARK FINALIZADO Y SCRIPT EJECUTADO CON ÉXITO';
PRINT '====================================================================================================';
