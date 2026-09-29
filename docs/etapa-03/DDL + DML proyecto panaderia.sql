
-- DDL
CREATE DATABASE GESTOR_VENTAS_PANADERIA;

CREATE TABLE EMPLEADO 
(
DNI_empleado int not null,
Nombre varchar (30) not null,
Apellido varchar (30) not null,
Turno_Laboral varchar (50) not null,
CONSTRAINT PK_EMPLEADO PRIMARY KEY (DNI_empleado)
);

CREATE TABLE CLIENTE
(
DNI_cliente int not null,
Nombre varchar (30) not null,
Apellido varchar (30) not null,
CONSTRAINT PK_CLIENTE PRIMARY KEY (DNI_cliente)
);

CREATE TABLE MEDIO_PAGO
(
id_medioPago int not null,
descripcion varchar (50) not null,
CONSTRAINT PK_EMPLEADO PRIMARY KEY (id_medioPago)
);


-- DML
