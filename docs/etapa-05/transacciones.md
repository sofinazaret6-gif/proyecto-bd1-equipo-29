# Manejo de Transacciones y Control de Concurrencia (ACID)

## 1. Identificación y Metadatos
- **Proyecto:** Sistema de Gestión Comercial — Panadería Tortuga
- **Etapa:** Etapa V — Temas Técnicos
- **Materia:** Bases de Datos I — FaCENA (UNNE)
- **Responsable:** Lucas Martín Zárate (DNI: 34936602) — Integrante 1
- **Archivo SQL asociado:** `sql/tecnico/transacciones/01_transaccion_venta_stock.sql`
- **Motor:** Microsoft SQL Server Express (T-SQL)

---

## 2. Descripción Técnica y Fundamentos Teóricos
Una transacción es una unidad lógica de trabajo indivisible compuesta por una secuencia de operaciones sobre la base de datos que deben cumplir rigurosamente las propiedades **ACID**:

- **Atomicidad (Atomicity):** Principio de "todo o nada". Todas las sentencias DML que integran la transacción se confirman de manera permanente (`COMMIT TRANSACTION`) o, ante cualquier excepción o fallo, la totalidad de los cambios se revierten íntegramente (`ROLLBACK TRANSACTION`), impidiendo que persistan estados parciales o registros huérfanos.
- **Consistencia (Consistency):** La transacción traslada a la base de datos de un estado válido a otro estado igualmente válido, respetando todas las reglas de integridad referencial (FK), unicidad de claves primarias (PK) y restricciones de dominio (`CHECK` de stock no negativo, cantidades positivas, etc.).
- **Aislamiento (Isolation):** Las operaciones transaccionales concurrentes que se ejecutan simultáneamente en los puestos de caja quedan aisladas entre sí, evitando anomalías como lecturas sucias (*dirty reads*), lecturas no repetibles o tuplas fantasma según el nivel configurado.
- **Durabilidad (Durability):** Una vez que el motor confirma la operación con `COMMIT`, los efectos sobre el catálogo, comprobantes y stock persisten de forma definitiva en disco (archivos `.mdf` y bitácora `.ldf`), resistiendo caídas del sistema o cortes de energía.

---

## 3. Justificación en el Caso de Estudio (Panadería Tortuga)
En el punto de venta de una panadería comercial, despachar un pedido no es una acción aislada, sino un circuito transaccional compuesto que impacta de manera sincronizada en cuatro tablas críticas:

1. **`[Venta]` (Cabecera):** Registra el comprobante fiscal, fecha de emisión, cliente y empleado que despacha, además del subtotal calculado.
2. **`[Detalle_Venta]` (Renglón de Comprobante):** Almacena el desglose de productos despachados (ej. Pan Francés), congelando la cantidad y el precio unitario histórico para garantizar la inmutabilidad contable.
3. **`[Stock]` (Inventario Físico):** Descuenta en tiempo real las existencias disponibles (`cantidad_actual = cantidad_actual - @cantidad`) para no comercializar mercadería inexistente.
4. **`[Movimiento_Stock]` (Auditoría Histórica):** Asienta la trazabilidad del egreso con sello de tiempo (`fecha_hora`), naturaleza (`'VENTA'`) y volumen descontado.

### Riesgo sin control transaccional
Si el sistema ejecutara estas sentencias en modo autocommit y ocurriera una interrupción imprevista (corte de energía en mostrador, desconexión de red, error aritmético o bloqueo de fila) tras insertar la cabecera en `[Venta]`, el dinero quedaría cobrado pero la mercadería no figuraría descontada ni justificada en detalle. La implementación mediante bloques estructurados `BEGIN TRY ... BEGIN TRANSACTION ... COMMIT ... END TRY BEGIN CATCH ... ROLLBACK ... END CATCH` blinda la operación, garantizando la reversión total ante imprevistos.

---

## 4. Escenarios de Prueba Implementados en el Script SQL

El script `sql/tecnico/transacciones/01_transaccion_venta_stock.sql` fue diseñado de manera idempotente (calculando dinámicamente `@id_venta` e `@id_movimiento-Stock` mediante `ISNULL(MAX(...), 0) + 1` para permitir múltiples ejecuciones sin colisión de claves) y ejecuta dos escenarios controlados:

### 4.1. Escenario 1: Transacción Exitosa de Venta con Descuento de Stock (COMMIT)
- **Objetivo:** Demostrar el flujo completo y atómico cuando no se presentan inconsistencias ni excepciones.
- **Operaciones encadenadas:**
  1. `INSERT INTO [Venta]` explicitando la columna `fecha` mediante `CAST(GETDATE() AS DATE)`.
  2. `INSERT INTO [Detalle_Venta]` registrando el producto y precio unitario histórico.
  3. `UPDATE [Stock]` decrementando la cantidad vendida.
  4. `INSERT INTO [Movimiento_Stock]` dejando constancia formal del egreso con tipo `'VENTA'`.
  5. `COMMIT TRANSACTION` para persistir los cambios definitivamente.
- **Comprobación post-ejecución:** Se ejecutan cuatro sentencias `SELECT` que verifican la presencia del comprobante, el renglón correspondiente, el stock actualizado y el registro de auditoría asociado.

### 4.2. Escenario 2: Demostración de Atomicidad mediante Error Intencional (ROLLBACK)
- **Objetivo:** Provocar deliberadamente una excepción tras haber insertado la cabecera del comprobante para verificar que el motor anula toda la unidad lógica sin dejar datos huérfanos.
- **Mecanismo de falla forzada:**
  1. Se ejecuta el `INSERT` de cabecera en `[Venta]` (id asignado en el espacio provisional de la transacción).
  2. Inmediatamente después, se induce un fallo en tiempo de ejecución mediante una **división por cero** (`SET @fallo_forzado = 1 / @divisor_cero`).
  3. La excepción aborta la secuencia antes de llegar al detalle, a la actualización de stock y al `COMMIT`.
  4. El flujo salta al bloque `BEGIN CATCH`, donde la guarda defensiva `IF @@TRANCOUNT > 0` ejecuta `ROLLBACK TRANSACTION`.
- **Comprobación empírica de atomicidad:**
  - `SELECT * FROM [Venta] WHERE id_venta = @id_venta_error;` $\rightarrow$ **0 filas devueltas**.
  - `SELECT * FROM [Detalle_Venta] WHERE id_venta = @id_venta_error;` $\rightarrow$ **0 filas devueltas**.
  - Se comprueba empíricamente que la venta del paso 1 fue deshecha en su totalidad y no existe registro parcial en la base de datos.