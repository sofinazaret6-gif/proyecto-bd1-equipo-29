# Etapa V — Temas Técnicos: Seguridad (Usuarios/Roles) e Índices

## 1. Identificación
* **Proyecto:** Sistema de Gestión Comercial — Panadería Tortuga
* **Materia:** Bases de Datos I — FaCENA (UNNE)
* **Responsable:** Nicolás Pini (DNI: 46.844.274) 
* **Motor:** Microsoft SQL Server Express (T-SQL)
* **Scripts:**
  * Seguridad: `sql/tecnico/seguridad/01_usuarios_roles.sql`
  * Índices: `sql/tecnico/indices/02_indices_optimizacion.sql`

---

## 2. Seguridad: usuarios, roles y menor privilegio

### 2.1. Conceptos
* **Principio de Menor Privilegio:** cada usuario tiene solo los permisos que necesita para su trabajo.
* **Login:** credencial a nivel servidor (`login_cajero`).
* **Usuario:** el login dentro de una base de datos (`cajero_pos` en `Panaderia_Tortuga`).
* **Rol:** grupo de permisos que se asigna a usuarios (`Rol_Cajero`). Se administran permisos por rol y no por persona (RBAC).
* **`GRANT`:** concede un permiso.
* **`DENY`:** bloquea un permiso y prevalece sobre cualquier `GRANT`, incluso uno heredado de otro rol.
* **`EXECUTE AS USER` / `REVERT`:** permite al administrador ejecutar instrucciones como si fuera otro usuario, para probar sus permisos.

### 2.2. Justificación
El cajero emite tickets, carga renglones, registra el medio de pago y consulta precios. Hay dos riesgos que evitar:
* Que borre una venta (`DELETE` en `Venta` / `Detalle_Venta`) después de cobrar en efectivo y se quede con el dinero.
* Que cambie precios (`UPDATE` en `Producto`).

### 2.3. Creación de identidades
1. `CREATE LOGIN [login_cajero] WITH PASSWORD = ..., CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF`
2. `CREATE USER [cajero_pos] FOR LOGIN [login_cajero]`
3. `CREATE ROLE [Rol_Cajero]` y `ALTER ROLE [Rol_Cajero] ADD MEMBER [cajero_pos]`

Cada paso verifica primero si el objeto ya existe (`IF NOT EXISTS`), así que el script se puede ejecutar más de una vez.

> **Nota:** la contraseña está escrita en el script y la política de complejidad y vencimiento está desactivada. Esto es así solo para la demostración. En producción la contraseña no debe quedar en el código y `CHECK_POLICY` debe estar activado.

### 2.4. Matriz de permisos de `Rol_Cajero`

| Tabla | `GRANT` | `DENY` | Motivo |
| :--- | :---: | :---: | :--- |
| `Venta` | `SELECT`, `INSERT` | `DELETE` | Emite ventas; no puede anularlas físicamente. |
| `Detalle_Venta` | `SELECT`, `INSERT` | `DELETE` | Carga renglones; no puede borrarlos. |
| `Venta_MedioDePago` | `SELECT`, `INSERT` | — | Registra cobros. |
| `Producto` | `SELECT` | `UPDATE`, `DELETE` | Consulta precios; no puede modificarlos. |
| `Cliente` | `SELECT` | `UPDATE`, `DELETE` | Asocia clientes a la venta. |
| `Empleado`, `MedioDePago`, `Unidad_Medida`, `Promocion` | `SELECT` | — | Datos de consulta. |

Sobre las tablas que no figuran en la matriz el cajero no tiene ningún permiso.

### 2.5. Pruebas (ejecutadas como `cajero_pos`)

| # | Acción | Resultado |
| :---: | :--- | :--- |
| 1 | `SELECT USER_NAME(), IS_ROLEMEMBER('Rol_Cajero')` y luego `SELECT TOP 5 ... FROM Producto` | **Permitido.** Confirma que la sesión es `cajero_pos` (miembro del rol = 1) y devuelve 5 productos. |
| 2 | `INSERT` de la venta 8999 y su renglón, y lectura con `JOIN` entre `Venta` y `Detalle_Venta` | **Permitido.** La venta se graba y el cajero puede leerla. |
| 3 | `DELETE FROM Detalle_Venta WHERE id_venta = 8999` | **Bloqueado.** Error 229: *The DELETE permission was denied on the object 'Detalle_Venta'*. |
| 4 | `UPDATE Producto SET precio_unitario = 10 WHERE id_producto = 1` | **Bloqueado.** Error 229: *The UPDATE permission was denied on the object 'Producto'*. |

Al final del script, el administrador borra la venta de prueba 8999.

`Venta_MedioDePago` tiene `INSERT` habilitado, pero ninguna demo lo prueba.

---

## 3. Índices

### 3.1. Conceptos
* SQL Server guarda los datos en **páginas de 8 KB**. Las *lecturas lógicas* (`logical reads`) cuentan cuántas páginas lee una consulta y son la medida de costo que usamos.
* **Índice agrupado (clustered):** define el orden físico de la tabla. Normalmente es la clave primaria.
* **Índice no agrupado (nonclustered):** estructura aparte, en árbol B+, ordenada por las columnas elegidas.
* **Clustered Index Scan:** recorre la tabla entera.
* **Index Seek:** baja por el árbol directo a las filas que cumplen el filtro.
* **`INCLUDE` (índice cubierto):** guarda columnas extra en las hojas del índice, para responder la consulta sin volver a la tabla (se evita el *Key Lookup*).

### 3.2. Índices creados

```sql
CREATE NONCLUSTERED INDEX [IX_Venta_DNI_cliente]
ON dbo.[Venta] ([DNI_cliente])
INCLUDE ([fecha], [subtotal]);

CREATE NONCLUSTERED INDEX [IX_MovimientoStock_FechaHora]
ON dbo.[Movimiento_Stock] ([fecha_hora])
INCLUDE ([tipo_movimiento], [cantidad], [id_stock]);
```

* **`Venta(DNI_cliente)`:** SQL Server no indexa automáticamente las claves foráneas. Sin este índice, consultar el historial de un cliente obliga a leer todas las ventas.
* **`Movimiento_Stock(fecha_hora)`:** las auditorías de stock filtran por rango de fechas. El índice permite leer solo ese rango.

Los dos se crean dentro de un `IF NOT EXISTS`, por lo que volver a ejecutar el script no da error.

### 3.3. Datos de prueba
Con muy pocas filas, el optimizador prefiere recorrer la tabla y la diferencia no se ve. Por eso el script carga **1500 ventas** (ids 3000–4499) y **1500 movimientos de stock** sintéticos, solo si cada tabla tiene menos de 500 filas.

> **Atención:** estos registros quedan en la base, porque el script no los borra. Hay que tenerlo en cuenta en cualquier consulta que cuente o sume ventas.

### 3.4. Resultados medidos (`SET STATISTICS IO ON`)

| Consulta | Filas | Sin índice (Clustered Index Scan) | Con índice (Index Seek) | Reducción |
| :--- | :---: | :---: | :---: | :---: |
| Ventas del cliente 34936602 | 301 | 9 lecturas | 5 lecturas | 44% |
| Movimientos de 48 h hasta el último registrado | 193 | 11 lecturas | 3 lecturas | 73% |

En cada consulta se fuerza el índice con `WITH (INDEX(...))`, para comparar los dos caminos sobre los mismos datos. El caso 2 usa las 48 horas anteriores al último movimiento cargado, y no las anteriores a `GETDATE()`, para que el rango nunca quede vacío.

El script también activa `SET STATISTICS TIME ON`, pero con este volumen de datos los tiempos dan cerca de 0 ms en los dos casos y no permiten comparar. Por eso la medida que usamos son las lecturas lógicas.

**Cómo ver el plan de ejecución:** en SSMS, activar *Include Actual Execution Plan* (`Ctrl+M`) antes de ejecutar (`F5`). En la pestaña *Execution plan* aparece *Clustered Index Scan* en los casos 1.A y 2.A, e *Index Seek* en 1.B y 2.B.

### 3.5. Verificación en el catálogo
Al final, el script consulta `sys.indexes`, `sys.index_columns` y `sys.columns` para mostrar los dos índices creados. Devuelve 7 filas: por cada índice, su columna clave y sus columnas `INCLUDE` (`Es_Columna_Include = 1`).

La mejora del caso de ventas es menor porque el cliente tiene 301 de las 1510 ventas (20%), así que el índice igual tiene que leer muchas hojas. Cuanto más chico sea el filtro y más grande la tabla, mayor es la diferencia. El scan crece con el tamaño de la tabla, mientras que el seek crece con la cantidad de filas que devuelve la consulta.

---

## 4. Conclusiones
1. **Seguridad:** con `Rol_Cajero`, el cajero puede vender pero no borrar ventas ni modificar precios, y el motor rechaza esos intentos con el error 229.
2. **Índices:** los dos índices reemplazan el recorrido de la tabla por una búsqueda en el árbol. Con 1500 filas reducen las lecturas entre un 44% y un 73%, y la ventaja aumenta a medida que la tabla crece.
