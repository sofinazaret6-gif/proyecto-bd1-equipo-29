USE Panaderia_Tortuga;
GO
-- =================================================================================================
-- 1: 
-- Inserción de datos de prueba para tablas maestras y stock (Categorias, Stock, Unidad-Medida, Empleado, Cliente)
-- =================================================================================================

INSERT INTO [Categoria] (id_categoria, [descripción]) VALUES
(1, 'Panadería Tradicional'),
(2, 'Pastelería y Confitería'),
(3, 'Facturas y Medialunas'),
(4, 'Especialidades Maduradas');

INSERT INTO [Stock] (id_stock, cantidad_actual, stock_minimo) VALUES
(101, 150.00, 20.00),
(102, 80.00, 15.00),
(103, 30.00, 5.00),
(104, 50.00, 10.00);

INSERT INTO [Unidad-Medida] (id_unidadMedida, descripcion, abreviatura) VALUES
(1, 'Kilogramo', 'kg'),
(2, 'Docena', 'doc'),
(3, 'Unidad', 'u');

INSERT INTO [Cliente] ([DNI_cliente], [Nombre], [Apellido]) VALUES
(34936602, 'Lucas', 'Zárate'),
(46843173, 'Octavio', 'Dorrego'),
(46717369, 'Kiara', 'Zacarías');

INSERT INTO [Empleado] ([DNI_empleado], [Nombre], [Apellido], [Turno_Laboral]) VALUES
(28456123, 'Martín', 'Gómez', 'Turno Mañana'),
(31789456, 'Valeria', 'Fernández', 'Turno Tarde');

INSERT INTO [MedioDePago] (id_medioDePago, descripcion) VALUES
(1, 'Efectivo'),
(2, 'Tarjeta de Débito'),
(3, 'Tarjeta de Crédito'),
(4, 'Transferencia Bancaria / QR');


-- =================================================================================================
-- 2:
-- Inserción de datos de prueba transaccionales y de relaciones (Productos, Promociones, Ventas, Detalles, Pagos, Movimientos)
-- =================================================================================================

INSERT INTO [Producto] (id_producto, nombre, precio_unitario, id_categoria, id_stock) VALUES
(1, 'Pan Francés', 2200.00, 1, 101),
(2, 'Medialunas de Manteca', 600.00, 3, 102),
(3, 'Torta Rogel Artesanal', 18500.00, 2, 103),
(4, 'Panettone Tradicional Madurado', 9500.00, 4, 104);

INSERT INTO [Producto_Unidad] (id_productoUnidad, [conversión], id_producto, id_unidadMedida) VALUES
(1, 1.0000, 1, 1),
(2, 1.0000, 2, 3),
(3, 12.0000, 2, 2),
(4, 1.0000, 3, 3),
(5, 1.0000, 4, 3);

INSERT INTO [Promocion] (id_promocion, descripcion, fecha_inicio, fecha_fin) VALUES
(1, 'Super Descuento Docena de Medialunas', '2026-09-01', '2026-10-31'),
(2, 'Fin de Semana Dulce en Confitería', '2026-09-20', '2026-09-30');

INSERT INTO [Categoria_Promocion] (id_categoriaPromocion, id_categoria, id_promocion) VALUES
(1, 3, 1),
(2, 2, 2);

INSERT INTO [Movimiento_Stock] ([id_movimiento-Stock], fecha_hora, tipo_movimiento, cantidad, id_stock) VALUES
(1, '2026-09-25 06:00:00', 'INGRESO', 150.00, 101),
(2, '2026-09-25 06:30:00', 'INGRESO', 80.00, 102),
(3, '2026-09-25 07:00:00', 'INGRESO', 30.00, 103),
(4, '2026-09-25 07:15:00', 'COMPRA', 50.00, 104);

INSERT INTO [Venta] (id_venta, subtotal, DNI_cliente, DNI_empleado) VALUES
(1001, 11600.00, 34936602, 28456123),
(1002, 4400.00, NULL, 31789456);

INSERT INTO [Detalle_Venta] (id_venta, id_producto, cantidad, precio_unitario) VALUES
(1001, 1, 2.00, 2200.00),
(1001, 2, 12.00, 600.00),
(1002, 1, 2.00, 2200.00);

INSERT INTO [Venta_MedioDePago] ([id_venta-MedioDePago], id_venta, id_medioDePago, importe) VALUES
(1, 1001, 1, 5000.00),
(2, 1001, 4, 6600.00),
(3, 1002, 1, 4400.00);