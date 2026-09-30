## Implementación DDL: Tablas Maestras

La construcción del esquema físico inicia con la configuración inicial del entorno y la creación de la base de datos `Panaderia_Tortuga`, sentando las bases para las entidades fuertes independientes del modelo.

### Consideraciones Técnicas
* **Motor de Base de Datos:** Se utiliza **Microsoft SQL Server (T-SQL)** para garantizar la integridad y el rendimiento transaccional.
* **Estructura Maestra:** Se estructuraron las tablas fundamentales `Categoria`, `Stock` y `Unidad_Medida`.
* **Tipos de Datos y Dominios:** Se definieron correctamente los dominios mediante tipos de datos escalares (`INT`, `VARCHAR`, `DECIMAL`).


## Tablas de Segundo Nivel
A continuación de las tablas maestras, se implementaron las entidades transaccionales y de asociación `Producto`,` Producto_Unidad`, `Venta`.
* **En las relaciones 1 a N:** la clave primaria de la tabla del lado 1 migra como clave foránea a la tabla del lado N.
* **Para la relación de producto y unidad de medida:** se estableció una tabla que hereda claves actuando como foráneas.

