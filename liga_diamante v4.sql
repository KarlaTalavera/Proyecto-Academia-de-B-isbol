-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 22-05-2026 a las 04:20:30
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
-- Base de datos: `liga_diamante`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `desempeno_bateador`
--

CREATE TABLE `desempeno_bateador` (
  `id_desempeno` int(11) NOT NULL,
  `id_jugador` int(11) NOT NULL,
  `id_partido` int(11) NOT NULL,
  `id_equipo` int(11) NOT NULL,
  `turnos_al_bate` int(11) NOT NULL DEFAULT 0,
  `hits` int(11) NOT NULL DEFAULT 0,
  `dobles` int(11) NOT NULL DEFAULT 0,
  `triples` int(11) NOT NULL DEFAULT 0,
  `jonrones` int(11) NOT NULL DEFAULT 0,
  `carreras` int(11) NOT NULL DEFAULT 0,
  `carreras_impulsadas` int(11) NOT NULL DEFAULT 0,
  `bolas` int(11) NOT NULL DEFAULT 0,
  `strikes` int(11) NOT NULL DEFAULT 0,
  `foul` int(11) NOT NULL DEFAULT 0,
  `outs` int(11) NOT NULL DEFAULT 0,
  `asistencias` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `desempeno_bateador`
--

INSERT INTO `desempeno_bateador` (`id_desempeno`, `id_jugador`, `id_partido`, `id_equipo`, `turnos_al_bate`, `hits`, `dobles`, `triples`, `jonrones`, `carreras`, `carreras_impulsadas`, `bolas`, `strikes`, `foul`, `outs`, `asistencias`) VALUES
(1, 2, 1, 1, 4, 2, 1, 0, 0, 1, 2, 0, 0, 0, 0, 0),
(2, 3, 1, 1, 4, 2, 0, 0, 1, 2, 2, 0, 0, 0, 0, 0),
(3, 4, 1, 1, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(4, 5, 1, 1, 3, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(5, 6, 1, 1, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6, 7, 1, 1, 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(7, 8, 1, 1, 4, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0),
(8, 9, 1, 1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9, 12, 1, 2, 4, 2, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(10, 13, 1, 2, 4, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(11, 14, 1, 2, 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(12, 15, 1, 2, 4, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(13, 16, 1, 2, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(14, 17, 1, 2, 3, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(15, 18, 1, 2, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(16, 19, 1, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(17, 22, 2, 3, 4, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(18, 23, 2, 3, 4, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(19, 24, 2, 3, 3, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(20, 25, 2, 3, 4, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(21, 26, 2, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(22, 27, 2, 3, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(23, 32, 2, 4, 4, 2, 1, 0, 1, 2, 3, 0, 0, 0, 0, 0),
(24, 33, 2, 4, 4, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(25, 34, 2, 4, 4, 2, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(26, 35, 2, 4, 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(27, 36, 2, 4, 4, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0),
(28, 37, 2, 4, 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(29, 38, 2, 4, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(30, 12, 5, 2, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(31, 13, 5, 2, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(32, 14, 5, 2, 3, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(33, 15, 5, 2, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(34, 16, 5, 2, 4, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(35, 17, 5, 2, 3, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(36, 22, 5, 3, 5, 3, 1, 0, 1, 2, 3, 0, 0, 0, 0, 0),
(37, 23, 5, 3, 4, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(38, 24, 5, 3, 5, 2, 1, 0, 0, 1, 2, 0, 0, 0, 0, 0),
(39, 25, 5, 3, 4, 2, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0),
(40, 26, 5, 3, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(41, 27, 5, 3, 4, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(42, 28, 5, 3, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(43, 29, 5, 3, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(44, 2, 9, 1, 5, 3, 1, 0, 1, 2, 3, 0, 0, 0, 0, 0),
(45, 3, 9, 1, 4, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(46, 4, 9, 1, 4, 2, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(47, 5, 9, 1, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(48, 6, 9, 1, 4, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0),
(49, 7, 9, 1, 3, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(50, 8, 9, 1, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(51, 22, 9, 3, 4, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(52, 23, 9, 3, 3, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(53, 24, 9, 3, 4, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(54, 25, 9, 3, 3, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(55, 26, 9, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(56, 27, 9, 3, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(57, 42, 3, 5, 4, 2, 0, 0, 1, 2, 2, 0, 0, 0, 0, 0),
(58, 43, 3, 5, 4, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(59, 44, 3, 5, 4, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(60, 45, 3, 5, 3, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(61, 52, 3, 6, 4, 2, 1, 0, 0, 1, 2, 0, 0, 0, 0, 0),
(62, 53, 3, 6, 4, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0),
(63, 54, 3, 6, 4, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(64, 55, 3, 6, 3, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(65, 62, 4, 7, 4, 3, 1, 0, 1, 2, 3, 0, 0, 0, 0, 0),
(66, 63, 4, 7, 4, 2, 0, 1, 0, 2, 1, 0, 0, 0, 0, 0),
(67, 64, 4, 7, 4, 2, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(68, 65, 4, 7, 4, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(69, 72, 4, 8, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(70, 73, 4, 8, 3, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(71, 74, 4, 8, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(72, 75, 4, 8, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(73, 32, 6, 4, 4, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(74, 33, 6, 4, 4, 2, 1, 0, 0, 2, 2, 0, 0, 0, 0, 0),
(75, 34, 6, 4, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(76, 35, 6, 4, 3, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(77, 42, 6, 5, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(78, 43, 6, 5, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(79, 44, 6, 5, 4, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(80, 45, 6, 5, 3, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(81, 52, 7, 6, 4, 2, 0, 0, 1, 2, 2, 0, 0, 0, 0, 0),
(82, 53, 7, 6, 4, 2, 1, 0, 0, 1, 2, 0, 0, 0, 0, 0),
(83, 54, 7, 6, 4, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(84, 55, 7, 6, 4, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(85, 62, 7, 7, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(86, 63, 7, 7, 4, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(87, 64, 7, 7, 3, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(88, 65, 7, 7, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(89, 72, 8, 8, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(90, 73, 8, 8, 3, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(91, 74, 8, 8, 3, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(92, 75, 8, 8, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(93, 2, 8, 1, 4, 2, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(94, 3, 8, 1, 4, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(95, 4, 8, 1, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(96, 5, 8, 1, 3, 2, 1, 0, 0, 1, 2, 0, 0, 0, 0, 0),
(97, 12, 10, 2, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(98, 13, 10, 2, 4, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(99, 14, 10, 2, 4, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(100, 15, 10, 2, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(101, 32, 10, 4, 5, 2, 0, 0, 1, 2, 2, 0, 0, 0, 0, 0),
(102, 33, 10, 4, 4, 2, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(103, 34, 10, 4, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(104, 35, 10, 4, 4, 2, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(105, 42, 11, 5, 4, 2, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(106, 43, 11, 5, 3, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(107, 44, 11, 5, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(108, 45, 11, 5, 3, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(109, 62, 11, 7, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(110, 63, 11, 7, 3, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(111, 64, 11, 7, 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(112, 65, 11, 7, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(113, 52, 12, 6, 5, 3, 1, 0, 1, 3, 3, 0, 0, 0, 0, 0),
(114, 53, 12, 6, 4, 3, 0, 1, 0, 2, 2, 0, 0, 0, 0, 0),
(115, 54, 12, 6, 4, 2, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0),
(116, 55, 12, 6, 4, 2, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(117, 56, 12, 6, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(118, 57, 12, 6, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(119, 72, 12, 8, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(120, 73, 12, 8, 3, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(121, 74, 12, 8, 3, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(122, 75, 12, 8, 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(123, 76, 12, 8, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(124, 2, 16, 1, 4, 3, 1, 0, 1, 2, 3, 0, 0, 0, 0, 0),
(125, 3, 16, 1, 4, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(126, 4, 16, 1, 4, 2, 1, 0, 0, 2, 1, 0, 0, 0, 0, 0),
(127, 5, 16, 1, 3, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(128, 6, 16, 1, 4, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(129, 8, 16, 1, 4, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0),
(130, 12, 16, 2, 4, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(131, 13, 16, 2, 4, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(132, 14, 16, 2, 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(133, 15, 16, 2, 4, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(134, 16, 16, 2, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(135, 22, 17, 3, 4, 2, 1, 0, 0, 2, 1, 0, 0, 0, 0, 0),
(136, 23, 17, 3, 4, 2, 0, 0, 0, 1, 2, 0, 0, 0, 0, 0),
(137, 24, 17, 3, 4, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(138, 25, 17, 3, 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(139, 32, 17, 4, 4, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(140, 33, 17, 4, 4, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(141, 34, 17, 4, 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(142, 35, 17, 4, 4, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(143, 42, 18, 5, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(144, 43, 18, 5, 4, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(145, 44, 18, 5, 4, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(146, 45, 18, 5, 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(147, 52, 18, 6, 4, 3, 1, 0, 1, 3, 3, 0, 0, 0, 0, 0),
(148, 53, 18, 6, 4, 2, 0, 0, 0, 1, 2, 0, 0, 0, 0, 0),
(149, 54, 18, 6, 4, 2, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(150, 55, 18, 6, 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(151, 12, 19, 2, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(152, 13, 19, 2, 4, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(153, 14, 19, 2, 3, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(154, 15, 19, 2, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(155, 22, 19, 3, 5, 3, 1, 0, 1, 3, 3, 0, 0, 0, 0, 0),
(156, 23, 19, 3, 4, 2, 0, 1, 0, 2, 2, 0, 0, 0, 0, 0),
(157, 24, 19, 3, 4, 2, 1, 0, 0, 1, 2, 0, 0, 0, 0, 0),
(158, 25, 19, 3, 4, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(159, 26, 19, 3, 4, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(160, 32, 20, 4, 4, 3, 1, 0, 1, 2, 3, 0, 0, 0, 0, 0),
(161, 33, 20, 4, 4, 2, 0, 0, 0, 2, 1, 0, 0, 0, 0, 0),
(162, 34, 20, 4, 4, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(163, 35, 20, 4, 3, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(164, 42, 20, 5, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(165, 43, 20, 5, 4, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(166, 44, 20, 5, 3, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(167, 45, 20, 5, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(168, 52, 21, 6, 4, 2, 0, 0, 1, 2, 2, 0, 0, 0, 0, 0),
(169, 53, 21, 6, 4, 2, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(170, 54, 21, 6, 4, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
(171, 55, 21, 6, 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(172, 2, 21, 1, 4, 2, 1, 0, 0, 2, 2, 0, 0, 0, 0, 0),
(173, 3, 21, 1, 4, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(174, 4, 21, 1, 4, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
(175, 5, 21, 1, 3, 2, 1, 0, 0, 1, 2, 0, 0, 0, 0, 0),
(176, 61, 24, 7, 1, 1, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0),
(177, 61, 22, 7, 3, 2, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0),
(178, 62, 22, 7, 2, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(179, 63, 22, 7, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(180, 64, 22, 7, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0),
(181, 65, 22, 7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(182, 67, 22, 7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(183, 68, 22, 7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(184, 69, 22, 7, 2, 2, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0),
(185, 70, 22, 7, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0),
(198, 2, 22, 1, 2, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
(199, 3, 22, 1, 2, 2, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0),
(200, 4, 22, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(201, 5, 22, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(202, 6, 22, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(203, 7, 22, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(204, 8, 22, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(205, 9, 22, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(206, 10, 22, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(270, 1, 22, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(271, 81, 22, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `desempeno_pitcher`
--

CREATE TABLE `desempeno_pitcher` (
  `id_desempeno_pitcher` int(11) NOT NULL,
  `id_jugador` int(11) NOT NULL,
  `id_partido` int(11) NOT NULL,
  `id_equipo` int(11) NOT NULL,
  `innings_pitcheados` decimal(4,1) NOT NULL DEFAULT 0.0,
  `hits_permitidos` int(11) NOT NULL DEFAULT 0,
  `carreras_permitidas` int(11) NOT NULL DEFAULT 0,
  `carreras_limpias` int(11) NOT NULL DEFAULT 0,
  `jonrones_permitidos` int(11) NOT NULL DEFAULT 0,
  `golpes_bateador` int(11) NOT NULL DEFAULT 0 COMMENT 'HBP - Hit by Pitch',
  `bases_por_bolas` int(11) NOT NULL DEFAULT 0 COMMENT 'BB - Walks',
  `ponches` int(11) NOT NULL DEFAULT 0,
  `ganado` tinyint(1) NOT NULL DEFAULT 0,
  `perdido` tinyint(1) NOT NULL DEFAULT 0,
  `salvado` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `desempeno_pitcher`
--

INSERT INTO `desempeno_pitcher` (`id_desempeno_pitcher`, `id_jugador`, `id_partido`, `id_equipo`, `innings_pitcheados`, `hits_permitidos`, `carreras_permitidas`, `carreras_limpias`, `jonrones_permitidos`, `golpes_bateador`, `bases_por_bolas`, `ponches`, `ganado`, `perdido`, `salvado`) VALUES
(1, 1, 1, 1, 7.0, 5, 2, 2, 0, 0, 2, 8, 1, 0, 0),
(2, 10, 1, 1, 2.0, 2, 1, 1, 0, 0, 1, 3, 0, 0, 0),
(3, 11, 1, 2, 6.0, 7, 4, 3, 0, 0, 3, 5, 0, 1, 0),
(4, 20, 1, 2, 3.0, 2, 1, 1, 0, 0, 0, 2, 0, 0, 0),
(5, 21, 2, 3, 5.0, 8, 5, 4, 0, 0, 4, 3, 0, 1, 0),
(6, 30, 2, 3, 4.0, 2, 1, 1, 0, 0, 1, 4, 0, 0, 0),
(7, 31, 2, 4, 9.0, 5, 2, 2, 0, 0, 1, 10, 1, 0, 0),
(8, 41, 3, 5, 8.0, 6, 3, 3, 0, 0, 2, 7, 1, 0, 0),
(9, 50, 3, 5, 3.0, 2, 1, 1, 0, 0, 1, 2, 0, 0, 0),
(10, 51, 3, 6, 7.0, 6, 4, 3, 0, 0, 3, 6, 0, 1, 0),
(11, 60, 3, 6, 4.0, 2, 1, 1, 0, 0, 0, 3, 0, 0, 0),
(12, 61, 4, 7, 9.0, 4, 1, 1, 0, 0, 1, 11, 1, 0, 0),
(13, 71, 4, 8, 5.0, 9, 5, 4, 0, 0, 3, 3, 0, 1, 0),
(14, 80, 4, 8, 4.0, 3, 2, 2, 0, 0, 1, 2, 0, 0, 0),
(15, 11, 5, 2, 4.0, 9, 6, 5, 0, 0, 3, 2, 0, 0, 0),
(16, 20, 5, 2, 5.0, 4, 2, 2, 0, 0, 1, 4, 0, 1, 0),
(17, 21, 5, 3, 9.0, 6, 3, 3, 0, 0, 2, 7, 1, 0, 0),
(18, 31, 6, 4, 9.0, 5, 2, 2, 0, 0, 2, 8, 1, 0, 0),
(19, 41, 6, 5, 6.0, 6, 4, 3, 0, 0, 3, 5, 0, 1, 0),
(20, 50, 6, 5, 3.0, 2, 1, 1, 0, 0, 0, 2, 0, 0, 0),
(21, 51, 7, 6, 9.0, 6, 3, 3, 0, 0, 2, 8, 1, 0, 0),
(22, 61, 7, 7, 6.0, 8, 5, 4, 0, 0, 3, 5, 0, 1, 0),
(23, 70, 7, 7, 3.0, 2, 1, 1, 0, 0, 1, 3, 0, 0, 0),
(24, 71, 8, 8, 5.0, 7, 3, 2, 0, 0, 3, 3, 0, 0, 0),
(25, 80, 8, 8, 4.0, 2, 1, 1, 0, 0, 0, 2, 0, 1, 0),
(26, 1, 8, 1, 9.0, 3, 1, 1, 0, 0, 1, 9, 1, 0, 0),
(27, 1, 9, 1, 8.0, 4, 1, 1, 0, 0, 1, 9, 1, 0, 0),
(28, 10, 9, 1, 1.0, 1, 1, 1, 0, 0, 0, 2, 0, 0, 0),
(29, 21, 9, 3, 5.0, 9, 5, 4, 0, 0, 3, 3, 0, 1, 0),
(30, 30, 9, 3, 4.0, 2, 1, 1, 0, 0, 1, 3, 0, 0, 0),
(31, 11, 10, 2, 7.0, 7, 4, 3, 0, 0, 2, 6, 0, 1, 0),
(32, 20, 10, 2, 3.0, 2, 1, 1, 0, 0, 1, 3, 0, 0, 0),
(33, 31, 10, 4, 10.0, 7, 4, 4, 0, 0, 1, 8, 1, 0, 0),
(34, 41, 11, 5, 9.0, 4, 1, 1, 0, 0, 2, 10, 1, 0, 0),
(35, 61, 11, 7, 6.0, 5, 2, 2, 0, 0, 2, 5, 0, 1, 0),
(36, 70, 11, 7, 3.0, 2, 1, 1, 0, 0, 1, 3, 0, 0, 0),
(37, 51, 12, 6, 9.0, 5, 2, 2, 0, 0, 1, 9, 1, 0, 0),
(38, 71, 12, 8, 4.0, 10, 6, 5, 0, 0, 3, 2, 0, 1, 0),
(39, 80, 12, 8, 5.0, 4, 2, 2, 0, 0, 1, 3, 0, 0, 0),
(40, 1, 16, 1, 9.0, 5, 2, 2, 0, 0, 1, 10, 1, 0, 0),
(41, 11, 16, 2, 5.0, 8, 5, 4, 0, 0, 3, 4, 0, 1, 0),
(42, 20, 16, 2, 4.0, 4, 2, 2, 0, 0, 1, 2, 0, 0, 0),
(43, 21, 17, 3, 8.0, 5, 2, 2, 0, 0, 2, 9, 1, 0, 0),
(44, 30, 17, 3, 1.0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0),
(45, 31, 17, 4, 6.0, 6, 3, 3, 0, 0, 2, 5, 0, 1, 0),
(46, 40, 17, 4, 3.0, 2, 1, 1, 0, 0, 1, 2, 0, 0, 0),
(47, 41, 18, 5, 5.0, 8, 5, 4, 0, 0, 3, 3, 0, 1, 0),
(48, 50, 18, 5, 4.0, 2, 1, 1, 0, 0, 1, 2, 0, 0, 0),
(49, 51, 18, 6, 9.0, 7, 3, 3, 0, 0, 2, 7, 1, 0, 0),
(50, 11, 19, 2, 4.0, 9, 6, 5, 0, 0, 3, 2, 0, 0, 0),
(51, 20, 19, 2, 5.0, 4, 2, 2, 0, 0, 1, 3, 0, 1, 0),
(52, 21, 19, 3, 9.0, 6, 3, 3, 0, 0, 2, 8, 1, 0, 0),
(53, 31, 20, 4, 9.0, 4, 2, 2, 0, 0, 1, 9, 1, 0, 0),
(54, 41, 20, 5, 6.0, 7, 5, 4, 0, 0, 3, 4, 0, 1, 0),
(55, 50, 20, 5, 3.0, 2, 1, 1, 0, 0, 0, 2, 0, 0, 0),
(56, 51, 21, 6, 6.0, 5, 4, 3, 0, 0, 2, 4, 0, 1, 0),
(57, 60, 21, 6, 3.0, 2, 1, 1, 0, 0, 1, 2, 0, 0, 0),
(58, 1, 21, 1, 9.0, 7, 4, 4, 0, 0, 2, 8, 1, 0, 0),
(59, 88, 24, 11, 0.5, 2, 1, 1, 1, 0, 2, 1, 1, 0, 1),
(60, 66, 22, 7, 2.0, 6, 0, 0, 0, 0, 0, 3, 0, 0, 0),
(62, 82, 22, 1, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `egreso`
--

CREATE TABLE `egreso` (
  `id_egreso` int(11) NOT NULL,
  `id_temporada` int(11) NOT NULL,
  `id_proveedor` int(11) DEFAULT NULL,
  `nota_gastos` varchar(300) NOT NULL,
  `gasto` decimal(10,2) NOT NULL,
  `fecha_egreso` date NOT NULL,
  `tipo_pago` enum('Efectivo','Transferencia','Divisas','Pago Movil','Cheque','Zelle') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `egreso`
--

INSERT INTO `egreso` (`id_egreso`, `id_temporada`, `id_proveedor`, `nota_gastos`, `gasto`, `fecha_egreso`, `tipo_pago`, `created_at`, `updated_at`) VALUES
(1, 2, 2, 'Arbitraje Jornada 1 (4 partidos)', 8000.00, '2026-03-07', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(2, 2, 2, 'Arbitraje Jornada 2 (4 partidos)', 8000.00, '2026-03-14', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(3, 2, 2, 'Arbitraje Jornada 3 (4 partidos)', 8000.00, '2026-03-21', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(4, 2, 1, 'Compra de pelotas oficiales (50 unidades)', 4500.00, '2026-02-25', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(5, 2, 3, 'Transporte Jornada 1', 3000.00, '2026-03-06', 'Pago Movil', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(6, 2, 3, 'Transporte Jornada 2', 3000.00, '2026-03-13', 'Pago Movil', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(7, 2, 4, 'Catering inauguración temporada', 5000.00, '2026-02-28', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(8, 2, 5, 'Impresión de programas — 500 unidades', 2000.00, '2026-02-26', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(9, 2, 6, 'Servicios médicos Jornada 1', 2500.00, '2026-03-07', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(10, 2, 6, 'Servicios médicos Jornada 2', 2500.00, '2026-03-14', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(11, 2, NULL, 'Mantenimiento terreno de juego', 3500.00, '2026-03-01', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(12, 1, 2, 'Arbitraje Jornada 1 (3 partidos)', 6000.00, '2025-02-08', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(13, 1, 2, 'Arbitraje Jornada 2 (3 partidos)', 6000.00, '2025-02-22', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(14, 1, 3, 'Transporte Jornada 1', 2500.00, '2025-02-07', 'Pago Movil', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(15, 1, 3, 'Transporte Jornada 2', 2500.00, '2025-02-21', 'Pago Movil', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(16, 1, 1, 'Compra de pelotas (30 unidades)', 2700.00, '2025-01-30', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(17, 1, 6, 'Servicios médicos Jornada 1', 2000.00, '2025-02-08', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(18, 1, 6, 'Servicios médicos Jornada 2', 2000.00, '2025-02-22', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(19, 2, 2, 'Pago de arbitros juegos de la semana', 10215.75, '2026-05-22', 'Divisas', '2026-05-14 13:44:11', '2026-05-14 13:44:11'),
(20, 2, 2, 'Arbitraje', 5107.87, '2026-05-22', 'Efectivo', '2026-05-14 13:44:39', '2026-05-14 13:44:39');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipo`
--

CREATE TABLE `equipo` (
  `id_equipo` int(11) NOT NULL,
  `nombre_equipo` varchar(150) NOT NULL,
  `entrenador` varchar(150) NOT NULL,
  `responsable` varchar(150) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `logo_url` varchar(255) DEFAULT NULL COMMENT 'URL relativa del logo/escudo del equipo',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `equipo`
--

INSERT INTO `equipo` (`id_equipo`, `nombre_equipo`, `entrenador`, `responsable`, `email`, `telefono`, `logo_url`, `created_at`, `updated_at`) VALUES
(1, 'Leones de Caracas', 'Humberto Casique', 'Luis Martínez', 'leones@ligadiamante.com', '0412-123-4567', NULL, '2026-05-09 16:33:33', '2026-05-09 18:39:07'),
(2, 'Tigres de Aragua', 'José Rodríguez', 'Pedro Gómez', 'tigres@ligadiamante.com', '0414-2345678', NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(3, 'Águilas del Zulia', 'Miguel Hernández', 'Ana López', 'aguilas@ligadiamante.com', '0416-3456789', NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(4, 'Navegantes del Magallanes', 'Roberto Silva', 'María González', 'navegantes@ligadiamante.com', '0424-4567890', NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(5, 'Caribes de Anzoátegui', 'Fernando Torres', 'Jorge Pérez', 'caribes@ligadiamante.com', '0412-5678901', NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(6, 'Bravos de Margarita', 'Andrés Morales', 'Carmen Díaz', 'bravos@ligadiamante.com', '0414-6789012', NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(7, 'Cardenales de Lara', 'Ricardo Vargas', 'Elena Ramírez', 'cardenales@ligadiamante.com', '0416-7890123', NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(8, 'Tiburones de La Guaira', 'Daniel Castillo', 'Patricia Rojas', 'tiburones@ligadiamante.com', '0424-8901234', NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(10, 'Las pumas', 'legoshi', 'elkalo', 'milo12@gmail.com', '0412-900-1234', NULL, '2026-05-14 12:00:52', '2026-05-14 12:00:52'),
(11, 'Los Chivos de Pavia', 'Magda Perozo', 'Pedro Pascal', 'loschivos@ligadiamante.com', '0414-722-3123', NULL, '2026-05-14 13:15:19', '2026-05-14 13:15:19');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estadio`
--

CREATE TABLE `estadio` (
  `id_estadio` int(11) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `ciudad` varchar(100) NOT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `capacidad` int(11) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `estadio`
--

INSERT INTO `estadio` (`id_estadio`, `nombre`, `ciudad`, `direccion`, `capacidad`, `activo`, `created_at`, `updated_at`) VALUES
(1, 'Estadio Antonio Herrera Gutiérrez', 'Barquisimeto', NULL, 9, 1, '2026-05-11 19:11:55', '2026-05-11 19:11:55'),
(2, 'Estadio Monumental', 'Caracas', 'Distrito Capital', 10000, 1, '2026-05-22 02:11:18', '2026-05-22 02:11:32');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ingreso`
--

CREATE TABLE `ingreso` (
  `id_ingreso` int(11) NOT NULL,
  `id_equipo` int(11) NOT NULL,
  `id_temporada` int(11) NOT NULL,
  `concepto` varchar(300) NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `fecha_ingreso` date NOT NULL,
  `tipo_pago` enum('Efectivo','Transferencia','Divisas','Pago Movil','Cheque','Zelle') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `categoria` enum('inscripcion','patrocinio','taquilleria','concesion','multa','otro') DEFAULT 'otro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `ingreso`
--

INSERT INTO `ingreso` (`id_ingreso`, `id_equipo`, `id_temporada`, `concepto`, `valor`, `fecha_ingreso`, `tipo_pago`, `created_at`, `updated_at`, `categoria`) VALUES
(1, 1, 1, 'Inscripción Leones - Apertura 2025', 5000.00, '2025-01-10', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'inscripcion'),
(2, 2, 1, 'Inscripción Tigres - Apertura 2025', 5000.00, '2025-01-12', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'inscripcion'),
(3, 3, 1, 'Inscripción Águilas - Apertura 2025', 5000.00, '2025-01-14', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'inscripcion'),
(4, 4, 1, 'Inscripción Navegantes - Apertura 2025', 5000.00, '2025-01-15', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'inscripcion'),
(5, 5, 1, 'Inscripción Caribes - Apertura 2025', 5000.00, '2025-01-16', 'Pago Movil', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'inscripcion'),
(6, 6, 1, 'Inscripción Bravos - Apertura 2025', 5000.00, '2025-01-18', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'inscripcion'),
(7, 1, 1, 'Patrocinio Leones — Empresa Polar', 7500.00, '2025-01-25', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'patrocinio'),
(8, 3, 1, 'Patrocinio Águilas — Grupo Digitel', 6000.00, '2025-01-28', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'patrocinio'),
(9, 1, 1, 'Venta de boletos Jornada 1', 4800.00, '2025-02-08', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'taquilleria'),
(10, 2, 1, 'Venta de boletos Jornada 2', 5200.00, '2025-02-22', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'taquilleria'),
(11, 1, 1, 'Venta de programas y merchandising', 950.00, '2025-02-09', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'concesion'),
(12, 3, 1, 'Alquiler de palcos Jornada 1', 1800.00, '2025-02-08', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:33:34', 'otro'),
(13, 5, 1, 'Donación Gobernación del Estado', 8000.00, '2025-03-05', 'Cheque', '2026-05-09 16:33:34', '2026-05-09 16:33:34', 'otro'),
(14, 6, 1, 'Patrocinio adicional — Cervecería Regional', 4500.00, '2025-03-10', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'patrocinio'),
(15, 1, 2, 'Inscripción Leones - Clausura 2026', 5500.00, '2026-02-01', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'inscripcion'),
(16, 2, 2, 'Inscripción Tigres - Clausura 2026', 5500.00, '2026-02-02', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'inscripcion'),
(17, 3, 2, 'Inscripción Águilas - Clausura 2026', 5500.00, '2026-02-03', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'inscripcion'),
(18, 4, 2, 'Inscripción Navegantes - Clausura 2026', 5500.00, '2026-02-04', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'inscripcion'),
(19, 5, 2, 'Inscripción Caribes - Clausura 2026', 5500.00, '2026-02-05', 'Pago Movil', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'inscripcion'),
(20, 6, 2, 'Inscripción Bravos - Clausura 2026', 5500.00, '2026-02-06', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'inscripcion'),
(21, 1, 2, 'Patrocinio Leones — Empresa ABC', 8000.00, '2026-02-15', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'patrocinio'),
(22, 3, 2, 'Patrocinio Águilas — Comercial XYZ', 6000.00, '2026-02-18', 'Transferencia', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'patrocinio'),
(23, 2, 2, 'Venta de boletos Jornada 1', 3500.00, '2026-03-07', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'taquilleria'),
(24, 1, 2, 'Venta de boletos Jornada 2', 4200.00, '2026-03-14', 'Efectivo', '2026-05-09 16:33:34', '2026-05-09 16:44:06', 'taquilleria'),
(25, 5, 2, 'Donación Alcaldía Municipal', 10000.00, '2026-02-20', 'Cheque', '2026-05-09 16:33:34', '2026-05-09 16:33:34', 'otro'),
(28, 8, 2, 'Inscripción equipo #26', 8888.00, '2026-05-14', NULL, '2026-05-14 11:26:22', '2026-05-14 11:26:22', 'inscripcion'),
(29, 10, 2, 'Inscripción equipo #27', 11111.00, '2026-05-14', NULL, '2026-05-14 12:38:01', '2026-05-14 12:38:01', 'inscripcion'),
(30, 11, 2, 'Inscripción equipo #28', 5500.00, '2026-05-14', NULL, '2026-05-14 13:22:33', '2026-05-14 13:22:33', 'inscripcion'),
(31, 10, 3, 'Inscripción equipo #29', 700.00, '2026-05-22', 'Pago Movil', '2026-05-22 02:18:23', '2026-05-22 02:19:19', 'inscripcion');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inscripcion`
--

CREATE TABLE `inscripcion` (
  `id_inscripcion` int(11) NOT NULL,
  `id_equipo` int(11) NOT NULL,
  `id_temporada` int(11) NOT NULL,
  `fecha_inscripcion` date NOT NULL,
  `estado_pago` enum('pendiente','pagado','rechazado') NOT NULL DEFAULT 'pendiente',
  `tipo_pago` varchar(50) DEFAULT NULL,
  `monto_pagado` decimal(10,2) NOT NULL DEFAULT 0.00,
  `observaciones` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `inscripcion`
--

INSERT INTO `inscripcion` (`id_inscripcion`, `id_equipo`, `id_temporada`, `fecha_inscripcion`, `estado_pago`, `tipo_pago`, `monto_pagado`, `observaciones`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2025-01-10', 'pagado', NULL, 5000.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(2, 2, 1, '2025-01-12', 'pagado', NULL, 5000.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(3, 3, 1, '2025-01-14', 'pagado', NULL, 5000.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(4, 4, 1, '2025-01-15', 'pagado', NULL, 5000.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(5, 5, 1, '2025-01-16', 'pagado', NULL, 5000.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(6, 6, 1, '2025-01-18', 'pagado', NULL, 5000.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(7, 1, 2, '2026-02-01', 'pagado', NULL, 5500.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(8, 2, 2, '2026-02-02', 'pagado', NULL, 5500.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(9, 3, 2, '2026-02-03', 'pagado', NULL, 5500.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(10, 4, 2, '2026-02-04', 'pagado', NULL, 5500.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(11, 5, 2, '2026-02-05', 'pagado', NULL, 5500.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(12, 6, 2, '2026-02-06', 'pagado', NULL, 5500.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(13, 7, 2, '2026-02-07', 'pendiente', NULL, 0.00, NULL, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(26, 8, 2, '2026-05-14', 'pagado', 'Pago Móvil', 8888.00, 'pague', '2026-05-14 11:26:22', '2026-05-14 11:26:22'),
(27, 10, 2, '2026-05-14', 'pagado', 'Divisas', 11111.00, 'pooo', '2026-05-14 12:38:01', '2026-05-14 12:38:01'),
(28, 11, 2, '2026-05-14', 'pagado', 'Pago Móvil', 5500.00, 'Inscripcion', '2026-05-14 13:22:33', '2026-05-14 13:22:33'),
(29, 10, 3, '2026-05-22', 'pagado', 'Efectivo', 700.00, 'pago las pumas\n', '2026-05-22 02:18:23', '2026-05-22 02:18:23');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `jugador`
--

CREATE TABLE `jugador` (
  `id_jugador` int(11) NOT NULL,
  `id_equipo` int(11) NOT NULL,
  `cedula` varchar(20) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `rol` enum('bateador','pitcher','utilidad') NOT NULL DEFAULT 'bateador',
  `posicion` enum('P','C','1B','2B','3B','SS','LF','CF','RF','DH','UT') NOT NULL DEFAULT 'UT',
  `brazo_dominante` enum('derecho','izquierdo','ambidiestro') DEFAULT NULL,
  `foto_url` varchar(255) DEFAULT NULL COMMENT 'URL relativa de la foto del jugador',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `jugador`
--

INSERT INTO `jugador` (`id_jugador`, `id_equipo`, `cedula`, `nombre`, `apellido`, `fecha_nacimiento`, `rol`, `posicion`, `brazo_dominante`, `foto_url`, `activo`, `created_at`, `updated_at`) VALUES
(1, 1, 'V-20123456', 'Andrés', 'García', '1995-03-15', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(2, 1, 'V-21234567', 'Carlos', 'Ramírez', '1998-07-22', 'bateador', 'C', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(3, 1, 'V-22345678', 'Daniel', 'Moreno', '1996-11-08', 'bateador', '1B', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(4, 1, 'V-23456789', 'Eduardo', 'Pérez', '1999-01-30', 'bateador', '2B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(5, 1, 'V-24567890', 'Fernando', 'López', '1997-05-12', 'bateador', '3B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(6, 1, 'V-25678901', 'Gabriel', 'Hernández', '2000-09-18', 'bateador', 'SS', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(7, 1, 'V-26789012', 'Héctor', 'Martínez', '1994-12-05', 'bateador', 'LF', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(8, 1, 'V-27890123', 'Ignacio', 'Torres', '1998-04-20', 'bateador', 'CF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(9, 1, 'V-28901234', 'Julián', 'Castro', '1997-08-14', 'bateador', 'RF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(10, 1, 'V-29012345', 'Kevin', 'Díaz', '2001-02-28', 'pitcher', 'P', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(11, 2, 'V-30123456', 'Luis', 'Navarro', '1996-06-10', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(12, 2, 'V-31234567', 'Marcos', 'Vargas', '1999-10-25', 'bateador', 'C', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(13, 2, 'V-32345678', 'Nelson', 'Jiménez', '1997-03-07', 'bateador', '1B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(14, 2, 'V-33456789', 'Oscar', 'Medina', '1998-08-19', 'bateador', '2B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(15, 2, 'V-34567890', 'Pablo', 'Rojas', '2000-01-14', 'bateador', '3B', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(16, 2, 'V-35678901', 'Rafael', 'Sánchez', '1995-11-22', 'bateador', 'SS', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(17, 2, 'V-36789012', 'Samuel', 'Rivas', '1999-04-30', 'bateador', 'LF', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(18, 2, 'V-37890123', 'Tomás', 'Acosta', '1996-09-08', 'bateador', 'CF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(19, 2, 'V-38901234', 'Uriel', 'Blanco', '1998-12-16', 'bateador', 'RF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(20, 2, 'V-39012345', 'Víctor', 'Flores', '2001-06-03', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(21, 3, 'V-40123456', 'William', 'Delgado', '1997-02-14', 'pitcher', 'P', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(22, 3, 'V-41234567', 'Xavier', 'Gutiérrez', '1998-05-20', 'bateador', 'C', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(23, 3, 'V-42345678', 'Yohan', 'Paredes', '1996-10-11', 'bateador', '1B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(24, 3, 'V-43456789', 'Adrián', 'Quintero', '1999-03-28', 'bateador', '2B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(25, 3, 'V-44567890', 'Brandon', 'Urdaneta', '2000-07-15', 'bateador', '3B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(26, 3, 'V-45678901', 'Cristian', 'Zambrano', '1995-12-01', 'bateador', 'SS', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(27, 3, 'V-46789012', 'Diego', 'Andrade', '1998-06-18', 'bateador', 'LF', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(28, 3, 'V-47890123', 'Emilio', 'Briceño', '1997-01-25', 'bateador', 'CF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(29, 3, 'V-48901234', 'Franco', 'Colmenares', '1999-09-09', 'bateador', 'RF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(30, 3, 'V-49012345', 'Gerardo', 'Dávila', '2001-04-17', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(31, 4, 'V-50123456', 'Hugo', 'Espinoza', '1996-08-22', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(32, 4, 'V-51234567', 'Iván', 'Figueroa', '1999-11-30', 'bateador', 'C', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(33, 4, 'V-52345678', 'Jorge', 'Galindo', '1997-04-05', 'bateador', '1B', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(34, 4, 'V-53456789', 'Kelvin', 'Herrera', '1998-07-13', 'bateador', '2B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(35, 4, 'V-54567890', 'Leonardo', 'Ibarra', '2000-02-20', 'bateador', '3B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(36, 4, 'V-55678901', 'Manuel', 'Jaimes', '1995-10-08', 'bateador', 'SS', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(37, 4, 'V-56789012', 'Néstor', 'Leal', '1999-01-16', 'bateador', 'LF', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(38, 4, 'V-57890123', 'Orlando', 'Manzano', '1996-05-24', 'bateador', 'CF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(39, 4, 'V-58901234', 'Pedro', 'Noguera', '1998-10-02', 'bateador', 'RF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(40, 4, 'V-59012345', 'Quintín', 'Olivares', '2001-03-11', 'pitcher', 'P', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(41, 5, 'V-60123456', 'Ramón', 'Palacios', '1997-06-28', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(42, 5, 'V-61234567', 'Simón', 'Quijada', '1998-09-15', 'bateador', 'C', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(43, 5, 'V-62345678', 'Tulio', 'Requena', '1996-12-22', 'bateador', '1B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(44, 5, 'V-63456789', 'Ulises', 'Salazar', '1999-05-08', 'bateador', '2B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(45, 5, 'V-64567890', 'Valentín', 'Trujillo', '2000-08-30', 'bateador', '3B', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(46, 5, 'V-65678901', 'Wilson', 'Ugueto', '1995-03-18', 'bateador', 'SS', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(47, 5, 'V-66789012', 'Ximén', 'Villegas', '1998-07-06', 'bateador', 'LF', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(48, 5, 'V-67890123', 'Yovany', 'Zerpa', '1997-11-14', 'bateador', 'CF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(49, 5, 'V-68901234', 'Zósimo', 'Araujo', '1999-02-21', 'bateador', 'RF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(50, 5, 'V-69012345', 'Abelardo', 'Bermúdez', '2001-08-05', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(51, 6, 'V-70123456', 'Benito', 'Contreras', '1996-04-12', 'pitcher', 'P', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(52, 6, 'V-71234567', 'Camilo', 'Domínguez', '1999-08-28', 'bateador', 'C', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(53, 6, 'V-72345678', 'Darío', 'Escalona', '1997-01-05', 'bateador', '1B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(54, 6, 'V-73456789', 'Esteban', 'Fuentes', '1998-06-17', 'bateador', '2B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(55, 6, 'V-74567890', 'Fabián', 'Guerra', '2000-10-24', 'bateador', '3B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(56, 6, 'V-75678901', 'Gonzalo', 'Hidalgo', '1995-05-09', 'bateador', 'SS', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(57, 6, 'V-76789012', 'Horacio', 'Infante', '1998-09-26', 'bateador', 'LF', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(58, 6, 'V-77890123', 'Israel', 'Juárez', '1997-02-13', 'bateador', 'CF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(59, 6, 'V-78901234', 'Josué', 'Kindelán', '1999-07-01', 'bateador', 'RF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(60, 6, 'V-79012345', 'Kendry', 'Ladera', '2001-01-19', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(61, 7, 'V-80123456', 'Leonel', 'Matos', '1996-10-06', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(62, 7, 'V-81234567', 'Mauricio', 'Navas', '1999-03-23', 'bateador', 'C', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(63, 7, 'V-82345678', 'Nicolás', 'Obregón', '1997-08-10', 'bateador', '1B', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(64, 7, 'V-83456789', 'Octavio', 'Piñero', '1998-01-27', 'bateador', '2B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(65, 7, 'V-84567890', 'Pascual', 'Quevedo', '2000-05-14', 'bateador', '3B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(66, 7, 'V-85678901', 'Quirino', 'Rondón', '1995-09-30', 'bateador', 'SS', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(67, 7, 'V-86789012', 'Rodolfo', 'Suárez', '1998-02-08', 'bateador', 'LF', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(68, 7, 'V-87890123', 'Sergio', 'Tovar', '1997-06-25', 'bateador', 'CF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(69, 7, 'V-88901234', 'Tadeo', 'Ureña', '1999-11-12', 'bateador', 'RF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(70, 7, 'V-89012345', 'Ubaldo', 'Valero', '2001-05-29', 'pitcher', 'P', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(71, 8, 'V-90123456', 'Valentino', 'Wolff', '1996-12-16', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(72, 8, 'V-91234567', 'Wálter', 'Yépez', '1999-05-03', 'bateador', 'C', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(73, 8, 'V-92345678', 'Xerxes', 'Zuloaga', '1997-10-20', 'bateador', '1B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(74, 11, 'V-93456789', 'Yamil', 'Abreu', '1998-03-08', 'bateador', '2B', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-21 11:14:02'),
(75, 8, 'V-94567890', 'Zacarías', 'Bolívar', '2000-07-25', 'bateador', '3B', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(76, 8, 'V-95678901', 'Alfredo', 'Cabrera', '1995-11-11', 'bateador', 'SS', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(77, 8, 'V-96789012', 'Bernardo', 'Dugarte', '1998-04-28', 'bateador', 'LF', 'izquierdo', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(78, 8, 'V-97890123', 'Claudio', 'Escalante', '1997-09-15', 'bateador', 'CF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(79, 8, 'V-98901234', 'Damián', 'Ferrer', '1999-02-02', 'bateador', 'RF', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(80, 8, 'V-99012345', 'Ernesto', 'Graterol', '2001-06-18', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(81, 1, 'V-31772123', 'Keyler', 'Carrillo', '2026-04-30', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-09 17:15:40', '2026-05-09 17:15:40'),
(82, 1, 'V-31661271', 'Goku', 'Perez', '2014-03-19', 'utilidad', 'CF', '', NULL, 1, '2026-05-13 12:02:43', '2026-05-13 12:02:43'),
(83, 4, 'V-32192342', 'Sarai', 'Leon', '2005-12-02', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-14 11:28:20', '2026-05-14 11:28:20'),
(84, 10, 'V-12345789', 'karala', 'tula', '2007-06-05', 'pitcher', 'C', 'derecho', NULL, 1, '2026-05-14 12:09:21', '2026-05-14 12:09:21'),
(85, 11, 'V-31663615', 'Keyler', 'Castillo', '2006-06-14', 'utilidad', 'SS', 'derecho', NULL, 1, '2026-05-14 13:18:53', '2026-05-14 13:19:16'),
(86, 11, 'V-19283123', 'KArla', 'Talavera', '2021-02-10', 'bateador', '1B', 'derecho', NULL, 1, '2026-05-14 13:20:08', '2026-05-14 13:20:08'),
(87, 11, 'V-32663615', 'Santiago', 'Rodriguez', '2010-02-03', 'pitcher', 'P', 'derecho', NULL, 1, '2026-05-14 13:20:46', '2026-05-14 13:20:46'),
(88, 11, 'V-6123123', 'Sarai', 'Melano', '2006-03-15', 'utilidad', 'LF', 'ambidiestro', NULL, 1, '2026-05-14 13:21:18', '2026-05-14 13:21:18'),
(89, 11, 'V-32192312', 'Humberto', 'Cacique', '1994-02-24', 'utilidad', '3B', 'ambidiestro', NULL, 1, '2026-05-14 13:21:55', '2026-05-14 13:21:55');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lineup`
--

CREATE TABLE `lineup` (
  `id_lineup` int(11) NOT NULL,
  `id_partido` int(11) NOT NULL,
  `id_jugador` int(11) NOT NULL,
  `id_equipo` int(11) NOT NULL,
  `orden_bateo` int(11) DEFAULT NULL COMMENT 'Posicion en el orden al bate (1-9)',
  `posicion_juego` varchar(50) DEFAULT NULL COMMENT 'Posicion defensiva en este juego',
  `es_titular` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `lineup`
--

INSERT INTO `lineup` (`id_lineup`, `id_partido`, `id_jugador`, `id_equipo`, `orden_bateo`, `posicion_juego`, `es_titular`) VALUES
(2, 24, 89, 11, 1, '1B', 1),
(3, 24, 85, 11, 2, 'C', 1),
(4, 24, 88, 11, 3, 'SS', 1),
(5, 24, 86, 11, 4, 'P', 1),
(6, 24, 87, 11, 5, 'CF', 1),
(7, 24, 61, 7, 1, 'P', 1),
(8, 24, 62, 7, 2, 'C', 1),
(9, 24, 63, 7, 3, '1B', 1),
(10, 24, 64, 7, 4, '2B', 1),
(11, 22, 61, 7, NULL, 'BN', 0),
(12, 22, 62, 7, NULL, '2B', 1),
(13, 22, 63, 7, NULL, '3B', 1),
(14, 22, 64, 7, NULL, '1B', 1),
(15, 22, 65, 7, NULL, 'C', 1),
(16, 22, 66, 7, 5, 'P', 1),
(17, 22, 67, 7, NULL, 'LF', 1),
(18, 22, 68, 7, NULL, 'CF', 1),
(19, 22, 69, 7, NULL, 'RF', 1),
(20, 22, 70, 7, NULL, 'DH', 1),
(21, 22, 2, 1, 10, '1B', 1),
(22, 22, 3, 1, 9, '2B', 1),
(23, 22, 4, 1, 8, '3B', 1),
(24, 22, 5, 1, 7, 'SS', 1),
(25, 22, 6, 1, 6, 'LF', 1),
(26, 22, 7, 1, 5, 'CF', 1),
(27, 22, 8, 1, 4, 'RF', 1),
(28, 22, 9, 1, 3, 'DH', 1),
(29, 22, 10, 1, 2, 'C', 1),
(30, 22, 82, 1, 1, 'P', 1),
(101, 22, 1, 1, NULL, 'RP', 1),
(102, 22, 81, 1, NULL, 'BN', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `noticia`
--

CREATE TABLE `noticia` (
  `id_noticia` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `contenido` text DEFAULT NULL,
  `foto_url` varchar(500) DEFAULT NULL,
  `fecha_publicacion` date DEFAULT NULL,
  `activa` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `noticia`
--

INSERT INTO `noticia` (`id_noticia`, `titulo`, `contenido`, `foto_url`, `fecha_publicacion`, `activa`, `created_at`) VALUES
(1, 'El culion culiao', 'Dicen que fue un 3 de mayo, como a las 6 de la tarde, cogieron a mamagallo y el decir ay eso arde. Cogieron a mamagallo y el decía eso arde, no vayas para esa fiesta, te dijeron mamagallo, porque hay un maldito negro caroteando a los borrachos, que a mas de 1 en este pueblo lo ha dejado viendo rayos.', '/uploads/noticia-1778758978126.png', '2026-05-03', 1, '2026-05-14 11:42:58'),
(2, 'Jesus Hernandez ficha con Los pumas', 'Jesus hernandez, joven promesa ficha con el equipo de los pumas, esperandole una temporada llena de exitos', '/uploads/noticia-1779416119378.jpg', '2026-05-21', 1, '2026-05-22 02:15:19');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificacion`
--

CREATE TABLE `notificacion` (
  `id` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `tipo` enum('admin','caja') NOT NULL,
  `titulo` varchar(200) NOT NULL,
  `mensaje` text NOT NULL,
  `leida` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `notificacion`
--

INSERT INTO `notificacion` (`id`, `id_usuario`, `tipo`, `titulo`, `mensaje`, `leida`, `created_at`) VALUES
(1, 1, 'admin', 'Nueva sanción registrada', 'Se registró una sanción de tipo \"suspension\": El Negro no ha pagao el refresco', 1, '2026-05-14 11:19:41'),
(2, 1, 'admin', 'Nueva sanción registrada', 'Se registró una sanción de tipo \"suspension\": Negro paga tu vaina', 1, '2026-05-14 11:20:37');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partido`
--

CREATE TABLE `partido` (
  `id_partido` int(11) NOT NULL,
  `id_temporada` int(11) NOT NULL,
  `id_equipo_casa` int(11) NOT NULL,
  `id_equipo_visitante` int(11) NOT NULL,
  `fecha_juego` date NOT NULL,
  `hora_juego` time NOT NULL,
  `id_estadio` int(11) DEFAULT NULL,
  `lugar` varchar(200) DEFAULT NULL,
  `innings_programados` int(11) NOT NULL DEFAULT 9,
  `estado` enum('programado','en_curso','finalizado','suspendido') NOT NULL DEFAULT 'programado',
  `boletos_general` int(11) NOT NULL DEFAULT 0,
  `precio_general` decimal(10,2) NOT NULL DEFAULT 0.00,
  `boletos_vip` int(11) NOT NULL DEFAULT 0,
  `precio_vip` decimal(10,2) NOT NULL DEFAULT 0.00,
  `capacidad_estadio` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Volcado de datos para la tabla `partido`
--

INSERT INTO `partido` (`id_partido`, `id_temporada`, `id_equipo_casa`, `id_equipo_visitante`, `fecha_juego`, `hora_juego`, `id_estadio`, `lugar`, `innings_programados`, `estado`, `boletos_general`, `precio_general`, `boletos_vip`, `precio_vip`, `capacidad_estadio`, `created_at`, `updated_at`) VALUES
(1, 2, 1, 2, '2026-03-07', '14:00:00', NULL, 'Estadio Universitario', 9, 'finalizado', 7200, 20.00, 480, 65.00, 12000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(2, 2, 3, 4, '2026-03-07', '16:00:00', NULL, 'Estadio La Ceiba', 9, 'finalizado', 4400, 18.00, 310, 55.00, 8000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(3, 2, 5, 6, '2026-03-07', '18:00:00', NULL, 'Estadio Alfonso López', 9, 'finalizado', 5100, 18.00, 350, 55.00, 9000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(4, 2, 7, 8, '2026-03-08', '14:00:00', NULL, 'Estadio Antonio Herrera', 9, 'finalizado', 3800, 15.00, 260, 50.00, 7000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(5, 2, 2, 3, '2026-03-14', '14:00:00', NULL, 'Estadio José Pérez Colmenares', 9, 'finalizado', 5800, 18.00, 420, 60.00, 10000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(6, 2, 4, 5, '2026-03-14', '16:00:00', NULL, 'Estadio Universitario', 9, 'finalizado', 7600, 20.00, 510, 65.00, 12000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(7, 2, 6, 7, '2026-03-14', '18:00:00', NULL, 'Estadio Luis Aparicio', 9, 'finalizado', 9200, 22.00, 680, 70.00, 15000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(8, 2, 8, 1, '2026-03-15', '14:00:00', NULL, 'Estadio Litoral', 9, 'finalizado', 3100, 15.00, 200, 48.00, 6000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(9, 2, 1, 3, '2026-03-21', '14:00:00', NULL, 'Estadio Universitario', 9, 'finalizado', 8400, 20.00, 590, 65.00, 12000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(10, 2, 2, 4, '2026-03-21', '16:00:00', NULL, 'Estadio José Pérez Colmenares', 9, 'finalizado', 6200, 18.00, 450, 60.00, 10000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(11, 2, 5, 7, '2026-03-21', '18:00:00', NULL, 'Estadio Alfonso López', 9, 'finalizado', 5500, 18.00, 380, 55.00, 9000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(12, 2, 6, 8, '2026-03-22', '14:00:00', NULL, 'Estadio Luis Aparicio', 9, 'finalizado', 10500, 22.00, 820, 70.00, 15000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(13, 2, 3, 1, '2026-03-28', '14:00:00', NULL, 'Estadio La Ceiba', 9, 'finalizado', 0, 0.00, 0, 0.00, 0, '2026-05-09 16:33:34', '2026-05-09 16:33:39'),
(14, 2, 4, 2, '2026-03-28', '16:00:00', NULL, 'Estadio Universitario', 9, 'finalizado', 0, 0.00, 0, 0.00, 0, '2026-05-09 16:33:34', '2026-05-09 16:33:39'),
(15, 2, 7, 5, '2026-03-29', '18:00:00', NULL, 'Estadio Antonio Herrera', 9, 'finalizado', 0, 0.00, 0, 0.00, 0, '2026-05-09 16:33:34', '2026-05-09 16:33:39'),
(16, 1, 1, 2, '2025-02-08', '14:00:00', NULL, 'Estadio Universitario', 9, 'finalizado', 8200, 18.00, 520, 55.00, 12000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(17, 1, 3, 4, '2025-02-08', '16:00:00', NULL, 'Estadio La Ceiba', 9, 'finalizado', 4600, 15.00, 300, 48.00, 8000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(18, 1, 5, 6, '2025-02-09', '14:00:00', NULL, 'Estadio Alfonso López', 9, 'finalizado', 5000, 15.00, 320, 48.00, 9000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(19, 1, 2, 3, '2025-02-22', '14:00:00', NULL, 'Estadio José Pérez Colmenares', 9, 'finalizado', 5500, 18.00, 380, 55.00, 10000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(20, 1, 4, 5, '2025-02-22', '16:00:00', NULL, 'Estadio Universitario', 9, 'finalizado', 7000, 18.00, 460, 55.00, 12000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(21, 1, 6, 1, '2025-02-23', '14:00:00', NULL, 'Estadio Luis Aparicio', 9, 'finalizado', 8800, 20.00, 600, 60.00, 15000, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(22, 2, 7, 1, '2026-05-20', '14:00:00', 1, 'Estadio Antonio Herrera Gutiérrez', 9, 'finalizado', 0, 0.00, 0, 0.00, 0, '2026-05-11 19:12:14', '2026-05-20 19:36:38'),
(24, 2, 7, 11, '2026-05-21', '19:00:00', 1, 'Estadio Antonio Herrera Gutiérrez', 9, 'finalizado', 0, 0.00, 0, 0.00, 0, '2026-05-14 13:24:17', '2026-05-14 13:28:59'),
(25, 2, 11, 5, '2026-05-22', '19:00:00', 1, 'Estadio Antonio Herrera Gutiérrez', 9, 'finalizado', 0, 0.00, 0, 0.00, 0, '2026-05-14 13:25:24', '2026-05-20 17:55:56'),
(26, 2, 11, 7, '2026-05-31', '20:00:00', 1, 'Estadio Antonio Herrera Gutiérrez', 9, 'programado', 0, 0.00, 0, 0.00, 0, '2026-05-14 13:25:49', '2026-05-14 13:25:49');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `id_proveedor` int(11) NOT NULL,
  `rif` varchar(75) NOT NULL,
  `nombre_proveedor` varchar(125) NOT NULL,
  `servicio` varchar(300) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`id_proveedor`, `rif`, `nombre_proveedor`, `servicio`, `telefono`, `email`, `activo`, `created_at`, `updated_at`) VALUES
(1, 'J-12345678-9', 'Deportes Venezuela C.A.', 'Suministro de pelotas y bates', '0212-1234567', 'ventas@deportesve.com', 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(2, 'J-23456789-0', 'Árbitros Asociados', 'Servicios de arbitraje profesional', '0412-9876543', 'arbitros@asociados.com', 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(3, 'J-34567890-1', 'Transporte Express C.A.', 'Transporte de equipos a estadios', '0414-5551234', 'info@transporteexpress.com', 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(4, 'J-45678901-2', 'Catering El Diamante', 'Servicio de alimentación para eventos', '0416-4443322', 'pedidos@cateringdiamante.com', 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(5, 'J-56789012-3', 'Imprenta Digital Plus', 'Impresión de programas y boletos', '0424-3332211', 'ventas@imprentadigital.com', 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(6, 'V-15678901', 'Dr. Roberto Méndez', 'Servicios médicos y paramédicos', '0412-7778899', 'dr.mendez@gmail.com', 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(7, 'j-2474783', 'keyler', 'publicidad', '0422-456-6783', 'publicidad@ligadiamante.com', 1, '2026-05-21 12:26:07', '2026-05-21 12:26:07');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `resultado`
--

CREATE TABLE `resultado` (
  `id_resultado` int(11) NOT NULL,
  `id_partido` int(11) NOT NULL,
  `carreras_home` int(11) NOT NULL DEFAULT 0,
  `carreras_visitantes` int(11) NOT NULL DEFAULT 0,
  `hits_home` int(11) NOT NULL DEFAULT 0,
  `hits_visitantes` int(11) NOT NULL DEFAULT 0,
  `errores_home` int(11) NOT NULL DEFAULT 0,
  `errores_visitantes` int(11) NOT NULL DEFAULT 0,
  `innings_totales` int(11) NOT NULL DEFAULT 9,
  `id_pitcher_ganador` int(11) DEFAULT NULL,
  `id_pitcher_perdedor` int(11) DEFAULT NULL,
  `id_pitcher_salvador` int(11) DEFAULT NULL,
  `observaciones` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `resultado`
--

INSERT INTO `resultado` (`id_resultado`, `id_partido`, `carreras_home`, `carreras_visitantes`, `hits_home`, `hits_visitantes`, `errores_home`, `errores_visitantes`, `innings_totales`, `id_pitcher_ganador`, `id_pitcher_perdedor`, `id_pitcher_salvador`, `observaciones`) VALUES
(1, 1, 5, 3, 9, 7, 1, 2, 9, 1, 11, NULL, NULL),
(2, 2, 2, 6, 5, 10, 3, 0, 9, 31, 21, NULL, NULL),
(3, 3, 5, 4, 8, 8, 1, 1, 11, 41, 51, NULL, NULL),
(4, 4, 7, 1, 12, 4, 0, 3, 9, 61, 71, NULL, NULL),
(5, 5, 3, 8, 6, 13, 2, 0, 9, 21, 20, NULL, NULL),
(6, 6, 5, 2, 8, 5, 1, 2, 9, 31, 41, NULL, NULL),
(7, 7, 6, 3, 10, 6, 0, 1, 9, 51, 61, NULL, NULL),
(8, 8, 1, 4, 3, 9, 3, 0, 9, 1, 71, NULL, NULL),
(9, 9, 6, 2, 11, 5, 0, 2, 9, 1, 21, NULL, NULL),
(10, 10, 4, 5, 7, 9, 1, 1, 10, 31, 11, NULL, NULL),
(11, 11, 3, 1, 7, 4, 0, 2, 9, 41, 61, NULL, NULL),
(12, 12, 8, 2, 14, 5, 0, 3, 9, 51, 71, NULL, NULL),
(13, 16, 7, 2, 12, 5, 0, 2, 9, 1, 11, NULL, NULL),
(14, 17, 4, 3, 8, 6, 1, 1, 9, 21, 31, NULL, NULL),
(15, 18, 3, 6, 7, 10, 2, 0, 9, 51, 41, NULL, NULL),
(16, 19, 3, 8, 6, 13, 2, 0, 9, 21, 11, NULL, NULL),
(17, 20, 6, 2, 9, 4, 0, 1, 9, 31, 41, NULL, NULL),
(18, 21, 4, 5, 10, 7, 1, 0, 9, 1, 51, NULL, NULL),
(19, 24, 5, 9, 4, 7, 8, 3, 9, NULL, NULL, NULL, 'asi'),
(24, 22, 5, 3, 12, 4, 0, 0, 9, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sancion`
--

CREATE TABLE `sancion` (
  `id_sancion` int(11) NOT NULL,
  `id_temporada` int(11) NOT NULL,
  `id_jugador` int(11) DEFAULT NULL,
  `id_equipo` int(11) DEFAULT NULL,
  `tipo` enum('amonestacion','suspension','multa','expulsion') NOT NULL,
  `descripcion` text NOT NULL,
  `fecha_sancion` date NOT NULL,
  `partidos_suspension` int(11) NOT NULL DEFAULT 0 COMMENT 'Cantidad de partidos suspendido',
  `monto_multa` decimal(10,2) NOT NULL DEFAULT 0.00,
  `estado` enum('activa','cumplida','apelada','revocada') NOT NULL DEFAULT 'activa',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `sancion`
--

INSERT INTO `sancion` (`id_sancion`, `id_temporada`, `id_jugador`, `id_equipo`, `tipo`, `descripcion`, `fecha_sancion`, `partidos_suspension`, `monto_multa`, `estado`, `created_at`, `updated_at`) VALUES
(1, 2, 15, 2, 'suspension', 'Conducta antideportiva — discusión con árbitro', '2026-03-14', 2, 0.00, 'activa', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(2, 2, NULL, 6, 'multa', 'Retraso en llegada al estadio (>30 min)', '2026-03-14', 0, 1500.00, 'activa', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(3, 2, 7, 1, 'amonestacion', 'Lanzamiento de casco después del tercer out', '2026-03-07', 0, 0.00, 'cumplida', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(4, 2, 33, 4, 'suspension', 'Agresión verbal a jugador contrario', '2026-03-21', 3, 500.00, 'activa', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(5, 2, 52, 6, 'amonestacion', 'Demora excesiva en posición de bateo', '2026-03-22', 0, 0.00, 'cumplida', '2026-05-09 16:33:34', '2026-05-09 16:33:34'),
(7, 2, 81, 1, 'suspension', 'Negro paga tu vaina', '2026-05-14', 1, 1222.00, 'activa', '2026-05-14 11:20:37', '2026-05-14 11:20:37');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `seguimiento`
--

CREATE TABLE `seguimiento` (
  `id` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_equipo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `seguimiento`
--

INSERT INTO `seguimiento` (`id`, `id_usuario`, `id_equipo`) VALUES
(1, 5, 1),
(2, 5, 3),
(3, 5, 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `temporada`
--

CREATE TABLE `temporada` (
  `id_temporada` int(11) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `anio` year(4) NOT NULL,
  `categoria` varchar(100) NOT NULL,
  `costo_inscripcion` decimal(10,2) NOT NULL DEFAULT 0.00,
  `activa` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `temporada`
--

INSERT INTO `temporada` (`id_temporada`, `nombre`, `anio`, `categoria`, `costo_inscripcion`, `activa`, `created_at`, `updated_at`) VALUES
(1, 'Temporada Apertura 2025', '2025', 'Semi-profesional', 5000.00, 0, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(2, 'Temporada Clausura 2026', '2026', 'Semi-profesional', 5500.00, 1, '2026-05-09 16:33:33', '2026-05-09 16:33:33'),
(3, 'Temporada Iujoa', '2026', 'Juvenil', 700.00, 1, '2026-05-22 02:13:27', '2026-05-22 02:13:27');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transferencia`
--

CREATE TABLE `transferencia` (
  `id_transferencia` int(11) NOT NULL,
  `id_jugador` int(11) NOT NULL,
  `id_equipo_origen` int(11) NOT NULL,
  `id_equipo_destino` int(11) NOT NULL,
  `estado` enum('pendiente','aceptada','rechazada') DEFAULT 'pendiente',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `transferencia`
--

INSERT INTO `transferencia` (`id_transferencia`, `id_jugador`, `id_equipo_origen`, `id_equipo_destino`, `estado`, `created_at`) VALUES
(1, 61, 7, 1, 'aceptada', '2026-05-21 21:06:13'),
(2, 61, 1, 7, 'aceptada', '2026-05-21 21:07:09'),
(3, 74, 1, 7, 'aceptada', '2026-05-21 21:34:06'),
(4, 65, 7, 1, 'rechazada', '2026-05-21 21:48:25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `rol` enum('administrador','dueno','caja','anotador','publico') NOT NULL DEFAULT 'publico',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `id_equipo` int(11) DEFAULT NULL COMMENT 'ID del equipo que pertenece al dueño o anotador'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `nombre`, `email`, `password_hash`, `rol`, `activo`, `created_at`, `updated_at`, `id_equipo`) VALUES
(1, 'Admin Liga', 'admin@ligadiamante.com', '$2a$10$EYDOZPn7CrbAplMkwSvEZ.qigrJuJYU66NwvyXEZlWuD4D8fX9xae', 'administrador', 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34', NULL),
(2, 'Carlos Dueño', 'dueno@ligadiamante.com', '$2a$10$EYDOZPn7CrbAplMkwSvEZ.qigrJuJYU66NwvyXEZlWuD4D8fX9xae', 'dueno', 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34', NULL),
(3, 'María Cajera', 'caja@ligadiamante.com', '$2a$10$EYDOZPn7CrbAplMkwSvEZ.qigrJuJYU66NwvyXEZlWuD4D8fX9xae', 'caja', 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34', NULL),
(4, 'Pedro Anotador', 'anotador@ligadiamante.com', '$2a$10$EYDOZPn7CrbAplMkwSvEZ.qigrJuJYU66NwvyXEZlWuD4D8fX9xae', 'anotador', 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34', NULL),
(5, 'Juan Fanático', 'fan@ligadiamante.com', '$2a$10$EYDOZPn7CrbAplMkwSvEZ.qigrJuJYU66NwvyXEZlWuD4D8fX9xae', 'publico', 1, '2026-05-09 16:33:34', '2026-05-09 16:33:34', NULL),
(6, 'Humberto', 'leones@ligadiamante.com', '$2a$10$pNBcKyHMHAD31tBC5QLzFeDs6YhVY2BKFjA8xDFypvvcLqd/kDj0K', 'dueno', 1, '2026-05-09 17:05:37', '2026-05-09 17:05:37', 1),
(7, 'Magda Perozo', 'loschivos@ligadiamante.com', '$2a$10$CvZ//sIrO6ZqFdQa1Tvtj.gz3sIqR76rrA9mcUXRjY.Q2NsXmJbm2', 'dueno', 1, '2026-05-14 13:17:17', '2026-05-14 13:17:17', 11);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `desempeno_bateador`
--
ALTER TABLE `desempeno_bateador`
  ADD PRIMARY KEY (`id_desempeno`),
  ADD UNIQUE KEY `uq_bateador_partido` (`id_jugador`,`id_partido`),
  ADD KEY `fk_bat_partido` (`id_partido`),
  ADD KEY `fk_bat_equipo` (`id_equipo`);

--
-- Indices de la tabla `desempeno_pitcher`
--
ALTER TABLE `desempeno_pitcher`
  ADD PRIMARY KEY (`id_desempeno_pitcher`),
  ADD UNIQUE KEY `uq_pitcher_partido` (`id_jugador`,`id_partido`),
  ADD KEY `fk_pit_partido` (`id_partido`),
  ADD KEY `fk_pit_equipo` (`id_equipo`);

--
-- Indices de la tabla `egreso`
--
ALTER TABLE `egreso`
  ADD PRIMARY KEY (`id_egreso`),
  ADD KEY `fk_egreso_temporada` (`id_temporada`),
  ADD KEY `fk_egreso_proveedor` (`id_proveedor`);

--
-- Indices de la tabla `equipo`
--
ALTER TABLE `equipo`
  ADD PRIMARY KEY (`id_equipo`);

--
-- Indices de la tabla `estadio`
--
ALTER TABLE `estadio`
  ADD PRIMARY KEY (`id_estadio`);

--
-- Indices de la tabla `ingreso`
--
ALTER TABLE `ingreso`
  ADD PRIMARY KEY (`id_ingreso`),
  ADD KEY `fk_ingreso_equipo` (`id_equipo`),
  ADD KEY `fk_ingreso_temporada` (`id_temporada`);

--
-- Indices de la tabla `inscripcion`
--
ALTER TABLE `inscripcion`
  ADD PRIMARY KEY (`id_inscripcion`),
  ADD UNIQUE KEY `uq_inscripcion_equipo_temporada` (`id_equipo`,`id_temporada`),
  ADD KEY `fk_inscripcion_temporada` (`id_temporada`);

--
-- Indices de la tabla `jugador`
--
ALTER TABLE `jugador`
  ADD PRIMARY KEY (`id_jugador`),
  ADD KEY `fk_jugador_equipo` (`id_equipo`);

--
-- Indices de la tabla `lineup`
--
ALTER TABLE `lineup`
  ADD PRIMARY KEY (`id_lineup`),
  ADD UNIQUE KEY `uq_lineup_jugador_partido` (`id_partido`,`id_jugador`),
  ADD KEY `fk_lineup_jugador` (`id_jugador`),
  ADD KEY `fk_lineup_equipo` (`id_equipo`);

--
-- Indices de la tabla `noticia`
--
ALTER TABLE `noticia`
  ADD PRIMARY KEY (`id_noticia`);

--
-- Indices de la tabla `notificacion`
--
ALTER TABLE `notificacion`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `partido`
--
ALTER TABLE `partido`
  ADD PRIMARY KEY (`id_partido`),
  ADD KEY `fk_partido_temporada` (`id_temporada`),
  ADD KEY `fk_partido_casa` (`id_equipo_casa`),
  ADD KEY `fk_partido_visitante` (`id_equipo_visitante`),
  ADD KEY `fk_partido_estadio` (`id_estadio`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`id_proveedor`),
  ADD UNIQUE KEY `uq_proveedor_rif` (`rif`);

--
-- Indices de la tabla `resultado`
--
ALTER TABLE `resultado`
  ADD PRIMARY KEY (`id_resultado`),
  ADD UNIQUE KEY `uq_resultado_partido` (`id_partido`),
  ADD KEY `fk_resultado_pitcher_ganador` (`id_pitcher_ganador`),
  ADD KEY `fk_resultado_pitcher_perdedor` (`id_pitcher_perdedor`),
  ADD KEY `fk_resultado_pitcher_salvador` (`id_pitcher_salvador`);

--
-- Indices de la tabla `sancion`
--
ALTER TABLE `sancion`
  ADD PRIMARY KEY (`id_sancion`),
  ADD KEY `fk_sancion_temporada` (`id_temporada`),
  ADD KEY `fk_sancion_jugador` (`id_jugador`),
  ADD KEY `fk_sancion_equipo` (`id_equipo`);

--
-- Indices de la tabla `seguimiento`
--
ALTER TABLE `seguimiento`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_seguimiento` (`id_usuario`,`id_equipo`),
  ADD KEY `fk_seguimiento_equipo` (`id_equipo`);

--
-- Indices de la tabla `temporada`
--
ALTER TABLE `temporada`
  ADD PRIMARY KEY (`id_temporada`);

--
-- Indices de la tabla `transferencia`
--
ALTER TABLE `transferencia`
  ADD PRIMARY KEY (`id_transferencia`),
  ADD KEY `id_jugador` (`id_jugador`),
  ADD KEY `id_equipo_origen` (`id_equipo_origen`),
  ADD KEY `id_equipo_destino` (`id_equipo_destino`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `uq_usuario_email` (`email`),
  ADD KEY `fk_usuario_equipo` (`id_equipo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `desempeno_bateador`
--
ALTER TABLE `desempeno_bateador`
  MODIFY `id_desempeno` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=291;

--
-- AUTO_INCREMENT de la tabla `desempeno_pitcher`
--
ALTER TABLE `desempeno_pitcher`
  MODIFY `id_desempeno_pitcher` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- AUTO_INCREMENT de la tabla `egreso`
--
ALTER TABLE `egreso`
  MODIFY `id_egreso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `equipo`
--
ALTER TABLE `equipo`
  MODIFY `id_equipo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `estadio`
--
ALTER TABLE `estadio`
  MODIFY `id_estadio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `ingreso`
--
ALTER TABLE `ingreso`
  MODIFY `id_ingreso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT de la tabla `inscripcion`
--
ALTER TABLE `inscripcion`
  MODIFY `id_inscripcion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `jugador`
--
ALTER TABLE `jugador`
  MODIFY `id_jugador` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=90;

--
-- AUTO_INCREMENT de la tabla `lineup`
--
ALTER TABLE `lineup`
  MODIFY `id_lineup` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=115;

--
-- AUTO_INCREMENT de la tabla `noticia`
--
ALTER TABLE `noticia`
  MODIFY `id_noticia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `notificacion`
--
ALTER TABLE `notificacion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `partido`
--
ALTER TABLE `partido`
  MODIFY `id_partido` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `id_proveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `resultado`
--
ALTER TABLE `resultado`
  MODIFY `id_resultado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT de la tabla `sancion`
--
ALTER TABLE `sancion`
  MODIFY `id_sancion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `seguimiento`
--
ALTER TABLE `seguimiento`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `temporada`
--
ALTER TABLE `temporada`
  MODIFY `id_temporada` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `transferencia`
--
ALTER TABLE `transferencia`
  MODIFY `id_transferencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `desempeno_bateador`
--
ALTER TABLE `desempeno_bateador`
  ADD CONSTRAINT `fk_bat_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipo` (`id_equipo`),
  ADD CONSTRAINT `fk_bat_jugador` FOREIGN KEY (`id_jugador`) REFERENCES `jugador` (`id_jugador`),
  ADD CONSTRAINT `fk_bat_partido` FOREIGN KEY (`id_partido`) REFERENCES `partido` (`id_partido`);

--
-- Filtros para la tabla `desempeno_pitcher`
--
ALTER TABLE `desempeno_pitcher`
  ADD CONSTRAINT `fk_pit_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipo` (`id_equipo`),
  ADD CONSTRAINT `fk_pit_jugador` FOREIGN KEY (`id_jugador`) REFERENCES `jugador` (`id_jugador`),
  ADD CONSTRAINT `fk_pit_partido` FOREIGN KEY (`id_partido`) REFERENCES `partido` (`id_partido`);

--
-- Filtros para la tabla `egreso`
--
ALTER TABLE `egreso`
  ADD CONSTRAINT `fk_egreso_proveedor` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`),
  ADD CONSTRAINT `fk_egreso_temporada` FOREIGN KEY (`id_temporada`) REFERENCES `temporada` (`id_temporada`);

--
-- Filtros para la tabla `ingreso`
--
ALTER TABLE `ingreso`
  ADD CONSTRAINT `fk_ingreso_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipo` (`id_equipo`),
  ADD CONSTRAINT `fk_ingreso_temporada` FOREIGN KEY (`id_temporada`) REFERENCES `temporada` (`id_temporada`);

--
-- Filtros para la tabla `inscripcion`
--
ALTER TABLE `inscripcion`
  ADD CONSTRAINT `fk_inscripcion_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipo` (`id_equipo`),
  ADD CONSTRAINT `fk_inscripcion_temporada` FOREIGN KEY (`id_temporada`) REFERENCES `temporada` (`id_temporada`);

--
-- Filtros para la tabla `jugador`
--
ALTER TABLE `jugador`
  ADD CONSTRAINT `fk_jugador_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipo` (`id_equipo`);

--
-- Filtros para la tabla `lineup`
--
ALTER TABLE `lineup`
  ADD CONSTRAINT `fk_lineup_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipo` (`id_equipo`),
  ADD CONSTRAINT `fk_lineup_jugador` FOREIGN KEY (`id_jugador`) REFERENCES `jugador` (`id_jugador`),
  ADD CONSTRAINT `fk_lineup_partido` FOREIGN KEY (`id_partido`) REFERENCES `partido` (`id_partido`);

--
-- Filtros para la tabla `notificacion`
--
ALTER TABLE `notificacion`
  ADD CONSTRAINT `notificacion_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE;

--
-- Filtros para la tabla `partido`
--
ALTER TABLE `partido`
  ADD CONSTRAINT `fk_partido_casa` FOREIGN KEY (`id_equipo_casa`) REFERENCES `equipo` (`id_equipo`),
  ADD CONSTRAINT `fk_partido_estadio` FOREIGN KEY (`id_estadio`) REFERENCES `estadio` (`id_estadio`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_partido_temporada` FOREIGN KEY (`id_temporada`) REFERENCES `temporada` (`id_temporada`),
  ADD CONSTRAINT `fk_partido_visitante` FOREIGN KEY (`id_equipo_visitante`) REFERENCES `equipo` (`id_equipo`);

--
-- Filtros para la tabla `resultado`
--
ALTER TABLE `resultado`
  ADD CONSTRAINT `fk_resultado_partido` FOREIGN KEY (`id_partido`) REFERENCES `partido` (`id_partido`),
  ADD CONSTRAINT `fk_resultado_pitcher_ganador` FOREIGN KEY (`id_pitcher_ganador`) REFERENCES `jugador` (`id_jugador`),
  ADD CONSTRAINT `fk_resultado_pitcher_perdedor` FOREIGN KEY (`id_pitcher_perdedor`) REFERENCES `jugador` (`id_jugador`),
  ADD CONSTRAINT `fk_resultado_pitcher_salvador` FOREIGN KEY (`id_pitcher_salvador`) REFERENCES `jugador` (`id_jugador`);

--
-- Filtros para la tabla `sancion`
--
ALTER TABLE `sancion`
  ADD CONSTRAINT `fk_sancion_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipo` (`id_equipo`),
  ADD CONSTRAINT `fk_sancion_jugador` FOREIGN KEY (`id_jugador`) REFERENCES `jugador` (`id_jugador`),
  ADD CONSTRAINT `fk_sancion_temporada` FOREIGN KEY (`id_temporada`) REFERENCES `temporada` (`id_temporada`);

--
-- Filtros para la tabla `seguimiento`
--
ALTER TABLE `seguimiento`
  ADD CONSTRAINT `fk_seguimiento_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipo` (`id_equipo`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_seguimiento_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE;

--
-- Filtros para la tabla `transferencia`
--
ALTER TABLE `transferencia`
  ADD CONSTRAINT `transferencia_ibfk_1` FOREIGN KEY (`id_jugador`) REFERENCES `jugador` (`id_jugador`) ON DELETE CASCADE,
  ADD CONSTRAINT `transferencia_ibfk_2` FOREIGN KEY (`id_equipo_origen`) REFERENCES `equipo` (`id_equipo`) ON DELETE CASCADE,
  ADD CONSTRAINT `transferencia_ibfk_3` FOREIGN KEY (`id_equipo_destino`) REFERENCES `equipo` (`id_equipo`) ON DELETE CASCADE;

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `fk_usuario_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipo` (`id_equipo`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
