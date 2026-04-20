-- ============================================================
-- Liga Diamante - Schema v2 (Normalizada)
-- Incluye: esquema completo + fotos/logos + taquilla + noticias
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
-- 1. TEMPORADA
-- ============================================================
CREATE TABLE `temporada` (
  `id_temporada`      INT(11)        NOT NULL AUTO_INCREMENT,
  `nombre`            VARCHAR(150)   NOT NULL,
  `anio`              YEAR           NOT NULL,
  `categoria`         VARCHAR(100)   NOT NULL,
  `costo_inscripcion` DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
  `activa`            TINYINT(1)     NOT NULL DEFAULT 1,
  `created_at`        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_temporada`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. EQUIPO
-- ============================================================
CREATE TABLE `equipo` (
  `id_equipo`      INT(11)       NOT NULL AUTO_INCREMENT,
  `nombre_equipo`  VARCHAR(150)  NOT NULL,
  `entrenador`     VARCHAR(150)  NOT NULL,
  `responsable`    VARCHAR(150)  NOT NULL,
  `email`          VARCHAR(100)  DEFAULT NULL,
  `telefono`       VARCHAR(20)   DEFAULT NULL,
  `logo_url`       VARCHAR(255)  DEFAULT NULL COMMENT 'URL relativa del logo/escudo del equipo',
  `created_at`     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. INSCRIPCION (N:M equipo ↔ temporada)
-- ============================================================
CREATE TABLE `inscripcion` (
  `id_inscripcion`  INT(11)     NOT NULL AUTO_INCREMENT,
  `id_equipo`       INT(11)     NOT NULL,
  `id_temporada`    INT(11)     NOT NULL,
  `fecha_inscripcion` DATE      NOT NULL,
  `estado_pago`     ENUM('pendiente','pagado','rechazado') NOT NULL DEFAULT 'pendiente',
  `monto_pagado`    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `observaciones`   TEXT        DEFAULT NULL,
  `created_at`      TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_inscripcion`),
  UNIQUE KEY `uq_inscripcion_equipo_temporada` (`id_equipo`, `id_temporada`),
  CONSTRAINT `fk_inscripcion_equipo`    FOREIGN KEY (`id_equipo`)    REFERENCES `equipo`    (`id_equipo`),
  CONSTRAINT `fk_inscripcion_temporada` FOREIGN KEY (`id_temporada`) REFERENCES `temporada` (`id_temporada`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. JUGADOR
-- ============================================================
CREATE TABLE `jugador` (
  `id_jugador`        INT(11)      NOT NULL AUTO_INCREMENT,
  `id_equipo`         INT(11)      NOT NULL,
  `cedula`            VARCHAR(20)  DEFAULT NULL,
  `nombre`            VARCHAR(100) NOT NULL,
  `apellido`          VARCHAR(100) NOT NULL,
  `fecha_nacimiento`  DATE         NOT NULL,
  `rol`               ENUM('bateador','pitcher','utilidad') NOT NULL DEFAULT 'bateador',
  `posicion`          ENUM('P','C','1B','2B','3B','SS','LF','CF','RF','DH','UT') NOT NULL DEFAULT 'UT',
  `brazo_dominante`   ENUM('derecho','izquierdo','ambidiestro') DEFAULT NULL,
  `foto_url`          VARCHAR(255) DEFAULT NULL COMMENT 'URL relativa de la foto del jugador',
  `activo`            TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at`        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_jugador`),
  CONSTRAINT `fk_jugador_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipo` (`id_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. USUARIO
-- ============================================================
CREATE TABLE `usuario` (
  `id_usuario`    INT(11)      NOT NULL AUTO_INCREMENT,
  `nombre`        VARCHAR(100) NOT NULL,
  `email`         VARCHAR(100) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `rol`           ENUM('administrador','dueno','caja','anotador','publico') NOT NULL DEFAULT 'publico',
  `activo`        TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuario_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. PARTIDO
-- ============================================================
CREATE TABLE `partido` (
  `id_partido`          INT(11)      NOT NULL AUTO_INCREMENT,
  `id_temporada`        INT(11)      NOT NULL,
  `id_equipo_casa`      INT(11)      NOT NULL,
  `id_equipo_visitante` INT(11)      NOT NULL,
  `fecha_juego`         DATE         NOT NULL,
  `hora_juego`          TIME         NOT NULL,
  `lugar`               VARCHAR(200) DEFAULT NULL,
  `innings_programados` INT(11)       NOT NULL DEFAULT 9,
  `estado`              ENUM('programado','en_curso','finalizado','suspendido') NOT NULL DEFAULT 'programado',
  `boletos_general`     INT(11)       NOT NULL DEFAULT 0,
  `precio_general`      DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `boletos_vip`         INT(11)       NOT NULL DEFAULT 0,
  `precio_vip`          DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `capacidad_estadio`   INT(11)       NOT NULL DEFAULT 0,
  `created_at`          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_partido`),
  CONSTRAINT `chk_equipos_diferentes` CHECK (`id_equipo_casa` <> `id_equipo_visitante`),
  CONSTRAINT `fk_partido_temporada`  FOREIGN KEY (`id_temporada`)        REFERENCES `temporada` (`id_temporada`),
  CONSTRAINT `fk_partido_casa`       FOREIGN KEY (`id_equipo_casa`)      REFERENCES `equipo` (`id_equipo`),
  CONSTRAINT `fk_partido_visitante`  FOREIGN KEY (`id_equipo_visitante`) REFERENCES `equipo` (`id_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. RESULTADO
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
  CONSTRAINT `fk_resultado_partido`          FOREIGN KEY (`id_partido`)          REFERENCES `partido`  (`id_partido`),
  CONSTRAINT `fk_resultado_pitcher_ganador`  FOREIGN KEY (`id_pitcher_ganador`)  REFERENCES `jugador`  (`id_jugador`),
  CONSTRAINT `fk_resultado_pitcher_perdedor` FOREIGN KEY (`id_pitcher_perdedor`) REFERENCES `jugador`  (`id_jugador`),
  CONSTRAINT `fk_resultado_pitcher_salvador` FOREIGN KEY (`id_pitcher_salvador`) REFERENCES `jugador`  (`id_jugador`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. LINEUP / ALINEACION
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
-- 9. DESEMPENO_BATEADOR
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
-- 10. DESEMPENO_PITCHER
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
-- 11. PROVEEDOR (independiente de egreso)
-- ============================================================
CREATE TABLE `proveedor` (
  `id_proveedor`     INT(11)      NOT NULL AUTO_INCREMENT,
  `rif`              VARCHAR(75)  NOT NULL,
  `nombre_proveedor` VARCHAR(125) NOT NULL,
  `servicio`         VARCHAR(300) NOT NULL,
  `telefono`         VARCHAR(20)  DEFAULT NULL,
  `email`            VARCHAR(100) DEFAULT NULL,
  `activo`           TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at`       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_proveedor`),
  UNIQUE KEY `uq_proveedor_rif` (`rif`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. INGRESO
-- ============================================================
CREATE TABLE `ingreso` (
  `id_ingreso`    INT(11)       NOT NULL AUTO_INCREMENT,
  `id_equipo`     INT(11)       NOT NULL,
  `id_temporada`  INT(11)       NOT NULL,
  `concepto`      VARCHAR(300)  NOT NULL,
  `valor`         DECIMAL(10,2) NOT NULL,
  `fecha_ingreso` DATE          NOT NULL,
  `tipo_pago`     ENUM('Efectivo','Transferencia','Divisas','Pago Movil','Cheque','Zelle') DEFAULT NULL,
  `created_at`    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_ingreso`),
  CONSTRAINT `fk_ingreso_equipo`    FOREIGN KEY (`id_equipo`)    REFERENCES `equipo`    (`id_equipo`),
  CONSTRAINT `fk_ingreso_temporada` FOREIGN KEY (`id_temporada`) REFERENCES `temporada` (`id_temporada`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 13. EGRESO (ahora referencia a proveedor, no al revés)
-- ============================================================
CREATE TABLE `egreso` (
  `id_egreso`     INT(11)       NOT NULL AUTO_INCREMENT,
  `id_temporada`  INT(11)       NOT NULL,
  `id_proveedor`  INT(11)       DEFAULT NULL,
  `nota_gastos`   VARCHAR(300)  NOT NULL,
  `gasto`         DECIMAL(10,2) NOT NULL,
  `fecha_egreso`  DATE          NOT NULL,
  `tipo_pago`     ENUM('Efectivo','Transferencia','Divisas','Pago Movil','Cheque','Zelle') DEFAULT NULL,
  `created_at`    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_egreso`),
  CONSTRAINT `fk_egreso_temporada`  FOREIGN KEY (`id_temporada`) REFERENCES `temporada` (`id_temporada`),
  CONSTRAINT `fk_egreso_proveedor`  FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 14. SANCION (nuevo — control disciplinario)
-- ============================================================
CREATE TABLE `sancion` (
  `id_sancion`    INT(11)       NOT NULL AUTO_INCREMENT,
  `id_temporada`  INT(11)       NOT NULL,
  `id_jugador`    INT(11)       DEFAULT NULL,
  `id_equipo`     INT(11)       DEFAULT NULL,
  `tipo`          ENUM('amonestacion','suspension','multa','expulsion') NOT NULL,
  `descripcion`   TEXT          NOT NULL,
  `fecha_sancion` DATE          NOT NULL,
  `partidos_suspension` INT(11) NOT NULL DEFAULT 0 COMMENT 'Cantidad de partidos suspendido',
  `monto_multa`   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `estado`        ENUM('activa','cumplida','apelada','revocada') NOT NULL DEFAULT 'activa',
  `created_at`    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_sancion`),
  CONSTRAINT `fk_sancion_temporada` FOREIGN KEY (`id_temporada`) REFERENCES `temporada` (`id_temporada`),
  CONSTRAINT `fk_sancion_jugador`   FOREIGN KEY (`id_jugador`)   REFERENCES `jugador`   (`id_jugador`),
  CONSTRAINT `fk_sancion_equipo`    FOREIGN KEY (`id_equipo`)    REFERENCES `equipo`     (`id_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 15. SEGUIMIENTO (fan — seguir equipos)
-- ============================================================
CREATE TABLE `seguimiento` (
  `id`          INT(11) NOT NULL AUTO_INCREMENT,
  `id_usuario`  INT(11) NOT NULL,
  `id_equipo`   INT(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_seguimiento` (`id_usuario`, `id_equipo`),
  CONSTRAINT `fk_seguimiento_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE,
  CONSTRAINT `fk_seguimiento_equipo`  FOREIGN KEY (`id_equipo`)  REFERENCES `equipo`  (`id_equipo`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 16. NOTICIA (contenido de la página pública)
-- ============================================================
CREATE TABLE `noticia` (
  `id_noticia`        INT(11)      NOT NULL AUTO_INCREMENT,
  `titulo`            VARCHAR(255) NOT NULL,
  `contenido`         TEXT         DEFAULT NULL,
  `foto_url`          VARCHAR(500) DEFAULT NULL,
  `fecha_publicacion` DATE         DEFAULT NULL,
  `activa`            TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at`        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_noticia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

COMMIT;
