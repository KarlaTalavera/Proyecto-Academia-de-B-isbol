const PartidoModel   = require('../models/partido.model')
const DesempenoModel = require('../models/desempeno.model')
const EstadioModel   = require('../models/estadio.model')
const db             = require('../config/database')

// ── FUNCIÓN GUARDIA: Validaciones de tiempo, estado y ROL ──
async function chequearBloqueo(id_partido, tipoAccion, usuario) {
  const partido = await PartidoModel.findById(id_partido);
  if (!partido) return { error: 'Partido no encontrado', status: 404 };

  // 1. VALIDACIÓN DE ROL: Dueños no pueden tocar resultados, stats ni reprogramar
  if (usuario && usuario.rol === 'dueno') {
    if (['resultado', 'estadisticas', 'estado', 'reprogramar'].includes(tipoAccion)) {
      return { error: 'ACCESO DENEGADO: Los dueños de equipo solo pueden gestionar su propio lineup.', status: 403 };
    }
  }

  // 2. BLOQUEO DE 24 HORAS (MODO AUDITORÍA)
  if (partido.estado === 'finalizado') {
    const fechaStr = typeof partido.fecha_juego === 'string' ? partido.fecha_juego.split('T')[0] : partido.fecha_juego.toISOString().split('T')[0];
    const fechaJuego = new Date(`${fechaStr}T${partido.hora_juego}`);
    const limiteEdicion = new Date(fechaJuego.getTime() + (30 * 60 * 60 * 1000));
    
    if (new Date() > limiteEdicion) {
      // En lugar de bloquear, levantamos la bandera de auditar
      return { auditar: true };
    }
  }

  // 3. REGLA DEL FUTURO: No alterar eventos de juegos que no han ocurrido
  if (tipoAccion === 'resultado' || tipoAccion === 'estadisticas') {
    const fechaStr = typeof partido.fecha_juego === 'string' ? partido.fecha_juego.split('T')[0] : partido.fecha_juego.toISOString().split('T')[0];
    const fechaHoraJuego = new Date(`${fechaStr}T${partido.hora_juego}`);
    if (new Date() < fechaHoraJuego) {
      return { error: 'No se pueden registrar resultados ni estadísticas de un partido que viaja en el tiempo (Aún no ha comenzado).', status: 400 };
    }
  }

  return { auditar: false }; 
}

// ── FUNCIÓN AUXILIAR: Validación de Choque de Horarios (4 Horas de margen) ──
function hayChoqueDeHorario(horaNueva, horaExistente, horasMargen = 4) {
  const [hN, mN] = horaNueva.split(':').map(Number);
  const [hE, mE] = horaExistente.split(':').map(Number);
  const minN = hN * 60 + mN;
  const minE = hE * 60 + mE;
  return Math.abs(minN - minE) < (horasMargen * 60);
}

const PartidoController = {
  async listar(req, res) {
    await PartidoModel.autoFinalizarVencidos()
    const { temporada } = req.query
    const idEquipo = req.usuario?.rol === 'dueno' ? req.usuario.id_equipo : null
    const data = await PartidoModel.findAll(temporada || null, idEquipo)
    res.json(data)
  },

  async obtener(req, res) {
    const partido = await PartidoModel.findById(req.params.id)
    if (!partido) return res.status(404).json({ error: 'Partido no encontrado' })
    res.json(partido)
  },

  async crear(req, res) {
    const { id_temporada, id_equipo_casa, id_equipo_visitante, fecha_juego, hora_juego, id_estadio, lugar } = req.body
    
    if (!id_temporada || !id_equipo_casa || !id_equipo_visitante || !fecha_juego || !hora_juego) {
      return res.status(400).json({ error: 'id_temporada, equipos, fecha_juego y hora_juego son requeridos' })
    }

    if (id_equipo_casa === id_equipo_visitante) {
      return res.status(400).json({ error: 'Un equipo no puede jugar contra sí mismo' })
    }

    const fechaHoraJuego = new Date(`${fecha_juego}T${hora_juego}`);
    if (fechaHoraJuego <= new Date()) {
      return res.status(400).json({ error: 'Solo se pueden programar partidos en fechas futuras' })
    }

    const [choqueRivales] = await db.query(
      `SELECT id_partido FROM partido WHERE fecha_juego = ? AND ((id_equipo_casa = ? AND id_equipo_visitante = ?) OR (id_equipo_casa = ? AND id_equipo_visitante = ?))`,
      [fecha_juego, id_equipo_casa, id_equipo_visitante, id_equipo_visitante, id_equipo_casa]
    );
    if (choqueRivales.length > 0) {
      return res.status(400).json({ error: 'Estos dos equipos ya se enfrentan en esta misma fecha. No pueden jugar dos veces el mismo día.' });
    }

    if (id_estadio) {
      const [partidosMismoDia] = await db.query(
        `SELECT hora_juego FROM partido WHERE fecha_juego = ? AND id_estadio = ?`,
        [fecha_juego, id_estadio]
      );
      for (let p of partidosMismoDia) {
        if (hayChoqueDeHorario(hora_juego, p.hora_juego, 4)) {
          return res.status(400).json({ error: 'Colisión de horario: Debe haber al menos 4 horas de diferencia entre partidos programados en el mismo estadio.' });
        }
      }
    } else if (lugar) {
      const [partidosMismoDiaLugar] = await db.query(
        `SELECT hora_juego FROM partido WHERE fecha_juego = ? AND lugar = ?`,
        [fecha_juego, lugar]
      );
      for (let p of partidosMismoDiaLugar) {
        if (hayChoqueDeHorario(hora_juego, p.hora_juego, 4)) {
          return res.status(400).json({ error: 'Colisión de horario: Ya hay un partido en este lugar muy cerca de esta hora.' });
        }
      }
    }

    const [choqueEquipo] = await db.query(
      `SELECT hora_juego FROM partido WHERE fecha_juego = ? AND (id_equipo_casa IN (?, ?) OR id_equipo_visitante IN (?, ?))`,
      [fecha_juego, id_equipo_casa, id_equipo_visitante, id_equipo_casa, id_equipo_visitante]
    );
    for (let p of choqueEquipo) {
      if (hayChoqueDeHorario(hora_juego, p.hora_juego, 4)) {
        return res.status(400).json({ error: 'Uno de los equipos ya tiene un partido programado demasiado cerca de esta hora.' });
      }
    }

    const id = await PartidoModel.create(req.body)
    res.status(201).json({ id_partido: id })
  },

  async reprogramar(req, res) {
    const chequeo = await chequearBloqueo(req.params.id, 'reprogramar', req.usuario);
    if (chequeo.error) return res.status(chequeo.status).json({ error: chequeo.error });

    const partidoActual = await PartidoModel.findById(req.params.id);
    
    if (partidoActual.estado === 'finalizado' || partidoActual.estado === 'en_curso') {
        return res.status(400).json({ error: 'Solo puedes reprogramar partidos Programados o Suspendidos.' });
    }

    const { fecha_juego, hora_juego } = req.body
    const fechaHoraJuego = new Date(`${fecha_juego}T${hora_juego}`);
    if (fechaHoraJuego <= new Date()) return res.status(400).json({ error: 'La reprogramación debe ser en una fecha futura.' })

    const [choqueRivales] = await db.query(
      `SELECT id_partido FROM partido WHERE fecha_juego = ? AND ((id_equipo_casa = ? AND id_equipo_visitante = ?) OR (id_equipo_casa = ? AND id_equipo_visitante = ?)) AND id_partido != ?`,
      [fecha_juego, partidoActual.id_equipo_casa, partidoActual.id_equipo_visitante, partidoActual.id_equipo_visitante, partidoActual.id_equipo_casa, req.params.id]
    );
    if (choqueRivales.length > 0) {
      return res.status(400).json({ error: 'Estos dos equipos ya se enfrentan en esta nueva fecha. No pueden jugar dos veces el mismo día.' });
    }

    if (partidoActual.id_estadio) {
      const [partidosMismoDia] = await db.query(
        `SELECT hora_juego FROM partido WHERE fecha_juego = ? AND id_estadio = ? AND id_partido != ?`,
        [fecha_juego, partidoActual.id_estadio, req.params.id]
      );
      for (let p of partidosMismoDia) {
        if (hayChoqueDeHorario(hora_juego, p.hora_juego, 4)) {
          return res.status(400).json({ error: 'Colisión de horario: El estadio ya está ocupado a esa hora por otro partido.' });
        }
      }
    }

    const [choqueEquipo] = await db.query(
      `SELECT hora_juego FROM partido WHERE fecha_juego = ? AND (id_equipo_casa IN (?, ?) OR id_equipo_visitante IN (?, ?)) AND id_partido != ?`,
      [fecha_juego, partidoActual.id_equipo_casa, partidoActual.id_equipo_visitante, partidoActual.id_equipo_casa, partidoActual.id_equipo_visitante, req.params.id]
    );
    for (let p of choqueEquipo) {
      if (hayChoqueDeHorario(hora_juego, p.hora_juego, 4)) {
        return res.status(400).json({ error: 'Uno de los equipos tiene otro compromiso programado muy cerca de esta nueva hora.' });
      }
    }

    await PartidoModel.updateFechaHora(req.params.id, fecha_juego, hora_juego)
    res.json({ ok: true })
  },

  async actualizarEstado(req, res) {
    const chequeo = await chequearBloqueo(req.params.id, 'estado', req.usuario);
    if (chequeo.error) return res.status(chequeo.status).json({ error: chequeo.error });

    const partidoActual = await PartidoModel.findById(req.params.id);
    const { estado } = req.body

    if (partidoActual.estado === 'finalizado') {
        return res.status(400).json({ error: 'Un partido finalizado no puede retroceder de estado.' });
    }

    await PartidoModel.updateEstado(req.params.id, estado)
    res.json({ ok: true })
  },

  async eliminar(req, res) {
    const affected = await PartidoModel.delete(req.params.id)
    if (!affected) return res.status(404).json({ error: 'Partido no encontrado' })
    res.json({ ok: true })
  },

  async getLineup(req, res) {
    const id_partido = req.params.id;
    const [partido] = await db.query(`SELECT id_equipo_casa, id_equipo_visitante FROM partido WHERE id_partido = ?`, [id_partido]);
    if (!partido.length) return res.status(404).json({ error: 'Partido no encontrado' });
    
    const [roster] = await db.query(`
      SELECT j.id_jugador, j.id_equipo, j.nombre, j.apellido, j.posicion as posicion_natural, j.rol,
             l.id_lineup, l.orden_bateo, l.posicion_juego, COALESCE(l.es_titular, 0) as es_titular
      FROM jugador j
      LEFT JOIN lineup l ON l.id_jugador = j.id_jugador AND l.id_partido = ?
      WHERE j.id_equipo IN (?, ?) AND j.activo = 1
    `, [id_partido, partido[0].id_equipo_casa, partido[0].id_equipo_visitante]);
    res.json(roster);
  },

  async setLineup(req, res) {
    const id_partido = req.params.id;
    const { entries } = req.body;
    const usuario = req.usuario;

    const partido = await PartidoModel.findById(id_partido);
    if (partido.estado === 'finalizado') {
      return res.status(400).json({ error: 'El partido ya finalizó. La alineación está bloqueada permanentemente.' });
    }

    if (usuario && usuario.rol === 'dueno') {
      const trampa = entries.some(entry => Number(entry.id_equipo) !== Number(usuario.id_equipo));
      if (trampa) return res.status(403).json({ error: 'ALERTA: Solo puedes modificar jugadores que pertenezcan a tu equipo.' });
    }

    const posiciones = entries.map(e => e.posicion_juego).filter(p => p && p.trim() !== '');
    if (new Set(posiciones).size !== posiciones.length) return res.status(400).json({ error: 'Posiciones defensivas repetidas.' });

    const ordenes = entries.map(e => e.orden_bateo).filter(o => o && o > 0);
    if (new Set(ordenes).size !== ordenes.length) return res.status(400).json({ error: 'Números de orden al bate duplicados.' });

    for (const entry of entries) {
      if (entry.posicion_juego && entry.posicion_juego.trim() !== '') {
        await db.query(
          `INSERT INTO lineup (id_partido, id_jugador, id_equipo, orden_bateo, posicion_juego, es_titular) VALUES (?, ?, ?, ?, ?, ?)
           ON DUPLICATE KEY UPDATE orden_bateo=VALUES(orden_bateo), posicion_juego=VALUES(posicion_juego), es_titular=VALUES(es_titular)`,
          [id_partido, entry.id_jugador, entry.id_equipo, entry.orden_bateo || null, entry.posicion_juego, entry.es_titular ? 1 : 0]
        );

        if (entry.posicion_juego === 'P') {
          await db.query(`INSERT IGNORE INTO desempeno_pitcher (id_jugador, id_partido, id_equipo) VALUES (?, ?, ?)`, [entry.id_jugador, id_partido, entry.id_equipo]);
        } else {
          await db.query(`INSERT IGNORE INTO desempeno_bateador (id_jugador, id_partido, id_equipo) VALUES (?, ?, ?)`, [entry.id_jugador, id_partido, entry.id_equipo]);
        }

      } else {
        await db.query(`DELETE FROM lineup WHERE id_partido = ? AND id_jugador = ?`, [id_partido, entry.id_jugador]);
        await db.query(`DELETE FROM desempeno_bateador WHERE id_partido = ? AND id_jugador = ?`, [id_partido, entry.id_jugador]);
        await db.query(`DELETE FROM desempeno_pitcher WHERE id_partido = ? AND id_jugador = ?`, [id_partido, entry.id_jugador]);
      }
    }
    res.json({ ok: true });
  },

  async getResultado(req, res) {
    const [rows] = await db.query('SELECT * FROM resultado WHERE id_partido = ?', [req.params.id])
    res.json(rows[0] || null)
  },

  async guardarResultado(req, res) {
    const chequeo = await chequearBloqueo(req.params.id, 'resultado', req.usuario);
    if (chequeo.error) return res.status(chequeo.status).json({ error: chequeo.error });

    const { carreras_home, carreras_visitantes, hits_home, hits_visitantes, errores_home, errores_visitantes, innings_totales } = req.body;

    if (carreras_home === carreras_visitantes) return res.status(400).json({ error: 'Un partido de béisbol no puede terminar en empate. Revisa las carreras.' });
    if (carreras_home < 0 || carreras_visitantes < 0) return res.status(400).json({ error: 'Las carreras no pueden ser negativas.' });

    await db.query(
      `INSERT INTO resultado (id_partido, carreras_home, carreras_visitantes, hits_home, hits_visitantes, errores_home, errores_visitantes, innings_totales)
       VALUES (?,?,?,?,?,?,?,?)
       ON DUPLICATE KEY UPDATE
         carreras_home=VALUES(carreras_home), carreras_visitantes=VALUES(carreras_visitantes),
         hits_home=VALUES(hits_home), hits_visitantes=VALUES(hits_visitantes),
         errores_home=VALUES(errores_home), errores_visitantes=VALUES(errores_visitantes),
         innings_totales=VALUES(innings_totales)`,
      [req.params.id, carreras_home, carreras_visitantes, hits_home, hits_visitantes, errores_home, errores_visitantes, innings_totales]
    );
    
    await PartidoModel.updateEstado(req.params.id, 'finalizado');

    // AUDITORÍA: Generamos notificación si la modificación fue fuera de tiempo
    if (chequeo.auditar) {
      const idUsuario = req.usuario ? req.usuario.id_usuario : null;
      const nombreUsuario = req.usuario ? req.usuario.nombre : 'Un Anotador';
      await db.query(
        `INSERT INTO notificacion (id_usuario, tipo, titulo, mensaje) VALUES (?, 'admin', 'Edición Extemporánea', ?)`,
        [idUsuario, `El usuario ${nombreUsuario} ha modificado el resultado general del partido #${req.params.id} después del límite de 24 horas.`]
      );
    }

    res.json({ ok: true });
  },

  async getDesempeno(req, res) {
    const [bateadores, pitchers] = await Promise.all([
      DesempenoModel.findBateadorByPartido(req.params.id),
      DesempenoModel.findPitcherByPartido(req.params.id),
    ])
    res.json({ bateadores, pitchers })
  },

  async guardarDesempenoBateador(req, res) {
    const chequeo = await chequearBloqueo(req.params.id, 'estadisticas', req.usuario);
    if (chequeo.error) return res.status(chequeo.status).json({ error: chequeo.error });
    
    await DesempenoModel.upsertBateador({ ...req.body, id_partido: req.params.id })

    // AUDITORÍA
    if (chequeo.auditar) {
      const idUsuario = req.usuario ? req.usuario.id_usuario : null;
      const nombreUsuario = req.usuario ? req.usuario.nombre : 'Un Anotador';
      await db.query(`INSERT INTO notificacion (id_usuario, tipo, titulo, mensaje) VALUES (?, 'admin', 'Edición Extemporánea', ?)`,
        [idUsuario, `El usuario ${nombreUsuario} modificó estadísticas de bateo en el partido #${req.params.id} tras 24h.`]
      );
    }

    res.json({ ok: true })
  },

  async guardarDesempenoPitcher(req, res) {
    const chequeo = await chequearBloqueo(req.params.id, 'estadisticas', req.usuario);
    if (chequeo.error) return res.status(chequeo.status).json({ error: chequeo.error });
    
    await DesempenoModel.upsertPitcher({ ...req.body, id_partido: req.params.id })

    // AUDITORÍA
    if (chequeo.auditar) {
      const idUsuario = req.usuario ? req.usuario.id_usuario : null;
      const nombreUsuario = req.usuario ? req.usuario.nombre : 'Un Anotador';
      await db.query(`INSERT INTO notificacion (id_usuario, tipo, titulo, mensaje) VALUES (?, 'admin', 'Edición Extemporánea', ?)`,
        [idUsuario, `El usuario ${nombreUsuario} modificó estadísticas de pitcheo en el partido #${req.params.id} tras 24h.`]
      );
    }

    res.json({ ok: true })
  },

  async getTaquilla(req, res) {
    const [rows] = await db.query(`SELECT boletos_general, precio_general, boletos_vip, precio_vip, capacidad_estadio FROM partido WHERE id_partido = ?`, [req.params.id])
    if (!rows[0]) return res.status(404).json({ error: 'Partido no encontrado' })
    res.json(rows[0])
  },

  async guardarTaquilla(req, res) {
    const chequeo = await chequearBloqueo(req.params.id, 'taquilla', req.usuario);
    if (chequeo.error) return res.status(chequeo.status).json({ error: chequeo.error });
    
    const { boletos_general, precio_general, boletos_vip, precio_vip, capacidad_estadio } = req.body
    await db.query(
      `UPDATE partido SET boletos_general=?, precio_general=?, boletos_vip=?, precio_vip=?, capacidad_estadio=? WHERE id_partido=?`,
      [boletos_general || 0, precio_general || 0, boletos_vip || 0, precio_vip || 0, capacidad_estadio || 0, req.params.id]
    )

    // AUDITORÍA
    if (chequeo.auditar) {
      const idUsuario = req.usuario ? req.usuario.id_usuario : null;
      const nombreUsuario = req.usuario ? req.usuario.nombre : 'Un usuario';
      await db.query(`INSERT INTO notificacion (id_usuario, tipo, titulo, mensaje) VALUES (?, 'admin', 'Edición Extemporánea', ?)`,
        [idUsuario, `El usuario ${nombreUsuario} modificó la taquilla del partido #${req.params.id} tras 24h.`]
      );
    }

    res.json({ ok: true })
  },
}

module.exports = PartidoController