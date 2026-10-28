
USE Panaderia_Tortuga;
GO

-- =================================================================================================
-- BLOQUE 1: PROVISIÓN DE IDENTIDADES (LOGIN, USER Y ROL)
-- =================================================================================================

-- 1.1 Creación del LOGIN a nivel servidor para la terminal de cobro
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_cajero')
BEGIN
    CREATE LOGIN [login_cajero] 
    WITH PASSWORD = N'CajeroSeguro_2026!', 
         CHECK_POLICY = OFF, 
         CHECK_EXPIRATION = OFF;
    PRINT '>>> [OK] Login de servidor [login_cajero] creado exitosamente.';
END
ELSE
BEGIN
    PRINT '>>> [INFO] El login [login_cajero] ya existe en el servidor.';
END
GO

-- 1.2 Creación del USUARIO de base de datos vinculado al login de la terminal
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'cajero_pos')
BEGIN
    CREATE USER [cajero_pos] FOR LOGIN [login_cajero];
    PRINT '>>> [OK] Usuario de base de datos [cajero_pos] creado exitosamente.';
END
ELSE
BEGIN
    PRINT '>>> [INFO] El usuario [cajero_pos] ya existe en la base de datos.';
END
GO

-- 1.3 Creación del ROL de base de datos para agrupar las responsabilidades del cajero
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'Rol_Cajero' AND type = 'R')
BEGIN
    CREATE ROLE [Rol_Cajero];
    PRINT '>>> [OK] Rol [Rol_Cajero] creado exitosamente.';
END
ELSE
BEGIN
    PRINT '>>> [INFO] El rol [Rol_Cajero] ya existe.';
END
GO

-- 1.4 Incorporación del usuario al rol de caja
ALTER ROLE [Rol_Cajero] ADD MEMBER [cajero_pos];
PRINT '>>> [OK] Usuario [cajero_pos] incorporado como miembro de [Rol_Cajero].';
GO

-- =================================================================================================
-- BLOQUE 2: ASIGNACIÓN GRANULAR DE PERMISOS (PRINCIPIO DE MENOR PRIVILEGIO)
-- =================================================================================================

-- 2.1 Concesión de permisos estrictamente necesarios (GRANT)
-- El cajero debe registrar ventas, detalles y medios de pago, y consultar datos de consulta rápida.
GRANT SELECT, INSERT ON dbo.[Venta] TO [Rol_Cajero];
GRANT SELECT, INSERT ON dbo.[Detalle_Venta] TO [Rol_Cajero];
GRANT SELECT, INSERT ON dbo.[Venta_MedioDePago] TO [Rol_Cajero];

GRANT SELECT ON dbo.[Producto] TO [Rol_Cajero];
GRANT SELECT ON dbo.[Cliente] TO [Rol_Cajero];
GRANT SELECT ON dbo.[Empleado] TO [Rol_Cajero];
GRANT SELECT ON dbo.[MedioDePago] TO [Rol_Cajero];
GRANT SELECT ON dbo.[Unidad_Medida] TO [Rol_Cajero];
GRANT SELECT ON dbo.[Promocion] TO [Rol_Cajero];
PRINT '>>> [OK] Permisos operativos (GRANT SELECT, INSERT) asignados a [Rol_Cajero].';

-- 2.2 Bloqueo explícito de operaciones destructivas o críticas (DENY)
-- Evita anulación física unilateral de comprobantes o adulteración de precios en catálogo.
DENY DELETE ON dbo.[Detalle_Venta] TO [Rol_Cajero];
DENY DELETE ON dbo.[Venta] TO [Rol_Cajero];
DENY UPDATE, DELETE ON dbo.[Producto] TO [Rol_Cajero];
DENY UPDATE, DELETE ON dbo.[Cliente] TO [Rol_Cajero];
PRINT '>>> [OK] Restricciones explícitas (DENY DELETE, UPDATE) asignadas a [Rol_Cajero].';
GO

-- =================================================================================================
-- BLOQUE 3: ESCENARIO DE DEMOSTRACIÓN Y VALIDACIÓN CRUZADA DE SEGURIDAD (RBAC)
-- =================================================================================================
PRINT '=================================================================================';
PRINT '>>> INICIANDO ESCENARIOS DE DEMOSTRACIÓN DE SEGURIDAD (RBAC) <<<';
PRINT '=================================================================================';
GO

-- -------------------------------------------------------------------------------------------------
-- DEMOSTRACIÓN 1: OPERACIÓN AUTORIZADA - CONSULTA DE CATÁLOGO (SELECT)
-- -------------------------------------------------------------------------------------------------
PRINT '>>> DEMO 1: Consulta de catálogo de productos (Operación Permitida para el cajero)...';

EXECUTE AS USER = 'cajero_pos';
SELECT 
    USER_NAME() AS [Usuario_Activo],
    IS_ROLEMEMBER('Rol_Cajero') AS [Es_Miembro_Rol_Cajero];

SELECT TOP 5 
    id_producto,
    nombre,
    precio_unitario,
    activo
FROM dbo.[Producto];
REVERT;

PRINT '>>> DEMO 1 EXITOSA: El cajero pudo consultar el catálogo correctamente.';
GO

-- -------------------------------------------------------------------------------------------------
-- DEMOSTRACIÓN 2: OPERACIÓN AUTORIZADA - REGISTRO DE VENTA EN MOSTRADOR (INSERT)
-- -------------------------------------------------------------------------------------------------
PRINT '>>> DEMO 2: Emisión y guardado de ticket de venta (Operación Permitida para el cajero)...';

-- Asegurar limpieza previa de la venta demo por si quedó de una corrida anterior
IF EXISTS (SELECT 1 FROM dbo.[Detalle_Venta] WHERE id_venta = 8999)
    DELETE FROM dbo.[Detalle_Venta] WHERE id_venta = 8999;
IF EXISTS (SELECT 1 FROM dbo.[Venta] WHERE id_venta = 8999)
    DELETE FROM dbo.[Venta] WHERE id_venta = 8999;

EXECUTE AS USER = 'cajero_pos';

DECLARE @id_venta_demo INT = 8999;
DECLARE @id_prod_demo INT = 1; -- Pan Francés
DECLARE @precio_demo DECIMAL(12,2) = 2200.00;
DECLARE @cantidad_demo DECIMAL(10,2) = 2.00;

-- 2.a Inserción de cabecera en Venta
INSERT INTO dbo.[Venta] (id_venta, subtotal, DNI_cliente, DNI_empleado, fecha)
VALUES (@id_venta_demo, (@precio_demo * @cantidad_demo), 34936602, 28456123, CAST(GETDATE() AS DATE));

-- 2.b Inserción de renglón en Detalle_Venta
INSERT INTO dbo.[Detalle_Venta] (id_venta, id_producto, cantidad, precio_unitario)
VALUES (@id_venta_demo, @id_prod_demo, @cantidad_demo, @precio_demo);

-- Verificación de lectura de la venta recién creada bajo sesión de cajero
SELECT 
    v.id_venta,
    v.subtotal,
    v.fecha,
    d.id_producto,
    d.cantidad,
    d.precio_unitario
FROM dbo.[Venta] v
INNER JOIN dbo.[Detalle_Venta] d ON v.id_venta = d.id_venta
WHERE v.id_venta = @id_venta_demo;

REVERT;

PRINT '>>> DEMO 2 EXITOSA: Cabecera y renglón insertados correctamente por [cajero_pos].';
GO

-- -------------------------------------------------------------------------------------------------
-- DEMOSTRACIÓN 3: RESTRICCIÓN DE SEGURIDAD - INTENTO DE BORRADO DE DETALLE (DENY DELETE)
-- -------------------------------------------------------------------------------------------------
PRINT '>>> DEMO 3: Intento de borrado físico en Detalle_Venta (Operación Denegada por Seguridad)...';

EXECUTE AS USER = 'cajero_pos';

BEGIN TRY
    -- Intentar borrar el renglón de la venta como cajero
    DELETE FROM dbo.[Detalle_Venta] WHERE id_venta = 8999;
    
    -- Si la línea anterior no falla, el control de acceso falló
    PRINT '>>> ALERTA CRÍTICA: La eliminación fue permitida indebidamente.';
END TRY
BEGIN CATCH
    PRINT '>>> DEMO 3 EXITOSA: El motor SQL Server interceptó y canceló la operación.';
    PRINT '    Código de Error  : ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT '    Detalle del Motor: ' + ERROR_MESSAGE();
END CATCH;

REVERT;
GO

-- -------------------------------------------------------------------------------------------------
-- DEMOSTRACIÓN 4: RESTRICCIÓN DE SEGURIDAD - INTENTO DE ADULTERACIÓN DE PRECIO (DENY UPDATE)
-- -------------------------------------------------------------------------------------------------
PRINT '>>> DEMO 4: Intento de adulteración de precio en Producto (Operación Denegada por Seguridad)...';

EXECUTE AS USER = 'cajero_pos';

BEGIN TRY
    -- Intentar cambiar precio de catálogo como cajero
    UPDATE dbo.[Producto] 
    SET precio_unitario = 10.00 
    WHERE id_producto = 1;
    
    PRINT '>>> ALERTA CRÍTICA: La modificación fue permitida indebidamente.';
END TRY
BEGIN CATCH
    PRINT '>>> DEMO 4 EXITOSA: El motor SQL Server interceptó y canceló la operación.';
    PRINT '    Código de Error  : ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT '    Detalle del Motor: ' + ERROR_MESSAGE();
END CATCH;

REVERT;
GO

-- =================================================================================================
-- BLOQUE 4: LIMPIEZA FINAL DE DATOS DE PRUEBA (COMO ADMINISTRADOR)
-- =================================================================================================

-- Asegurar limpieza administrativa de los registros de prueba generados en la demostración
IF EXISTS (SELECT 1 FROM dbo.[Detalle_Venta] WHERE id_venta = 8999)
BEGIN
    DELETE FROM dbo.[Detalle_Venta] WHERE id_venta = 8999;
END;

IF EXISTS (SELECT 1 FROM dbo.[Venta] WHERE id_venta = 8999)
BEGIN
    DELETE FROM dbo.[Venta] WHERE id_venta = 8999;
END;

PRINT '=================================================================================';
PRINT '>>> [OK] Registros de prueba temporales (id_venta 8999) eliminados como administrador.';
PRINT '>>> [FIN] Demostración de Seguridad completada con éxito.';
PRINT '=================================================================================';
GO
