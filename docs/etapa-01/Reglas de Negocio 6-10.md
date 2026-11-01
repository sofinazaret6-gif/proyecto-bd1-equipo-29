 # Reglas de Negocio 6-10

# RN.06: Identificación de Comprobantes de Venta
Cada venta genera un único comprobante o ticket que sirve como respaldo de la operación. Este ticket vincula obligatoriamente a un único empleado como responsable de la atención, además de registrar la fecha, hora y el detalle consolidado de los productos y cantidades adquiridas.

## RN.07: Reposición de Stock
Toda reposición de mercadería (producción propia o compra) se registra como un movimiento de ingreso (`INGRESO` o `COMPRA`) sobre la ficha de stock del producto, con su fecha, hora y cantidad, incrementando el inventario disponible. La gestión de proveedores, órdenes de compra y costos de adquisición queda fuera del alcance del sistema.

## RN.08: Restricción de Stock y Consistencia
Cada ítem de venta debe validar la existencia de stock disponible para el producto correspondiente. No es posible confirmar una línea de venta si la cantidad solicitada supera el inventario actual registrado en la ficha del producto, manteniendo así la integridad física de las transacciones.

## RN.09: Reglas de Promociones y Descuentos Temporales
Una promoción comercial (como descuentos por docena o 2x1) puede aplicarse a una o múltiples categorías de productos, y cada categoría puede ser alcanzada por múltiples promociones a lo largo del tiempo. Estas reglas se aplican únicamente dentro de un rango de vigencia definido por una fecha de inicio y una fecha de fin, lo que permite gestionar descuentos temporales de forma dinámica.

## RN.10: Habilitación de Productos para la Venta
Solo los productos habilitados (activos) pueden venderse. Un producto que se discontinúa o no cumple los controles de calidad se da de baja lógica (`activo = 0`): deja de ofrecerse a la venta pero se conserva en el catálogo para no perder el historial de ventas y movimientos de stock asociados.