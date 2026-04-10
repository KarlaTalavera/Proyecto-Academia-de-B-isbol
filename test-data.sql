-- ================================================================
--  LIGA DIAMANTE — Datos de prueba completos (v2 Normalizada)
--  Ejecutar DESPUÉS de liga-diamante-v2.sql
-- ================================================================

USE `liga_diamante`;

SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM seguimiento;
DELETE FROM sancion;
DELETE FROM desempeno_pitcher;
DELETE FROM desempeno_bateador;
DELETE FROM lineup;
DELETE FROM resultado;
DELETE FROM partido;
DELETE FROM ingreso;
DELETE FROM egreso;
DELETE FROM proveedor;
DELETE FROM inscripcion;
DELETE FROM jugador;
DELETE FROM usuario;
DELETE FROM equipo;
DELETE FROM temporada;
ALTER TABLE temporada          AUTO_INCREMENT = 1;
ALTER TABLE equipo             AUTO_INCREMENT = 1;
ALTER TABLE inscripcion        AUTO_INCREMENT = 1;
ALTER TABLE jugador            AUTO_INCREMENT = 1;
ALTER TABLE usuario            AUTO_INCREMENT = 1;
ALTER TABLE partido            AUTO_INCREMENT = 1;
ALTER TABLE resultado          AUTO_INCREMENT = 1;
ALTER TABLE lineup             AUTO_INCREMENT = 1;
ALTER TABLE desempeno_bateador AUTO_INCREMENT = 1;
ALTER TABLE desempeno_pitcher  AUTO_INCREMENT = 1;
ALTER TABLE proveedor          AUTO_INCREMENT = 1;
ALTER TABLE ingreso            AUTO_INCREMENT = 1;
ALTER TABLE egreso             AUTO_INCREMENT = 1;
ALTER TABLE sancion            AUTO_INCREMENT = 1;
ALTER TABLE seguimiento        AUTO_INCREMENT = 1;
SET FOREIGN_KEY_CHECKS = 1;

-- ── TEMPORADAS ──────────────────────────────────────────────
INSERT INTO temporada (nombre, anio, categoria, costo_inscripcion, activa) VALUES
('Temporada Apertura 2025', 2025, 'Semi-profesional', 5000.00, 0),
('Temporada Clausura 2026', 2026, 'Semi-profesional', 5500.00, 1),
('Temporada Juvenil 2025',  2025, 'Juvenil',          2000.00, 0);

-- ── EQUIPOS (8 equipos) ─────────────────────────────────────
INSERT INTO equipo (nombre_equipo, entrenador, responsable, email, telefono) VALUES
('Leones de Caracas',         'Carlos Mendoza',   'Luis Martínez',   'leones@ligadiamante.com',     '0412-1234567'),
('Tigres de Aragua',          'José Rodríguez',   'Pedro Gómez',     'tigres@ligadiamante.com',     '0414-2345678'),
('Águilas del Zulia',         'Miguel Hernández', 'Ana López',       'aguilas@ligadiamante.com',    '0416-3456789'),
('Navegantes del Magallanes', 'Roberto Silva',    'María González',  'navegantes@ligadiamante.com', '0424-4567890'),
('Caribes de Anzoátegui',     'Fernando Torres',  'Jorge Pérez',     'caribes@ligadiamante.com',    '0412-5678901'),
('Bravos de Margarita',       'Andrés Morales',   'Carmen Díaz',     'bravos@ligadiamante.com',     '0414-6789012'),
('Cardenales de Lara',        'Ricardo Vargas',   'Elena Ramírez',   'cardenales@ligadiamante.com', '0416-7890123'),
('Tiburones de La Guaira',    'Daniel Castillo',  'Patricia Rojas',  'tiburones@ligadiamante.com',  '0424-8901234');

-- ── INSCRIPCIONES (equipo ↔ temporada) ──────────────────────
INSERT INTO inscripcion (id_equipo, id_temporada, fecha_inscripcion, estado_pago, monto_pagado) VALUES
-- Apertura 2025: 6 equipos
(1, 1, '2025-01-10', 'pagado', 5000.00),
(2, 1, '2025-01-12', 'pagado', 5000.00),
(3, 1, '2025-01-14', 'pagado', 5000.00),
(4, 1, '2025-01-15', 'pagado', 5000.00),
(5, 1, '2025-01-16', 'pagado', 5000.00),
(6, 1, '2025-01-18', 'pagado', 5000.00),
-- Clausura 2026: 8 equipos
(1, 2, '2026-02-01', 'pagado',    5500.00),
(2, 2, '2026-02-02', 'pagado',    5500.00),
(3, 2, '2026-02-03', 'pagado',    5500.00),
(4, 2, '2026-02-04', 'pagado',    5500.00),
(5, 2, '2026-02-05', 'pagado',    5500.00),
(6, 2, '2026-02-06', 'pagado',    5500.00),
(7, 2, '2026-02-07', 'pendiente', 0.00),
(8, 2, '2026-02-08', 'pendiente', 0.00);

-- ── JUGADORES (10 por equipo = 80 jugadores) ────────────────
INSERT INTO jugador (id_equipo, cedula, nombre, apellido, fecha_nacimiento, rol, posicion, brazo_dominante) VALUES
-- Equipo 1: Leones de Caracas (jugadores 1-10)
(1, 'V-20123456', 'Andrés',   'García',    '1995-03-15', 'pitcher',   'P',  'derecho'),
(1, 'V-21234567', 'Carlos',   'Ramírez',   '1998-07-22', 'bateador',  'C',  'derecho'),
(1, 'V-22345678', 'Daniel',   'Moreno',    '1996-11-08', 'bateador',  '1B', 'izquierdo'),
(1, 'V-23456789', 'Eduardo',  'Pérez',     '1999-01-30', 'bateador',  '2B', 'derecho'),
(1, 'V-24567890', 'Fernando', 'López',     '1997-05-12', 'bateador',  '3B', 'derecho'),
(1, 'V-25678901', 'Gabriel',  'Hernández', '2000-09-18', 'bateador',  'SS', 'derecho'),
(1, 'V-26789012', 'Héctor',   'Martínez',  '1994-12-05', 'bateador',  'LF', 'izquierdo'),
(1, 'V-27890123', 'Ignacio',  'Torres',    '1998-04-20', 'bateador',  'CF', 'derecho'),
(1, 'V-28901234', 'Julián',   'Castro',    '1997-08-14', 'bateador',  'RF', 'derecho'),
(1, 'V-29012345', 'Kevin',    'Díaz',      '2001-02-28', 'pitcher',   'P',  'izquierdo'),
-- Equipo 2: Tigres de Aragua (jugadores 11-20)
(2, 'V-30123456', 'Luis',     'Navarro',   '1996-06-10', 'pitcher',   'P',  'derecho'),
(2, 'V-31234567', 'Marcos',   'Vargas',    '1999-10-25', 'bateador',  'C',  'derecho'),
(2, 'V-32345678', 'Nelson',   'Jiménez',   '1997-03-07', 'bateador',  '1B', 'derecho'),
(2, 'V-33456789', 'Oscar',    'Medina',    '1998-08-19', 'bateador',  '2B', 'derecho'),
(2, 'V-34567890', 'Pablo',    'Rojas',     '2000-01-14', 'bateador',  '3B', 'izquierdo'),
(2, 'V-35678901', 'Rafael',   'Sánchez',   '1995-11-22', 'bateador',  'SS', 'derecho'),
(2, 'V-36789012', 'Samuel',   'Rivas',     '1999-04-30', 'bateador',  'LF', 'izquierdo'),
(2, 'V-37890123', 'Tomás',    'Acosta',    '1996-09-08', 'bateador',  'CF', 'derecho'),
(2, 'V-38901234', 'Uriel',    'Blanco',    '1998-12-16', 'bateador',  'RF', 'derecho'),
(2, 'V-39012345', 'Víctor',   'Flores',    '2001-06-03', 'pitcher',   'P',  'derecho'),
-- Equipo 3: Águilas del Zulia (jugadores 21-30)
(3, 'V-40123456', 'William',  'Delgado',   '1997-02-14', 'pitcher',   'P',  'izquierdo'),
(3, 'V-41234567', 'Xavier',   'Gutiérrez', '1998-05-20', 'bateador',  'C',  'derecho'),
(3, 'V-42345678', 'Yohan',    'Paredes',   '1996-10-11', 'bateador',  '1B', 'derecho'),
(3, 'V-43456789', 'Adrián',   'Quintero',  '1999-03-28', 'bateador',  '2B', 'derecho'),
(3, 'V-44567890', 'Brandon',  'Urdaneta',  '2000-07-15', 'bateador',  '3B', 'derecho'),
(3, 'V-45678901', 'Cristian', 'Zambrano',  '1995-12-01', 'bateador',  'SS', 'derecho'),
(3, 'V-46789012', 'Diego',    'Andrade',   '1998-06-18', 'bateador',  'LF', 'izquierdo'),
(3, 'V-47890123', 'Emilio',   'Briceño',   '1997-01-25', 'bateador',  'CF', 'derecho'),
(3, 'V-48901234', 'Franco',   'Colmenares','1999-09-09', 'bateador',  'RF', 'derecho'),
(3, 'V-49012345', 'Gerardo',  'Dávila',    '2001-04-17', 'pitcher',   'P',  'derecho'),
-- Equipo 4: Navegantes del Magallanes (jugadores 31-40)
(4, 'V-50123456', 'Hugo',     'Espinoza',  '1996-08-22', 'pitcher',   'P',  'derecho'),
(4, 'V-51234567', 'Iván',     'Figueroa',  '1999-11-30', 'bateador',  'C',  'derecho'),
(4, 'V-52345678', 'Jorge',    'Galindo',   '1997-04-05', 'bateador',  '1B', 'izquierdo'),
(4, 'V-53456789', 'Kelvin',   'Herrera',   '1998-07-13', 'bateador',  '2B', 'derecho'),
(4, 'V-54567890', 'Leonardo', 'Ibarra',    '2000-02-20', 'bateador',  '3B', 'derecho'),
(4, 'V-55678901', 'Manuel',   'Jaimes',    '1995-10-08', 'bateador',  'SS', 'derecho'),
(4, 'V-56789012', 'Néstor',   'Leal',      '1999-01-16', 'bateador',  'LF', 'izquierdo'),
(4, 'V-57890123', 'Orlando',  'Manzano',   '1996-05-24', 'bateador',  'CF', 'derecho'),
(4, 'V-58901234', 'Pedro',    'Noguera',   '1998-10-02', 'bateador',  'RF', 'derecho'),
(4, 'V-59012345', 'Quintín',  'Olivares',  '2001-03-11', 'pitcher',   'P',  'izquierdo'),
-- Equipo 5: Caribes de Anzoátegui (jugadores 41-50)
(5, 'V-60123456', 'Ramón',    'Palacios',  '1997-06-28', 'pitcher',   'P',  'derecho'),
(5, 'V-61234567', 'Simón',    'Quijada',   '1998-09-15', 'bateador',  'C',  'derecho'),
(5, 'V-62345678', 'Tulio',    'Requena',   '1996-12-22', 'bateador',  '1B', 'derecho'),
(5, 'V-63456789', 'Ulises',   'Salazar',   '1999-05-08', 'bateador',  '2B', 'derecho'),
(5, 'V-64567890', 'Valentín', 'Trujillo',  '2000-08-30', 'bateador',  '3B', 'izquierdo'),
(5, 'V-65678901', 'Wilson',   'Ugueto',    '1995-03-18', 'bateador',  'SS', 'derecho'),
(5, 'V-66789012', 'Ximén',    'Villegas',  '1998-07-06', 'bateador',  'LF', 'izquierdo'),
(5, 'V-67890123', 'Yovany',   'Zerpa',     '1997-11-14', 'bateador',  'CF', 'derecho'),
(5, 'V-68901234', 'Zósimo',   'Araujo',    '1999-02-21', 'bateador',  'RF', 'derecho'),
(5, 'V-69012345', 'Abelardo', 'Bermúdez',  '2001-08-05', 'pitcher',   'P',  'derecho'),
-- Equipo 6: Bravos de Margarita (jugadores 51-60)
(6, 'V-70123456', 'Benito',   'Contreras', '1996-04-12', 'pitcher',   'P',  'izquierdo'),
(6, 'V-71234567', 'Camilo',   'Domínguez', '1999-08-28', 'bateador',  'C',  'derecho'),
(6, 'V-72345678', 'Darío',    'Escalona',  '1997-01-05', 'bateador',  '1B', 'derecho'),
(6, 'V-73456789', 'Esteban',  'Fuentes',   '1998-06-17', 'bateador',  '2B', 'derecho'),
(6, 'V-74567890', 'Fabián',   'Guerra',    '2000-10-24', 'bateador',  '3B', 'derecho'),
(6, 'V-75678901', 'Gonzalo',  'Hidalgo',   '1995-05-09', 'bateador',  'SS', 'derecho'),
(6, 'V-76789012', 'Horacio',  'Infante',   '1998-09-26', 'bateador',  'LF', 'izquierdo'),
(6, 'V-77890123', 'Israel',   'Juárez',    '1997-02-13', 'bateador',  'CF', 'derecho'),
(6, 'V-78901234', 'Josué',    'Kindelán',  '1999-07-01', 'bateador',  'RF', 'derecho'),
(6, 'V-79012345', 'Kendry',   'Ladera',    '2001-01-19', 'pitcher',   'P',  'derecho'),
-- Equipo 7: Cardenales de Lara (jugadores 61-70)
(7, 'V-80123456', 'Leonel',   'Matos',     '1996-10-06', 'pitcher',   'P',  'derecho'),
(7, 'V-81234567', 'Mauricio', 'Navas',     '1999-03-23', 'bateador',  'C',  'derecho'),
(7, 'V-82345678', 'Nicolás',  'Obregón',   '1997-08-10', 'bateador',  '1B', 'izquierdo'),
(7, 'V-83456789', 'Octavio',  'Piñero',    '1998-01-27', 'bateador',  '2B', 'derecho'),
(7, 'V-84567890', 'Pascual',  'Quevedo',   '2000-05-14', 'bateador',  '3B', 'derecho'),
(7, 'V-85678901', 'Quirino',  'Rondón',    '1995-09-30', 'bateador',  'SS', 'derecho'),
(7, 'V-86789012', 'Rodolfo',  'Suárez',    '1998-02-08', 'bateador',  'LF', 'izquierdo'),
(7, 'V-87890123', 'Sergio',   'Tovar',     '1997-06-25', 'bateador',  'CF', 'derecho'),
(7, 'V-88901234', 'Tadeo',    'Ureña',     '1999-11-12', 'bateador',  'RF', 'derecho'),
(7, 'V-89012345', 'Ubaldo',   'Valero',    '2001-05-29', 'pitcher',   'P',  'izquierdo'),
-- Equipo 8: Tiburones de La Guaira (jugadores 71-80)
(8, 'V-90123456', 'Valentino','Wolff',     '1996-12-16', 'pitcher',   'P',  'derecho'),
(8, 'V-91234567', 'Wálter',   'Yépez',     '1999-05-03', 'bateador',  'C',  'derecho'),
(8, 'V-92345678', 'Xerxes',   'Zuloaga',   '1997-10-20', 'bateador',  '1B', 'derecho'),
(8, 'V-93456789', 'Yamil',    'Abreu',     '1998-03-08', 'bateador',  '2B', 'derecho'),
(8, 'V-94567890', 'Zacarías', 'Bolívar',   '2000-07-25', 'bateador',  '3B', 'izquierdo'),
(8, 'V-95678901', 'Alfredo',  'Cabrera',   '1995-11-11', 'bateador',  'SS', 'derecho'),
(8, 'V-96789012', 'Bernardo', 'Dugarte',   '1998-04-28', 'bateador',  'LF', 'izquierdo'),
(8, 'V-97890123', 'Claudio',  'Escalante', '1997-09-15', 'bateador',  'CF', 'derecho'),
(8, 'V-98901234', 'Damián',   'Ferrer',    '1999-02-02', 'bateador',  'RF', 'derecho'),
(8, 'V-99012345', 'Ernesto',  'Graterol',  '2001-06-18', 'pitcher',   'P',  'derecho');

-- ── USUARIOS ────────────────────────────────────────────────
-- Contraseña para todos: "admin123" → bcrypt hash
INSERT INTO usuario (nombre, email, password_hash, rol) VALUES
('Admin Liga',     'admin@ligadiamante.com',    '$2a$10$EYDOZPn7CrbAplMkwSvEZ.qigrJuJYU66NwvyXEZlWuD4D8fX9xae', 'administrador'),
('Carlos Dueño',   'dueno@ligadiamante.com',    '$2a$10$EYDOZPn7CrbAplMkwSvEZ.qigrJuJYU66NwvyXEZlWuD4D8fX9xae', 'dueno'),
('María Cajera',   'caja@ligadiamante.com',     '$2a$10$EYDOZPn7CrbAplMkwSvEZ.qigrJuJYU66NwvyXEZlWuD4D8fX9xae', 'caja'),
('Pedro Anotador', 'anotador@ligadiamante.com', '$2a$10$EYDOZPn7CrbAplMkwSvEZ.qigrJuJYU66NwvyXEZlWuD4D8fX9xae', 'anotador'),
('Juan Fanático',  'fan@ligadiamante.com',      '$2a$10$EYDOZPn7CrbAplMkwSvEZ.qigrJuJYU66NwvyXEZlWuD4D8fX9xae', 'publico');

-- ── PARTIDOS (Clausura 2026 — 12 partidos finalizados + 3 programados) ──
INSERT INTO partido (id_temporada, id_equipo_casa, id_equipo_visitante, fecha_juego, hora_juego, lugar, estado) VALUES
-- Jornada 1 (7-8 marzo)
(2, 1, 2, '2026-03-07', '14:00:00', 'Estadio Universitario',         'finalizado'),
(2, 3, 4, '2026-03-07', '16:00:00', 'Estadio La Ceiba',              'finalizado'),
(2, 5, 6, '2026-03-07', '18:00:00', 'Estadio Alfonso López',         'finalizado'),
(2, 7, 8, '2026-03-08', '14:00:00', 'Estadio Antonio Herrera',       'finalizado'),
-- Jornada 2 (14-15 marzo)
(2, 2, 3, '2026-03-14', '14:00:00', 'Estadio José Pérez Colmenares', 'finalizado'),
(2, 4, 5, '2026-03-14', '16:00:00', 'Estadio Universitario',         'finalizado'),
(2, 6, 7, '2026-03-14', '18:00:00', 'Estadio Luis Aparicio',         'finalizado'),
(2, 8, 1, '2026-03-15', '14:00:00', 'Estadio Litoral',               'finalizado'),
-- Jornada 3 (21-22 marzo)
(2, 1, 3, '2026-03-21', '14:00:00', 'Estadio Universitario',         'finalizado'),
(2, 2, 4, '2026-03-21', '16:00:00', 'Estadio José Pérez Colmenares', 'finalizado'),
(2, 5, 7, '2026-03-21', '18:00:00', 'Estadio Alfonso López',         'finalizado'),
(2, 6, 8, '2026-03-22', '14:00:00', 'Estadio Luis Aparicio',         'finalizado'),
-- Jornada 4 (próximos — 28-29 marzo)
(2, 3, 1, '2026-03-28', '14:00:00', 'Estadio La Ceiba',              'programado'),
(2, 4, 2, '2026-03-28', '16:00:00', 'Estadio Universitario',         'programado'),
(2, 7, 5, '2026-03-29', '18:00:00', 'Estadio Antonio Herrera',       'programado');

-- ── RESULTADOS (12 partidos finalizados) ────────────────────
INSERT INTO resultado (id_partido, carreras_home, carreras_visitantes, hits_home, hits_visitantes, errores_home, errores_visitantes, innings_totales, id_pitcher_ganador, id_pitcher_perdedor) VALUES
(1,  5, 3,  9,  7, 1, 2, 9,  1,  11),   -- Leones 5 - Tigres 3
(2,  2, 6,  5, 10, 3, 0, 9, 31,  21),   -- Águilas 2 - Navegantes 6
(3,  5, 4,  8,  8, 1, 1, 11, 41, 51),   -- Caribes 5 - Bravos 4
(4,  7, 1, 12,  4, 0, 3, 9,  61, 71),   -- Cardenales 7 - Tiburones 1
(5,  3, 8,  6, 13, 2, 0, 9,  21, 20),   -- Tigres 3 - Águilas 8
(6,  5, 2,  8,  5, 1, 2, 9,  31, 41),   -- Navegantes 5 - Caribes 2
(7,  6, 3, 10,  6, 0, 1, 9,  51, 61),   -- Bravos 6 - Cardenales 3
(8,  1, 4,  3,  9, 3, 0, 9,   1, 71),   -- Tiburones 1 - Leones 4
(9,  6, 2, 11,  5, 0, 2, 9,   1, 21),   -- Leones 6 - Águilas 2
(10, 4, 5,  7,  9, 1, 1, 10, 31, 11),   -- Tigres 4 - Navegantes 5
(11, 3, 1,  7,  4, 0, 2, 9,  41, 61),   -- Caribes 3 - Cardenales 1
(12, 8, 2, 14,  5, 0, 3, 9,  51, 71);   -- Bravos 8 - Tiburones 2

-- ── DESEMPEÑO BATEADORES ────────────────────────────────────
-- Partido 1: Leones(1) 5 - Tigres(2) 3
INSERT INTO desempeno_bateador (id_jugador, id_partido, id_equipo, turnos_al_bate, hits, dobles, triples, jonrones, carreras, carreras_impulsadas) VALUES
(2,  1, 1, 4, 2, 1, 0, 0, 1, 2), (3,  1, 1, 4, 2, 0, 0, 1, 2, 2),
(4,  1, 1, 4, 1, 0, 0, 0, 0, 0), (5,  1, 1, 3, 1, 1, 0, 0, 1, 1),
(6,  1, 1, 4, 1, 0, 0, 0, 0, 0), (7,  1, 1, 3, 1, 0, 0, 0, 1, 0),
(8,  1, 1, 4, 1, 0, 1, 0, 0, 0), (9,  1, 1, 3, 0, 0, 0, 0, 0, 0),
(12, 1, 2, 4, 2, 1, 0, 0, 1, 1), (13, 1, 2, 4, 1, 0, 0, 0, 0, 1),
(14, 1, 2, 3, 1, 0, 0, 0, 1, 0), (15, 1, 2, 4, 1, 0, 0, 0, 0, 1),
(16, 1, 2, 4, 1, 0, 0, 0, 0, 0), (17, 1, 2, 3, 0, 0, 0, 0, 1, 0),
(18, 1, 2, 4, 1, 0, 0, 0, 0, 0), (19, 1, 2, 3, 0, 0, 0, 0, 0, 0);

-- Partido 2: Águilas(3) 2 - Navegantes(4) 6
INSERT INTO desempeno_bateador (id_jugador, id_partido, id_equipo, turnos_al_bate, hits, dobles, triples, jonrones, carreras, carreras_impulsadas) VALUES
(22, 2, 3, 4, 1, 0, 0, 0, 1, 0), (23, 2, 3, 4, 1, 0, 0, 0, 0, 1),
(24, 2, 3, 3, 1, 1, 0, 0, 0, 1), (25, 2, 3, 4, 1, 0, 0, 0, 1, 0),
(26, 2, 3, 3, 0, 0, 0, 0, 0, 0), (27, 2, 3, 3, 1, 0, 0, 0, 0, 0),
(32, 2, 4, 4, 2, 1, 0, 1, 2, 3), (33, 2, 4, 4, 2, 0, 0, 0, 1, 1),
(34, 2, 4, 4, 2, 1, 0, 0, 1, 1), (35, 2, 4, 3, 1, 0, 0, 0, 1, 0),
(36, 2, 4, 4, 1, 0, 1, 0, 0, 1), (37, 2, 4, 3, 1, 0, 0, 0, 1, 0),
(38, 2, 4, 4, 1, 0, 0, 0, 0, 0);

-- Partido 5: Tigres(2) 3 - Águilas(3) 8
INSERT INTO desempeno_bateador (id_jugador, id_partido, id_equipo, turnos_al_bate, hits, dobles, triples, jonrones, carreras, carreras_impulsadas) VALUES
(12, 5, 2, 4, 1, 0, 0, 0, 0, 0), (13, 5, 2, 4, 1, 0, 0, 0, 1, 1),
(14, 5, 2, 3, 1, 1, 0, 0, 0, 1), (15, 5, 2, 4, 1, 0, 0, 0, 0, 0),
(16, 5, 2, 4, 1, 0, 0, 0, 1, 0), (17, 5, 2, 3, 1, 0, 0, 0, 0, 1),
(22, 5, 3, 5, 3, 1, 0, 1, 2, 3), (23, 5, 3, 4, 2, 0, 0, 0, 1, 1),
(24, 5, 3, 5, 2, 1, 0, 0, 1, 2), (25, 5, 3, 4, 2, 0, 1, 0, 1, 0),
(26, 5, 3, 4, 1, 0, 0, 0, 1, 1), (27, 5, 3, 4, 1, 0, 0, 0, 1, 0),
(28, 5, 3, 4, 1, 0, 0, 0, 1, 1), (29, 5, 3, 3, 1, 0, 0, 0, 0, 0);

-- Partido 9: Leones(1) 6 - Águilas(3) 2
INSERT INTO desempeno_bateador (id_jugador, id_partido, id_equipo, turnos_al_bate, hits, dobles, triples, jonrones, carreras, carreras_impulsadas) VALUES
(2,  9, 1, 5, 3, 1, 0, 1, 2, 3), (3,  9, 1, 4, 2, 0, 0, 0, 1, 1),
(4,  9, 1, 4, 2, 1, 0, 0, 1, 1), (5,  9, 1, 4, 1, 0, 0, 0, 0, 0),
(6,  9, 1, 4, 1, 0, 1, 0, 1, 0), (7,  9, 1, 3, 1, 0, 0, 0, 1, 1),
(8,  9, 1, 4, 1, 0, 0, 0, 0, 0),
(22, 9, 3, 4, 1, 0, 0, 0, 1, 0), (23, 9, 3, 3, 1, 0, 0, 0, 0, 1),
(24, 9, 3, 4, 1, 1, 0, 0, 0, 0), (25, 9, 3, 3, 1, 0, 0, 0, 1, 1),
(26, 9, 3, 4, 0, 0, 0, 0, 0, 0), (27, 9, 3, 3, 1, 0, 0, 0, 0, 0);

-- Partidos 3,4,6,7,8,10,11,12 — estadísticas clave
INSERT INTO desempeno_bateador (id_jugador, id_partido, id_equipo, turnos_al_bate, hits, dobles, triples, jonrones, carreras, carreras_impulsadas) VALUES
-- P3: Caribes(5) 5 - Bravos(6) 4
(42, 3, 5, 4, 2, 0, 0, 1, 2, 2), (43, 3, 5, 4, 1, 1, 0, 0, 1, 1),
(44, 3, 5, 4, 2, 0, 0, 0, 0, 1), (45, 3, 5, 3, 1, 0, 0, 0, 1, 1),
(52, 3, 6, 4, 2, 1, 0, 0, 1, 2), (53, 3, 6, 4, 1, 0, 0, 1, 1, 1),
(54, 3, 6, 4, 2, 0, 0, 0, 1, 0), (55, 3, 6, 3, 1, 0, 0, 0, 1, 1),
-- P4: Cardenales(7) 7 - Tiburones(8) 1
(62, 4, 7, 4, 3, 1, 0, 1, 2, 3), (63, 4, 7, 4, 2, 0, 1, 0, 2, 1),
(64, 4, 7, 4, 2, 1, 0, 0, 1, 1), (65, 4, 7, 4, 2, 0, 0, 0, 1, 1),
(72, 4, 8, 3, 1, 0, 0, 0, 0, 0), (73, 4, 8, 3, 1, 0, 0, 0, 1, 1),
(74, 4, 8, 3, 1, 0, 0, 0, 0, 0), (75, 4, 8, 3, 0, 0, 0, 0, 0, 0),
-- P6: Navegantes(4) 5 - Caribes(5) 2
(32, 6, 4, 4, 2, 0, 0, 0, 1, 1), (33, 6, 4, 4, 2, 1, 0, 0, 2, 2),
(34, 6, 4, 4, 1, 0, 0, 0, 1, 1), (35, 6, 4, 3, 1, 0, 0, 0, 1, 1),
(42, 6, 5, 4, 1, 0, 0, 0, 1, 1), (43, 6, 5, 3, 1, 0, 0, 0, 0, 0),
(44, 6, 5, 4, 1, 1, 0, 0, 0, 1), (45, 6, 5, 3, 0, 0, 0, 0, 1, 0),
-- P7: Bravos(6) 6 - Cardenales(7) 3
(52, 7, 6, 4, 2, 0, 0, 1, 2, 2), (53, 7, 6, 4, 2, 1, 0, 0, 1, 2),
(54, 7, 6, 4, 2, 0, 0, 0, 1, 1), (55, 7, 6, 4, 1, 0, 0, 0, 1, 0),
(62, 7, 7, 4, 1, 0, 0, 0, 1, 1), (63, 7, 7, 4, 1, 0, 0, 0, 0, 1),
(64, 7, 7, 3, 1, 1, 0, 0, 1, 1), (65, 7, 7, 3, 1, 0, 0, 0, 0, 0),
-- P8: Tiburones(8) 1 - Leones(1) 4
(72, 8, 8, 3, 1, 0, 0, 0, 0, 0), (73, 8, 8, 3, 0, 0, 0, 0, 1, 0),
(74, 8, 8, 3, 1, 0, 0, 0, 0, 1), (75, 8, 8, 3, 0, 0, 0, 0, 0, 0),
(2,  8, 1, 4, 2, 1, 0, 0, 1, 1), (3,  8, 1, 4, 2, 0, 0, 0, 1, 1),
(4,  8, 1, 4, 1, 0, 0, 0, 0, 0), (5,  8, 1, 3, 2, 1, 0, 0, 1, 2),
-- P10: Tigres(2) 4 - Navegantes(4) 5
(12, 10, 2, 4, 1, 0, 0, 0, 1, 1), (13, 10, 2, 4, 2, 0, 0, 0, 1, 1),
(14, 10, 2, 4, 1, 1, 0, 0, 1, 1), (15, 10, 2, 4, 1, 0, 0, 0, 0, 0),
(32, 10, 4, 5, 2, 0, 0, 1, 2, 2), (33, 10, 4, 4, 2, 1, 0, 0, 1, 1),
(34, 10, 4, 4, 1, 0, 0, 0, 1, 1), (35, 10, 4, 4, 2, 1, 0, 0, 1, 1),
-- P11: Caribes(5) 3 - Cardenales(7) 1
(42, 11, 5, 4, 2, 1, 0, 0, 1, 1), (43, 11, 5, 3, 1, 0, 0, 0, 1, 1),
(44, 11, 5, 4, 1, 0, 0, 0, 0, 0), (45, 11, 5, 3, 1, 0, 0, 0, 1, 1),
(62, 11, 7, 3, 1, 0, 0, 0, 0, 0), (63, 11, 7, 3, 1, 0, 0, 0, 0, 1),
(64, 11, 7, 3, 1, 0, 0, 0, 1, 0), (65, 11, 7, 3, 0, 0, 0, 0, 0, 0),
-- P12: Bravos(6) 8 - Tiburones(8) 2
(52, 12, 6, 5, 3, 1, 0, 1, 3, 3), (53, 12, 6, 4, 3, 0, 1, 0, 2, 2),
(54, 12, 6, 4, 2, 0, 0, 1, 1, 1), (55, 12, 6, 4, 2, 1, 0, 0, 1, 1),
(56, 12, 6, 4, 2, 0, 0, 0, 0, 0), (57, 12, 6, 4, 1, 0, 0, 0, 1, 1),
(72, 12, 8, 3, 1, 0, 0, 0, 0, 0), (73, 12, 8, 3, 1, 1, 0, 0, 1, 1),
(74, 12, 8, 3, 1, 0, 0, 0, 0, 1), (75, 12, 8, 3, 1, 0, 0, 0, 1, 0),
(76, 12, 8, 3, 0, 0, 0, 0, 0, 0);

-- ── DESEMPEÑO PITCHERS ──────────────────────────────────────
INSERT INTO desempeno_pitcher (id_jugador, id_partido, id_equipo, innings_pitcheados, hits_permitidos, carreras_permitidas, carreras_limpias, bases_por_bolas, ponches, ganado, perdido) VALUES
-- P1: Leones vs Tigres
(1,  1, 1, 7.0, 5, 2, 2, 2, 8, 1, 0),
(10, 1, 1, 2.0, 2, 1, 1, 1, 3, 0, 0),
(11, 1, 2, 6.0, 7, 4, 3, 3, 5, 0, 1),
(20, 1, 2, 3.0, 2, 1, 1, 0, 2, 0, 0),
-- P2: Águilas vs Navegantes
(21, 2, 3, 5.0, 8, 5, 4, 4, 3, 0, 1),
(30, 2, 3, 4.0, 2, 1, 1, 1, 4, 0, 0),
(31, 2, 4, 9.0, 5, 2, 2, 1, 10, 1, 0),
-- P3: Caribes vs Bravos
(41, 3, 5, 8.0, 6, 3, 3, 2, 7, 1, 0),
(50, 3, 5, 3.0, 2, 1, 1, 1, 2, 0, 0),
(51, 3, 6, 7.0, 6, 4, 3, 3, 6, 0, 1),
(60, 3, 6, 4.0, 2, 1, 1, 0, 3, 0, 0),
-- P4: Cardenales vs Tiburones
(61, 4, 7, 9.0, 4, 1, 1, 1, 11, 1, 0),
(71, 4, 8, 5.0, 9, 5, 4, 3, 3, 0, 1),
(80, 4, 8, 4.0, 3, 2, 2, 1, 2, 0, 0),
-- P5: Tigres vs Águilas
(11, 5, 2, 4.0, 9, 6, 5, 3, 2, 0, 0),
(20, 5, 2, 5.0, 4, 2, 2, 1, 4, 0, 1),
(21, 5, 3, 9.0, 6, 3, 3, 2, 7, 1, 0),
-- P6: Navegantes vs Caribes
(31, 6, 4, 9.0, 5, 2, 2, 2, 8, 1, 0),
(41, 6, 5, 6.0, 6, 4, 3, 3, 5, 0, 1),
(50, 6, 5, 3.0, 2, 1, 1, 0, 2, 0, 0),
-- P7: Bravos vs Cardenales
(51, 7, 6, 9.0, 6, 3, 3, 2, 8, 1, 0),
(61, 7, 7, 6.0, 8, 5, 4, 3, 5, 0, 1),
(70, 7, 7, 3.0, 2, 1, 1, 1, 3, 0, 0),
-- P8: Tiburones vs Leones
(71, 8, 8, 5.0, 7, 3, 2, 3, 3, 0, 0),
(80, 8, 8, 4.0, 2, 1, 1, 0, 2, 0, 1),
(1,  8, 1, 9.0, 3, 1, 1, 1, 9, 1, 0),
-- P9: Leones vs Águilas
(1,  9, 1, 8.0, 4, 1, 1, 1, 9, 1, 0),
(10, 9, 1, 1.0, 1, 1, 1, 0, 2, 0, 0),
(21, 9, 3, 5.0, 9, 5, 4, 3, 3, 0, 1),
(30, 9, 3, 4.0, 2, 1, 1, 1, 3, 0, 0),
-- P10: Tigres vs Navegantes
(11, 10, 2, 7.0, 7, 4, 3, 2, 6, 0, 1),
(20, 10, 2, 3.0, 2, 1, 1, 1, 3, 0, 0),
(31, 10, 4, 10.0, 7, 4, 4, 1, 8, 1, 0),
-- P11: Caribes vs Cardenales
(41, 11, 5, 9.0, 4, 1, 1, 2, 10, 1, 0),
(61, 11, 7, 6.0, 5, 2, 2, 2, 5, 0, 1),
(70, 11, 7, 3.0, 2, 1, 1, 1, 3, 0, 0),
-- P12: Bravos vs Tiburones
(51, 12, 6, 9.0, 5, 2, 2, 1, 9, 1, 0),
(71, 12, 8, 4.0, 10, 6, 5, 3, 2, 0, 1),
(80, 12, 8, 5.0, 4, 2, 2, 1, 3, 0, 0);

-- ── PROVEEDORES ─────────────────────────────────────────────
INSERT INTO proveedor (rif, nombre_proveedor, servicio, telefono, email) VALUES
('J-12345678-9', 'Deportes Venezuela C.A.',   'Suministro de pelotas y bates',        '0212-1234567', 'ventas@deportesve.com'),
('J-23456789-0', 'Árbitros Asociados',        'Servicios de arbitraje profesional',    '0412-9876543', 'arbitros@asociados.com'),
('J-34567890-1', 'Transporte Express C.A.',   'Transporte de equipos a estadios',      '0414-5551234', 'info@transporteexpress.com'),
('J-45678901-2', 'Catering El Diamante',      'Servicio de alimentación para eventos', '0416-4443322', 'pedidos@cateringdiamante.com'),
('J-56789012-3', 'Imprenta Digital Plus',     'Impresión de programas y boletos',      '0424-3332211', 'ventas@imprentadigital.com'),
('V-15678901',   'Dr. Roberto Méndez',        'Servicios médicos y paramédicos',       '0412-7778899', 'dr.mendez@gmail.com');

-- ── INGRESOS ────────────────────────────────────────────────
INSERT INTO ingreso (id_equipo, id_temporada, concepto, valor, fecha_ingreso, tipo_pago) VALUES
(1, 2, 'Inscripción Leones - Clausura 2026',     5500.00, '2026-02-01', 'Transferencia'),
(2, 2, 'Inscripción Tigres - Clausura 2026',     5500.00, '2026-02-02', 'Transferencia'),
(3, 2, 'Inscripción Águilas - Clausura 2026',    5500.00, '2026-02-03', 'Efectivo'),
(4, 2, 'Inscripción Navegantes - Clausura 2026', 5500.00, '2026-02-04', 'Transferencia'),
(5, 2, 'Inscripción Caribes - Clausura 2026',    5500.00, '2026-02-05', 'Pago Movil'),
(6, 2, 'Inscripción Bravos - Clausura 2026',     5500.00, '2026-02-06', 'Efectivo'),
(1, 2, 'Patrocinio Leones — Empresa ABC',        8000.00, '2026-02-15', 'Transferencia'),
(3, 2, 'Patrocinio Águilas — Comercial XYZ',     6000.00, '2026-02-18', 'Transferencia'),
(2, 2, 'Venta de boletos Jornada 1',             3500.00, '2026-03-07', 'Efectivo'),
(1, 2, 'Venta de boletos Jornada 2',             4200.00, '2026-03-14', 'Efectivo'),
(5, 2, 'Donación Alcaldía Municipal',            10000.00,'2026-02-20', 'Cheque');

-- ── EGRESOS ─────────────────────────────────────────────────
INSERT INTO egreso (id_temporada, id_proveedor, nota_gastos, gasto, fecha_egreso, tipo_pago) VALUES
(2, 2, 'Arbitraje Jornada 1 (4 partidos)',          8000.00,  '2026-03-07', 'Transferencia'),
(2, 2, 'Arbitraje Jornada 2 (4 partidos)',          8000.00,  '2026-03-14', 'Transferencia'),
(2, 2, 'Arbitraje Jornada 3 (4 partidos)',          8000.00,  '2026-03-21', 'Transferencia'),
(2, 1, 'Compra de pelotas oficiales (50 unidades)', 4500.00,  '2026-02-25', 'Efectivo'),
(2, 3, 'Transporte Jornada 1',                      3000.00,  '2026-03-06', 'Pago Movil'),
(2, 3, 'Transporte Jornada 2',                      3000.00,  '2026-03-13', 'Pago Movil'),
(2, 4, 'Catering inauguración temporada',           5000.00,  '2026-02-28', 'Transferencia'),
(2, 5, 'Impresión de programas — 500 unidades',     2000.00,  '2026-02-26', 'Efectivo'),
(2, 6, 'Servicios médicos Jornada 1',               2500.00,  '2026-03-07', 'Transferencia'),
(2, 6, 'Servicios médicos Jornada 2',               2500.00,  '2026-03-14', 'Transferencia'),
(2, NULL, 'Mantenimiento terreno de juego',          3500.00,  '2026-03-01', 'Efectivo');

-- ── SANCIONES ───────────────────────────────────────────────
INSERT INTO sancion (id_temporada, id_jugador, id_equipo, tipo, descripcion, fecha_sancion, partidos_suspension, monto_multa, estado) VALUES
(2, 15, 2, 'suspension',   'Conducta antideportiva — discusión con árbitro',    '2026-03-14', 2, 0.00,    'activa'),
(2, NULL, 6, 'multa',      'Retraso en llegada al estadio (>30 min)',           '2026-03-14', 0, 1500.00, 'activa'),
(2, 7,  1, 'amonestacion', 'Lanzamiento de casco después del tercer out',      '2026-03-07', 0, 0.00,    'cumplida'),
(2, 33, 4, 'suspension',   'Agresión verbal a jugador contrario',              '2026-03-21', 3, 500.00,  'activa'),
(2, 52, 6, 'amonestacion', 'Demora excesiva en posición de bateo',             '2026-03-22', 0, 0.00,    'cumplida');

-- ── SEGUIMIENTO (fan sigue a Leones, Águilas y Caribes) ─────
INSERT INTO seguimiento (id_usuario, id_equipo) VALUES
(5, 1), (5, 3), (5, 5);
