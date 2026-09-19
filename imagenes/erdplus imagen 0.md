```mermaid
erDiagram
    EMPLEADO ||--o{ VENTA : registra
    CLIENTE ||--o{ ASOCIA : asocia
    VENTA ||--o{ ASOCIA : contiene
    VENTA ||--o{ MEDIO_DE_PAGO : se_abona_con
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
        int id_producto FK
        int id_movimientoStock FK
    }

    PRODUCTO {
        int id_producto PK
        varchar nombreProd
        numeric precioActual
        int id_categoria FK
    }

    TIENE {
        int id_producto PK, FK
        int id_unidadMedida PK, FK
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
    }

    VENTA {
        int id_venta PK
        date fecha
        numeric subtotal
        time hora
        int dni_Empleado FK
        int id_medioPago FK
    }

    ASOCIA {
        int dni_Cliente PK, FK
        int id_venta PK, FK
    }

    INCLUYE {
        int id_venta PK, FK
        int id_producto PK, FK
        int cantidad
        numeric precioUnitario
    }

    MEDIO_DE_PAGO {
        int id_medioPago PK
        varchar descripcion
    }

    PARTICIPA_EN {
        int id_categoria PK, FK
        int id_Promocion PK, FK
    }
    