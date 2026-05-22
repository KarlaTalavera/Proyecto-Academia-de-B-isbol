const db = require('../config/database')

// ─────────────────────────────────────────────
//  BATEADOR
// ─────────────────────────────────────────────

async function getBateadoresPorPartido(id_partido) {
  const [rows] = await db.query(
    `SELECT db.*, j.nombre, j.apellido, j.posicion, j.rol, e.nombre_equipo,
       ROUND(db.hits / NULLIF(db.turnos_al_bate, 0), 3) AS promedio_bate
     FROM desempeno_bateador db
     JOIN jugador j ON j.id_jugador = db.id_jugador
     JOIN equipo  e ON e.id_equipo  = db.id_equipo
     WHERE db.id_partido = ?
     ORDER BY db.id_equipo, j.apellido`, [id_partido])
  return rows
}

async function getBateadorPartidos(id_jugador) {
  const [rows] = await db.query(
    `SELECT db.*, p.fecha_juego, p.id_temporada, t.nombre AS nombre_temporada,
       p.id_equipo_visitante, p.id_equipo_casa,
       ev.nombre_equipo AS equipo_visitante, el.nombre_equipo AS equipo_casa,
       ROUND(db.hits / NULLIF(db.turnos_al_bate, 0), 3) AS promedio_bate
     FROM desempeno_bateador db
     JOIN partido   p  ON p.id_partido   = db.id_partido
     JOIN temporada t  ON t.id_temporada = p.id_temporada
     JOIN equipo    ev ON ev.id_equipo   = p.id_equipo_visitante
     JOIN equipo    el ON el.id_equipo   = p.id_equipo_casa
     WHERE db.id_jugador = ?
     ORDER BY p.fecha_juego DESC`, [id_jugador])
  return rows
}

async function getBateadorPorTemporada(id_jugador) {
  const [rows] = await db.query(
    `SELECT p.id_temporada, t.nombre AS nombre_temporada,
       COUNT(DISTINCT db.id_partido) AS partidos_jugados,
       SUM(db.turnos_al_bate) AS turnos_al_bate,
       SUM(db.hits) AS hits, SUM(db.dobles) AS dobles,
       SUM(db.triples) AS triples, SUM(db.jonrones) AS jonrones,
       SUM(db.carreras) AS carreras, SUM(db.carreras_impulsadas) AS carreras_impulsadas,
       SUM(db.bolas) AS bolas, SUM(db.outs) AS outs, SUM(db.asistencias) AS asistencias,
       ROUND(SUM(db.hits) / NULLIF(SUM(db.turnos_al_bate), 0), 3) AS avg,
       ROUND((SUM(db.hits) + SUM(db.bolas)) / NULLIF(SUM(db.turnos_al_bate) + SUM(db.bolas), 0), 3) AS obp,
       ROUND((SUM(db.hits) + SUM(db.dobles) + 2*SUM(db.triples) + 3*SUM(db.jonrones)) / NULLIF(SUM(db.turnos_al_bate), 0), 3) AS slg
     FROM desempeno_bateador db
     JOIN partido   p ON p.id_partido   = db.id_partido
     JOIN temporada t ON t.id_temporada = p.id_temporada
     WHERE db.id_jugador = ?
     GROUP BY p.id_temporada, t.nombre
     ORDER BY p.id_temporada DESC`, [id_jugador])
  return rows
}

async function getBateadorPorFecha(id_jugador, fecha_inicio, fecha_fin) {
  const [rows] = await db.query(
    `SELECT db.*, p.fecha_juego, p.id_temporada, t.nombre AS nombre_temporada,
       p.id_equipo_visitante, p.id_equipo_casa,
       ev.nombre_equipo AS equipo_visitante, el.nombre_equipo AS equipo_casa,
       ROUND(db.hits / NULLIF(db.turnos_al_bate, 0), 3) AS promedio_bate
     FROM desempeno_bateador db
     JOIN partido   p  ON p.id_partido   = db.id_partido
     JOIN temporada t  ON t.id_temporada = p.id_temporada
     JOIN equipo    ev ON ev.id_equipo   = p.id_equipo_visitante
     JOIN equipo    el ON el.id_equipo   = p.id_equipo_casa
     WHERE db.id_jugador = ? AND p.fecha_juego BETWEEN ? AND ?
     ORDER BY p.fecha_juego DESC`, [id_jugador, fecha_inicio, fecha_fin])
  return rows
}

// ─────────────────────────────────────────────
//  PITCHER
// ─────────────────────────────────────────────

async function getPitcheresPorPartido(id_partido) {
  const [rows] = await db.query(
    `SELECT dp.*, j.nombre, j.apellido, j.posicion, e.nombre_equipo,
       ROUND(dp.carreras_limpias * 9 / NULLIF(dp.innings_pitcheados, 0), 2) AS era
     FROM desempeno_pitcher dp
     JOIN jugador j ON j.id_jugador = dp.id_jugador
     JOIN equipo  e ON e.id_equipo  = dp.id_equipo
     WHERE dp.id_partido = ?
     ORDER BY dp.id_equipo, dp.innings_pitcheados DESC`, [id_partido])
  return rows
}

async function getPitcherPartidos(id_jugador) {
  const [rows] = await db.query(
    `SELECT dp.*, p.fecha_juego, p.id_temporada, t.nombre AS nombre_temporada,
       p.id_equipo_visitante, p.id_equipo_casa,
       ev.nombre_equipo AS equipo_visitante, el.nombre_equipo AS equipo_casa,
       ROUND(dp.carreras_limpias * 9 / NULLIF(dp.innings_pitcheados, 0), 2) AS era
     FROM desempeno_pitcher dp
     JOIN partido   p  ON p.id_partido   = dp.id_partido
     JOIN temporada t  ON t.id_temporada = p.id_temporada
     JOIN equipo    ev ON ev.id_equipo   = p.id_equipo_visitante
     JOIN equipo    el ON el.id_equipo   = p.id_equipo_casa
     WHERE dp.id_jugador = ?
     ORDER BY p.fecha_juego DESC`, [id_jugador])
  return rows
}

async function getPitcherPorTemporada(id_jugador) {
  const [rows] = await db.query(
    `SELECT p.id_temporada, t.nombre AS nombre_temporada,
       COUNT(DISTINCT dp.id_partido) AS partidos,
       SUM(dp.innings_pitcheados) AS innings_pitcheados,
       SUM(dp.hits_permitidos) AS hits_permitidos,
       SUM(dp.carreras_permitidas) AS carreras_permitidas,
       SUM(dp.carreras_limpias) AS carreras_limpias,
       SUM(dp.jonrones_permitidos) AS jonrones_permitidos,
       SUM(dp.golpes_bateador) AS golpes_bateador,
       SUM(dp.bases_por_bolas) AS bases_por_bolas,
       SUM(dp.ponches) AS ponches,
       SUM(dp.ganado) AS victorias, SUM(dp.perdido) AS derrotas, SUM(dp.salvado) AS salvados,
       ROUND(SUM(dp.carreras_limpias) * 9 / NULLIF(SUM(dp.innings_pitcheados), 0), 2) AS era,
       ROUND((SUM(dp.bases_por_bolas) + SUM(dp.hits_permitidos)) / NULLIF(SUM(dp.innings_pitcheados), 0), 3) AS whip,
       ROUND(SUM(dp.ponches) * 9 / NULLIF(SUM(dp.innings_pitcheados), 0), 2) AS k_por_9
     FROM desempeno_pitcher dp
     JOIN partido   p ON p.id_partido   = dp.id_partido
     JOIN temporada t ON t.id_temporada = p.id_temporada
     WHERE dp.id_jugador = ?
     GROUP BY p.id_temporada, t.nombre
     ORDER BY p.id_temporada DESC`, [id_jugador])
  return rows
}

async function getPitcherPorFecha(id_jugador, fecha_inicio, fecha_fin) {
  const [rows] = await db.query(
    `SELECT dp.*, p.fecha_juego, p.id_temporada, t.nombre AS nombre_temporada,
       p.id_equipo_visitante, p.id_equipo_casa,
       ev.nombre_equipo AS equipo_visitante, el.nombre_equipo AS equipo_casa,
       ROUND(dp.carreras_limpias * 9 / NULLIF(dp.innings_pitcheados, 0), 2) AS era
     FROM desempeno_pitcher dp
     JOIN partido   p  ON p.id_partido   = dp.id_partido
     JOIN temporada t  ON t.id_temporada = p.id_temporada
     JOIN equipo    ev ON ev.id_equipo   = p.id_equipo_visitante
     JOIN equipo    el ON el.id_equipo   = p.id_equipo_casa
     WHERE dp.id_jugador = ? AND p.fecha_juego BETWEEN ? AND ?
     ORDER BY p.fecha_juego DESC`, [id_jugador, fecha_inicio, fecha_fin])
  return rows
}

module.exports = {
  getBateadoresPorPartido,
  getBateadorPartidos,
  getBateadorPorTemporada,
  getBateadorPorFecha,
  getPitcheresPorPartido,
  getPitcherPartidos,
  getPitcherPorTemporada,
  getPitcherPorFecha,
}