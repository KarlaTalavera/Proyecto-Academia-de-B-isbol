/**
 * Middleware de control de acceso por rol.
 * Uso: router.get('/ruta', verificarToken, soloRoles('administrador', 'dueno'), handler)
 *
 * Roles disponibles:
 *   administrador — acceso total a finanzas y reportes contables
 *   dueno         — gestión de equipos, jugadores, horarios y resultados
 *   caja          — registro de ingresos/egresos y emisión de recibos
 *   publico       — solo lectura de resultados y estadísticas
 */
function soloRoles(...roles) {
  return (req, res, next) => {
    if (!req.usuario) {
      return res.status(401).json({ error: 'No autenticado' })
    }
    if (!roles.includes(req.usuario.rol)) {
      return res.status(403).json({ error: 'No tienes permiso para esta acción' })
    }
    next()
  }
}

module.exports = { soloRoles }
