-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 21-02-2026 a las 19:40:13
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
  `gasto` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipo`
--

CREATE TABLE `equipo` (
  `Id-Equipo` int(11) NOT NULL,
  `Cant-jugadores` int(11) NOT NULL,
  `Nombre-equipo` text NOT NULL,
  `Entrenador` text NOT NULL,
  `Id-Jugador` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ingreso`
--

CREATE TABLE `ingreso` (
  `Id-ingreso` int(11) NOT NULL,
  `Concepto` varchar(300) NOT NULL,
  `Valor` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `jugador`
--

CREATE TABLE `jugador` (
  `Id-jugador` int(11) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Apellido` varchar(100) NOT NULL,
  `Edad` int(11) NOT NULL,
  `Rol` varchar(100) NOT NULL,
  `Pocision` varchar(100) NOT NULL,
  `Diestro` int(11) NOT NULL,
  `Zurdo` int(11) NOT NULL,
  `Id-Desempeño` int(11) NOT NULL
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
  `Id-Equipo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `desempeño`
--
ALTER TABLE `desempeño`
  ADD PRIMARY KEY (`Id-Desempeño`);

--
-- Indices de la tabla `egreso`
--
ALTER TABLE `egreso`
  ADD PRIMARY KEY (`Id-egreso`);

--
-- Indices de la tabla `equipo`
--
ALTER TABLE `equipo`
  ADD PRIMARY KEY (`Id-Equipo`);

--
-- Indices de la tabla `ingreso`
--
ALTER TABLE `ingreso`
  ADD PRIMARY KEY (`Id-ingreso`);

--
-- Indices de la tabla `jugador`
--
ALTER TABLE `jugador`
  ADD PRIMARY KEY (`Id-jugador`);

--
-- Indices de la tabla `liga`
--
ALTER TABLE `liga`
  ADD PRIMARY KEY (`Id-Liga`);

--
-- Indices de la tabla `partido-a-jugar`
--
ALTER TABLE `partido-a-jugar`
  ADD PRIMARY KEY (`Id-partido`);

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
