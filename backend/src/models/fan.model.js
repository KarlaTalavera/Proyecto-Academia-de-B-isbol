const db = require('../config/database')

// Crea la tabla seguimiento si no existe
async function initTabla() {
  await db.query(`
    CREATE TABLE IF NOT EXISTS seguimiento (
      id         INT AUTO_INCREMENT PRIMARY KEY,
      id_usuario INT NOT NULL,
      id_equipo  INT NOT NULL,
      UNIQUE KEY uq_fan_equipo (id_usuario, id_equipo),
      FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
      FOREIGN KEY (id_equipo)  REFERENCES equipo(id_equipo)   ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `)
}
initTabla().catch(console.error)

const FanModel = {
  // Todos los equipos con flag siguiendo=1/0 para este usuario
  async listarEquiposConFlag(id_usuario) {
    const [rows] = await db.query(
      `SELECT e.*,
              IF(s.id IS NOT NULL, 1, 0) AS siguiendo
       FROM equipo e
       LEFT JOIN seguimiento s ON s.id_equipo = e.id_equipo AND s.id_usuario = ?
       ORDER BY e.nombre_equipo`,
      [id_usuario]
    )
    return rows
  },

  // Equipos que el usuario sigue
  async misEquipos(id_usuario) {
    const [rows] = await db.query(
      `SELECT e.*
       FROM seguimiento s
       JOIN equipo e ON e.id_equipo = s.id_equipo
       WHERE s.id_usuario = ?
       ORDER BY e.nombre_equipo`,
      [id_usuario]
    )
    return rows
  },

  async seguir(id_usuario, id_equipo) {
    await db.query(
      'INSERT IGNORE INTO seguimiento (id_usuario, id_equipo) VALUES (?, ?)',
      [id_usuario, id_equipo]
    )
  },

  async dejarSeguir(id_usuario, id_equipo) {
    await db.query(
      'DELETE FROM seguimiento WHERE id_usuario = ? AND id_equipo = ?',
      [id_usuario, id_equipo]
    )
  },

  // Próximos juegos de los equipos seguidos
  async proximosJuegos(id_usuario) {
    const [rows] = await db.query(
      `SELECT p.*,
              ec.nombre_equipo AS equipo_casa,
              ev.nombre_equipo AS equipo_visitante
       FROM partido p
       JOIN equipo ec ON p.id_equipo_casa      = ec.id_equipo
       JOIN equipo ev ON p.id_equipo_visitante  = ev.id_equipo
       WHERE p.estado IN ('programado', 'en_juego')
         AND (
           p.id_equipo_casa      IN (SELECT id_equipo FROM seguimiento WHERE id_usuario = ?)
           OR
           p.id_equipo_visitante IN (SELECT id_equipo FROM seguimiento WHERE id_usuario = ?)
         )
       ORDER BY p.fecha_juego, p.hora_juego
       LIMIT 10`,
      [id_usuario, id_usuario]
    )
    return rows
  },

  // Estadísticas de bateadores de los equipos seguidos
  async estadisticasBateadores(id_usuario) {
    const [rows] = await db.query(
      `SELECT
         j.id_jugador,
         CONCAT(j.nombre, ' ', j.apellido) AS jugador,
         e.nombre_equipo,
         SUM(d.turnos_al_bate)      AS AB,
         SUM(d.hits)                AS H,
         SUM(d.jonrones)            AS HR,
         SUM(d.carreras_impulsadas) AS RBI,
         ROUND(SUM(d.hits) / NULLIF(SUM(d.turnos_al_bate), 0), 3) AS AVG
       FROM desempeno_bateador d
       JOIN jugador j ON d.id_jugador = j.id_jugador
       JOIN equipo  e ON d.id_equipo  = e.id_equipo
       WHERE e.id_equipo IN (
         SELECT id_equipo FROM seguimiento WHERE id_usuario = ?
       )
       GROUP BY j.id_jugador, j.nombre, j.apellido, e.nombre_equipo
       HAVING AB > 0
       ORDER BY AVG DESC
       LIMIT 20`,
      [id_usuario]
    )
    return rows
  },

  // Últimos resultados de equipos seguidos
  async ultimosResultados(id_usuario) {
    const [rows] = await db.query(
      `SELECT p.id_partido, p.fecha_juego, p.lugar,
              ec.nombre_equipo AS equipo_casa,
              ev.nombre_equipo AS equipo_visitante,
              r.carreras_home, r.carreras_visitantes
       FROM partido p
       JOIN equipo ec  ON p.id_equipo_casa     = ec.id_equipo
       JOIN equipo ev  ON p.id_equipo_visitante = ev.id_equipo
       JOIN resultado r ON r.id_partido = p.id_partido
       WHERE p.estado = 'finalizado'
         AND (
           p.id_equipo_casa      IN (SELECT id_equipo FROM seguimiento WHERE id_usuario = ?)
           OR
           p.id_equipo_visitante IN (SELECT id_equipo FROM seguimiento WHERE id_usuario = ?)
         )
       ORDER BY p.fecha_juego DESC
       LIMIT 5`,
      [id_usuario, id_usuario]
    )
    return rows
  },
}

module.exports = FanModel
