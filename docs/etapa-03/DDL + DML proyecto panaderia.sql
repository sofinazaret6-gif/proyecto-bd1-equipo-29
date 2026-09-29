----------------------------------------------------------------------------------------------------
-- PROYECTO: PANADERÍA TORTUGA
-- ARCHIVO: panaderia_tortuga.sql
-- DIALECTO: Microsoft SQL Server (T-SQL)
-- DESCRIPCIÓN: Implementación del esquema relacional exacto (DDL + DML) 
----------------------------------------------------------------------------------------------------
CREATE DATABASE Panaderia_Tortuga;
GO
USE Panaderia_Tortuga;
GO

-- Creación de Tablas Maestras
CREATE TABLE [Categoria] (
    id_categoria INT NOT NULL,
    [descripción] VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Categoria PRIMARY KEY (id_categoria),
    CONSTRAINT CK_Categoria_Descripcion CHECK (LEN(TRIM([descripción])) > 0)
);
GO

CREATE TABLE [Stock] (
    id_stock INT NOT NULL,
    cantidad_actual DECIMAL(12,2) NOT NULL DEFAULT 0,
    stock_minimo DECIMAL(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT PK_Stock PRIMARY KEY (id_stock),
    CONSTRAINT CK_Stock_CantidadActual CHECK (cantidad_actual >= 0),
    CONSTRAINT CK_Stock_StockMinimo CHECK (stock_minimo >= 0)
);
GO

CREATE TABLE [Unidad_Medida] (
    id_unidadMedida INT NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    abreviatura VARCHAR(10) NOT NULL,
    CONSTRAINT PK_UnidadMedida PRIMARY KEY (id_unidadMedida),
    CONSTRAINT CK_UnidadMedida_Descripcion CHECK (LEN(TRIM(descripcion)) > 0),
    CONSTRAINT CK_UnidadMedida_Abreviatura CHECK (LEN(TRIM(abreviatura)) > 0)
);
GO

CREATE TABLE [Cliente] (
    [DNI_cliente] INT NOT NULL,
    [Nombre] VARCHAR(100) NOT NULL,
    [Apellido] VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY ([DNI_cliente]),
    CONSTRAINT CK_Cliente_DNI CHECK ([DNI_cliente] > 0)
);
GO

CREATE TABLE [Empleado] (
    [DNI_empleado] INT NOT NULL,
    [Nombre] VARCHAR(100) NOT NULL,
    [Apellido] VARCHAR(100) NOT NULL,
    [Turno_Laboral] VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Empleado PRIMARY KEY ([DNI_empleado]),
    CONSTRAINT CK_Empleado_DNI CHECK ([DNI_empleado] > 0),
    CONSTRAINT CK_Empleado_Turno CHECK (LEN(TRIM([Turno_Laboral])) > 0)
);
GO

CREATE TABLE [MedioDePago] (
    id_medioDePago INT NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    CONSTRAINT PK_MedioDePago PRIMARY KEY (id_medioDePago),
    CONSTRAINT CK_MedioDePago_Descripcion CHECK (LEN(TRIM(descripcion)) > 0)
);
GO

CREATE TABLE [Promocion] (
    id_promocion INT NOT NULL,
    descripcion VARCHAR(150) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CONSTRAINT PK_Promocion PRIMARY KEY (id_promocion),
    CONSTRAINT CK_Promocion_Fechas CHECK (fecha_fin >= fecha_inicio)
);
GO

-- =================================================================================================
--  2: 
-- Creación de Tablas de Segundo Nivel y Producto-Unidad (Producto, Producto-Unidad, Venta)
-- =================================================================================================

CREATE TABLE [Producto] (
    id_producto INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    id_categoria INT NOT NULL,
    id_stock INT NOT NULL,
    CONSTRAINT PK_Producto PRIMARY KEY (id_producto),
    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (id_categoria) REFERENCES [Categoria](id_categoria),
    CONSTRAINT FK_Producto_Stock FOREIGN KEY (id_stock) REFERENCES [Stock](id_stock),
    CONSTRAINT UQ_Producto_Stock UNIQUE (id_stock),
    CONSTRAINT CK_Producto_PrecioUnitario CHECK (precio_unitario > 0)
);
GO

CREATE TABLE [Producto_Unidad] (
    id_productoUnidad INT NOT NULL,
    [conversión] DECIMAL(10,4) NOT NULL,
    id_producto INT NOT NULL,
    id_unidadMedida INT NOT NULL,
    CONSTRAINT PK_ProductoUnidad PRIMARY KEY (id_productoUnidad),
    CONSTRAINT FK_ProductoUnidad_Producto FOREIGN KEY (id_producto) REFERENCES [Producto](id_producto),
    CONSTRAINT FK_ProductoUnidad_UnidadMedida FOREIGN KEY (id_unidadMedida) REFERENCES [Unidad-Medida](id_unidadMedida),
    CONSTRAINT UQ_Producto_UnidadMedida UNIQUE (id_producto, id_unidadMedida),
    CONSTRAINT CK_ProductoUnidad_Conversion CHECK ([conversión] > 0)
);
GO

CREATE TABLE [Venta] (
    id_venta INT NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
    DNI_cliente INT NULL,
    DNI_empleado INT NOT NULL,
    CONSTRAINT PK_Venta PRIMARY KEY (id_venta),
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY (DNI_cliente) REFERENCES [Cliente]([DNI_cliente]),
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (DNI_empleado) REFERENCES [Empleado]([DNI_empleado]),
    CONSTRAINT CK_Venta_Subtotal CHECK (subtotal >= 0)
);
GO
