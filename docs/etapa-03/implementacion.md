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

