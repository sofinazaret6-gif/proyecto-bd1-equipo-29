# Requerimiento 1: Emisión de Factura / Comprobante de Venta Consolidado

## 1. Identificación y Metadatos
- **Proyecto:** Sistema de Gestión de Ventas — Panadería Tortuga
- **Etapa:** Etapa IV — Consultas y Casos de Uso
- **Responsable:** Lucas Martín Zárate (Integrante 1 - DNI: 34936602)
- **Ubicación del documento:** `docs/etapa-04/comprobante-venta.md`
- **Archivo SQL asociado:** `sql/consultas/comprobante_venta.sql`
- **Dialecto / Estándar:** Microsoft SQL Server (T-SQL) adaptado a **ANSI SQL-92 / ANSI SQL-99**

---

## 2. Descripción y Objetivo de Negocio
El objetivo fundamental de esta consulta es generar la representación estructurada de un **comprobante fiscal o ticket de venta comercial**, consolidando en una única salida tabular tanto los datos generales de la operación (encabezado) como las líneas de artículos adquiridos (detalle).

En el modelo operativo de una panadería barrial, el punto de venta requiere despachar operaciones de manera rápida, clara y transparente:
1. El cliente y el cajero deben visualizar de forma desglosada cada artículo despachado, su cantidad (unitaria o pesable fraccionada) y el precio unitario pactado.
2. Se debe calcular en tiempo de consulta el subtotal de cada renglón.
3. Se debe presentar el importe total acumulado de la venta en cada línea para validar la consistencia frente a los cobros registrados.

---

## 3. Entidades y Esquema Relacional Involucrado
La consulta vincula cinco tablas del esquema relacional físico mediante claves primarias y foráneas:

- **`[Venta]` (Tabla Transaccional Cabecera):** Proporciona el número de comprobante (`id_venta`) y las claves foráneas hacia el cliente y el empleado.
- **`[Detalle_Venta]` (Tabla Asociativa / Transaccional N:M):** Provee las tuplas de renglón con los atributos `cantidad` y `precio_unitario` histórico congelado.
- **`[Producto]` (Catálogo de Artículos):** Aporta el código identificador (`id_producto`) y la denominación comercial descriptiva (`nombre`).
- **`[Empleado]` (Entidad Maestra de Personal):** Identifica al operador responsable del despacho mediante su nombre, apellido y turno laboral (`Turno_Laboral`), permitiendo la trazabilidad y arqueo de caja.
- **`[Cliente]` (Entidad Maestra de Clientes):** Permite asociar los datos personales (`Nombre`, `Apellido`, `DNI_cliente`) cuando el cliente solicita comprobante formal o cuenta corriente.

---

## 4. Script SQL Implementado (Estándar ANSI Optimizado)

```sql
USE Panaderia_Tortuga;
GO

-- Parámetro de entrada para emitir el comprobante de venta específico
DECLARE @id_venta_consulta INT = 1001;

SELECT 
    v.id_venta AS nro_comprobante,
    
    -- Encabezado: Tratamiento estándar ANSI de valores nulos (COALESCE)
    COALESCE(CONCAT(c.Apellido, ', ', c.Nombre), 'Consumidor Final / Anónimo') AS cliente,
    COALESCE(CAST(c.DNI_cliente AS VARCHAR(20)), 'S/D') AS dni_cliente,
    
    -- Encabezado: Atributos de auditoría del personal de despacho
    CONCAT(e.Apellido, ', ', e.Nombre) AS atendido_por,
    e.Turno_Laboral AS turno_empleado,
    
    -- Detalle: Renglón de artículos
    p.id_producto AS cod_producto,
    p.nombre AS descripcion_articulo,
    dv.cantidad AS cantidad,
    dv.precio_unitario AS precio_unitario_historico,
    
    -- Subtotal por renglón con casteo numérico y protección ante nulos
    CAST((COALESCE(dv.cantidad, 0) * COALESCE(dv.precio_unitario, 0)) AS DECIMAL(12,2)) AS subtotal_renglon,
    
    -- Total acumulado obtenido de la tabla derivada (calculado una sola vez en memoria)
    tot.total_comprobante

-- Origen relacional y combinaciones explícitas con AS
FROM [Venta] AS v
INNER JOIN [Detalle_Venta] AS dv 
    ON v.id_venta = dv.id_venta
INNER JOIN [Producto] AS p 
    ON dv.id_producto = p.id_producto
INNER JOIN [Empleado] AS e 
    ON v.DNI_empleado = e.DNI_empleado
LEFT JOIN [Cliente] AS c 
    ON v.DNI_cliente = c.DNI_cliente

-- Optimización: Pre-agregación en el FROM que evita re-escanear la tabla fila a fila
INNER JOIN (
    SELECT 
        d2.id_venta, 
        CAST(SUM(COALESCE(d2.cantidad, 0) * COALESCE(d2.precio_unitario, 0)) AS DECIMAL(12,2)) AS total_comprobante
    FROM [Detalle_Venta] AS d2
    WHERE d2.id_venta = @id_venta_consulta
    GROUP BY d2.id_venta
) AS tot 
    ON v.id_venta = tot.id_venta

WHERE v.id_venta = @id_venta_consulta
ORDER BY p.id_producto ASC;
GO