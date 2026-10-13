# Consulta de Negocio Avanzada — Documentación Técnica

*Proyecto:* Panadería Tortuga  
*Etapa:* IV — Consultas e informes SQL  
*Responsable:* Dorrego Octavio

## 1. Objetivo

Analizar las compras acumuladas por cliente durante un período determinado e identificar aquellos cuya facturación total sea igual o superior a un importe mínimo establecido

Esta consulta permite reconocer a los clientes que representan un mayor volumen de facturación para la panadería

## 2. Tablas utilizadas

- Cliente: contiene los datos identificatorios de los clientes.
- Venta: registra los comprobantes y las fechas de las operaciones.
- Detalle_Venta: contiene las cantidaes de productos vendidas y sus precios unitarios históricos.

## 3. Operaciones SQL implementadas

### INNER JOIN

Se utilizan combinaciones entre las tres tablas:

- Cliente con Venta, mediante DNI_cliente.
- Venta con Detalle_Venta, mediante id_venta.

Estas relaciones permiten vincular a cada cliente con sus compras y con los productos incluidos en cada comprobante.

### WHERE

Filtra las ventas realizadas dentro del rango de fechas seleccionado.

### GROUP BY

Agrupa las operaciones por DNI, nombre y apellido del cliente para calcular sus indicadores de manera individual.

### SUM

Calcula la facturación acumulada mediante la suma de la cantidad multiplicada por el precio unitario histórico de cada producto.

### COUNT

Permite obtener la cantidad de comprobantes distintos y la cantidad de líneas de detalle asociadas a las compras del cliente.

### HAVING

Filtra los grupos obtenidos mediante GROUP BY, conservando únicamente aquellos cuya facturación acumulada alcanza o supera el importe mínimo definido.

### ORDER BY

Ordena los resultados por facturación descendente para mostrar primero a los clientes con mayor importe acumulado.

## 4. Parámetros de entrada

La consulta utiliza tres parámetros:

| Parámetro    | Descripción                 | Valor inicial |
|---           |            ---              |    --         |
| @fecha_desde | Fecha inicial del análisis  | 01/10/2026    |
| @fecha_hasta | Fecha final del análisis    | 31/10/2026    |
| @facturacion_minima| Facturación mínima requerida | $10.000|

Estos valores pueden modificarse para analizar otros períodos o establecer distintos umbrales de facturación.

## 5. Indicadores obtenidos

- DNI del cliente.
- Nombre completo del cliente.
- Cantidad de compras realizadas.
- Cantidad de líneas de detalle compradas.
- Total de unidades adquiridas.
- Facturación acumulada.

## 6. Consideraciones técnicas

Los importes se calculan a partir de Detalle_Venta.precio_unitario, que representa el precio histórico de cada operación.

El uso de COUNT(DISTINCT v.id_venta) evita contar varias veces un mismo comprobante cuando contiene más de una línea de detalle.

El filtro de facturación se implementa mediante HAVING porque depende de una suma calculada sobre cada grupo.

La consulta utiliza INNER JOIN, por lo que no incluye las ventas sin cliente registrado ni los clientes que no realizaron compras durante el período.

## 7. Resultado esperado

Se obtiene un listado de clientes que alcanzaron la facturación mínima establecida durante el período analizado, ordenados desde el mayor importe acumulado al menor.

Este resultado facilita la identificación de clientes de mayor valor comercial y permite realizar análisis posteriores sobre su comportamiento de compra.