# Requerimiento 2: Reporte Agregado de Ventas por Vendedor

## 1. Identificación y Metadatos
* **Proyecto:** Sistema de Gestión de Ventas — Panadería Tortuga
* **Etapa:** Etapa IV — Consultas y Casos de Uso
* **Responsable:** Kiara Itatí Zacarias
* **Archivo SQL asociado:** [`sql/consultas/informe_ventas.sql`](../../sql/consultas/informe_ventas.sql)
* **Dialecto / Estándar:** Microsoft SQL Server (T-SQL) adaptado a **ANSI SQL-92 / ANSI SQL-99**

---

## 2. Descripción y Objetivo de Negocio
El objetivo principal de esta consulta es generar un **informe analítico de desempeño comercial por empleado de mostrador** dentro de una ventana temporal parametrizada (rango de fechas).

En la dinámica operativa de la panadería:
1. La administración necesita monitorear la productividad de los empleados en atención al público, discriminando por turno laboral (`Turno Manana`, `Turno Tarde`, etc.).
2. Se requiere cuantificar no solo el volumen monetario recaudado (**total facturado**), sino también el flujo de atención (**cantidad de ventas/tickets emitidos**) y la intensidad de despacho (**cantidad de artículos y unidades vendidas**).
3. Permite calcular el **ticket promedio** por vendedor, facilitando la evaluación del rendimiento y la toma de decisiones sobre incentivos o reasignación de personal en turnos de alta demanda.

---

## 3. Entidades y Esquema Relacional Involucrado
La consulta vincula tres tablas del esquema físico a través del encadenamiento relacional `Empleado -> Venta -> Detalle_Venta`:

* **`[Empleado]` (Entidad Maestra de Personal):** Aporta la identidad del vendedor mediante su clave primaria (`DNI_empleado`), sus datos filiatorios (`Apellido`, `Nombre`) y su turno de asignación (`Turno_Laboral`).
* **`[Venta]` (Tabla Transaccional Cabecera):** Actúa como pivote de la transacción. Proporciona el número de comprobante (`id_venta`), la clave foránea hacia el empleado responsable y el atributo de auditoría temporal (`fecha`) utilizado para el filtrado.
* **`[Detalle_Venta]` (Tabla Transaccional N:M):** Contiene los renglones de venta con las cantidades físicas despachadas (`cantidad`) y los precios unitarios históricos pactados (`precio_unitario`).

---

## 4. Script SQL Implementado (Estándar ANSI)

```sql
USE Panaderia_Tortuga;
GO

-- =================================================================================================
-- SECCIÓN 1: REPORTE AGREGADO POR VENDEDOR
-- Responsable: Integrante 2
-- Consigna: Total de ventas realizadas por cada vendedor en un rango de fechas.
-- Operaciones SQL:
--   * INNER JOIN entre Empleado, Venta y Detalle_Venta.
--   * Funciones agregadas SUM y COUNT.
--   * Agrupamiento con GROUP BY.
--   * Filtro de rango de fechas en la cláusula WHERE.
-- =================================================================================================

-- Parámetros de entrada para el rango de fechas analizado
DECLARE @fecha_desde DATE = '2026-10-01';
DECLARE @fecha_hasta DATE = '2026-10-31';

SELECT 
    e.DNI_empleado AS dni_empleado,
    CONCAT(e.Apellido, ', ', e.Nombre) AS vendedor,
    e.Turno_Laboral AS turno_empleado,
    
    -- Métricas cuantitativas y agregadas
    COUNT(DISTINCT v.id_venta) AS cantidad_ventas_realizadas,
    COUNT(dv.id_producto) AS cantidad_lineas_despachadas,
    CAST(SUM(dv.cantidad) AS DECIMAL(12,2)) AS total_unidades_despachadas,
    CAST(SUM(dv.cantidad * dv.precio_unitario) AS DECIMAL(12,2)) AS total_ventas_facturado,
    
    -- Ticket promedio por comprobante emitido
    CAST(SUM(dv.cantidad * dv.precio_unitario) / COUNT(DISTINCT v.id_venta) AS DECIMAL(12,2)) AS ticket_promedio

-- Origen relacional con combinaciones internas explícitas (INNER JOIN)
FROM [Empleado] AS e
INNER JOIN [Venta] AS v 
    ON e.DNI_empleado = v.DNI_empleado
INNER JOIN [Detalle_Venta] AS dv 
    ON v.id_venta = dv.id_venta

-- Filtro por rango temporal solicitado
WHERE v.fecha BETWEEN @fecha_desde AND @fecha_hasta

-- Agrupamiento por clave primaria y atributos descriptivos del personal
GROUP BY 
    e.DNI_empleado,
    e.Apellido,
    e.Nombre,
    e.Turno_Laboral

-- Ordenamiento analítico decreciente por volumen de facturación
ORDER BY 
    total_ventas_facturado DESC,
    vendedor ASC;
GO
```

---

## 5. Justificación Técnica de Operaciones y Agregaciones

* **Combinaciones internas (`INNER JOIN`):** Se garantiza que únicamente figuren empleados que hayan registrado al menos una venta con detalle dentro del período evaluado, preservando la integridad estricta entre cabecera y renglones.
* **Filtro de rango (`WHERE v.fecha BETWEEN ...`):** Permite acotar el análisis a cualquier ventana temporal (mensual, quincenal o semanal) de manera parametrizada y eficiente mediante predicados sobre la columna de fecha.
* **Distinción en el conteo (`COUNT(DISTINCT v.id_venta)`):** Dado que el `INNER JOIN` expande las filas al nivel de renglones de `Detalle_Venta`, el calificador `DISTINCT` es imprescindible para contar comprobantes únicos y no duplicar transacciones.
* **Cálculo de importes acumulados (`SUM(dv.cantidad * dv.precio_unitario)`):** Multiplica la cantidad despachada por el precio histórico de cada artículo vendido y consolida la suma total por vendedor, garantizando exactitud frente a los subtotales de la cabecera.
* **Casteo numérico explícito (`CAST(... AS DECIMAL(12,2))`):** Estandariza la precisión decimal monetaria según el diseño de datos del proyecto, evitando inconsistencias por redondeo flotante.
* **Agrupamiento unívoco (`GROUP BY`):** Cumple con la norma ANSI SQL incluyendo la clave primaria del empleado (`DNI_empleado`) junto con sus columnas no agregadas presentes en la cláusula `SELECT`.

---

## 6. Validación de Resultados y Salida de Ejecución

Ejecutando la consulta sobre el dataset de prueba cargado en la base de datos `Panaderia_Tortuga`, se obtiene la siguiente salida consolidada:

| dni_empleado | vendedor | turno_empleado | cantidad_ventas_realizadas | cantidad_lineas_despachadas | total_unidades_despachadas | total_ventas_facturado | ticket_promedio |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| 28456123 | Gomez, Martin | Turno Manana | 4 | 6 | 24.00 | $56.100,00 | $14.025,00 |
| 39120485 | Mendez, Sofia | Turno Manana | 3 | 5 | 10.91 | $27.002,00 | $9.000,67 |
| 31789456 | Fernandez, Valeria | Turno Tarde | 3 | 4 | 5.00 | $17.700,00 | $5.900,00 |

### Análisis del Resultado:
1. **Líder en ventas:** El vendedor *Martín Gómez* registra la mayor facturación ($56.100,00) a través de 4 ventas y 24 unidades despachadas, con un ticket promedio de $14.025,00 en el turno mañana.
2. **Distribución por turno:** Se observa un mayor volumen de operaciones durante el turno mañana (7 transacciones entre Gómez y Méndez) en comparación con el turno tarde (3 transacciones de Fernández), reflejando el patrón comercial esperado para una panadería.

---
---

## 7. Reporte Agregado de Ventas por Categoría

### 7.1 Identificación y Metadatos

- **Proyecto:** Sistema de Gestión de Ventas — Panadería Tortuga.
- **Etapa:** Etapa IV — Consultas y Casos de Uso.
- **Responsable:** Ferretti Sofia.
- **Archivo SQL asociado:** `sql/consultas/informe_ventas.sql`.
- **Dialecto:** Microsoft SQL Server (T-SQL), con operaciones relacionales y agregadas compatibles con los principios de ANSI SQL.

### 7.2 Descripción y Objetivo de Negocio

El objetivo de esta consulta es generar un informe analítico de ventas agrupadas por categoría de producto dentro de un rango de fechas parametrizado.

Este reporte permite a la administración:

1. Identificar las categorías que generan mayor facturación.
2. Cuantificar las unidades comercializadas por categoría.
3. Conocer cuántas ventas incluyeron productos de cada categoría.
4. Comparar el desempeño comercial de las distintas líneas de productos.
5. Obtener información útil para planificar la producción, administrar el stock y diseñar promociones comerciales.

### 7.3 Entidades y Esquema Relacional Involucrado

La consulta relaciona cuatro tablas del esquema físico:

- **`Categoria`:** proporciona el identificador y la descripción de cada categoría.
- **`Producto`:** vincula cada producto con su categoría mediante `id_categoria`.
- **`Detalle_Venta`:** contiene los productos vendidos, las cantidades y los precios unitarios históricos.
- **`Venta`:** proporciona el identificador del comprobante y la fecha necesaria para filtrar las operaciones.

El encadenamiento relacional es:

`Categoria → Producto → Detalle_Venta → Venta`

### 7.4 Operaciones SQL Implementadas

**INNER JOIN:** relaciona las categorías con sus productos y con los detalles de las ventas, permitiendo determinar qué productos se comercializaron en cada categoría.

**WHERE:** limita el análisis al período seleccionado mediante las variables `@fecha_desde_categoria` y `@fecha_hasta_categoria`.

**COUNT(DISTINCT v.id_venta):** contabiliza la cantidad de comprobantes distintos que incluyen productos de cada categoría, evitando contar dos veces una misma venta dentro de esa categoría.

**COUNT(dv.id_producto):** contabiliza las líneas de detalle correspondientes a los productos vendidos.

**SUM(dv.cantidad):** calcula el total de unidades vendidas por categoría.

**SUM(dv.cantidad * dv.precio_unitario):** calcula la facturación acumulada de los productos de cada categoría utilizando sus precios históricos.

**CAST(... AS DECIMAL(12,2)):** establece una precisión decimal de dos posiciones para la presentación de los indicadores numéricos.

**GROUP BY:** agrupa los registros por identificador y descripción de categoría para obtener un resultado consolidado por cada una.

**ORDER BY:** ordena las categorías por facturación descendente, colocando primero aquellas que generaron mayores ingresos.

### 7.5 Parámetros de Entrada

| Parámetro | Descripción | Valor inicial |
|---|---|---|
| `@fecha_desde_categoria` | Fecha inicial del período | 01/10/2026 |
| `@fecha_hasta_categoria` | Fecha final del período | 31/10/2026 |

Los parámetros pueden modificarse para realizar análisis semanales, mensuales o correspondientes a otros períodos.

El filtro utiliza una fecha inicial inclusiva y un límite superior exclusivo correspondiente al día siguiente de la fecha final. De esta manera, se incluyen todas las operaciones del último día, incluso si el campo `fecha` contiene horas.

### 7.6 Indicadores Obtenidos

El resultado de la consulta presenta:

- Código de la categoría.
- Descripción de la categoría.
- Cantidad de ventas distintas que incluyeron productos de esa categoría.
- Cantidad de líneas de detalle vendidas.
- Total de unidades vendidas.
- Importe total facturado por categoría.

### 7.7 Consideraciones Técnicas

La facturación se calcula mediante `Detalle_Venta.cantidad * Detalle_Venta.precio_unitario`, ya que este último representa el precio histórico registrado al realizar la venta.

El uso de `COUNT(DISTINCT v.id_venta)` es necesario porque una misma venta puede contener varias líneas de detalle correspondientes a una misma categoría.

La consulta emplea `INNER JOIN`, por lo que solamente devuelve categorías que tengan productos con ventas registradas dentro del período. Las categorías sin ventas durante ese rango no aparecen en el resultado.

La validez del filtro temporal depende de que `Venta.fecha` esté correctamente cargada para las operaciones analizadas.

### 7.8 Validación y Ejecución

Para validar el informe:

1. Abrir Microsoft SQL Server Management Studio.
2. Abrir `sql/consultas/informe_ventas.sql`.
3. Verificar que la base de datos `Panaderia_Tortuga` contenga las tablas y los datos de prueba.
4. Ejecutar el script completo.
5. Revisar el conjunto de resultados correspondiente a la sección 2.
6. Comprobar que las categorías aparezcan agrupadas y ordenadas por facturación.

Los valores finales deben documentarse a partir de la ejecución real de la consulta. No se incluyen resultados numéricos de ejemplo como si fueran una salida verificada.

### 7.9 Resultado Esperado y Utilidad para el Negocio

El informe permite comparar la facturación y el volumen de ventas de las distintas categorías de la panadería durante el período seleccionado.

Esta información contribuye a identificar las líneas de productos con mejor desempeño comercial y proporciona una base cuantitativa para tomar decisiones relacionadas con la producción, las compras, el stock y las estrategias de promoción.
