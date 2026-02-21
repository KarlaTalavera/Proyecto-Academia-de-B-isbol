-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 21-02-2026 a las 20:58:15
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
-- Estructura de tabla para la tabla `desempeño`
--

CREATE TABLE `desempeño` (
  `Id-Desempeño` int(11) NOT NULL,
  `Id-jugador` int(11) NOT NULL,
  `Id-partido` int(11) NOT NULL,
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
-- Estructura de tabla para la tabla `egreso`
--

CREATE TABLE `egreso` (
  `Id-egreso` int(11) NOT NULL,
  `Nota-gatos` varchar(300) NOT NULL,
  `gasto` decimal(10,2) NOT NULL,
  `Id-partido` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipo`
--

CREATE TABLE `equipo` (
  `Id-Equipo` int(11) NOT NULL,
  `Cant-jugadores` int(11) NOT NULL,
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
  `Edad` int(11) NOT NULL,
  `Rol` varchar(100) NOT NULL,
  `Pocision` varchar(100) NOT NULL,
  `Diestro` int(11) NOT NULL,
  `Zurdo` int(11) NOT NULL
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

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `desempeño`
--
ALTER TABLE `desempeño`
  ADD PRIMARY KEY (`Id-Desempeño`),
  ADD KEY `fk_desempeño_jugador` (`Id-jugador`),
  ADD KEY `fk_desempeño_partido` (`Id-partido`);

--
-- Indices de la tabla `egreso`
--
ALTER TABLE `egreso`
  ADD PRIMARY KEY (`Id-egreso`),
  ADD KEY `fk_egreso_partido` (`Id-partido`);

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
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `desempeño`
--
ALTER TABLE `desempeño`
  MODIFY `Id-Desempeño` int(11) NOT NULL AUTO_INCREMENT;

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
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `desempeño`
--
ALTER TABLE `desempeño`
  ADD CONSTRAINT `fk_desempeño_jugador` FOREIGN KEY (`Id-jugador`) REFERENCES `jugador` (`Id-jugador`),
  ADD CONSTRAINT `fk_desempeño_partido` FOREIGN KEY (`Id-partido`) REFERENCES `partido-a-jugar` (`Id-partido`);

--
-- Filtros para la tabla `egreso`
--
ALTER TABLE `egreso`
  ADD CONSTRAINT `fk_egreso_partido` FOREIGN KEY (`Id-partido`) REFERENCES `partido-a-jugar` (`Id-partido`);

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
