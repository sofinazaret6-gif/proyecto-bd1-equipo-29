```mermaid
erDiagram
    EMPLEADO ||--o{ VENTA : registra
    CLIENTE ||--o{ VENTA : asocia
    VENTA ||--o{ VENTA_MEDIO_PAGO : se_abona_con
    MEDIO_PAGO ||--o{ VENTA_MEDIO_PAGO : incluye
    VENTA ||--|{ DETALLE_VENTA : contiene
    PRODUCTO ||--o{ DETALLE_VENTA : compone
    CATEGORIA ||--o{ PRODUCTO : clasifica
    STOCK ||--|| PRODUCTO : posee
    STOCK ||--o{ MOVIMIENTO_STOCK : registra
    CATEGORIA ||--o{ CATEGORIA_PROMOCION : aplica
    PROMOCION ||--|{ CATEGORIA_PROMOCION : incluye
    TIPO_PROMOCION ||--o{ PROMOCION : tipifica
    PRODUCTO ||--o{ PRODUCTO_UNIDAD : presenta
    UNIDAD_MEDIDA ||--o{ PRODUCTO_UNIDAD : define

    CLIENTE {
        int DNI_cliente PK
        varchar Nombre
        varchar Apellido
        bit activo
    }

    EMPLEADO {
        int DNI_empleado PK
        varchar Nombre
        varchar Apellido
        varchar Turno_Laboral
        bit activo
    }

    PROMOCION {
        int id_promocion PK
        varchar descripcion
        date fecha_inicio
        date fecha_fin
        bit activo
        int id_tipoPromocion FK
    }

    TIPO_PROMOCION {
        int id_tipoPromocion PK
        varchar descripcion
        numeric valor
    }

    CATEGORIA {
        int id_categoria PK
        varchar descripcion
        bit activo
    }

    STOCK {
        int id_stock PK
        numeric cantidad_actual
        numeric stock_minimo
    }

    PRODUCTO {
        int id_producto PK
        varchar nombre
        numeric precio_unitario
        int id_categoria FK
        int id_stock FK
        bit activo
    }

    PRODUCTO_UNIDAD {
        int id_productoUnidad PK
        numeric conversion
        int id_producto FK
        int id_unidadMedida FK
    }

    UNIDAD_MEDIDA {
        int id_unidadMedida PK
        varchar descripcion
        char abreviatura
    }

    MOVIMIENTO_STOCK {
        int id_movimiento_Stock PK
        datetime fecha_hora
        varchar tipo_movimiento
        numeric cantidad
        int id_stock FK
    }

    VENTA {
        int id_venta PK
        numeric subtotal
        int DNI_cliente FK
        int DNI_empleado FK
        date fecha
        time hora
    }

    DETALLE_VENTA {
        int id_venta PK, FK
        numeric cantidad
        numeric precio_unitario
        int id_producto PK, FK
    }

    MEDIO_PAGO {
        int id_medioPago PK
        varchar descripcion
        bit activo
    }

    VENTA_MEDIO_PAGO {
        int id_venta_MedioPago PK
        numeric importe
        int id_venta FK
        int id_medioPago FK
    }

    CATEGORIA_PROMOCION {
        int id_categoriaPromocion PK
        int id_categoria FK
        int id_promocion FK
    }
