-- CREACIÓN DE LA BASE DE DATOS Y TABLAS
DROP DATABASE IF EXISTS andesbike;

CREATE DATABASE andesbike
CHARACTER SET  utf8mb4
COLLATE utf8mb4_unicode_ci;

USE andesbike

-- TABLA 1: TIENDAS
CREATE TABLE tiendas (
	id_tienda INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    comuna VARCHAR(80) NOT NULL
);

-- TABLA 2: VENDEDORES
CREATE TABLE vendedores (
	id_vendedor INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_tienda INT NULL,
    fecha_ingreso DATE NOT NULL,
    
    CONSTRAINT fk_vendedores_tiendas
    FOREIGN KEY (id_tienda)
    REFERENCES tiendas(id_tienda)
);

-- TABLA 3: BICICLETAS
CREATE TABLE bicicletas (
	id_bicicleta INT PRIMARY KEY,
    modelo VARCHAR(100) NOT NULL,
    categoria VARCHAR(20) NOT NULL,
    precio DECIMAL(12,2) NOT NULL,
    
    CONSTRAINT chk_categoria
    CHECK (categoria IN (
		'Montaña',
        'Ruta',
        'Urbana',
        'Infantil',
		'Eléctrica'
	)),
    
    CONSTRAINT chk_precio
    CHECK (precio >= 0)
);

-- TABLA 4: VENTAS
CREATE TABLE ventas (
	id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_vendedor INT NOT NULL,
    id_bicicleta INT NOT NULL,
    fecha DATE NOT NULL,
    unidades INT NOT NULL,
    
    CONSTRAINT chk_unidades
    CHECK (unidades > 0),
    
    CONSTRAINT fk_ventas_vendedores
    FOREIGN KEY (id_vendedor)
    REFERENCES vendedores(id_vendedor),
    
    CONSTRAINT fk_ventas_bicicletas
    FOREIGN KEY (id_bicicleta)
    REFERENCES bicicletas(id_bicicleta)
);

-- CARGA DE LOS DATOS
INSERT INTO tiendas
(id_tienda, nombre, comuna)
VALUES
(1, 'Andes Providencia', 'Providencia'),
(2, 'Andes Maipú', 'Maipú'),
(3, 'Andes Concepción', 'Concepción'),
(4, 'Andes La Serena', 'La Serena');

INSERT INTO vendedores
(id_vendedor, nombre, id_tienda, fecha_ingreso)
VALUES
(1, 'Camila Ortiz', 1, '2024-06-20'),
(2, 'Diego Fuentes', 1, '2024-01-15'),
(3, 'Javiera Soto', 2, '2023-07-24'),
(4, 'Matías Herrera', 2, '2024-01-15'),
(5, 'Paula Riquelme', 3, '2022-11-02'),
(6, 'Ignacio Vera', 3, '2024-08-19'),
(7, 'Fernanda Lillo', 1, '2025-02-03'),
(8, 'Rubén Castro', NULL, '2025-06-10');

INSERT INTO bicicletas
(id_bicicleta, modelo, categoria, precio)
VALUES
(1, 'Cordillera 29', 'Montaña', 549990.00),
(2, 'Ruta Austral', 'Ruta', 899990.00),
(3, 'Urbana Pro', 'Urbana', 329990.00),
(4, 'Pequeño Andes', 'Infantil', 149990.00),
(5, 'Volt City', 'Eléctrica', 1249990.00),
(6, 'Trail Master', 'Montaña', 749990.00),
(7, 'Urbana Lite', 'Urbana', 229990.00),
(8, 'Sprint R7', 'Ruta', 1099990.00);

INSERT INTO ventas
(id_vendedor, id_bicicleta, fecha, unidades)
VALUES
(1, 1, '2025-03-04', 2),
(4, 1, '2025-03-27', 1),
(1, 3, '2025-03-18', 1), 
(4, 5, '2025-05-09', 2),
(1, 5, '2025-04-02', 1),
(5, 2, '2025-04-08', 1),
(2, 2, '2025-03-04', 1),
(5, 6, '2025-04-23', 2),
(2, 1, '2025-04-11', 3),
(5, 4, '2025-06-02', 5),
(2, 7, '2025-05-06', 2),
(6, 3, '2025-05-13', 3),
(3, 4, '2025-03-21', 4),
(6, 7, '2025-06-17', 1),
(3, 3, '2025-04-15', 2),
(6, 1, '2025-06-24', 2),
(3, 6, '2025-05-20', 1),
(1, 6, '2025-06-30', 1);

-- VERIFICACIÓN DE LAS TABLAS
SELECT
    COUNT(*) AS total_ventas,
    SUM(v.unidades) AS total_unidades,
    SUM(v.unidades * b.precio) AS monto_total
FROM ventas AS v
JOIN bicicletas AS b
    ON v.id_bicicleta = b.id_bicicleta;

-- CONSULTA 1
SELECT
    vendedores.nombre AS vendedor,
    COUNT (ventas.id_venta) AS cantidad_ventas
FROM vendedores
LEFT JOIN ventas
    ON vendedores.id_vendedor = ventas.id_vendedor
GROUP BY vendedores.id_vendedor, vendedores.nombre
ORDER BY cantidad_ventas DESC, vendedor ASC;

-- CONSULTA 2
SELECT
    tiendas.nombre AS tienda,
    COUNT(ventas.id_venta) AS cantidad_ventas,
    COALESCE(SUM(ventas.unidades), 0) AS unidades_vendidas
FROM tiendas
LEFT JOIN vendedores
    ON tiendas.id_tienda = vendedores.id_tienda
LEFT JOIN ventas
    ON vendedores.id_vendedor = ventas.id_vendedor
GROUP BY tiendas.id_tienda, tiendas.nombre
ORDER BY unidades_vendidas DESC;

-- CONSULTA 3
SELECT
	tiendas.nombre AS tienda
FROM tiendas
LEFT JOIN vendedores
	ON tiendas.id_tienda = vendedores.id_tienda
WHERE vendedores.id_vendedor IS NULL;

-- CONSULTA 4
SELECT
    bicicletas.modelo
FROM bicicletas
LEFT JOIN ventas
    ON bicicletas.id_bicicleta = ventas.id_bicicleta
    AND ventas.fecha >= '2025-06-01'
    AND ventas.fecha < '2025-07-01'
WHERE ventas.id_venta IS NULL
ORDER BY bicicletas.modelo;

-- CONSULTA 5
SELECT
	vendedores.nombre AS vendedor,
    tiendas.nombre AS tienda
FROM vendedores
LEFT JOIN ventas
	ON vendedores.id_vendedor = ventas.id_vendedor
LEFT JOIN tiendas
	ON vendedores.id_tienda = tiendas.id_tienda
WHERE ventas.id_venta IS NULL
ORDER BY vendedores.nombre;

-- CONSULTA 6
SELECT
    vendedor1.nombre AS primer_vendedor,
    vendedor1.fecha_ingreso AS ingreso_primero,
    vendedor2.nombre AS segundo_vendedor,
    vendedor2.fecha_ingreso AS ingreso_segundo,
    tiendas.nombre AS tienda
FROM vendedores AS vendedor1
JOIN vendedores AS vendedor2
    ON vendedor1.id_tienda = vendedor2.id_tienda
    AND (
        vendedor1.fecha_ingreso < vendedor2.fecha_ingreso
        OR (
            vendedor1.fecha_ingreso = vendedor2.fecha_ingreso
            AND vendedor1.id_vendedor < vendedor2.id_vendedor
        )
    )
JOIN tiendas
    ON vendedor1.id_tienda = tiendas.id_tienda
ORDER BY
    tiendas.nombre,
    vendedor1.fecha_ingreso,
    vendedor1.nombre;

-- CONSULTA 7
SELECT
    tiendas.nombre AS tienda,
    SUM(ventas.unidades * bicicletas.precio) AS monto_total
FROM tiendas
JOIN vendedores
    ON tiendas.id_tienda = vendedores.id_tienda
JOIN ventas
    ON vendedores.id_vendedor = ventas.id_vendedor
JOIN bicicletas
    ON ventas.id_bicicleta = bicicletas.id_bicicleta
WHERE bicicletas.categoria IN ('Montaña', 'Ruta')
GROUP BY tiendas.id_tienda, tiendas.nombre
HAVING SUM(ventas.unidades * bicicletas.precio) > 2000000
ORDER BY monto_total DESC;

-- CONSULTA 8
SELECT
	bicicletas.modelo,
    bicicletas.precio
FROM bicicletas
WHERE bicicletas.precio > (
	SELECT AVG(precio)
    FROM bicicletas
)
ORDER BY bicicletas.precio DESC;

-- CONSULTA 9
SELECT
    vendedores.nombre AS vendedor,
    AVG(ventas.unidades) AS promedio_unidades
FROM vendedores
JOIN ventas
    ON vendedores.id_vendedor = ventas.id_vendedor
GROUP BY vendedores.id_vendedor, vendedores.nombre
HAVING AVG(ventas.unidades) > (
    SELECT AVG(unidades)
    FROM ventas
)
ORDER BY promedio_unidades DESC, vendedores.nombre ASC;

-- CONSULTA 10
SELECT
    vendedores.nombre AS vendedor,
    SUM(ventas.unidades * bicicletas.precio) AS monto_total
FROM vendedores
LEFT JOIN ventas
    ON vendedores.id_vendedor = ventas.id_vendedor
LEFT JOIN bicicletas
    ON ventas.id_bicicleta = bicicletas.id_bicicleta
GROUP BY vendedores.id_vendedor, vendedores.nombre
ORDER BY monto_total DESC, vendedores.nombre ASC;