# Reglas de Negocio

## RN.01: Gestión de Productos y Unidades
Cada categoría agrupa a múltiples productos, mientras que cada producto pertenece obligatoriamente a una única categoría. Esto asegura que el catálogo esté siempre organizado, permitiendo identificar la unidad de medida específica (kg, unidad o docena) para cada artículo de forma clara.

## RN.02: Gestión y Control de Stock
Un producto mantiene una única ficha de control de inventario. A esta ficha le corresponden múltiples movimientos, ya sean ingresos por compras a proveedores o egresos por ventas. El sistema emite una alerta si la cantidad resultante desciende por debajo del umbral mínimo configurado.

## RN.03: Registro de Clientes
Una venta puede registrarse sin asociar a ningún cliente (venta mostrador anónima); sin embargo, si se registra un cliente, una venta específica queda vinculada a un único cliente. A la inversa, un cliente puede realizar múltiples ventas a lo largo del tiempo, permitiendo su fidelización o cuenta corriente.

## RN.04: Historial de Precios y Detalle de Operación
Una venta se desglosa en múltiples líneas de detalle; cada una de estas líneas hace referencia a un único producto y conserva el precio unitario acordado en el momento preciso de la transacción, asegurando que cambios futuros en el catálogo no alteren el histórico.

## RN.05: Métodos de Pago y Pagos Combinados
Una venta puede abonarse utilizando uno o varios métodos de pago (efectivo, tarjeta, transferencia), lo que permite operaciones combinadas. A su vez, cada método de pago disponible puede figurar en múltiples operaciones de venta distintas.