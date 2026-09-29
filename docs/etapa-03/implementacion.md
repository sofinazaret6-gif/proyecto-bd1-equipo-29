## Implementación DDL: Tablas Maestras

La construcción del esquema físico inicia con la configuración inicial del entorno y la creación de la base de datos `Panaderia_Tortuga`, sentando las bases para las entidades fuertes independientes del modelo.

### Consideraciones Técnicas
* **Motor de Base de Datos:** Se utiliza **Microsoft SQL Server (T-SQL)** para garantizar la integridad y el rendimiento transaccional.
* **Estructura Maestra:** Se estructuraron las tablas fundamentales `Categoria`, `Stock` y `Unidad_Medida`.
* **Tipos de Datos y Dominios:** Se definieron correctamente los dominios mediante tipos de datos escalares (`INT`, `VARCHAR`, `DECIMAL`).


## Tablas de Segundo Nivel
A continuación de las tablas maestras, se implementaron las entidades transaccionales y de asociación (Producto, Producto_Unidad, Venta).
* En las relaciones 1 a N, la clave primaria de la tabla del lado 1 migra como clave foránea a la tabla del lado N.
* Para la relación de producto y unidad de medida, se estableció una tabla que hereda claves actuando como foráneas.



## Implementación DDL - Tablas de Tercer Nivel (Transaccionales e Intermedias)
Para mapear las relaciones de muchos a muchos (N:M) y los registros transaccionales del negocio, se implementaron las tablas de tercer nivel: `Detalle-Venta`, `Venta-MedioDePago`, `Movimiento-Stock` y `Categoria-Promocion`.

* **Resolución de relaciones (N:M):** En entidades como `Detalle-Venta`, se estructuró una clave primaria compuesta (`PK_DetalleVenta`) formada por `id_venta` e `id_producto`. Ambas columnas actúan simultáneamente como claves primarias y claves foráneas hacia sus respectivas tablas maestras, garantizando que un artículo se registre una sola vez por venta.
* **Entidades con Clave Subrogada:** En `Venta-MedioDePago` y `Movimiento-Stock` se optó por claves primarias artificiales simples (`[id_venta-MedioDePago]` e `[id_movimiento-Stock]`) para admitir transacciones atómicas repetibles en distintos momentos temporales.
* **Auditoría Temporal Automática:** En la tabla `Movimiento-Stock`, el atributo `fecha_hora` se configuró con valor predeterminado `DEFAULT GETDATE()`, asegurando el registro cronológico automático de cada operación de inventario.


## Implementación DML - Poblado Inicial de Tablas Maestras y Catálogos

La fase inicial de manipulación de datos (DML) consistió en la carga de datos maestros e independientes. Al no poseer dependencias externas de clave foránea, estas tablas debieron ser pobladas antes que las entidades transaccionales para evitar errores de integridad referencial.

* *Categorías y Unidades de Medida:* Se registraron las clasificaciones comerciales base y las unidades de medida necesarias para la venta fraccionada o por docena.
* *Inventario Base (Stock):* Se inicializaron los registros de stock con sus niveles actuales y límites mínimos de reposición, garantizando que el atributo cantidad_actual sea mayor o igual que cero.
* *Entidades Fuertes (Cliente y Empleado):* Se ingresaron los registros de clientes con sus números de documento y la nómina de empleados asignados a turnos específicos de trabajo (Turno Mañana y Turno Tarde).
* *Catálogo de Medios de Pago:* Se dieron de alta las modalidades de cobro aceptadas por el negocio (Efectivo, Débito, Crédito y Transferencias/QR).


## Implementación DML - Transacciones, Relaciones y Consistencia Histórica

La fase final de manipulación de datos (DML) consolida el circuito comercial y operativo del negocio mediante el poblado de las entidades de segundo y tercer nivel, garantizando la trazabilidad histórica y el flujo transaccional.

* **Catálogo de Productos y Unidades:** Se dieron de alta artículos vinculados a sus categorías y fichas de inventario (Stock), definiendo a su vez las equivalencias en `Producto_Unidad` (por ejemplo, venta unitaria y por docena con factor de conversión 12.0000).
* **Gestión de Promociones Temporales:** Se registraron promociones con rangos de vigencia definidos (`fecha_inicio` y `fecha_fin`) y se asociaron formalmente a las categorías comerciales correspondientes a través de `Categoria-Promocion`.
* **Histórico de Movimientos de Inventario:** Se registraron operaciones de entrada (`INGRESO`, `COMPRA`) asociadas a los lotes iniciales de stock con marcas de tiempo cronológicas (`fecha_hora`).
* **Ventas y Desacoplamiento de Clientes:** Se implementó el registro de comprobantes con la cabecera `Venta`, demostrando la flexibilidad de asociar un cliente registrado con DNI o permitir la venta mostrador anónima (`DNI_cliente = NULL`), siempre asignando obligatoriamente al empleado responsable.
* **Detalle de Venta y Cobros Combinados:** Cada comprobante se desglosó en sus líneas en `Detalle-Venta`, congelando el precio unitario pactado al momento de la operación para proteger el histórico ante aumentos de catálogo. Además, se registraron pagos mixtos en `Venta-MedioDePago` (ej. una parte en efectivo y el saldo por transferencia/QR), cerrando la equivalencia financiera con el subtotal facturado.