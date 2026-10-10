USE Panaderia_Tortuga;
GO

SET LANGUAGE Spanish;
GO
SET DATEFORMAT ymd;
GO

-- Deshabilita todas las restricciones de clave foranea
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";
GO

-- Elimina los datos de todas las tablas
EXEC sp_MSforeachtable "DELETE FROM ?";
GO

-- Vuelve a habilitar y verificar todas las restricciones
EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL";
GO

-- =================================================================================================
-- 1: Tablas Maestras
-- =================================================================================================

INSERT INTO [Categoria] (id_categoria, [descripción]) VALUES
(1, 'Panaderia Tradicional'),
(2, 'Pasteleria y Confiteria'),
(3, 'Facturas y Medialunas'),
(4, 'Especialidades Maduradas'),
(5, 'Sandwicheria y Salados'),
(6, 'Bebidas e Infusiones'),
(7, 'Galleteria Seca'),
(8, 'Tartas y Postres'),
(9, 'Panes Integrales y Semillados'),
(10, 'Snacks y Copetin');

INSERT INTO [Stock] (id_stock, cantidad_actual, stock_minimo) VALUES
(101, 150.00, 25.00),
(102, 120.00, 24.00),
(103, 15.00, 5.00),
(104, 40.00, 10.00),
(105, 85.00, 15.00),
(106, 60.00, 12.00),
(107, 20.00, 5.00),
(108, 90.00, 20.00),
(109, 45.00, 10.00),
(110, 70.00, 15.00);

INSERT INTO [Unidad_Medida] (id_unidadMedida, descripcion, abreviatura) VALUES
(1, 'Kilogramo', 'kg'),
(2, 'Docena', 'doc'),
(3, 'Unidad', 'u'),
(4, 'Gramo', 'g'),
(5, 'Media Docena', 'm_doc'),
(6, 'Litro', 'lt'),
(7, 'Caja', 'cj'),
(8, 'Bolsa', 'bls');

INSERT INTO [Cliente] ([DNI_cliente], [Nombre], [Apellido]) VALUES
(34936602, 'Lucas', 'Zarate'),
(46843173, 'Octavio', 'Dorrego'),
(46717369, 'Kiara', 'Zacarias'),
(29812401, 'Mariana', 'Benitez'),
(38190544, 'Joaquin', 'Romero'),
(41552890, 'Camila', 'Alvarez'),
(33019284, 'Federico', 'Sosa'),
(27441902, 'Estela', 'Navarro'),
(36128471, 'Ignacio', 'Paredes'),
(42890123, 'Lucia', 'Morales');

INSERT INTO [Empleado] ([DNI_empleado], [Nombre], [Apellido], [Turno_Laboral]) VALUES
(28456123, 'Martin', 'Gomez', 'Turno Manana'),
(31789456, 'Valeria', 'Fernandez', 'Turno Tarde'),
(35901234, 'Gonzalo', 'Rios', 'Turno Noche'),
(39120485, 'Sofia', 'Mendez', 'Turno Manana'),
(25410982, 'Claudio', 'Acuna', 'Turno Tarde'),
(37281944, 'Elena', 'Vazquez', 'Turno Manana'),
(40192837, 'Damian', 'Castro', 'Turno Noche'),
(33829104, 'Paula', 'Herrera', 'Turno Tarde');

INSERT INTO [MedioDePago] (id_medioDePago, descripcion) VALUES
(1, 'Efectivo'),
(2, 'Tarjeta de Debito'),
(3, 'Tarjeta de Credito'),
(4, 'Transferencia Bancaria / QR'),
(5, 'Mercado Pago'),
(6, 'Billetera Virtual BNA+'),
(7, 'Cheque al Dia'),
(8, 'Cuenta Corriente Comercial');

INSERT INTO [Promocion] (id_promocion, descripcion, fecha_inicio, fecha_fin) VALUES
(1, 'Super Descuento Docena de Medialunas', '2026-09-01', '2026-10-31'),
(2, 'Fin de Semana Dulce en Confiteria', '2026-09-20', '2026-09-30'),
(3, 'Desayuno Tradicional Panaderia', '2026-10-01', '2026-10-15'),
(4, 'Semana del Sandwich de Miga', '2026-10-05', '2026-10-20'),
(5, 'Promo Merienda de Facturas', '2026-10-01', '2026-10-31'),
(6, 'Descuento Tartas y Postres', '2026-10-08', '2026-10-18'),
(7, 'Especial Madurados de Temporada', '2026-10-01', '2026-11-15'),
(8, 'Sabores Salados de la Tarde', '2026-10-10', '2026-10-25');

-- =================================================================================================
-- 2: Tablas de Segundo Nivel
-- =================================================================================================

INSERT INTO [Producto] (id_producto, nombre, precio_unitario, id_categoria, id_stock) VALUES
(1, 'Pan Frances', 2200.00, 1, 101),
(2, 'Medialunas de Manteca', 600.00, 3, 102),
(3, 'Torta Rogel Artesanal', 18500.00, 2, 103),
(4, 'Panettone Tradicional Madurado', 9500.00, 4, 104),
(5, 'Chipa Tradicional', 800.00, 1, 105),
(6, 'Sandwich de Miga Jamon y Queso', 1400.00, 5, 106),
(7, 'Tarta de Frutillas', 14000.00, 8, 107),
(8, 'Bizcochitos de Grasa', 3200.00, 7, 108),
(9, 'Pan de Campo Integral', 2800.00, 9, 109),
(10, 'Empanada de Carne a Cuchillo', 1600.00, 5, 110);

INSERT INTO [Producto_Unidad] (id_productoUnidad, [conversión], id_producto, id_unidadMedida) VALUES
(1, 1.0000, 1, 1),
(2, 1.0000, 2, 3),
(3, 12.0000, 2, 2),
(4, 1.0000, 3, 3),
(5, 1.0000, 4, 3),
(6, 1.0000, 5, 3),
(7, 12.0000, 5, 2),
(8, 1.0000, 6, 3),
(9, 12.0000, 6, 2),
(10, 1.0000, 7, 3),
(11, 1.0000, 8, 1),
(12, 1.0000, 9, 1);

INSERT INTO [Categoria_Promocion] (id_categoriaPromocion, id_categoria, id_promocion) VALUES
(1, 3, 1),
(2, 2, 2),
(3, 1, 3),
(4, 5, 4),
(5, 3, 5),
(6, 8, 6),
(7, 4, 7),
(8, 5, 8);

-- =================================================================================================
-- 3: Tablas de Tercer Nivel y Transaccionales
-- =================================================================================================

INSERT INTO [Movimiento_Stock] ([id_movimiento-Stock], fecha_hora, tipo_movimiento, cantidad, id_stock) VALUES
(1, '2026-10-01 05:00:00', 'INGRESO', 150.00, 101),
(2, '2026-10-01 05:20:00', 'INGRESO', 120.00, 102),
(3, '2026-10-01 05:40:00', 'INGRESO', 15.00, 103),
(4, '2026-10-01 06:00:00', 'COMPRA', 40.00, 104),
(5, '2026-10-01 06:15:00', 'INGRESO', 85.00, 105),
(6, '2026-10-01 06:30:00', 'INGRESO', 60.00, 106),
(7, '2026-10-01 06:45:00', 'INGRESO', 20.00, 107),
(8, '2026-10-01 07:00:00', 'INGRESO', 90.00, 108),
(9, '2026-10-01 07:15:00', 'INGRESO', 45.00, 109),
(10, '2026-10-01 07:30:00', 'INGRESO', 70.00, 110);

INSERT INTO [Venta] (id_venta, subtotal, DNI_cliente, DNI_empleado) VALUES
(1001, 11600.00, 34936602, 28456123),
(1002, 4400.00, NULL, 31789456),
(1003, 18500.00, 46843173, 28456123),
(1004, 5200.00, 46717369, 39120485),
(1005, 9500.00, 29812401, 31789456),
(1006, 7800.00, NULL, 39120485),
(1007, 19600.00, 38190544, 28456123),
(1008, 3800.00, 41552890, 31789456),
(1009, 14000.00, 33019284, 39120485),
(1010, 6400.00, 27441902, 28456123);

INSERT INTO [Detalle_Venta] (id_venta, id_producto, cantidad, precio_unitario) VALUES
(1001, 1, 2.00, 2200.00),
(1001, 2, 12.00, 600.00),
(1002, 1, 2.00, 2200.00),
(1003, 3, 1.00, 18500.00),
(1004, 5, 4.00, 800.00),
(1004, 1, 0.91, 2200.00),
(1005, 4, 1.00, 9500.00),
(1006, 6, 4.00, 1400.00),
(1006, 1, 1.00, 2200.00),
(1007, 6, 4.00, 1400.00),
(1007, 7, 1.00, 14000.00),
(1008, 8, 1.00, 3200.00),
(1008, 2, 1.00, 600.00),
(1009, 7, 1.00, 14000.00),
(1010, 10, 4.00, 1600.00);

INSERT INTO [Venta_MedioDePago] ([id_venta-MedioDePago], id_venta, id_medioDePago, importe) VALUES
(1, 1001, 1, 5000.00),
(2, 1001, 4, 6600.00),
(3, 1002, 1, 4400.00),
(4, 1003, 3, 18500.00),
(5, 1004, 2, 5200.00),
(6, 1005, 4, 9500.00),
(7, 1006, 1, 7800.00),
(8, 1007, 3, 10000.00),
(9, 1007, 2, 9600.00),
(10, 1008, 1, 3800.00),
(11, 1009, 4, 14000.00),
(12, 1010, 5, 6400.00);
GO