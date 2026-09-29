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

CREATE TABLE [Unidad-Medida] (
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