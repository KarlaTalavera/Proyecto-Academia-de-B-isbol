const m = require('../models/estadisticas.model');

// ─── PARTIDO — box score completo ─────────────────────────────────────────────

/** GET /api/estadisticas/partido/:id/bateadores */
exports.bateadoresPorPartido = async (req, res) => {
  try {
    res.json(await m.getBateadoresPorPartido(req.params.id));
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al obtener bateadores del partido' });
  }
};

/** GET /api/estadisticas/partido/:id/pitchers */
exports.pitcheresPorPartido = async (req, res) => {
  try {
    res.json(await m.getPitcheresPorPartido(req.params.id));
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al obtener pitchers del partido' });
  }
};

// ─── BATEADOR individual ───────────────────────────────────────────────────────

/** GET /api/estadisticas/jugador/:id/bateador/partidos */
exports.bateadorPartidos = async (req, res) => {
  try {
    res.json(await m.getBateadorPartidos(req.params.id));
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al obtener partidos del bateador' });
  }
};

/** GET /api/estadisticas/jugador/:id/bateador/temporadas */
exports.bateadorTemporadas = async (req, res) => {
  try {
    res.json(await m.getBateadorPorTemporada(req.params.id));
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al obtener temporadas del bateador' });
  }
};

/** GET /api/estadisticas/jugador/:id/bateador/fechas?inicio=YYYY-MM-DD&fin=YYYY-MM-DD */
exports.bateadorFechas = async (req, res) => {
  const { inicio, fin } = req.query;
  if (!inicio || !fin)
    return res.status(400).json({ error: 'Parámetros inicio y fin requeridos (YYYY-MM-DD)' });
  try {
    res.json(await m.getBateadorPorFecha(req.params.id, inicio, fin));
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al filtrar bateador por fechas' });
  }
};

// ─── PITCHER individual ────────────────────────────────────────────────────────

/** GET /api/estadisticas/jugador/:id/pitcher/partidos */
exports.pitcherPartidos = async (req, res) => {
  try {
    res.json(await m.getPitcherPartidos(req.params.id));
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al obtener partidos del pitcher' });
  }
};

/** GET /api/estadisticas/jugador/:id/pitcher/temporadas */
exports.pitcherTemporadas = async (req, res) => {
  try {
    res.json(await m.getPitcherPorTemporada(req.params.id));
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al obtener temporadas del pitcher' });
  }
};

/** GET /api/estadisticas/jugador/:id/pitcher/fechas?inicio=YYYY-MM-DD&fin=YYYY-MM-DD */
exports.pitcherFechas = async (req, res) => {
  const { inicio, fin } = req.query;
  if (!inicio || !fin)
    return res.status(400).json({ error: 'Parámetros inicio y fin requeridos (YYYY-MM-DD)' });
  try {
    res.json(await m.getPitcherPorFecha(req.params.id, inicio, fin));
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al filtrar pitcher por fechas' });
  }
};
