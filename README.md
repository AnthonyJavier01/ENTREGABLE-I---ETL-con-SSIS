# ETL de Carga y Validación de Ventas con SSIS

## Descripción

Este proyecto implementa un proceso ETL (Extract, Transform, Load) utilizando SQL Server Integration Services (SSIS) para procesar información de ventas almacenada en un archivo CSV y cargar únicamente los registros válidos en una base de datos SQL Server.

El proceso realiza validaciones de negocio, conversión de tipos de datos, cálculo de importes y validación de clientes mediante Lookup.

---

# Objetivo

Automatizar la carga de ventas garantizando que únicamente sean almacenadas en la base de datos aquellas que cumplan las reglas definidas por el negocio.

---

# Tecnologías Utilizadas

- SQL Server
- SQL Server Integration Services (SSIS)
- Visual Studio 2022
- SQL Server Integration Services Projects
- Archivo CSV como fuente de datos Ventas.csv

---

# Estructura del Proyecto

```text
ETLVentas
│
├── Package.dtsx
├── Project.params
│
├── Administradores de Conexiones
│   ├── CM_VentasCSV
│   ├── CM_VentasRechazadas
│   └── LocalHost.VentasETL
│
└── Flujo ETL
```

---

# Archivos Incluidos

## Archivo de Entrada prueba

**Ventas.csv**

```csv
IdVenta,FechaVenta,IdCliente,Producto,Cantidad,PrecioUnitario,Estado
1,2026-10-01,100,Laptop,2,1500,APROBADA
2,2026-10-01,100,Mouse,1,50,APROBADA
3,2026-10-01,101,Teclado,0,100,APROBADA
4,2026-10-01,102,Monitor,2,0,APROBADA
5,2026-10-01,100,Impresora,1,200,RECHAZADA
```

---

## Archivo de Rechazados

**VentasRechazadas.csv**

Archivo generado automáticamente por el proceso ETL para registrar las ventas rechazadas.

---

# Script SQL

## Crear Base de Datos

```sql
CREATE DATABASE VentasETL;
GO
```

---

## Crear Tabla Cliente

```sql
USE VentasETL;
GO

CREATE TABLE Cliente
(
    IdCliente INT PRIMARY KEY,
    Nombre VARCHAR(100)
);
```

---

## Insertar Datos de Clientes

```sql
INSERT INTO Cliente
VALUES
(100,'Juan Perez'),
(101,'Maria Lopez'),
(102,'Carlos Diaz');
```

---

## Crear Tabla Venta

```sql
CREATE TABLE Venta
(
    IdVenta INT PRIMARY KEY,
    FechaVenta DATE,
    IdCliente INT,
    Producto VARCHAR(100),
    Cantidad INT,
    PrecioUnitario DECIMAL(10,2),
    ImporteTotal DECIMAL(12,2),
    Estado VARCHAR(50)
);
```

---

# Flujo de Control (Control Flow)

El paquete contiene dos tareas:

## EST_LimpiarTablaVenta

Tarea de tipo Execute SQL Task que ejecuta la siguiente instrucción:

```sql
DELETE FROM Venta;
```

Su objetivo es limpiar la tabla antes de cada ejecución para evitar registros duplicados.

---

## DFT_Cargar_Ventas

Tarea de tipo Data Flow Task encargada de ejecutar todo el proceso ETL.

---

## Precedence Constraint

Se implementó un Precedence Constraint mediante una flecha verde que conecta ambas tareas.

```text
EST_LimpiarTablaVenta
          │
          ▼
DFT_Cargar_Ventas
```

Esto garantiza que la limpieza de la tabla se ejecute correctamente antes de iniciar la carga de datos.

---

# Flujo de Datos (Data Flow)

```text
Flat File Source
        │
        ▼
Data Conversion
        │
        ▼
Derived Column
        │
        ▼
Conditional Split
      /         \
     /           \
VentasValidas  VentasInvalidas
     │               │
     ▼               ▼
   Lookup      Flat File Destination
     │
     ▼
OLE DB Destination
```

---

# Componentes Utilizados

## 1. Flat File Source

Lee la información desde el archivo:

```text
Ventas.csv
```

---

## 2. Data Conversion

Convierte los tipos de datos del archivo CSV:

| Campo | Tipo Convertido |
|---------|---------|
| IdVenta | DT_I4 |
| IdCliente | DT_I4 |
| Cantidad | DT_I4 |
| PrecioUnitario | DT_NUMERIC |
| FechaVenta | DT_DBDATE |

---

## 3. Derived Column

Calcula el campo:

```text
ImporteTotal
```

Utilizando la fórmula:

```text
Cantidad × PrecioUnitario
```

Ejemplo:

```text
2 × 1500 = 3000
```

---

## 4. Conditional Split

Aplica las siguientes reglas de negocio:

```text
Cantidad > 0
AND
PrecioUnitario > 0
AND
Estado = APROBADA
```

### Registros válidos

Se envían al componente Lookup.

### Registros inválidos

Se envían al archivo:

```text
VentasRechazadas.csv
```

---

## 5. Lookup

Valida que el cliente exista en la tabla:

```sql
Cliente
```

Relación utilizada:

```text
IdCliente_Conv → Cliente.IdCliente
```

---

## 6. OLE DB Destination

Inserta las ventas válidas en la tabla:

```sql
Venta
```

---

# Reglas de Negocio Implementadas

Una venta será almacenada únicamente cuando:

```text
Cantidad > 0
```

```text
PrecioUnitario > 0
```

```text
Estado = APROBADA
```

```text
IdCliente exista en la tabla Cliente
```



# Cómo Ejecutar el Proyecto

## Paso 1

Abrir la solución:

```text
ETLVentas.slnx
```

en Visual Studio 2026.

---

## Paso 2

Ejecutar el script de creación de base de datos y tablas en SQL Server.

---

## Paso 3

Verificar que existan registros en la tabla Cliente.

```sql
SELECT * FROM Cliente;
```

---

## Paso 4

Verificar la ruta configurada en:

```text
CM_VentasCSV
```

y confirmar que el archivo:

```text
Ventas.csv
```

existe en dicha ubicación.

---

## Paso 5

Abrir el paquete:

```text
Package.dtsx
```

---

## Paso 6

Ejecutar el proyecto presionando:

```text
F5
```

o seleccionando:

```text
Start Debugging
```

---

## Paso 7

Verificar que todos los componentes se ejecuten correctamente.

---

## Paso 8

Validar los resultados ejecutando:

```sql
SELECT *
FROM Venta;
```

---

## Paso 9

Abrir y revisar el archivo:

```text
VentasRechazadas.csv
```

---
# Evidencias Entregadas

- Proyecto SSIS completo.
- Package.dtsx.
- Script SQL de creación de tablas.
- Archivo Ventas.csv.
- Archivo VentasRechazadas.csv.
- Captura del Control Flow.
- Captura del Data Flow.
- Captura de ejecución exitosa.
- Resultado de consulta a la tabla Venta.

---