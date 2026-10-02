CREATE DATABASE VentasETL;
GO
 
USE VentasETL;
GO
 
CREATE TABLE Cliente
(
IdCliente INT PRIMARY KEY,
Nombre VARCHAR(100)
);


CREATE TABLE Venta
(
IdVenta INT PRIMARY KEY,
FechaVenta DATE,
IdCliente INT,
Producto VARCHAR(100),
Cantidad INT,
PrecioUnitario DECIMAL(10,2),
ImporteTotal DECIMAL(12,2),
Estado VARCHAR(20),
 
CONSTRAINT FK_Venta_Cliente
FOREIGN KEY (IdCliente)
REFERENCES Cliente(IdCliente)



INSERT INTO Cliente
VALUES
(100,'Juan Perez'),
(101,'Maria Lopez'),
(102,'Carlos Diaz');
);