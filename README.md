## Nombre : 
### Juan David Eliezer Gomez Meza

## Base De datos Asignada:
###  Alfonso Brandon Camargo Florez


## Respuestas

~~~~mysql
USE Tech_Haven;
~~~~


1. Obtener la lista de todos los productos con sus precio

~~~~mysql
SELECT P.nombre  AS nombre, P.precio AS precio
FROM Productos AS P;
~~~~

2. Encontrar todos los pedidos realizados por un usuario específico, por ejemplo, Juan Perez

~~~~mysql
SELECT P.id AS id , P.fecha AS fecha, P.total AS total
FROM Usuarios AS U
INNER JOIN Pedidos AS P ON U.id = P.id_usuario
WHERE U.nombre = 'Juan Perez';
~~~~

3. Listar los detalles de todos los pedidos, incluyendo el nombre del producto, cantidad y precio
unitario

~~~~mysql
SELECT PD.id_pedido AS PedidoID, PR.nombre AS Producto, PD.cantidad AS cantidad , PD.precio_unitario AS precio_unitario
FROM Productos AS PR 
INNER JOIN DetallesPedidos AS PD ON PR.id = PD.id_producto;
~~~~

4. Calcular el total gastado por cada usuario en todos sus pedidos


~~~~mysql
SELECT U.nombre AS nombre , PD.total AS TotalGastado
FROM Usuarios AS U
INNER JOIN Pedidos AS PD ON U.id = PD.id_usuario;
~~~~

5. Encontrar los productos más caros (precio mayor a $500)

~~~~mysql
SELECT nombre , precio
FROM Productos
WHERE precio > 500;
~~~~

6. Listar los pedidos realizados en una fecha específica, por ejemplo, 2024-03-10

~~~~mysql
SELECT id , id_usuario, fecha, total
FROM Pedidos 
WHERE fecha = '2024-03-10';
~~~~

7. Obtener el número total de pedidos realizados por cada usuario

~~~~mysql
SELECT U.nombre AS nombre , COUNT(P.id) AS NumeroDePedidos
FROM Usuarios AS U
INNER JOIN Pedidos AS P ON U.id = P.id_usuario
GROUP BY nombre;
~~~~

8. Encontrar el nombre del producto más vendido (mayor cantidad total vendida)

~~~~mysql
WITH stock_umbral AS (
    SELECT PD.nombre AS nombre, DP.cantidad AS CantidadTotal
    FROM Productos AS PD
    INNER JOIN DetallesPedidos AS DP ON PD.id = DP.id_producto
)
SELECT 
    nombre, 
    CantidadTotal
FROM stock_umbral
WHERE CantidadTotal = (SELECT MAX(CantidadTotal) FROM stock_umbral);
~~~~

9. Listar todos los usuarios que han realizado al menos un pedido

~~~~mysql
SELECT U.nombre, U.correo_electronico
FROM Usuarios AS U
INNER JOIN Pedidos AS P ON U.id = P.id_usuario;
~~~~

10. Obtener los detalles de un pedido específico, incluyendo los productos y cantidades, por
ejemplo, pedido con id 1

~~~~mysql
SELECT  PD.id AS PedidoID,
        U.nombre AS Usuario,
        PR.nombre AS Producto,
        DP.cantidad AS cantidad,
        DP.precio_unitario AS precio_unitario
FROM Usuarios AS U
INNER JOIN Pedidos AS PD ON U.id = PD.id_usuario
INNER JOIN DetallesPedidos AS DP ON PD.id = DP.id_pedido
INNER JOIN Productos AS PR ON DP.id_producto = PR.id
WHERE PD.id = 1; 
~~~~
## SUBCONSULTAS


1. Encontrar el nombre del usuario que ha gastado más en total

~~~~mysql
WITH gasto_mayor AS (
    SELECT  PD.id AS PedidoID,
        U.nombre AS Usuario,
        SUM(DP.precio_unitario)AS precio_unitario
FROM Usuarios AS U
INNER JOIN Pedidos AS PD ON U.id = PD.id_usuario
INNER JOIN DetallesPedidos AS DP ON PD.id = DP.id_pedido
INNER JOIN Productos AS PR ON DP.id_producto = PR.id
GROUP BY PedidoID, Usuario
)
SELECT Usuario AS nombre
FROM gasto_mayor
WHERE precio_unitario = (SELECT MAX(precio_unitario) FROM gasto_mayor);
~~~~

2. Listar los productos que han sido pedidos al menos una vez


~~~~mysql
SELECT P.nombre
FROM Productos  AS P
INNER JOIN DetallesPedidos AS DP ON P.id = DP.id_producto
INNER JOIN Productos AS PR ON DP.id_producto = PR.id;
~~~~

3. Obtener los detalles del pedido con el total más alto

~~~~mysql
SELECT PedidoID AS id, ID_usuario AS id_usuario , fecha, Cantidad_gastado_X_Usuario AS total
FROM vista_detalles_usuario
WHERE Cantidad_gastado_X_Usuario = (SELECT MAX(Cantidad_gastado_X_Usuario) FROM vista_detalles_usuario);
~~~~


4. Listar los usuarios que han realizado más de un pedido


~~~~mysql
WITH MAX_Pedidos AS (
        SELECT U.nombre AS nombre , COUNT(id_pedido) AS cantidad_X_Usuario
        FROM Usuarios AS U
            INNER JOIN Pedidos AS P ON U.id = P.id_usuario
            INNER JOIN DetallesPedidos AS DP ON P.id = DP.id_pedido
            GROUP BY nombre
)
SELECT nombre 
FROM MAX_Pedidos
WHERE cantidad_X_Usuario = (SELECT max(cantidad_X_Usuario) FROM MAX_Pedidos);
~~~~

5. Encontrar el producto más caro que ha sido pedido al menos una vez


~~~~mysql
WITH MAX_pruducto AS (
    SELECT P.nombre AS nombre , P.precio AS precio
    FROM Productos  AS P
    INNER JOIN DetallesPedidos AS DP  ON P.id = DP.id_producto
)
SELECT nombre, precio
FROM MAX_pruducto
WHERE precio = (SELECT max(precio) FROM `MAX_pruducto`);
~~~~
## PROCEDIMIENTOS ALMACENADOS


-  Crear un procedimiento almacenado para agregar un nuevo
producto

~~~~mysql
DELIMITER $$
DROP PROCEDURE IF EXISTS AgregarProducto;
CREATE PROCEDURE AgregarProducto(
    IN nombre VARCHAR(100),
    IN precio DECIMAL(10,2),
    IN descripcion TEXT
)
BEGIN
    DECLARE mensaje VARCHAR(100);
    INSERT INTO Productos (nombre, precio, descripcion) 
    VALUES (nombre, precio, descripcion);


    IF ROW_COUNT() > 0 THEN
        SET mensaje = 'El registro se ha creado correctamente.';
    ELSE
        SET mensaje = 'Error al crear el registro.';
    END IF;
    SELECT mensaje AS 'Mensaje';
END $$
DELIMITER ;
~~~~
~~~~mysql
CALL AgregarProducto('Sapo', 897.00, 'sirve pa muchas cosas')
~~~~

- Crear un procedimiento almacenado para obtener los
detalles de un pedido
~~~~mysql
DELIMITER $$
DROP PROCEDURE IF EXISTS ObtenerDetallesPedido;
CREATE PROCEDURE ObtenerDetallesPedido(
    IN parametro1 INT
)
BEGIN
    SELECT  PD.id AS PedidoID,
            U.nombre AS Usuario,
            PR.nombre AS Producto,
            DP.cantidad AS cantidad,
            DP.precio_unitario AS precio_unitario
    FROM Usuarios AS U
    INNER JOIN Pedidos AS PD ON U.id = PD.id_usuario
    INNER JOIN DetallesPedidos AS DP ON PD.id = DP.id_pedido
    INNER JOIN Productos AS PR ON DP.id_producto = PR.id
    WHERE PD.id  = parametro1;
END $$

DELIMITER ;
~~~~
~~~~mysql
CALL ObtenerDetallesPedido(1);
~~~~

- Crear un procedimiento almacenado para actualizar el
precio de un producto

~~~~mysql
DELIMITER $$
DROP PROCEDURE IF EXISTS actualizar_producto;
CREATE PROCEDURE actualizar_producto(
    IN N_id INT,
    IN N_nombre VARCHAR(100),
    IN N_precio DECIMAL(10,2),
    IN N_descripcion TEXT
)
BEGIN
UPDATE Productos
SET 
    id = N_id,
    nombre = N_nombre,
    precio = N_precio,
    descripcion = N_descripcion
WHERE id = N_id;
END $$

DELIMITER ;
~~~~
~~~~mysql
CALL actualizar_producto(13, 'perro', 788, 'un perro que ladra no muelde praa');
~~~~

- Crear un procedimiento almacenado para eliminar un
producto

~~~~mysql
DELIMITER $$
DROP PROCEDURE IF EXISTS eliminar_producto;
CREATE PROCEDURE eliminar_producto(
    IN prametro1 INT
)
BEGIN
    DELETE FROM Productos WHERE id = prametro1;
END $$

DELIMITER ;
~~~~
~~~~mysql
CALL eliminar_producto(13);
~~~~

- Crear un procedimiento almacenado para obtener el total
gastado por un usuario

~~~~mysql
DELIMITER $$
DROP PROCEDURE IF EXISTS TotalGastadoPorUsuario;
CREATE PROCEDURE TotalGastadoPorUsuario(
    IN prametro1 INT
)
BEGIN
SELECT  DISTINCT
        U.id AS id_usuario,
        PD.id AS id_pedido,
        U.nombre AS nombre,
        SUM(DP.precio_unitario) AS Cantidad_gastado_X_Usuario
FROM Usuarios AS U
INNER JOIN Pedidos AS PD ON U.id = PD.id_usuario
INNER JOIN DetallesPedidos AS DP ON PD.id = DP.id_pedido
INNER JOIN Productos AS PR ON DP.id_producto = PR.id
WHERE U.id = prametro1
GROUP BY id_usuario, id_pedido, nombre;
END $$
DELIMITER ;

~~~~

~~~~mysql
CALL TotalGastadoPorUsuario(1);
~~~~