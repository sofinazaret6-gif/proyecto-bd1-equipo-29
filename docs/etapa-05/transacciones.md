# Manejo de Transacciones y Control de Concurrencia (ACID)

## 1. Identificación y Metadatos
* **Proyecto:** Sistema de Gestión Comercial — Panadería Tortuga
* **Etapa:** Etapa V — Temas Técnicos
* **Materia:** Bases de Datos I — FaCENA (UNNE)
* **Responsable:** Lucas Martín Zárate (DNI: 34936602)
* **Archivo SQL asociado:** `sql/tecnico/transacciones/01_transaccion_venta_stock.sql`
* **Motor:** Microsoft SQL Server Express (T-SQL)

---

## 2. Descripción Técnica y Fundamentos Teóricos
Una transacción es una unidad lógica de trabajo compuesta por una o más sentencias SQL que deben ejecutarse bajo las propiedades **ACID**:
* **Atomicidad (Atomicity):** Todas las operaciones que conforman el circuito se confirman de forma permanente (`COMMIT`) o, ante cualquier imprevisto, se anula la totalidad sin persistir datos a medias (`ROLLBACK`).
* **Consistencia (Consistency):** La base de datos pasa de un estado íntegro válido a otro igualmente válido, sin vulnerar claves primarias, foráneas ni restricciones `CHECK`.
* **Aislamiento (Isolation):** Las operaciones simultáneas de caja no interfieren entre sí ni visualizan lecturas sucias durante la operación.
* **Durabilidad (Durability):** Una vez confirmada la venta, los cambios persisten de manera definitiva ante fallas de energía o reinicio del motor.

---

## 3. Justificación en el Caso de Estudio (Panadería Tortuga)
En el punto de venta de la panadería, registrar una venta no es una sentencia aislada. Es una operación compuesta que afecta simultáneamente a tres tablas críticas:
1. **`Venta`:** Alta de la cabecera del comprobante con su importe general.
2. **`Detalle-Venta`:** Registro de los renglones de artículos despachados y precios pactados.
3. **`Stock` / `Movimiento-Stock`:** Descuento físico de las existencias y asentamiento del movimiento histórico.

Si el sistema registra la cabecera de la venta pero ocurre una falla al insertar los renglones o al descontar el inventario (por ejemplo, por corte eléctrico, falla de red o falta de stock), la base de datos quedaría en un estado corrupto (dinero cobrado sin mercadería asentada). La implementación de un bloque transaccional controlado mediante `BEGIN TRY ... BEGIN TRANSACTION ... COMMIT ... END TRY BEGIN CATCH ... ROLLBACK ... END CATCH` blindará el sistema frente a estas anomalías.

---

## 4. Escenarios de Prueba Diseñados
Para validar el cumplimiento de las propiedades de la transacción, el script asociado ejecuta dos casos:
* **Escenario de Éxito (Transacción Exitosa):** Inserción completa y consistente en `Venta`, `Detalle-Venta` y descuento en `Stock`, cerrando con `COMMIT TRANSACTION`.
* **Escenario de Fallo Forzado (Demostración de Rollback):** Se fuerza un error deliberado (violación de restricción o error matemático inducido) tras haber insertado la cabecera de la venta, comprobando que el bloque `CATCH` captura la excepción, ejecuta `ROLLBACK TRANSACTION` y no deja ningún registro huérfano persistido en ninguna tabla.