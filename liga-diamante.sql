-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 01-03-2026 a las 19:21:51
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `liga-diamante`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `desempeño_bateador`
--

CREATE TABLE `desempeño_bateador` (
  `Id-Desempeño` int(11) NOT NULL,
  `Id-jugador` int(11) NOT NULL,
  `Id-resultado` int(11) NOT NULL,
  `Hinin-jugados` int(11) NOT NULL,
  `Asistencias` int(11) NOT NULL,
  `Hit` int(11) NOT NULL,
  `Dobles` int(11) NOT NULL,
  `Triples` int(11) NOT NULL,
  `Jonrón` int(11) NOT NULL,
  `Bolas` int(11) NOT NULL,
  `Strikes` int(11) NOT NULL,
  `Foul` int(11) NOT NULL,
  `Fuera` int(11) NOT NULL,
  `Carreras` int(11) NOT NULL,
  `Carreras-impulsadas` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `desempeño_picher`
--

CREATE TABLE `desempeño_picher` (
  `Id-desempeño_picher` int(11) NOT NULL,
  `IP` decimal(10,2) NOT NULL,
  `R` int(11) NOT NULL,
  `Hits` int(11) NOT NULL,
  `ER` int(11) NOT NULL,
  `HR(cuadrangular permitido))` int(11) NOT NULL,
  `HB` int(11) NOT NULL,
  `BB` int(11) NOT NULL,
  `juegos_juegados` int(11) NOT NULL,
  `ponches` int(11) NOT NULL,
  `id-jugador` int(11) NOT NULL,
  `Id-resultado` int(11) NOT NULL,
  `ganados` int(1) NOT NULL DEFAULT 0,
  `perdido` int(1) NOT NULL DEFAULT 0,
  `salvado` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `egreso`
--

CREATE TABLE `egreso` (
  `Id-egreso` int(11) NOT NULL,
  `Nota-gatos` varchar(300) NOT NULL,
  `gasto` decimal(10,2) NOT NULL,
  `Fecha_egreso` datetime DEFAULT NULL,
  `Id-Liga` int(11) NOT NULL,
  `Tipo_de_pago` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipo`
--

CREATE TABLE `equipo` (
  `Id-Equipo` int(11) NOT NULL,
  `Nombre-equipo` text NOT NULL,
  `Entrenador` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ingreso`
--

CREATE TABLE `ingreso` (
  `Id-ingreso` int(11) NOT NULL,
  `Concepto` varchar(300) NOT NULL,
  `Valor` decimal(10,2) NOT NULL,
  `Id-Equipo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `jugador`
--

CREATE TABLE `jugador` (
  `Id-jugador` int(11) NOT NULL,
  `Id-Equipo` int(11) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Apellido` varchar(100) NOT NULL,
  `Fecha_nacimiento` datetime NOT NULL,
  `Rol` varchar(100) NOT NULL,
  `Pocision` varchar(100) NOT NULL,
  `Brazo-dominante` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `liga`
--

CREATE TABLE `liga` (
  `Id-Liga` int(11) NOT NULL,
  `Categoria` text NOT NULL,
  `Tamaño` int(11) NOT NULL,
  `Costo-inscripcion` decimal(10,0) NOT NULL,
  `Id-partido` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partido-a-jugar`
--

CREATE TABLE `partido-a-jugar` (
  `Id-partido` int(11) NOT NULL,
  `hinin` int(11) NOT NULL,
  `Resultado` int(11) NOT NULL,
  `fecha-de-juego` date NOT NULL,
  `Hora-de-juego` time NOT NULL,
  `Id-Equipo-Casa` int(11) NOT NULL,
  `Id-Equipo-Visitante` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `provedor`
--

CREATE TABLE `provedor` (
  `Id_Provedor` int(11) NOT NULL,
  `R.I.F` varchar(75) NOT NULL,
  `Servicio` varchar(300) NOT NULL,
  `id_egreso` int(11) NOT NULL,
  `Nombre_provedor` varchar(125) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `resultado`
--

CREATE TABLE `resultado` (
  `Id-resultado` int(11) NOT NULL,
  `Id-partido-a-jugar` int(11) NOT NULL,
  `Carreras_Home` int(11) NOT NULL,
  `Carreras_visitantes` int(11) NOT NULL,
  `Hit_totales_Home` int(11) NOT NULL,
  `Hit_totales_visitantes` int(11) NOT NULL,
  `Errores_Home` int(11) NOT NULL,
  `Errores_visitantes` int(11) NOT NULL,
  `Innings_totales` int(11) NOT NULL,
  `Id-picher-ganador` int(11) NOT NULL,
  `Id-picher-perdedor` int(11) NOT NULL,
  `Id-picher-salvador` int(11) NOT NULL,
  `Observaciones` varchar(800) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `desempeño_bateador`
--
ALTER TABLE `desempeño_bateador`
  ADD PRIMARY KEY (`Id-Desempeño`),
  ADD KEY `fk_desempeño_jugador` (`Id-jugador`),
  ADD KEY `fk_bateador_resultado` (`Id-resultado`);

--
-- Indices de la tabla `desempeño_picher`
--
ALTER TABLE `desempeño_picher`
  ADD PRIMARY KEY (`Id-desempeño_picher`),
  ADD KEY `fk_picher_jugador` (`id-jugador`),
  ADD KEY `fk_picher_resultado` (`Id-resultado`);

--
-- Indices de la tabla `egreso`
--
ALTER TABLE `egreso`
  ADD PRIMARY KEY (`Id-egreso`),
  ADD KEY `fk_egreso_liga` (`Id-Liga`);

--
-- Indices de la tabla `equipo`
--
ALTER TABLE `equipo`
  ADD PRIMARY KEY (`Id-Equipo`);

--
-- Indices de la tabla `ingreso`
--
ALTER TABLE `ingreso`
  ADD PRIMARY KEY (`Id-ingreso`),
  ADD KEY `fk_ingreso_equipo` (`Id-Equipo`);

--
-- Indices de la tabla `jugador`
--
ALTER TABLE `jugador`
  ADD PRIMARY KEY (`Id-jugador`),
  ADD KEY `fk_jugador_equipo` (`Id-Equipo`);

--
-- Indices de la tabla `liga`
--
ALTER TABLE `liga`
  ADD PRIMARY KEY (`Id-Liga`),
  ADD KEY `fk_liga_partido` (`Id-partido`);

--
-- Indices de la tabla `partido-a-jugar`
--
ALTER TABLE `partido-a-jugar`
  ADD PRIMARY KEY (`Id-partido`),
  ADD KEY `fk_partido-a-jugar` (`Id-Equipo-Casa`),
  ADD KEY `fk_partido_visitante` (`Id-Equipo-Visitante`);

--
-- Indices de la tabla `provedor`
--
ALTER TABLE `provedor`
  ADD PRIMARY KEY (`Id_Provedor`),
  ADD KEY `fk_provedor_egreso` (`id_egreso`);

--
-- Indices de la tabla `resultado`
--
ALTER TABLE `resultado`
  ADD PRIMARY KEY (`Id-resultado`),
  ADD KEY `fk_resultado_partido` (`Id-partido-a-jugar`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `desempeño_bateador`
--
ALTER TABLE `desempeño_bateador`
  MODIFY `Id-Desempeño` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `desempeño_picher`
--
ALTER TABLE `desempeño_picher`
  MODIFY `Id-desempeño_picher` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `egreso`
--
ALTER TABLE `egreso`
  MODIFY `Id-egreso` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `equipo`
--
ALTER TABLE `equipo`
  MODIFY `Id-Equipo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ingreso`
--
ALTER TABLE `ingreso`
  MODIFY `Id-ingreso` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `jugador`
--
ALTER TABLE `jugador`
  MODIFY `Id-jugador` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `liga`
--
ALTER TABLE `liga`
  MODIFY `Id-Liga` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `partido-a-jugar`
--
ALTER TABLE `partido-a-jugar`
  MODIFY `Id-partido` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `provedor`
--
ALTER TABLE `provedor`
  MODIFY `Id_Provedor` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `resultado`
--
ALTER TABLE `resultado`
  MODIFY `Id-resultado` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `desempeño_bateador`
--
ALTER TABLE `desempeño_bateador`
  ADD CONSTRAINT `fk_bateador_resultado` FOREIGN KEY (`Id-resultado`) REFERENCES `resultado` (`Id-resultado`),
  ADD CONSTRAINT `fk_desempeño_jugador` FOREIGN KEY (`Id-jugador`) REFERENCES `jugador` (`Id-jugador`);

--
-- Filtros para la tabla `desempeño_picher`
--
ALTER TABLE `desempeño_picher`
  ADD CONSTRAINT `fk_picher_jugador` FOREIGN KEY (`id-jugador`) REFERENCES `jugador` (`Id-jugador`),
  ADD CONSTRAINT `fk_picher_resultado` FOREIGN KEY (`Id-resultado`) REFERENCES `resultado` (`Id-resultado`);

--
-- Filtros para la tabla `egreso`
--
ALTER TABLE `egreso`
  ADD CONSTRAINT `fk_egreso_liga` FOREIGN KEY (`Id-Liga`) REFERENCES `liga` (`Id-Liga`);

--
-- Filtros para la tabla `ingreso`
--
ALTER TABLE `ingreso`
  ADD CONSTRAINT `fk_ingreso_equipo` FOREIGN KEY (`Id-Equipo`) REFERENCES `equipo` (`Id-Equipo`);

--
-- Filtros para la tabla `jugador`
--
ALTER TABLE `jugador`
  ADD CONSTRAINT `fk_jugador_equipo` FOREIGN KEY (`Id-Equipo`) REFERENCES `equipo` (`Id-Equipo`);

--
-- Filtros para la tabla `liga`
--
ALTER TABLE `liga`
  ADD CONSTRAINT `fk_liga_partido` FOREIGN KEY (`Id-partido`) REFERENCES `partido-a-jugar` (`Id-partido`);

--
-- Filtros para la tabla `partido-a-jugar`
--
ALTER TABLE `partido-a-jugar`
  ADD CONSTRAINT `fk_partido-a-jugar` FOREIGN KEY (`Id-Equipo-Casa`) REFERENCES `equipo` (`Id-Equipo`),
  ADD CONSTRAINT `fk_partido_visitante` FOREIGN KEY (`Id-Equipo-Visitante`) REFERENCES `equipo` (`Id-Equipo`);

--
-- Filtros para la tabla `provedor`
--
ALTER TABLE `provedor`
  ADD CONSTRAINT `fk_provedor_egreso` FOREIGN KEY (`id_egreso`) REFERENCES `egreso` (`Id-egreso`);

--
-- Filtros para la tabla `resultado`
--
ALTER TABLE `resultado`
  ADD CONSTRAINT `fk_resultado_partido` FOREIGN KEY (`Id-partido-a-jugar`) REFERENCES `partido-a-jugar` (`Id-partido`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
