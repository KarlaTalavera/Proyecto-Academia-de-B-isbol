-- ================================================================
--  LIGA DIAMANTE — Datos de prueba completos
--  Ejecutar en phpMyAdmin o MySQL CLI sobre la BD liga_diamante
-- ================================================================

SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM seguimiento;
DELETE FROM desempeno_pitcher;
DELETE FROM desempeno_bateador;
DELETE FROM lineup;
DELETE FROM resultado;
DELETE FROM partido;
DELETE FROM jugador;
DELETE FROM ingreso;
DELETE FROM proveedor;
DELETE FROM egreso;
DELETE FROM equipo;
DELETE FROM usuario;
DELETE FROM temporada;
ALTER TABLE temporada         AUTO_INCREMENT = 1;
ALTER TABLE equipo            AUTO_INCREMENT = 1;
ALTER TABLE jugador           AUTO_INCREMENT = 1;
ALTER TABLE partido           AUTO_INCREMENT = 1;
ALTER TABLE resultado         AUTO_INCREMENT = 1;
ALTER TABLE lineup            AUTO_INCREMENT = 1;
ALTER TABLE ingreso           AUTO_INCREMENT = 1;
ALTER TABLE egreso            AUTO_INCREMENT = 1;
ALTER TABLE proveedor         AUTO_INCREMENT = 1;
ALTER TABLE desempeno_bateador AUTO_INCREMENT = 1;
ALTER TABLE desempeno_pitcher  AUTO_INCREMENT = 1;
ALTER TABLE seguimiento        AUTO_INCREMENT = 1;
ALTER TABLE usuario            AUTO_INCREMENT = 1;
SET FOREIGN_KEY_CHECKS = 1;

-- ── TEMPORADAS ────────────────────────────────────────────────
INSERT INTO temporada (nombre, anio, categoria, costo_inscripcion, activa) VALUES
  ('Temporada 2026 — Apertura',  2026, 'Semi-profesional', 500.00, 1),
  ('Temporada 2025 — Clausura',  2025, 'Aficionado',       300.00, 0);

-- ── EQUIPOS ───────────────────────────────────────────────────
INSERT INTO equipo (nombre_equipo, entrenador, responsable, email, telefono) VALUES
  ('Tigres de Lara',         'Carlos Medina',    'Pedro Álvarez',  'tigres@liga.com',   '0414-111-2233'),
  ('Águilas del Llano',      'José Rodríguez',   'María González', 'aguilas@liga.com',  '0424-222-3344'),
  ('Leones de Barquisimeto', 'Andrés Torrealba', 'Luis Castillo',  'leones@liga.com',   '0416-333-4455'),
  ('Cóndores del Andes',     'Rafael Suárez',    'Ana Pérez',      'condores@liga.com', '0412-444-5566'),
  ('Piratas del Oeste',      'Miguel Herrera',   'Carmen Rojas',   'piratas@liga.com',  '0426-555-6677'),
  ('Toros de Portuguesa',    'Ernesto Silva',    'Roberto Díaz',   'toros@liga.com',    '0414-666-7788');

-- ── JUGADORES ─────────────────────────────────────────────────
INSERT INTO jugador (id_equipo, cedula, nombre, apellido, fecha_nacimiento, rol, posicion, brazo_dominante, activo) VALUES
-- Tigres de Lara (id=1)
(1,'V-12345678','Carlos',   'Martínez','1998-03-15','bateador','Primera Base',    'Derecho',1),
(1,'V-23456789','Jesús',    'Pérez',   '2000-07-22','bateador','Segunda Base',    'Derecho',1),
(1,'V-34567890','Andrés',   'López',   '1997-11-10','bateador','Shortstop',       'Zurdo',  1),
(1,'V-45678901','Miguel',   'García',  '1999-04-05','pitcher', 'Lanzador',        'Derecho',1),
(1,'V-56789012','Roberto',  'Torres',  '2001-09-18','pitcher', 'Lanzador',        'Derecho',1),
-- Águilas del Llano (id=2)
(2,'V-67890123','Juan',     'Ramírez', '1998-06-12','bateador','Tercera Base',    'Derecho',1),
(2,'V-78901234','Luis',     'Herrera', '1999-02-28','bateador','Jardín Central',  'Derecho',1),
(2,'V-89012345','Pedro',    'Gómez',   '2000-08-30','bateador','Receptor',        'Derecho',1),
(2,'V-90123456','Daniel',   'Flores',  '1997-12-14','pitcher', 'Lanzador',        'Zurdo',  1),
(2,'V-01234567','Fernando', 'Morales', '2002-01-25','utilidad','Jardinero',       'Derecho',1),
-- Leones de Barquisimeto (id=3)
(3,'V-11223344','Santiago', 'Rivas',   '1999-05-07','bateador','Primera Base',    'Zurdo',  1),
(3,'V-22334455','Eduardo',  'Blanco',  '2000-10-19','bateador','Shortstop',       'Derecho',1),
(3,'V-33445566','Marcos',   'Ortega',  '1998-01-23','pitcher', 'Lanzador',        'Derecho',1),
(3,'V-44556677','Nicolás',  'Castro',  '2001-07-11','bateador','Segunda Base',    'Derecho',1),
-- Cóndores del Andes (id=4)
(4,'V-55667788','Gregorio', 'Vargas',  '1997-03-30','bateador','Jardín Izquierdo','Zurdo',  1),
(4,'V-66778899','Alejandro','Mendoza', '2000-11-15','pitcher', 'Lanzador',        'Derecho',1),
(4,'V-77889900','Ramón',    'Jiménez', '1999-06-08','bateador','Tercera Base',    'Derecho',1),
-- Piratas del Oeste (id=5)
(5,'V-88990011','Héctor',   'Núñez',   '1998-09-25','bateador','Receptor',        'Derecho',1),
(5,'V-99001122','Gabriel',  'Ríos',    '2001-04-14','pitcher', 'Lanzador',        'Zurdo',  1),
(5,'V-10111213','Cristóbal','Fuentes', '1999-12-03','bateador','Primera Base',    'Derecho',1),
-- Toros de Portuguesa (id=6)
(6,'V-21222324','Álvaro',   'Salcedo', '2000-02-17','bateador','Jardín Derecho',  'Derecho',1),
(6,'V-32333435','Iván',     'Parra',   '1997-08-09','pitcher', 'Lanzador',        'Derecho',1),
(6,'V-43444546','Reinaldo', 'Armas',   '2001-05-21','bateador','Segunda Base',    'Zurdo',  1);

-- ── PARTIDOS (temporada 1 = 2026 Apertura) ───────────────────
INSERT INTO partido (id_temporada, id_equipo_casa, id_equipo_visitante, fecha_juego, hora_juego, lugar, innings_programados, estado) VALUES
(1,1,2,'2026-03-01','15:00:00','Estadio Antonio Herrera Gutiérrez',9,'finalizado'),
(1,3,4,'2026-03-01','17:00:00','Estadio Barquisimeto',             9,'finalizado'),
(1,5,6,'2026-03-03','15:00:00','Estadio El Ujano',                 9,'finalizado'),
(1,2,3,'2026-03-05','16:00:00','Estadio Antonio Herrera Gutiérrez',9,'finalizado'),
(1,4,1,'2026-03-07','15:00:00','Estadio Barquisimeto',             9,'finalizado'),
(1,6,5,'2026-03-08','17:00:00','Estadio El Ujano',                 9,'finalizado'),
(1,1,3,'2026-03-10','15:00:00','Estadio Antonio Herrera Gutiérrez',9,'finalizado'),
(1,2,6,'2026-03-12','16:00:00','Estadio Barquisimeto',             9,'finalizado'),
(1,3,5,'2026-03-25','15:00:00','Estadio Barquisimeto',             9,'en_juego'),
(1,4,2,'2026-03-26','16:00:00','Estadio Antonio Herrera Gutiérrez',9,'programado'),
(1,1,6,'2026-03-27','15:00:00','Estadio El Ujano',                 9,'programado'),
(1,5,2,'2026-03-28','17:00:00','Estadio Barquisimeto',             9,'programado'),
(1,6,3,'2026-03-29','15:00:00','Estadio Antonio Herrera Gutiérrez',9,'programado'),
(1,4,5,'2026-04-01','16:00:00','Estadio El Ujano',                 9,'programado'),
(1,1,2,'2026-04-03','15:00:00','Estadio Barquisimeto',             9,'programado');

-- ── RESULTADOS (partidos 1-8 finalizados) ────────────────────
-- id_pitcher_ganador/perdedor apuntan a jugadores pitchers según equipos
INSERT INTO resultado (id_partido,carreras_home,carreras_visitantes,hits_home,hits_visitantes,errores_home,errores_visitantes,innings_totales,id_pitcher_ganador,id_pitcher_perdedor,id_pitcher_salvador,observaciones) VALUES
(1, 7,3,10, 6,1,2,9, 4, 9,NULL,'Victoria sólida de Tigres'),
(2, 4,5, 8, 9,2,1,9,13, 16,NULL,'Leones dominan la segunda mitad'),
(3, 2,6, 5,11,3,0,9,22, 19,NULL,'Toros contundentes'),
(4, 3,4, 7, 8,1,1,9,13,  9,  16,'Juego cerrado, Leones al triunfo'),
(5, 6,2, 9, 5,0,2,9,16,  4,NULL,'Cóndores sin piedad contra Tigres'),
(6, 1,4, 4, 9,3,0,9,19, 22,NULL,'Piratas superados'),
(7, 5,5, 8, 8,1,1,9,NULL,NULL,NULL,'Empate dramático en el noveno'),
(8, 3,7, 6,12,2,1,9,22,  9,NULL,'Toros aplastan a Águilas');

-- ── PARTIDOS (temporada 2 = 2025 Clausura, todos finalizados) ─
INSERT INTO partido (id_temporada, id_equipo_casa, id_equipo_visitante, fecha_juego, hora_juego, lugar, innings_programados, estado) VALUES
(2,1,2,'2025-09-05','15:00:00','Estadio Antonio Herrera Gutiérrez',9,'finalizado'),
(2,3,4,'2025-09-07','17:00:00','Estadio Barquisimeto',             9,'finalizado'),
(2,5,6,'2025-09-10','15:00:00','Estadio El Ujano',                 9,'finalizado'),
(2,2,1,'2025-09-12','16:00:00','Estadio Antonio Herrera Gutiérrez',9,'finalizado'),
(2,4,3,'2025-09-14','15:00:00','Estadio Barquisimeto',             9,'finalizado'),
(2,6,5,'2025-09-17','17:00:00','Estadio El Ujano',                 9,'finalizado'),
(2,1,4,'2025-09-19','15:00:00','Estadio Antonio Herrera Gutiérrez',9,'finalizado'),
(2,2,5,'2025-09-21','16:00:00','Estadio Barquisimeto',             9,'finalizado'),
(2,3,6,'2025-09-24','15:00:00','Estadio El Ujano',                 9,'finalizado'),
(2,4,1,'2025-09-26','17:00:00','Estadio Antonio Herrera Gutiérrez',9,'finalizado'),
(2,5,3,'2025-09-28','15:00:00','Estadio Barquisimeto',             9,'finalizado'),
(2,6,2,'2025-09-30','16:00:00','Estadio El Ujano',                 9,'finalizado');

-- ── RESULTADOS (temporada 2025 Clausura, partidos 16-27) ──────
INSERT INTO resultado (id_partido,carreras_home,carreras_visitantes,hits_home,hits_visitantes,errores_home,errores_visitantes,innings_totales,id_pitcher_ganador,id_pitcher_perdedor,id_pitcher_salvador,observaciones) VALUES
(16, 8,3,12, 6,0,2,9, 4, 9,NULL,'Tigres dominan la apertura del Clausura'),
(17, 5,2, 9, 5,1,1,9,13,16,NULL,'Leones imponen su poder ofensivo'),
(18, 3,6, 6,10,2,0,9,22,19,NULL,'Toros sin piedad ante Piratas'),
(19, 2,5, 5, 9,3,1,9, 4,13,NULL,'Águilas remontan en la séptima'),
(20, 7,1,11, 4,0,3,9,16, 4,NULL,'Cóndores aplastantes'),
(21, 4,4, 8, 8,1,1,9,NULL,NULL,NULL,'Empate agónico en el noveno inning'),
(22, 6,3, 9, 7,1,2,9, 4,16,NULL,'Tigres consolidan liderato'),
(23, 1,4, 4, 8,3,0,9,22, 9,NULL,'Toros frenan a Águilas'),
(24, 5,3, 8, 6,0,1,9,13,22,NULL,'Leones cierran la jornada fuerte'),
(25, 2,7, 5,12,2,0,9,16, 4,NULL,'Cóndores se imponen a Tigres'),
(26, 6,2,10, 5,1,2,9,13,19,NULL,'Leones dominan a Piratas'),
(27, 3,5, 7, 9,2,1,9,22,13,NULL,'Toros cierran el Clausura con victoria');

-- ── LINEUP (partido 1: Tigres vs Águilas) ────────────────────
INSERT INTO lineup (id_partido, id_jugador, id_equipo, orden_bateo, posicion_juego, es_titular) VALUES
(1,1,1,1,'Primera Base', 1),(1,2,1,2,'Segunda Base',1),(1,3,1,3,'Shortstop',  1),
(1,4,1,NULL,'Lanzador',  1),(1,5,1,NULL,'Lanzador',  0),
(1,6,2,1,'Tercera Base', 1),(1,7,2,2,'Jardín Central',1),(1,8,2,3,'Receptor',1),
(1,9,2,NULL,'Lanzador',  1),(1,10,2,NULL,'Jardinero', 0);

-- ── DESEMPEÑO BATEADORES ─────────────────────────────────────
INSERT INTO desempeno_bateador (id_jugador,id_partido,id_equipo,turnos_al_bate,hits,dobles,triples,jonrones,carreras,carreras_impulsadas,bolas,strikes,foul,outs,asistencias) VALUES
-- Partido 1: Tigres(1) vs Águilas(2)
(1,1,1,4,2,1,0,1,2,3,1,2,1,2,3),
(2,1,1,4,1,0,0,0,1,1,2,1,2,3,5),
(3,1,1,3,2,0,1,0,2,1,0,1,1,1,4),
(6,1,2,4,1,1,0,0,1,1,1,2,2,3,2),
(7,1,2,4,0,0,0,0,0,0,3,2,1,4,1),
(8,1,2,3,2,0,0,0,1,2,0,1,1,1,6),
-- Partido 2: Leones(3) vs Cóndores(4)
(11,2,3,4,2,1,0,0,1,2,2,1,1,2,4),
(12,2,3,4,1,0,0,0,1,0,1,2,2,3,6),
(15,2,4,4,0,0,0,0,0,0,2,3,1,4,2),
(17,2,4,3,1,1,0,0,1,1,0,1,2,2,3),
-- Partido 3: Piratas(5) vs Toros(6)
(20,3,5,4,1,0,0,0,0,1,1,2,1,3,2),
(18,3,5,4,0,0,0,0,0,0,2,3,2,4,1),
(23,3,6,4,3,1,1,1,2,3,0,1,1,1,5),
(21,3,6,4,2,0,0,0,2,2,1,1,1,2,4),
-- Partido 4: Águilas(2) vs Leones(3)
(6,4,2,4,2,1,0,0,1,1,2,1,1,2,3),
(8,4,2,3,0,0,0,0,0,0,1,3,2,3,1),
(11,4,3,4,1,1,0,0,1,2,0,2,1,2,4),
(12,4,3,4,2,0,0,0,1,1,1,1,2,2,6),
-- Partido 5: Cóndores(4) vs Tigres(1)
(15,5,4,4,3,1,0,1,3,3,0,1,1,1,3),
(17,5,4,4,1,0,0,0,1,1,2,2,1,3,2),
(1,5,1,4,0,0,0,0,0,0,3,3,2,4,1),
(2,5,1,4,1,0,0,0,1,1,1,2,1,3,2),
-- Partido 6: Toros(6) vs Piratas(5)
(23,6,6,4,1,0,0,0,0,1,1,2,2,3,3),
(21,6,6,3,0,0,0,0,0,0,2,3,1,3,2),
(20,6,5,4,2,1,0,0,1,1,0,1,1,2,4),
(18,6,5,4,1,0,0,0,1,2,1,2,2,3,1),
-- Partido 7: Tigres(1) vs Leones(3)
(1,7,1,4,2,0,0,0,2,1,1,1,1,2,3),
(3,7,1,4,1,1,0,0,1,2,0,2,2,3,5),
(11,7,3,4,2,1,0,0,1,1,2,1,1,2,4),
(12,7,3,3,1,0,0,0,1,1,1,2,2,2,6),
-- Partido 8: Águilas(2) vs Toros(6)
(6,8,2,4,1,0,0,0,1,1,1,2,1,3,2),
(7,8,2,3,0,0,0,0,0,0,2,3,2,3,1),
(23,8,6,4,3,1,1,0,2,3,0,1,1,1,5),
(21,8,6,4,2,0,0,1,2,2,1,1,1,2,4);

-- ── DESEMPEÑO PITCHERS ───────────────────────────────────────
INSERT INTO desempeno_pitcher (id_jugador,id_partido,id_equipo,innings_pitcheados,hits_permitidos,carreras_permitidas,carreras_limpias,jonrones_permitidos,golpes_bateador,bases_por_bolas,ponches,ganado,perdido,salvado) VALUES
(4, 1,1,9.0, 6,3,2,0,0,2,8,1,0,0),
(9, 1,2,9.0,10,7,6,1,1,3,5,0,1,0),
(13,2,3,9.0, 9,5,4,1,0,1,7,0,1,0),
(16,2,4,9.0, 8,4,3,0,1,2,6,1,0,0),
(22,3,6,9.0,11,6,5,0,0,3,4,1,0,0),
(19,3,5,9.0, 5,2,2,0,0,1,9,0,1,0);

-- ── INGRESOS ─────────────────────────────────────────────────
INSERT INTO ingreso (id_equipo,id_temporada,concepto,valor,fecha_ingreso,tipo_pago) VALUES
(1,1,'Inscripción temporada 2026 — Tigres de Lara',        500.00,'2026-01-10','Transferencia'),
(2,1,'Inscripción temporada 2026 — Águilas del Llano',     500.00,'2026-01-11','Transferencia'),
(3,1,'Inscripción temporada 2026 — Leones de Barquisimeto',500.00,'2026-01-12','Efectivo'),
(4,1,'Inscripción temporada 2026 — Cóndores del Andes',    500.00,'2026-01-13','Transferencia'),
(5,1,'Inscripción temporada 2026 — Piratas del Oeste',     500.00,'2026-01-14','Efectivo'),
(6,1,'Inscripción temporada 2026 — Toros de Portuguesa',   500.00,'2026-01-15','Transferencia'),
(1,1,'Multa por retiro tardío de lineup — Tigres',          50.00,'2026-02-20','Efectivo'),
(3,1,'Patrocinio local — Leones de Barquisimeto',         1200.00,'2026-03-01','Transferencia'),
(2,1,'Venta de boletería partido inaugural',               850.00,'2026-03-01','Efectivo'),
(5,1,'Cuota extraordinaria Piratas',                       200.00,'2026-03-05','Transferencia');

-- ── EGRESOS ──────────────────────────────────────────────────
INSERT INTO egreso (id_temporada,nota_gastos,gasto,fecha_egreso,tipo_pago) VALUES
(1,'Mantenimiento estadio Antonio Herrera Gutiérrez', 800.00,'2026-01-20','Transferencia'),
(1,'Compra de uniformes árbitros temporada 2026',     350.00,'2026-01-25','Efectivo'),
(1,'Impresión de boletos y material publicitario',    420.00,'2026-02-05','Transferencia'),
(1,'Alquiler de equipos de sonido partido inaugural', 200.00,'2026-03-01','Efectivo'),
(1,'Transporte equipos visitantes (marzo)',            600.00,'2026-03-10','Transferencia'),
(1,'Seguros y pólizas jugadores temporada',          1500.00,'2026-01-30','Transferencia');

-- ── PROVEEDORES ──────────────────────────────────────────────
INSERT INTO proveedor (rif,nombre_proveedor,servicio,id_egreso) VALUES
('J-30111222-3','Constructora Estadios C.A.',   'Mantenimiento y reparación de instalaciones',1),
('J-40222333-4','Uniformes Deportivos El Bate', 'Confección de uniformes y equipamiento',     2),
('J-50333444-5','Imprenta Rápida Barquisimeto', 'Impresión de material publicitario',         3),
('J-60444555-6','AudioPro Eventos',             'Alquiler de equipos de sonido y luces',      4),
('J-70555666-7','Transportes La Liga C.A.',     'Servicio de transporte para equipos',        5),
('J-80666777-8','Seguros Horizonte Venezuela',  'Pólizas de seguro deportivo',                6);

-- ── USUARIOS ─────────────────────────────────────────────────
-- Contraseñas: admin123 (administrador) | user123 (resto)
INSERT INTO usuario (nombre,email,password_hash,rol,activo) VALUES
('Admin Liga',     'admin@liga.com',    '$2a$10$OrLKB/iCGrXpwLUBH9lpe.r083E.CM4WfyD1HQjLxSADLbQu9YUyO','administrador',1),
('Carlos Dueño',   'dueno@liga.com',    '$2a$10$NO3ibXAr5vjspBB/L7gUQeqTPyoHkQfUyYTg3YQAJGZY44Kb7fX6W','dueno',        1),
('María Caja',     'caja@liga.com',     '$2a$10$NO3ibXAr5vjspBB/L7gUQeqTPyoHkQfUyYTg3YQAJGZY44Kb7fX6W','caja',         1),
('Juan Anotador',  'anotador@liga.com', '$2a$10$NO3ibXAr5vjspBB/L7gUQeqTPyoHkQfUyYTg3YQAJGZY44Kb7fX6W','anotador',     1),
('Pedro Fanático', 'fan@liga.com',      '$2a$10$NO3ibXAr5vjspBB/L7gUQeqTPyoHkQfUyYTg3YQAJGZY44Kb7fX6W','publico',      1);

-- ── SEGUIMIENTO (fan sigue Tigres y Leones) ──────────────────
INSERT INTO seguimiento (id_usuario,id_equipo) VALUES (5,1),(5,3);
