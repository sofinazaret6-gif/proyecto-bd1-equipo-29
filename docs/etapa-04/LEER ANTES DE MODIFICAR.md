Organización del Trabajo en Equipo (5 Integrantes)
Integrante 1 (Lucas Martín Zárate):

Requerimiento: 1. Factura/Comprobante de Venta.

Archivos a modificar/crear: comprobante_venta.sql y comprobante-venta.md.


Integrante 2: Reporte Agregado por Vendedor
Consigna asignada: Reporte Agregado (variante por vendedor). Total de ventas realizadas por cada vendedor en un rango de fechas.

Operaciones SQL: INNER JOIN entre Empleado, Venta y Detalle_Venta, funciones agregadas SUM y COUNT, agrupamiento por GROUP BY y filtro temporal en WHERE.

Archivos: sql/consultas/reporte_ventas_vendedor.sql y docs/reporte-ventas-vendedor.md.

Integrante 3: Reporte Agregado por Categoría
Consigna asignada: Reporte Agregado (variante por categoría). Total de ventas realizadas por cada categoría de producto en un rango de fechas.

Operaciones SQL: INNER JOIN entre Categoria, Producto y Detalle_Venta, métricas agregadas con SUM y COUNT, agrupamiento por GROUP BY y filtro de rango de fechas.

Archivos: sql/consultas/reporte_ventas_categoria.sql y docs/reporte-ventas-categoria.md.

Integrante 4: Consulta de Negocio Avanzada con HAVING
Consigna asignada: Consulta de Negocio Avanzada (variante agregada). Combinar al menos 3 tablas mediante JOIN y aplicar filtros condicionales con HAVING.

Operaciones SQL: JOIN entre Cliente, Venta y Detalle_Venta (o Producto, Detalle_Venta y Categoria), agrupamiento con GROUP BY y restricción posterior al agregado mediante HAVING (por ejemplo, clientes con facturación acumulada superior a un monto objetivo o categorías con más de N unidades despachadas).

Archivos: sql/consultas/consulta_avanzada_having.sql y docs/consulta-avanzada-having.md.

Integrante 5: Consulta de Negocio Avanzada con Subconsultas
Consigna asignada: Consulta de Negocio Avanzada (variante subconsulta). Combinar al menos 3 tablas mediante JOIN y aplicar filtros condicionales con subconsultas.

Operaciones SQL: JOIN de al menos 3 tablas (Venta, Detalle_Venta, Producto) filtradas condicionalmente mediante una subconsulta no trivial en la cláusula WHERE (por ejemplo, listar transacciones cuyos renglones superen el precio promedio de todos los productos del catálogo o productos que no registran ventas respecto al inventario general).

Archivos: sql/consultas/consulta_avanzada_subconsulta.sql y docs/consulta-avanzada-subconsulta.md