-- PROCEDIMIENTOS ALMACENADOS
USE Tech_Haven;
/*
Crear un procedimiento almacenado para agregar un nuevo
producto
*/
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
CALL AgregarProducto('Sapo', 897.00, 'sirve pa muchas cosas')

/*
Crear un procedimiento almacenado para obtener los
detalles de un pedido
*/
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

CALL ObtenerDetallesPedido(1);

/*
Crear un procedimiento almacenado para actualizar el
precio de un producto
*/

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

CALL actualizar_producto(13, 'perro', 788, 'un perro que ladra no muelde praa');

/*
Crear un procedimiento almacenado para eliminar un
producto
*/

DELIMITER $$
DROP PROCEDURE IF EXISTS eliminar_producto;
CREATE PROCEDURE eliminar_producto(
    IN prametro1 INT
)
BEGIN
    DELETE FROM Productos WHERE id = prametro1;
END $$

DELIMITER ;

CALL eliminar_producto(13);

/*
Crear un procedimiento almacenado para obtener el total
gastado por un usuario
*/

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

CALL TotalGastadoPorUsuario(1);