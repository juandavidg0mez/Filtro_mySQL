DROP DATABASE Tech_Haven;
CREATE DATABASE Tech_Haven;
USE Tech_Haven;
CREATE TABLE Productos(
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    descripcion TEXT NOT NULL
);

CREATE TABLE Usuarios(
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100),
    fecha_registro DATE NOT NULL
);

CREATE TABLE Pedidos(
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    fecha DATE,
    total DECIMAL(10,2),
    Foreign Key (id_usuario) REFERENCES Usuarios(id)
);

CREATE TABLE DetallesPedidos(
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    Foreign Key (id_pedido) REFERENCES Pedidos(id),
    Foreign Key (id_producto) REFERENCES Productos(id)
);
SHOW TABLEs;

-- =========================================
                -- CRECION VISTAS
-- =========================================
DROP  VIEW vista_detalles_usuario;
CREATE VIEW vista_detalles_usuario AS 
    SELECT  DISTINCT
        U.id AS ID_usuario,
        PD.id AS PedidoID,
        U.nombre AS Usuario,
        PD.total AS Cantidad_gastado_X_Usuario,
        PD.fecha AS fecha
FROM Usuarios AS U
INNER JOIN Pedidos AS PD ON U.id = PD.id_usuario
INNER JOIN DetallesPedidos AS DP ON PD.id = DP.id_pedido
INNER JOIN Productos AS PR ON DP.id_producto = PR.id;
