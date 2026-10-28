
# Etapa V — Funciones definidas por el usuario

## Proyecto: Panadería Tortuga

### Objetivo

Implementar funciones definidas por el usuario (UDF) en SQL Server para
reutilizar cálculos relacionados con las ventas y los clientes, y obtener
un resumen de productos vendidos durante un período determinado.

## Funciones implementadas

### 1. fn_CalcularTotalComprasCliente

- Tipo: Función escalar.
- Parámetro: DNI del cliente.
- Devuelve: Importe total histórico de las compras del cliente.
- Utilidad: Permite consultar cuánto compró un cliente a lo largo del
  tiempo, considerando las ventas registradas en el sistema.

El cálculo se realiza sumando los subtotales de las ventas asociadas
al cliente en la tabla Venta.

### 2. fn_CalcularDiasPeriodo

- Tipo: Función escalar.
- Parámetros: Fecha de inicio y fecha de fin.
- Devuelve: Cantidad de días entre ambas fechas.
- Utilidad: Permite calcular la duración de un período determinado,
  facilitando cálculos relacionados con fechas.

La función utiliza DATEDIFF para obtener la diferencia en días.

### 3. fn_ResumenProductosVendidos

- Tipo: Función con valores de tabla (Inline Table-Valued Function).
- Parámetros: Fecha de inicio y fecha de fin.
- Devuelve:
  - Identificador del producto.
  - Nombre del producto.
  - Cantidad total vendida.
  - Importe total vendido.
- Utilidad: Permite analizar el comportamiento comercial de los
  productos durante un período determinado.

El cálculo se realiza relacionando las tablas Venta, Detalle_Venta
y Producto.

## Archivos SQL

- sql/tecnico/funciones/01_funciones_negocio.sql

  Contiene la creación de las tres funciones definidas por el usuario.

- sql/tecnico/funciones/02_datos_prueba_funciones.sql

  Contiene modificaciones de fechas de ventas existentes para disponer
  de datos de prueba en diferentes días de octubre de 2026.

- sql/tecnico/funciones/03_pruebas_funciones.sql

  Contiene consultas SELECT, WHERE y CROSS APPLY para demostrar el
  funcionamiento y la utilización de las funciones.

## Pruebas realizadas

Se realizan consultas para:

- Obtener el total histórico de compras de cada cliente.
- Filtrar clientes que tienen compras registradas.
- Calcular la cantidad de días entre dos fechas.
- Consultar productos vendidos durante octubre de 2026.
- Obtener el resumen de productos vendidos utilizando CROSS APPLY.

## Consideraciones

Las funciones utilizan las tablas y los campos existentes en la base
de datos Panaderia_Tortuga.

No se agregan columnas ni tablas nuevas.

Las funciones no modifican los datos almacenados en la base de datos.
