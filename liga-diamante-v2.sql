-- ============================================================
-- Liga Diamante - Schema v2
-- Correcciones: nombres snake_case, utf8mb4, tablas faltantes,
--               campos faltantes, referencias circulares resueltas
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";
SET NAMES utf8mb4;

DROP DATABASE IF EXISTS `liga_diamante`;
CREATE DATABASE `liga_diamante`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `liga_diamante`;

-- ============================================================
-- 1. TEMPORADA (reemplaza a "liga" — corrige la referencia circular)
-- ============================================================
CREATE TABLE `temporada` (
  `id_temporada`      INT(11)        NOT NULL AUTO_INCREMENT,
  `nombre`            VARCHAR(150)   NOT NULL,
  `anio`              YEAR           NOT NULL,
  `categoria`         VARCHAR(100)   NOT NULL,
  `costo_inscripcion` DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
  `activa`            TINYINT(1)     NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_temporada`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. EQUIPO (agrega responsable, email, telefono)
-- ============================================================
CREATE TABLE `equipo` (
  `id_equipo`      INT(11)       NOT NULL AUTO_INCREMENT,
  `nombre_equipo`  VARCHAR(150)  NOT NULL,
  `entrenador`     VARCHAR(150)  NOT NULL,
  `responsable`    VARCHAR(150)  NOT NULL,
  `email`          VARCHAR(100)  DEFAULT NULL,
  `telefono`       VARCHAR(20)   DEFAULT NULL,
  PRIMARY KEY (`id_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. JUGADOR (corrige "Pocision", agrega cedula y activo)
-- ============================================================
CREATE TABLE `jugador` (
  `id_jugador`        INT(11)      NOT NULL AUTO_INCREMENT,
  `id_equipo`         INT(11)      NOT NULL,
  `cedula`            VARCHAR(20)  DEFAULT NULL,
  `nombre`            VARCHAR(100) NOT NULL,
  `apellido`          VARCHAR(100) NOT NULL,
  `fecha_nacimiento`  DATE         NOT NULL,
  `rol`               ENUM('bateador','pitcher','utilidad') NOT NULL DEFAULT 'bateador',
  `posicion`          VARCHAR(100) NOT NULL,
  `brazo_dominante`   VARCHAR(20)  DEFAULT NULL,
  `activo`            TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_jugador`),
  CONSTRAINT `fk_jugador_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipo` (`id_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. USUARIO (nuevo — control de acceso por roles)
-- ============================================================
CREATE TABLE `usuario` (
  `id_usuario`    INT(11)      NOT NULL AUTO_INCREMENT,
  `nombre`        VARCHAR(100) NOT NULL,
  `email`         VARCHAR(100) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `rol`           ENUM('administrador','dueno','caja','anotador','publico') NOT NULL DEFAULT 'publico',
  `id_jugador`    INT(11)      DEFAULT NULL,
  `activo`        TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuario_email` (`email`),
  CONSTRAINT `fk_usuario_jugador` FOREIGN KEY (`id_jugador`) REFERENCES `jugador` (`id_jugador`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. PARTIDO (renombrado de "partido-a-jugar", agrega lugar,
--    estado e id_temporada; elimina FK circular con liga)
-- ============================================================
CREATE TABLE `partido` (
  `id_partido`          INT(11)      NOT NULL AUTO_INCREMENT,
  `id_temporada`        INT(11)      NOT NULL,
  `id_equipo_casa`      INT(11)      NOT NULL,
  `id_equipo_visitante` INT(11)      NOT NULL,
  `fecha_juego`         DATE         NOT NULL,
  `hora_juego`          TIME         NOT NULL,
  `lugar`               VARCHAR(200) DEFAULT NULL,
  `innings_programados` INT(11)      NOT NULL DEFAULT 9,
  `estado`              ENUM('programado','en_curso','finalizado','suspendido') NOT NULL DEFAULT 'programado',
  PRIMARY KEY (`id_partido`),
  CONSTRAINT `fk_partido_temporada`  FOREIGN KEY (`id_temporada`)        REFERENCES `temporada` (`id_temporada`),
  CONSTRAINT `fk_partido_casa`       FOREIGN KEY (`id_equipo_casa`)      REFERENCES `equipo` (`id_equipo`),
  CONSTRAINT `fk_partido_visitante`  FOREIGN KEY (`id_equipo_visitante`) REFERENCES `equipo` (`id_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. RESULTADO (pitcher_salvador ahora nullable)
-- ============================================================
CREATE TABLE `resultado` (
  `id_resultado`         INT(11)      NOT NULL AUTO_INCREMENT,
  `id_partido`           INT(11)      NOT NULL,
  `carreras_home`        INT(11)      NOT NULL DEFAULT 0,
  `carreras_visitantes`  INT(11)      NOT NULL DEFAULT 0,
  `hits_home`            INT(11)      NOT NULL DEFAULT 0,
  `hits_visitantes`      INT(11)      NOT NULL DEFAULT 0,
  `errores_home`         INT(11)      NOT NULL DEFAULT 0,
  `errores_visitantes`   INT(11)      NOT NULL DEFAULT 0,
  `innings_totales`      INT(11)      NOT NULL DEFAULT 9,
  `id_pitcher_ganador`   INT(11)      DEFAULT NULL,
  `id_pitcher_perdedor`  INT(11)      DEFAULT NULL,
  `id_pitcher_salvador`  INT(11)      DEFAULT NULL,
  `observaciones`        TEXT         DEFAULT NULL,
  PRIMARY KEY (`id_resultado`),
  UNIQUE KEY `uq_resultado_partido` (`id_partido`),
  CONSTRAINT `fk_resultado_partido`         FOREIGN KEY (`id_partido`)          REFERENCES `partido`  (`id_partido`),
  CONSTRAINT `fk_resultado_pitcher_ganador` FOREIGN KEY (`id_pitcher_ganador`)  REFERENCES `jugador`  (`id_jugador`),
  CONSTRAINT `fk_resultado_pitcher_perdedor`FOREIGN KEY (`id_pitcher_perdedor`) REFERENCES `jugador`  (`id_jugador`),
  CONSTRAINT `fk_resultado_pitcher_salvador`FOREIGN KEY (`id_pitcher_salvador`) REFERENCES `jugador`  (`id_jugador`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. LINEUP / ALINEACION (nuevo — requerido por el PDF)
-- ============================================================
CREATE TABLE `lineup` (
  `id_lineup`      INT(11)      NOT NULL AUTO_INCREMENT,
  `id_partido`     INT(11)      NOT NULL,
  `id_jugador`     INT(11)      NOT NULL,
  `id_equipo`      INT(11)      NOT NULL,
  `orden_bateo`    INT(11)      DEFAULT NULL COMMENT 'Posicion en el orden al bate (1-9)',
  `posicion_juego` VARCHAR(50)  DEFAULT NULL COMMENT 'Posicion defensiva en este juego',
  `es_titular`     TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_lineup`),
  UNIQUE KEY `uq_lineup_jugador_partido` (`id_partido`, `id_jugador`),
  CONSTRAINT `fk_lineup_partido` FOREIGN KEY (`id_partido`) REFERENCES `partido` (`id_partido`),
  CONSTRAINT `fk_lineup_jugador` FOREIGN KEY (`id_jugador`) REFERENCES `jugador` (`id_jugador`),
  CONSTRAINT `fk_lineup_equipo`  FOREIGN KEY (`id_equipo`)  REFERENCES `equipo`  (`id_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. DESEMPENO_BATEADOR (corregidos nombres; referencia a partido)
-- ============================================================
CREATE TABLE `desempeno_bateador` (
  `id_desempeno`        INT(11) NOT NULL AUTO_INCREMENT,
  `id_jugador`          INT(11) NOT NULL,
  `id_partido`          INT(11) NOT NULL,
  `id_equipo`           INT(11) NOT NULL,
  `turnos_al_bate`      INT(11) NOT NULL DEFAULT 0,
  `hits`                INT(11) NOT NULL DEFAULT 0,
  `dobles`              INT(11) NOT NULL DEFAULT 0,
  `triples`             INT(11) NOT NULL DEFAULT 0,
  `jonrones`            INT(11) NOT NULL DEFAULT 0,
  `carreras`            INT(11) NOT NULL DEFAULT 0,
  `carreras_impulsadas` INT(11) NOT NULL DEFAULT 0,
  `bolas`               INT(11) NOT NULL DEFAULT 0,
  `strikes`             INT(11) NOT NULL DEFAULT 0,
  `foul`                INT(11) NOT NULL DEFAULT 0,
  `outs`                INT(11) NOT NULL DEFAULT 0,
  `asistencias`         INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_desempeno`),
  UNIQUE KEY `uq_bateador_partido` (`id_jugador`, `id_partido`),
  CONSTRAINT `fk_bat_jugador` FOREIGN KEY (`id_jugador`) REFERENCES `jugador`  (`id_jugador`),
  CONSTRAINT `fk_bat_partido` FOREIGN KEY (`id_partido`) REFERENCES `partido`  (`id_partido`),
  CONSTRAINT `fk_bat_equipo`  FOREIGN KEY (`id_equipo`)  REFERENCES `equipo`   (`id_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 9. DESEMPENO_PITCHER (renombrado de desempeño_picher)
-- ============================================================
CREATE TABLE `desempeno_pitcher` (
  `id_desempeno_pitcher`  INT(11)       NOT NULL AUTO_INCREMENT,
  `id_jugador`            INT(11)       NOT NULL,
  `id_partido`            INT(11)       NOT NULL,
  `id_equipo`             INT(11)       NOT NULL,
  `innings_pitcheados`    DECIMAL(4,1)  NOT NULL DEFAULT 0.0,
  `hits_permitidos`       INT(11)       NOT NULL DEFAULT 0,
  `carreras_permitidas`   INT(11)       NOT NULL DEFAULT 0,
  `carreras_limpias`      INT(11)       NOT NULL DEFAULT 0,
  `jonrones_permitidos`   INT(11)       NOT NULL DEFAULT 0,
  `golpes_bateador`       INT(11)       NOT NULL DEFAULT 0 COMMENT 'HBP - Hit by Pitch',
  `bases_por_bolas`       INT(11)       NOT NULL DEFAULT 0 COMMENT 'BB - Walks',
  `ponches`               INT(11)       NOT NULL DEFAULT 0,
  `ganado`                TINYINT(1)    NOT NULL DEFAULT 0,
  `perdido`               TINYINT(1)    NOT NULL DEFAULT 0,
  `salvado`               TINYINT(1)    NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_desempeno_pitcher`),
  UNIQUE KEY `uq_pitcher_partido` (`id_jugador`, `id_partido`),
  CONSTRAINT `fk_pit_jugador` FOREIGN KEY (`id_jugador`) REFERENCES `jugador` (`id_jugador`),
  CONSTRAINT `fk_pit_partido` FOREIGN KEY (`id_partido`) REFERENCES `partido` (`id_partido`),
  CONSTRAINT `fk_pit_equipo`  FOREIGN KEY (`id_equipo`)  REFERENCES `equipo`  (`id_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 10. INGRESO (agrega fecha_ingreso e id_temporada; corrige FK)
-- ============================================================
CREATE TABLE `ingreso` (
  `id_ingreso`    INT(11)       NOT NULL AUTO_INCREMENT,
  `id_equipo`     INT(11)       NOT NULL,
  `id_temporada`  INT(11)       NOT NULL,
  `concepto`      VARCHAR(300)  NOT NULL,
  `valor`         DECIMAL(10,2) NOT NULL,
  `fecha_ingreso` DATE          NOT NULL,
  `tipo_pago`     VARCHAR(100)  DEFAULT NULL,
  PRIMARY KEY (`id_ingreso`),
  CONSTRAINT `fk_ingreso_equipo`    FOREIGN KEY (`id_equipo`)    REFERENCES `equipo`    (`id_equipo`),
  CONSTRAINT `fk_ingreso_temporada` FOREIGN KEY (`id_temporada`) REFERENCES `temporada` (`id_temporada`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. EGRESO (corrige "Nota-gatos" → nota_gastos, id_temporada)
-- ============================================================
CREATE TABLE `egreso` (
  `id_egreso`     INT(11)       NOT NULL AUTO_INCREMENT,
  `id_temporada`  INT(11)       NOT NULL,
  `nota_gastos`   VARCHAR(300)  NOT NULL,
  `gasto`         DECIMAL(10,2) NOT NULL,
  `fecha_egreso`  DATE          NOT NULL,
  `tipo_pago`     VARCHAR(150)  DEFAULT NULL,
  PRIMARY KEY (`id_egreso`),
  CONSTRAINT `fk_egreso_temporada` FOREIGN KEY (`id_temporada`) REFERENCES `temporada` (`id_temporada`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. PROVEEDOR (corrige typo "provedor"; sin R.I.F. con punto)
-- ============================================================
CREATE TABLE `proveedor` (
  `id_proveedor`    INT(11)      NOT NULL AUTO_INCREMENT,
  `rif`             VARCHAR(75)  NOT NULL,
  `nombre_proveedor`VARCHAR(125) NOT NULL,
  `servicio`        VARCHAR(300) NOT NULL,
  `id_egreso`       INT(11)      NOT NULL,
  PRIMARY KEY (`id_proveedor`),
  CONSTRAINT `fk_proveedor_egreso` FOREIGN KEY (`id_egreso`) REFERENCES `egreso` (`id_egreso`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

COMMIT;
