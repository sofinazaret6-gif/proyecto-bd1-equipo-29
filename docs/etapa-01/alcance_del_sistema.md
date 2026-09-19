# Alcance del Sistema

El sistema está diseñado para cubrir el ciclo completo de la operación de venta de una panadería, sin incorporar funcionalidades que excedan la escala del negocio al que está dirigido.

## Funcionalidades Principales

El sistema contempla los siguientes módulos y capacidades:

* **Punto de Venta (POS):** Registro de ventas con soporte para múltiples productos por ticket y formas de pago combinadas (por ejemplo, una parte en efectivo y otra con tarjeta).
* **Gestión de Catálogo:** Administración de categorías, unidades de medida (unidad, kilogramo, docena) y precios, adaptado a la lógica particular de una panadería donde conviven productos que se venden por peso y por unidad.
* **Control de Stock:** Actualización en tiempo real con cada venta y compra, incorporando alertas de stock mínimo para anticipar faltantes de insumos o productos terminados.
* **Compras a Proveedores:** Registro para mantener la trazabilidad en la reposición de stock y el control de costos.
* **Gestión de Clientes (Opcional):** Pensada para casos de cuenta corriente o fidelización, sin ser un requisito obligatorio para operar (una venta de mostrador estándar no requiere cliente registrado).
* **Promociones y Descuentos:** Herramientas simples acordes a las prácticas habituales del rubro ($2 \times 1$, descuentos por cantidad, entre otros).
* **Reportes de Gestión:** Métricas esenciales como ventas por día, por producto, por empleado y productos más vendidos, sirviendo como insumo clave para la toma de decisiones del dueño.

---

## Fuera de Alcance (Exclusiones Deliberadas)

Deliberadamente, el sistema **no incluye** módulos complejos de gestión de caja como componentes separados. 

Dado que se trata de un local de escala reducida, la sesión de trabajo del sistema coincide con la operación diaria del negocio (se abre al comenzar las ventas y se cierra al finalizar la jornada). Por lo tanto, agregar una capa adicional de apertura y cierre de turno se considera redundante frente a la forma real en que opera este tipo de comercio.