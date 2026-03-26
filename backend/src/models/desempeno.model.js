const db = require('../config/database')

const DesempenoModel = {
  // ── BATEADOR ─────────────────────────────────────────────
  async findBateadorByPartido(id_partido) {
    const [rows] = await db.query(
      `SELECT d.*, j.nombre, j.apellido, e.nombre_equipo
       FROM desempeno_bateador d
       JOIN jugador j ON d.id_jugador = j.id_jugador
       JOIN equipo  e ON d.id_equipo  = e.id_equipo
       WHERE d.id_partido = ?
       ORDER BY e.id_equipo, d.id_desempeno`,
      [id_partido]
    )
    return rows
  },

  async upsertBateador(data) {
    const {
      id_jugador, id_partido, id_equipo,
      turnos_al_bate = 0, hits = 0, dobles = 0, triples = 0,
      jonrones = 0, carreras = 0, carreras_impulsadas = 0,
      bolas = 0, strikes = 0, foul = 0, outs = 0, asistencias = 0,
    } = data
    await db.query(
      `INSERT INTO desempeno_bateador
         (id_jugador, id_partido, id_equipo, turnos_al_bate, hits, dobles, triples,
          jonrones, carreras, carreras_impulsadas, bolas, strikes, foul, outs, asistencias)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
       ON DUPLICATE KEY UPDATE
         turnos_al_bate=VALUES(turnos_al_bate), hits=VALUES(hits), dobles=VALUES(dobles),
         triples=VALUES(triples), jonrones=VALUES(jonrones), carreras=VALUES(carreras),
         carreras_impulsadas=VALUES(carreras_impulsadas), bolas=VALUES(bolas),
         strikes=VALUES(strikes), foul=VALUES(foul), outs=VALUES(outs), asistencias=VALUES(asistencias)`,
      [id_jugador, id_partido, id_equipo, turnos_al_bate, hits, dobles, triples,
       jonrones, carreras, carreras_impulsadas, bolas, strikes, foul, outs, asistencias]
    )
  },

  // ── PITCHER ──────────────────────────────────────────────
  async findPitcherByPartido(id_partido) {
    const [rows] = await db.query(
      `SELECT d.*, j.nombre, j.apellido, e.nombre_equipo
       FROM desempeno_pitcher d
       JOIN jugador j ON d.id_jugador = j.id_jugador
       JOIN equipo  e ON d.id_equipo  = e.id_equipo
       WHERE d.id_partido = ?`,
      [id_partido]
    )
    return rows
  },

  async upsertPitcher(data) {
    const {
      id_jugador, id_partido, id_equipo,
      innings_pitcheados = 0, hits_permitidos = 0, carreras_permitidas = 0,
      carreras_limpias = 0, jonrones_permitidos = 0, golpes_bateador = 0,
      bases_por_bolas = 0, ponches = 0,
      ganado = 0, perdido = 0, salvado = 0,
    } = data
    await db.query(
      `INSERT INTO desempeno_pitcher
         (id_jugador, id_partido, id_equipo, innings_pitcheados, hits_permitidos,
          carreras_permitidas, carreras_limpias, jonrones_permitidos, golpes_bateador,
          bases_por_bolas, ponches, ganado, perdido, salvado)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)
       ON DUPLICATE KEY UPDATE
         innings_pitcheados=VALUES(innings_pitcheados), hits_permitidos=VALUES(hits_permitidos),
         carreras_permitidas=VALUES(carreras_permitidas), carreras_limpias=VALUES(carreras_limpias),
         jonrones_permitidos=VALUES(jonrones_permitidos), golpes_bateador=VALUES(golpes_bateador),
         bases_por_bolas=VALUES(bases_por_bolas), ponches=VALUES(ponches),
         ganado=VALUES(ganado), perdido=VALUES(perdido), salvado=VALUES(salvado)`,
      [id_jugador, id_partido, id_equipo, innings_pitcheados, hits_permitidos,
       carreras_permitidas, carreras_limpias, jonrones_permitidos, golpes_bateador,
       bases_por_bolas, ponches, ganado, perdido, salvado]
    )
  },

  // ── ESTADÍSTICAS ACUMULADAS (promedio de bateo) ───────────
  async promediosBateo(id_temporada) {
    const [rows] = await db.query(
      `SELECT
         j.id_jugador,
         CONCAT(j.nombre, ' ', j.apellido) AS jugador,
         e.nombre_equipo,
         SUM(d.turnos_al_bate)      AS AB,
         SUM(d.hits)                AS H,
         SUM(d.dobles)              AS X2B,
         SUM(d.triples)             AS X3B,
         SUM(d.jonrones)            AS HR,
         SUM(d.carreras)            AS R,
         SUM(d.carreras_impulsadas) AS RBI,
         ROUND(SUM(d.hits) / NULLIF(SUM(d.turnos_al_bate), 0), 3) AS AVG
       FROM desempeno_bateador d
       JOIN jugador j ON d.id_jugador = j.id_jugador
       JOIN equipo  e ON d.id_equipo  = e.id_equipo
       JOIN partido p ON d.id_partido = p.id_partido
       WHERE p.id_temporada = ?
       GROUP BY j.id_jugador, j.nombre, j.apellido, e.nombre_equipo
       ORDER BY AVG DESC`,
      [id_temporada]
    )
    return rows
  },
}

module.exports = DesempenoModel
