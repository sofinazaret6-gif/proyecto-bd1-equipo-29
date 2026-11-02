# Etapa V — Funciones definidas por el usuario

## 1. Identificación y metadatos

- **Proyecto:** Sistema de Gestión Comercial — Panadería Tortuga
- **Materia:** Bases de Datos I — FaCENA (UNNE)
- **Etapa:** Etapa V — Temas Técnicos
- **Tema especializado:** Funciones definidas por el usuario (UDF): escalares e Inline Table-Valued
- **Autor:** Sofía Ferretti (DNI: 46.718.162)  — Integrante 3
- **Fecha:** 01/11/2026
- **Motor:** Microsoft SQL Server Express (T-SQL)
- **Scripts asociados:**
  - `sql/tecnico/funciones/01_funciones_negocio.sql`
  - `sql/tecnico/funciones/02_pruebas_funciones.sql`

---

## 2. Objetivo

Implementar funciones definidas por el usuario (UDF) en SQL Server para
reutilizar cálculos relacionados con las ventas y los clientes, y obtener
un resumen de productos vendidos durante un período determinado.

---

## 3. Fundamentos

### 3.1 ¿Por qué usar funciones definidas por el usuario (UDF)?

Una UDF encapsula una lógica de cálculo dentro de la base de datos y la
expone con un nombre, parámetros y un tipo de retorno. Se invoca desde
cualquier consulta como si fuera una función propia del motor. Para este
proyecto aporta:

- **Reutilización:** el cálculo del total comprado por un cliente se escribe
  una sola vez y se usa en cualquier `SELECT`, `WHERE` u `ORDER BY`, en lugar
  de repetir el `SUM` en cada consulta.
- **Mantenimiento centralizado:** si cambia la regla, se modifica con
  `CREATE OR ALTER FUNCTION` en un solo lugar y todas las consultas heredan
  el cambio.
- **Consistencia:** todas las áreas obtienen el mismo resultado, porque nadie
  reimplementa la fórmula a su manera.
- **Legibilidad:** `WHERE dbo.fn_CalcularTotalComprasCliente(DNI_cliente) > 0`
  expresa la intención mejor que una subconsulta agregada incrustada.
- **Seguridad:** las funciones solo leen datos; no pueden ejecutar `INSERT`,
  `UPDATE` ni `DELETE` sobre tablas permanentes, por lo que son seguras para
  usar dentro de consultas.

**Diferencia con otros objetos:** a diferencia de un procedimiento almacenado,
una UDF **se usa dentro de una sentencia SQL** (en el `SELECT`, `WHERE`,
`FROM`…) y **siempre devuelve un valor** (escalar o tabla). Un procedimiento
se invoca con `EXEC`, puede modificar datos y no se puede colocar en un
`WHERE`.

**Cuidado con el costo:** una UDF escalar usada en `SELECT` o `WHERE` puede
ejecutarse una vez por cada fila de la tabla externa. Con el volumen de la
panadería no es un problema, pero en tablas grandes puede ser lento. Desde
SQL Server 2019 (nivel de compatibilidad 150) el motor puede "inlinear"
automáticamente muchas funciones escalares, siempre que cumplan ciertas
condiciones.

### 3.2 Función escalar vs. función con valores de tabla en línea (inline TVF)

| Aspecto | Función escalar | Inline Table-Valued Function |
| :--- | :--- | :--- |
| **Devuelve** | Un único valor (`INT`, `DECIMAL`, `DATE`…) | Un conjunto de filas y columnas (una tabla) |
| **Cláusula `RETURNS`** | Tipo de dato simple | `RETURNS TABLE` |
| **Cuerpo** | Bloque `BEGIN … END` con variables y `RETURN valor` | Un solo `RETURN ( SELECT … )`, sin `BEGIN … END` |
| **Dónde se usa** | Donde va una expresión: lista del `SELECT`, `WHERE`, `ORDER BY` | En el `FROM` / `JOIN`, o con `CROSS APPLY` |
| **Cómo lo ve el optimizador** | Como una llamada a una rutina; puede ejecutarse fila por fila | Se expande dentro de la consulta que la llama, como una vista con parámetros, y se optimiza junto con ella |
| **Cuándo conviene** | Cálculos puntuales y reutilizables sobre un dato | Consultas parametrizadas que devuelven un listado o resumen |
| **En este proyecto** | `fn_CalcularTotalComprasCliente`, `fn_CalcularDiasPeriodo` | `fn_ResumenProductosVendidos` |

**Por qué `fn_ResumenProductosVendidos` es inline y no de varias sentencias.**
Existe también la TVF *multi-statement* (declara una variable de tipo tabla,
la llena y la devuelve). Esa variante es opaca para el optimizador y suele
rendir peor. Como el resumen se resuelve con un único `SELECT` (joins +
`GROUP BY`), la forma inline es la más simple y eficiente.

**Por qué las otras dos son escalares.** Cada una recibe datos de entrada y
devuelve un solo valor (un importe y una cantidad de días), que es el caso de
uso de una función escalar.

**Por qué `CROSS APPLY` con la TVF.** `CROSS APPLY` ejecuta la función para
cada fila de la tabla de la izquierda pasándole sus valores, como se muestra
en la Prueba 5 del script de pruebas.

---

## 4. Funciones implementadas

### 4.1 fn_CalcularTotalComprasCliente

- Tipo: Función escalar.
- Parámetro: DNI del cliente.
- Devuelve: Importe total histórico de las compras del cliente.
- Utilidad: Permite consultar cuánto compró un cliente a lo largo del
  tiempo, considerando las ventas registradas en el sistema.

El cálculo se realiza sumando los subtotales de las ventas asociadas
al cliente en la tabla Venta.

### 4.2 fn_CalcularDiasPeriodo

- Tipo: Función escalar.
- Parámetros: Fecha de inicio y fecha de fin.
- Devuelve: Cantidad de días entre ambas fechas.
- Utilidad: Permite calcular la duración de un período determinado,
  facilitando cálculos relacionados con fechas.

La función utiliza DATEDIFF para obtener la diferencia en días.

### 4.3 fn_ResumenProductosVendidos

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

---

## 5. Archivos SQL

- sql/tecnico/funciones/01_funciones_negocio.sql

  Contiene la creación de las tres funciones definidas por el usuario.

- sql/tecnico/funciones/02_pruebas_funciones.sql

  Contiene consultas SELECT, WHERE y CROSS APPLY para demostrar el
  funcionamiento y la utilización de las funciones.

## 6. Pruebas realizadas

Se realizan consultas para:

- Obtener el total histórico de compras de cada cliente.
- Filtrar clientes que tienen compras registradas.
- Calcular la duración en días de la vigencia de cada promoción
  (fn_CalcularDiasPeriodo sobre la tabla Promocion).
- Consultar productos vendidos durante octubre de 2026.
- Obtener el resumen de productos vendidos utilizando CROSS APPLY.

## 7. Consideraciones

Las funciones utilizan las tablas y los campos existentes en la base
de datos Panaderia_Tortuga.

No se agregan columnas ni tablas nuevas.

Las funciones no modifican los datos almacenados en la base de datos.