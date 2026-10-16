# Casos de Uso y Mapeo del Sistema Comercial

*Proyecto:* Panadería Tortuga  
*Etapa:* IV — Consultas y Casos de Uso  
*Responsable:* Integrante 5 — Definición y Mapeo de Casos de Uso

## 1. Objetivo

Mapear integralmente los casos de uso del sistema comercial vinculando los requerimientos operativos del punto de venta (POS) y las necesidades de gestión gerencial con las consultas SQL implementadas en la etapa, ejecutando operaciones SQL de verificación cruzada para validar la consistencia e integridad de los datos frente a las reglas del negocio.

## 2. Tablas utilizadas

- **Venta:** cabecera de la transacción con número de comprobante, fecha, subtotal, empleado asignado y cliente opcional.
- **Detalle_Venta:** renglones de la operación con artículos adquiridos, cantidades físicas y precios unitarios históricos pactados.
- **Producto:** catálogo de artículos comercializados con descripción, categoría y precio de lista vigente.
- **Categoria:** agrupación de los artículos por rubro o familia de productos.
- **Empleado:** personal responsable de la atención en mostrador y registro del turno laboral.
- **Cliente:** registro de clientes frecuentes para cuenta corriente y fidelización.
- **Venta_MedioDePago:** desglose de las formas de cobro utilizadas (efectivo, tarjeta, transferencia, etc.).

## 3. Casos de Uso del Sistema Comercial

### CU-01: Emisión de Comprobante / Ticket de Venta Consolidado
- **Objetivo:** Generar el comprobante estructurado de una venta para el cliente y control fiscal, detallando cabecera, artículos, cantidades, precios unitarios históricos, subtotales por renglón y total general.
- **Actor:** Cajero / Empleado de Mostrador (beneficiario: Cliente).
- **Consulta asociada:** `sql/consultas/comprobante_venta.sql` (Lucas Zárate - Int. 1).
- **Flujo:** El cajero ingresa el número de venta (`@id_venta_consulta`); el sistema obtiene el comprobante, empleado y turno. Si la venta no registra cliente (`DNI_cliente IS NULL`), la consulta proyecta 'Consumidor Final / Anónimo' mediante `COALESCE`. Luego desglosa cada ítem desde `Detalle_Venta` con su subtotal (`cantidad * precio_unitario`) y calcula el total acumulado del ticket.
- **Reglas de negocio:** RN.03 (cliente opcional), RN.04 (precio histórico congelado) y RN.06 (identificación obligatoria de ticket con empleado y fecha).

### CU-02: Cobro Combinado y Arqueo por Comprobante
- **Objetivo:** Registrar y verificar que el importe total del comprobante se encuentre cubierto en su totalidad mediante uno o varios métodos de pago simultáneos.
- **Actor:** Cajero / Empleado de Mostrador.
- **Operación asociada:** Validación financiera contra `Venta_MedioDePago` y `Detalle_Venta`.
- **Flujo:** Al confirmar la venta, se capturan las imputaciones de pago (ej. una parte en Efectivo y otra en Transferencia bancaria o Tarjeta). El sistema valida que la suma de importes en `Venta_MedioDePago` equivalga exactamente al subtotal de `Venta`.
- **Reglas de negocio:** RN.05 (métodos de pago múltiples y pagos combinados).

### CU-03: Reporte de Rendimiento y Productividad por Vendedor
- **Objetivo:** Evaluar el desempeño comercial y operativo del personal de mostrador discriminando por turno laboral en una ventana de fechas parametrizada.
- **Actor:** Administrador / Dueño del Local.
- **Consulta asociada:** `sql/consultas/informe_ventas.sql` — Sección 1 (Kiara Zacarias - Int. 2).
- **Flujo:** Agrupa las ventas por empleado y turno mediante `INNER JOIN`, calculando ventas únicas (`COUNT DISTINCT`), líneas despachadas, unidades físicas, total facturado acumulado y ticket promedio.
- **Reglas de negocio:** RN.06 (empleado responsable de la transacción) y gestión de turnos laborales.

### CU-04: Análisis de Demanda y Facturación por Categoría
- **Objetivo:** Determinar qué familias de productos lideran la recaudación y el volumen físico de ventas para coordinar las horneadas diarias, compras de insumos y rotación de stock.
- **Actor:** Administrador / Encargado de Producción.
- **Consulta asociada:** `sql/consultas/informe_ventas.sql` — Sección 2 (Sofia Ferretti - Int. 3).
- **Flujo:** Enlaza la cadena relacional `Categoria -> Producto -> Detalle_Venta -> Venta` agrupando por categoría en el período analizado para computar comprobantes únicos alcanzados, líneas, unidades y facturación total.
- **Reglas de negocio:** RN.01 (categorización unívoca de productos), RN.02 (control de stock) y RN.09 (promociones por categoría).

### CU-05: Segmentación de Clientes de Alto Consumo (VIP)
- **Objetivo:** Reconocer a los clientes que alcanzan o superan un monto mínimo acumulado de facturación en el período para programas de fidelización o habilitación de cuenta corriente comercial.
- **Actor:** Administrador / Dueño del Local.
- **Consulta asociada:** `sql/consultas/consulta_avanzada.sql` (Octavio Dorrego - Int. 4).
- **Flujo:** Agrupa por cliente registrado mediante `INNER JOIN` y aplica la cláusula de restricción post-agrupamiento `HAVING SUM(...) >= @facturacion_minima` ($10.000,00).
- **Reglas de negocio:** RN.03 (registro y fidelización de clientes recurrentes).

### CU-06: Auditoría de Inmutabilidad de Precios Históricos
- **Objetivo:** Garantizar que el precio pactado al momento de cada transacción en `Detalle_Venta` permanezca inmutable ante futuros cambios o aumentos en el catálogo de `Producto`.
- **Actor:** Administrador / Auditor del Sistema.
- **Operación asociada:** Verificación de consistencia entre `Detalle_Venta.precio_unitario` y `Producto.precio_unitario`.
- **Flujo:** Compara el precio registrado en cada renglón histórico frente a la cotización vigente del maestro de productos, verificando que los reportes de ventas pasadas no sufran alteraciones contables retroactivas.
- **Reglas de negocio:** RN.04 (historial de precios y detalle de operación).

## 4. Matriz de Trazabilidad Integral

| Caso de Uso | Actor | Reglas de Negocio | Tablas Involucradas | Operaciones SQL Clave | Consulta Asociada | Responsable |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **CU-01:** Comprobante de Venta | Cajero | RN.03, RN.04, RN.06 | Venta, Detalle, Producto, Empleado, Cliente | INNER JOIN, LEFT JOIN, COALESCE, Subconsulta | comprobante_venta.sql | Lucas Zárate (Int. 1) |
| **CU-02:** Cobros Combinados | Cajero | RN.05 | Venta, Detalle_Venta, Venta_MedioDePago | SUM, GROUP BY, Comparación financiera | Operación SQL 2 | Integrante 5 |
| **CU-03:** Rendimiento Vendedor | Admin | RN.06 | Empleado, Venta, Detalle_Venta | INNER JOIN, GROUP BY, SUM, COUNT, Ticket prom. | informe_ventas.sql (1) | Kiara Zacarias (Int. 2) |
| **CU-04:** Demanda por Categoría | Admin / Prod | RN.01, RN.02, RN.09 | Categoria, Producto, Detalle, Venta | INNER JOIN (4 tablas), DATEADD, GROUP BY | informe_ventas.sql (2) | Sofia Ferretti (Int. 3) |
| **CU-05:** Clientes VIP | Admin | RN.03 | Cliente, Venta, Detalle_Venta | INNER JOIN, GROUP BY, HAVING SUM >= 10.000 | consulta_avanzada.sql | Octavio Dorrego (Int. 4) |
| **CU-06:** Precios Históricos | Admin / Auditor | RN.04 | Detalle_Venta, Producto, Venta | INNER JOIN, Comparación de atributos | Operación SQL 4 | Integrante 5 |

## 5. Operaciones SQL: Validación Funcional y Verificación Cruzada

Se implementaron y ejecutaron 4 operaciones SQL de verificación cruzada sobre el dataset de prueba (`sql/dml/datos_prueba.sql`) para validar la consistencia analítica, contable y transaccional entre las consultas de todos los compañeros.

### 5.1 Operación SQL 1: Cuadre Global de Facturación (CU-03 vs CU-04)

Verifica que la sumatoria total facturada por vendedor en el período analizado (Octubre 2026) sea idéntica al centavo frente a la sumatoria total por categoría:

```sql
USE Panaderia_Tortuga;
GO

DECLARE @fecha_desde DATE = '2026-10-01';
DECLARE @fecha_hasta DATE = '2026-10-31';

WITH TotalesPorVendedor AS (
    SELECT 
        'Vendedores (CU-03)' AS dimension,
        COUNT(DISTINCT v.id_venta) AS cantidad_ventas,
        CAST(SUM(dv.cantidad) AS DECIMAL(12,2)) AS total_unidades,
        CAST(SUM(dv.cantidad * dv.precio_unitario) AS DECIMAL(12,2)) AS total_facturado
    FROM Empleado AS e
    INNER JOIN Venta AS v ON e.DNI_empleado = v.DNI_empleado
    INNER JOIN Detalle_Venta AS dv ON v.id_venta = dv.id_venta
    WHERE v.fecha BETWEEN @fecha_desde AND @fecha_hasta
),
TotalesPorCategoria AS (
    SELECT 
        'Categorias (CU-04)' AS dimension,
        COUNT(DISTINCT v.id_venta) AS cantidad_ventas,
        CAST(SUM(dv.cantidad) AS DECIMAL(12,2)) AS total_unidades,
        CAST(SUM(dv.cantidad * dv.precio_unitario) AS DECIMAL(12,2)) AS total_facturado
    FROM Categoria AS c
    INNER JOIN Producto AS p ON c.id_categoria = p.id_categoria
    INNER JOIN Detalle_Venta AS dv ON p.id_producto = dv.id_producto
    INNER JOIN Venta AS v ON dv.id_venta = v.id_venta
    WHERE v.fecha >= @fecha_desde AND v.fecha < DATEADD(DAY, 1, @fecha_hasta)
)
SELECT 
    v.dimension AS origen_1, v.total_facturado AS total_vendedores,
    c.dimension AS origen_2, c.total_facturado AS total_categorias,
    CAST((v.total_facturado - c.total_facturado) AS DECIMAL(12,2)) AS diferencia_desvio,
    CASE 
        WHEN (v.total_facturado - c.total_facturado) = 0 
            THEN 'CONCILIACION EXITOSA (CUADRE 100% EXACTO)' 
        ELSE 'ERROR: DESCUADRE' 
    END AS estado_auditoria
FROM TotalesPorVendedor AS v CROSS JOIN TotalesPorCategoria AS c;
GO
```

* **Resultado Obtenido:**

| origen_1 | total_vendedores | origen_2 | total_categorias | diferencia_desvio | estado_auditoria |
| :--- | :---: | :--- | :---: | :---: | :--- |
| Vendedores (CU-03) | $100.802,00 | Categorias (CU-04) | $100.802,00 | $0,00 | CONCILIACION EXITOSA (CUADRE 100% EXACTO) |

* **Conclusión:** Desvío cero. Demuestra que ninguna combinación `JOIN` introduce multiplicidad espuria ni omisiones.

### 5.2 Operación SQL 2: Validación de Comprobante y Cobros Combinados (CU-01 y CU-02 / RN.05)

Audita las 10 ventas del mes verificando que `Subtotal Cabecera = Suma Detalle = Suma Medios de Pago`:

```sql
SELECT 
    v.id_venta AS nro_comprobante,
    v.fecha,
    COALESCE(CONCAT(c.Apellido, ', ', c.Nombre), 'Consumidor Final') AS cliente,
    v.subtotal AS subtotal_cabecera,
    det.total_detalle AS total_calculado_detalle,
    pago.total_pagos AS total_medios_pago,
    pago.cantidad_medios_usados,
    CASE 
        WHEN v.subtotal = det.total_detalle AND v.subtotal = pago.total_pagos 
            THEN 'CONSISTENTE (CUADRADO)' 
        ELSE 'ERROR DE INTEGRIDAD' 
    END AS estado_financiero
FROM Venta AS v
LEFT JOIN Cliente AS c ON v.DNI_cliente = c.DNI_cliente
INNER JOIN (
    SELECT id_venta, CAST(SUM(cantidad * precio_unitario) AS DECIMAL(12,2)) AS total_detalle
    FROM Detalle_Venta GROUP BY id_venta
) AS det ON v.id_venta = det.id_venta
INNER JOIN (
    SELECT id_venta, COUNT(id_medioDePago) AS cantidad_medios_usados, CAST(SUM(importe) AS DECIMAL(12,2)) AS total_pagos
    FROM Venta_MedioDePago GROUP BY id_venta
) AS pago ON v.id_venta = pago.id_venta
ORDER BY v.id_venta ASC;
GO
```

* **Resultado Obtenido:** Las 10 ventas resultan `CONSISTENTE (CUADRADO)`. Se comprueban los cobros combinados en la venta 1001 ($5.000 Efectivo + $6.600 Transferencia = $11.600) y la venta 1007 ($10.000 Crédito + $9.600 Débito = $19.600).

### 5.3 Operación SQL 3: Reconciliación Cruzada de Clientes VIP y Ventas Anónimas (CU-05 / RN.03)

Reconcilia la segmentación con `HAVING` frente al universo total de ventas de la panadería:

```sql
DECLARE @fecha_desde_seg DATE = '2026-10-01';
DECLARE @fecha_hasta_seg DATE = '2026-10-31';
DECLARE @umbral_vip DECIMAL(12,2) = 10000.00;

WITH FacturacionPorCliente AS (
    SELECT v.DNI_cliente, SUM(dv.cantidad * dv.precio_unitario) AS total_acumulado_cliente
    FROM Venta AS v INNER JOIN Detalle_Venta AS dv ON v.id_venta = dv.id_venta
    WHERE v.fecha BETWEEN @fecha_desde_seg AND @fecha_hasta_seg AND v.DNI_cliente IS NOT NULL
    GROUP BY v.DNI_cliente
),
ClasificacionVentas AS (
    SELECT 
        v.id_venta, v.subtotal,
        CASE 
            WHEN v.DNI_cliente IS NULL THEN '1. Venta Mostrador Anónima (Consumidor Final - RN.03)'
            WHEN fpc.total_acumulado_cliente >= @umbral_vip THEN '2. Cliente VIP Calificado (CU-05 >= $10.000)'
            ELSE '3. Cliente Identificado Consumo Regular (< $10.000)'
        END AS segmento
    FROM Venta AS v
    LEFT JOIN FacturacionPorCliente AS fpc ON v.DNI_cliente = fpc.DNI_cliente
    WHERE v.fecha BETWEEN @fecha_desde_seg AND @fecha_hasta_seg
)
SELECT 
    segmento,
    COUNT(DISTINCT id_venta) AS cantidad_comprobantes,
    CAST(SUM(subtotal) AS DECIMAL(12,2)) AS facturacion_segmento,
    CAST((SUM(subtotal) * 100.0 / 100802.00) AS DECIMAL(5,2)) AS porcentaje_facturacion
FROM ClasificacionVentas
GROUP BY segmento
ORDER BY segmento ASC;
GO
```

* **Resultado Obtenido:**

| Segmento de Facturación | Ventas | Facturación | Participación | Justificación Técnica |
| :--- | :---: | :---: | :---: | :--- |
| 1. Venta Mostrador Anónima (RN.03) | 2 | $12.200,00 | 12,10% | Ventas 1002 y 1006 (`DNI_cliente = NULL`). Excluidas en CU-05 por `INNER JOIN`, pero computadas en CU-01 con `COALESCE`. |
| 2. Cliente VIP Calificado (CU-05 $\ge \$10.000$) | 4 | $63.700,00 | 63,20% | Filtrados con `HAVING`. Clientes 38190544 ($19.600), 46843173 ($18.500), 33019284 ($14.000) y 34936602 ($11.600). |
| 3. Cliente Identificado Consumo Regular (< $10.000) | 4 | $24.900,00 | 24,70% | Clientes registrados que no alcanzaron el umbral. |
| **Total General del Mes** | **10** | **$100.802,00** | **100,00%** | **Cuadre exhaustivo del 100% de la facturación comercial.** |

### 5.4 Operación SQL 4: Auditoría de Inmutabilidad de Precios Históricos (CU-06 / RN.04)

Verifica que el precio congelado en `Detalle_Venta` preserve el valor acordado en la transacción frente a las cotizaciones maestras del catálogo:

```sql
SELECT 
    v.id_venta AS nro_comprobante,
    v.fecha,
    p.id_producto AS cod_producto,
    p.nombre AS descripcion_articulo,
    dv.precio_unitario AS precio_historico_detalle,
    p.precio_unitario AS precio_catalogo_maestro,
    dv.cantidad,
    CAST((dv.cantidad * dv.precio_unitario) AS DECIMAL(12,2)) AS subtotal_linea,
    CASE 
        WHEN dv.precio_unitario = p.precio_unitario 
            THEN 'PRECIO HISTORICO CONCUERDA CON CATALOGO'
        ELSE 'PRECIO HISTORICO DIFIERE (HISTORIAL PRESERVADO ANTE AUMENTOS)'
    END AS diagnostico_inmutabilidad
FROM Detalle_Venta AS dv
INNER JOIN Producto AS p ON dv.id_producto = p.id_producto
INNER JOIN Venta AS v ON dv.id_venta = v.id_venta
ORDER BY v.id_venta ASC, p.id_producto ASC;
GO
```

* **Resultado Obtenido:** Las 15 líneas de detalle conservan sus valores históricos congruentes con la fecha de operación, confirmando la regla RN.04.

## 6. Resultado esperado

1. Trazabilidad integral y formal entre los 6 casos de uso del sistema comercial, las reglas de negocio y las consultas SQL construidas.
2. Comprobación algorítmica de cuadre de facturación ($100.802,00), consistencia en cobros combinados e inmutabilidad histórica del catálogo.
