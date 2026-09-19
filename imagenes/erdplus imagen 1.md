```mermaid
erDiagram
    EMPLEADO ||--o{ VENTA : registra
    CLIENTE ||--o{ ASOCIA : asocia
    VENTA ||--o{ ASOCIA : asocia
    VENTA ||--o{ VENTA_MEDIO_PAGO : se_abona_con
    MEDIO_DE_PAGO ||--o{ VENTA_MEDIO_PAGO : incluye
    VENTA ||--|{ INCLUYE : contiene
    PRODUCTO ||--o{ INCLUYE : compone
    CATEGORIA ||--o{ PRODUCTO : clasifica
    STOCK ||--|| PRODUCTO : posee
    STOCK ||--o{ MOVIMIENTO_STOCK : registra
    CATEGORIA ||--o{ PARTICIPA_EN : aplica
    PROMOCION ||--|{ PARTICIPA_EN : incluye
    PRODUCTO ||--o{ TIENE : presenta
    UNIDAD_MEDIDA ||--o{ TIENE : define

    CLIENTE {
        int dni_Cliente PK
        varchar nombreCliente
        varchar apellido
    }

    EMPLEADO {
        int dni_Empleado PK
        varchar nombreEmpleado
        varchar apellidoEmpleado
        varchar turnoEmpleado
    }

    PROMOCION {
        int id_Promocion PK
        varchar descripcion
        int tipoPromocion
        numeric Valor
        date fechainicio
        date fechaFin
    }

    CATEGORIA {
        int id_categoria PK
        varchar descripcion
    }

    STOCK {
        int id_stock PK
        int stockMin
        int cantActual
    }

    PRODUCTO {
        int id_producto PK
        varchar nombreProd
        numeric precioActual
        int id_categoria FK
        int id_stock FK
    }

    TIENE {
        int id_productoUnitario PK
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
        int id_movimientoStock PK
        date fecha_Hora
        varchar tipoMovimiento
        int cantidad
        int id_stock FK
    }

    VENTA {
        int id_venta PK
        date fecha
        numeric subtotal
        time hora
        int dni_Empleado FK
    }

    ASOCIA {
        int dni_Cliente PK, FK
        int id_venta PK, FK
    }

    INCLUYE {
        int id_venta PK, FK
        int id_producto PK, FK
        int cantidad
        numeric precio_unitario
        varchar nombreProd
    }

    MEDIO_DE_PAGO {
        int id_medioPago PK
        varchar descripcion
    }

    VENTA_MEDIO_PAGO {
        int id_ventaMedioPago PK
        numeric importe
        int id_venta FK
        int id_medioPago FK
    }

    PARTICIPA_EN {
        int id_categoria PK
        int id_Promocion PK
    }





    ```
