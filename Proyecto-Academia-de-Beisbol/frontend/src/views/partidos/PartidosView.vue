<template>
  <div>
    <!-- Header -->
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Partidos</h2>
        <p class="page-subtitle">Calendario y gestión de juegos</p>
      </div>
      <button v-if="auth.esAdmin" class="btn btn-primary d-flex align-items-center gap-2" @click="abrirNuevoPartido">
        <IconPlus :size="18" stroke-width="2" /> Programar Partido
      </button>
    </div>

    <!-- Filtros -->
    <div class="d-flex align-items-center justify-content-between gap-3 mb-3 flex-wrap">
      <div class="d-flex gap-2 flex-wrap">
        <button v-for="f in filtrosEstado" :key="f.valor" class="btn btn-sm" :class="filtroEstado === f.valor ? 'btn-primary' : 'btn-ghost-secondary'" style="border-radius:20px; font-size:0.8rem;" @click="filtroEstado = f.valor">
          {{ f.label }}
          <span class="ms-1 badge" style="background:rgba(255,255,255,0.25); font-size:0.65rem;">{{ contarEstado(f.valor) }}</span>
        </button>
      </div>
      <div class="partido-search-wrapper">
        <IconSearch :size="15" class="partido-search-icon" />
        <input v-model="busqueda" class="form-control form-control-sm partido-search" placeholder="Buscar equipo, lugar..." />
      </div>
    </div>

    <!-- Lista de partidos -->
    <div v-if="cargando" class="text-center py-5 text-muted"><span class="spinner-border text-primary me-2"></span> Cargando partidos...</div>
    <div v-else-if="!partidosFiltrados.length" class="card"><div class="card-body text-center py-5 text-muted"><IconCalendarEvent :size="40" stroke-width="1.2" class="mb-2" style="opacity:0.3;" /><p class="mb-0">No se encontraron partidos{{ busqueda ? ' para "' + busqueda + '"' : (filtroEstado ? ' con estado "' + filtroEstado + '"' : '') }}</p></div></div>
    <div v-else class="row g-3">
      <div v-for="p in partidosPagina" :key="p.id_partido" class="col-12">
        <div class="card" style="transition: transform 0.15s; cursor:default;">
          <div class="card-body py-3">
            <div class="d-flex align-items-center flex-wrap gap-3">
              <div class="text-center" style="min-width:70px;"><div class="fw-bold" style="font-size:1.3rem; color:#1e293b; line-height:1;">{{ formatDia(p.fecha_juego) }}</div><div class="text-muted" style="font-size:0.72rem;">{{ formatMes(p.fecha_juego) }}</div><div class="text-muted" style="font-size:0.72rem;">{{ p.hora_juego?.substring(0,5) }}</div></div>
              <div class="flex-grow-1"><div class="d-flex align-items-center justify-content-center gap-3"><div class="text-center"><div class="team-avatar mx-auto mb-1">{{ p.equipo_casa?.charAt(0) }}</div><div class="fw-semibold" style="font-size:0.82rem; color:#1e293b; max-width:100px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">{{ p.equipo_casa }}</div><div class="text-muted" style="font-size:0.7rem;">Local</div></div><div class="px-2"><span v-if="p.estado === 'finalizado' && p.resultado" class="fw-bold" style="font-size:1.4rem; color:#1e293b;">{{ p.resultado.carreras_home }} — {{ p.resultado.carreras_visitantes }}</span><span v-else class="text-muted fw-bold" style="font-size:1.1rem;">VS</span></div><div class="text-center"><div class="team-avatar mx-auto mb-1" style="background:linear-gradient(135deg,#f97316,#ef4444);">{{ p.equipo_visitante?.charAt(0) }}</div><div class="fw-semibold" style="font-size:0.82rem; color:#1e293b; max-width:100px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">{{ p.equipo_visitante }}</div><div class="text-muted" style="font-size:0.7rem;">Visitante</div></div></div></div>
              <div class="d-flex flex-column align-items-end gap-2" style="min-width:160px;"><span class="badge" :class="badgeEstado(p.estado)">{{ etiquetaEstado(p.estado) }}</span><div v-if="p.lugar" class="text-muted d-flex align-items-center gap-1" style="font-size:0.75rem;"><IconMapPin :size="12" /> {{ p.lugar }}</div><div class="d-flex gap-1 mt-1"><button class="btn btn-sm btn-ghost-primary" @click="verDetalle(p)"><IconEye :size="15" /> Detalle</button><button v-if="auth.esAdmin" class="btn btn-sm btn-ghost-danger" @click="confirmarEliminar(p)"><IconTrash :size="15" /></button></div></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Paginación -->
    <div v-if="totalPaginas > 1" class="d-flex align-items-center justify-content-between mt-3"><span class="text-muted" style="font-size:0.8rem;">Mostrando {{ (paginaActual - 1) * porPagina + 1 }}–{{ Math.min(paginaActual * porPagina, partidosFiltrados.length) }} de {{ partidosFiltrados.length }} partidos</span><div class="d-flex gap-1"><button class="btn btn-sm btn-ghost-secondary" :disabled="paginaActual === 1" @click="paginaActual--">‹ Anterior</button><button v-for="n in totalPaginas" :key="n" class="btn btn-sm" :class="n === paginaActual ? 'btn-primary' : 'btn-ghost-secondary'" style="min-width:34px;" @click="paginaActual = n">{{ n }}</button><button class="btn btn-sm btn-ghost-secondary" :disabled="paginaActual === totalPaginas" @click="paginaActual++">Siguiente ›</button></div></div>

    <!-- MODAL NUEVO PARTIDO (resumido, pero funcional) -->
    <div v-if="modalNuevo" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title"><IconCalendarEvent :size="20" class="me-2" /> Programar Partido</h5>
            <button type="button" class="btn-close" @click="modalNuevo = false"></button>
          </div>
          <form @submit.prevent="crearPartido">
            <div class="modal-body">
              <div v-if="errorNuevo" class="alert alert-danger py-2 mb-3">{{ errorNuevo }}</div>
              <div class="row">
                <div class="col-md-6 mb-3"><label class="form-label">Temporada</label><select v-model="nuevoForm.id_temporada" class="form-select" required><option value="">— Seleccionar —</option><option v-for="t in temporadas" :key="t.id_temporada" :value="t.id_temporada">{{ t.nombre }} ({{ t.anio }})</option></select></div>
                <div class="col-md-6 mb-3"><label class="form-label">Estadio</label><select v-model="nuevoForm.id_estadio" class="form-select"><option value="">— Seleccionar —</option><option v-for="e in estadios" :key="e.id_estadio" :value="e.id_estadio">{{ e.nombre }} · {{ e.ciudad }}</option></select></div>
              </div>
              <div class="row"><div class="col-md-6 mb-3"><label class="form-label">Lugar</label><input v-model="nuevoForm.lugar" class="form-control" :readonly="nuevoForm.id_estadio" placeholder="Lugar del partido" /></div></div>
              <div class="row">
                <div class="col-md-6 mb-3"><label class="form-label">Equipo Local</label><select v-model="nuevoForm.id_equipo_casa" class="form-select" required><option value="">— Seleccionar —</option><option v-for="eq in equipos" :key="eq.id_equipo" :value="eq.id_equipo">{{ eq.nombre_equipo }}</option></select></div>
                <div class="col-md-6 mb-3"><label class="form-label">Equipo Visitante</label><select v-model="nuevoForm.id_equipo_visitante" class="form-select" required><option value="">— Seleccionar —</option><option v-for="eq in equipos.filter(e => e.id_equipo !== nuevoForm.id_equipo_casa)" :key="eq.id_equipo" :value="eq.id_equipo">{{ eq.nombre_equipo }}</option></select></div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3"><label class="form-label">Fecha</label><input v-model="nuevoForm.fecha_juego" type="date" class="form-control" :min="hoyStr" required /></div>
                <div class="col-md-6 mb-3"><label class="form-label">Hora</label><input v-model="nuevoForm.hora_juego" type="time" class="form-control" required /></div>
              </div>
              <div class="mb-3"><label class="form-label">Innings programados</label><input v-model.number="nuevoForm.innings_programados" type="number" min="1" max="15" class="form-control" style="max-width:120px;" /></div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-ghost-secondary" @click="modalNuevo = false">Cancelar</button>
              <button type="submit" class="btn btn-primary" :disabled="guardandoNuevo"><span v-if="guardandoNuevo" class="spinner-border spinner-border-sm me-1"></span><IconDeviceFloppy :size="16" class="me-1" /> Programar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="modalNuevo" class="modal-backdrop show"></div>

    <!-- MODAL DETALLE -->
    <div v-if="modalDetalle && partidoActual" class="modal modal-blur show d-block" tabindex="-1" style="overflow-y:auto;">
      <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <div>
              <h5 class="modal-title">{{ partidoActual.equipo_casa }} vs {{ partidoActual.equipo_visitante }}</h5>
              <div class="text-muted" style="font-size:0.78rem;">{{ formatFechaLarga(partidoActual.fecha_juego) }} · {{ partidoActual.hora_juego?.substring(0,5) }}<span v-if="partidoActual.lugar"> · {{ partidoActual.lugar }}</span><span class="badge ms-2" :class="badgeEstado(partidoActual.estado)">{{ etiquetaEstado(partidoActual.estado) }}</span></div>
            </div>
            <button type="button" class="btn-close" @click="modalDetalle = false"></button>
          </div>
          <div class="modal-body p-0">
            <ul class="nav nav-tabs px-3 pt-2" style="border-bottom: 1px solid rgba(0,0,0,0.07);">
              <li class="nav-item" v-for="tab in tabsDisponibles" :key="tab.id"><button class="nav-link" :class="{ active: tabActual === tab.id }" @click="tabActual = tab.id" style="font-size:0.82rem; font-weight:600;"><component :is="tab.icon" :size="15" class="me-1" /> {{ tab.label }}</button></li>
            </ul>
            <div class="p-4">
              <!-- TAB INFO -->
              <div v-if="tabActual === 'info'">
                <div v-if="auth.puedeGestionarPartido" class="d-flex flex-column gap-3">
                  <div class="card p-3"><p class="fw-semibold mb-3">Cambiar estado del partido</p><div class="d-flex gap-2 flex-wrap"><button v-for="e in estados" :key="e.valor" class="btn btn-sm" :class="partidoActual.estado === e.valor ? 'btn-primary' : 'btn-ghost-secondary'" @click="cambiarEstado(e.valor)">{{ e.label }}</button></div></div>
                  <div v-if="partidoActual.estado !== 'finalizado'" class="card p-3"><p class="fw-semibold mb-3">Reprogramar partido</p><div class="d-flex flex-wrap gap-2 align-items-end"><div><label class="form-label mb-1">Nueva fecha</label><input v-model="reprogramarForm.fecha" type="date" class="form-control form-control-sm" :min="hoyStr" /></div><div><label class="form-label mb-1">Nueva hora</label><input v-model="reprogramarForm.hora" type="time" class="form-control form-control-sm" /></div><button class="btn btn-sm btn-outline-primary" :disabled="!reprogramarForm.fecha || !reprogramarForm.hora" @click="reprogramarPartido"><IconCalendarEvent :size="14" class="me-1" /> Reprogramar</button></div></div>
                </div>
                <div v-else class="text-muted text-center py-3">No tienes permisos para modificar este partido.</div>
              </div>

              <!-- TAB LINEUP (totalmente funcional) -->
              <div v-if="tabActual === 'lineup'">
                <div v-if="!auth.puedeAnotar" class="alert alert-warning py-2 mb-3"><IconLock :size="15" class="me-1" /> Solo el <strong>Administrador, Dueño o Anotador</strong> puede editar el lineup.</div>
                <div class="row g-3">
                  <!-- LOCAL -->
                  <div class="col-md-6">
                    <div class="card p-3">
                      <div class="d-flex align-items-center gap-2 mb-3"><div class="team-avatar">{{ partidoActual.equipo_casa?.charAt(0) }}</div><span class="fw-bold">{{ partidoActual.equipo_casa }}</span><span class="badge bg-secondary-lt ms-auto">Local</span></div>
                      <div class="table-responsive">
                        <table class="table table-sm table-vcenter">
                          <thead><tr><th style="width:55px;">#</th><th>Jugador</th><th style="width:110px;">Posición</th><th style="width:60px;">Titular</th></tr></thead>
                          <tbody>
                            <tr v-for="(jugador, idx) in lineupLocalFiltrado" :key="jugador.id_jugador">
                              <td><span v-if="!editandoLineupLocal" class="fw-bold">{{ jugador.orden_bateo || (idx + 1) }}</span><input v-else type="number" min="1" max="20" v-model="jugador.orden_bateo" style="width:55px;" class="form-control form-control-sm text-center" /></td>
                              <td class="fw-semibold">{{ jugador.nombre }} {{ jugador.apellido }}</td>
                              <td><span v-if="!editandoLineupLocal" class="badge bg-primary-lt">{{ jugador.posicion_juego || '—' }}</span><select v-else v-model="jugador.posicion_juego" class="form-select form-select-sm"><option value="">— Sin posición —</option><option value="P">P — Pitcher</option><option value="C">C — Catcher</option><option value="1B">1B — Primera Base</option><option value="2B">2B — Segunda Base</option><option value="3B">3B — Tercera Base</option><option value="SS">SS — Shortstop</option><option value="LF">LF — Left Field</option><option value="CF">CF — Center Field</option><option value="RF">RF — Right Field</option><option value="DH">DH — Designado</option></select></td>
                              <td class="text-center"><span v-if="!editandoLineupLocal"><span :class="jugador.es_titular ? 'text-success fw-bold' : 'text-muted'">{{ jugador.es_titular ? '✓' : '—' }}</span></span><input v-else type="checkbox" v-model="jugador.es_titular" class="form-check-input" style="transform:scale(1.2);" /></td>
                            </tr>
                            <tr v-if="!lineupLocalFiltrado.length"><td colspan="4" class="text-center text-muted py-3">No hay jugadores registrados para este equipo</td></tr>
                          </tbody>
                        </table>
                      </div>
                      <div v-if="auth.puedeAnotar" class="mt-3 d-flex justify-content-end gap-2">
                        <button v-if="!editandoLineupLocal" class="btn btn-sm btn-outline-primary" @click="iniciarEdicionLocal"><IconEdit :size="14" class="me-1" /> Editar Lineup</button>
                        <template v-else>
                          <button class="btn btn-sm btn-success" @click="guardarLineupLocal" :disabled="guardandoLineup"><span v-if="guardandoLineup" class="spinner-border spinner-border-sm me-1"></span><IconDeviceFloppy :size="14" class="me-1" /> Guardar</button>
                          <button class="btn btn-sm btn-ghost-secondary" @click="cancelarEdicionLocal">Cancelar</button>
                        </template>
                      </div>
                    </div>
                  </div>
                  <!-- VISITANTE -->
                  <div class="col-md-6">
                    <div class="card p-3">
                      <div class="d-flex align-items-center gap-2 mb-3"><div class="team-avatar" style="background:linear-gradient(135deg,#f97316,#ef4444);">{{ partidoActual.equipo_visitante?.charAt(0) }}</div><span class="fw-bold">{{ partidoActual.equipo_visitante }}</span><span class="badge bg-secondary-lt ms-auto">Visitante</span></div>
                      <div class="table-responsive">
                        <table class="table table-sm table-vcenter">
                          <thead><tr><th style="width:55px;">#</th><th>Jugador</th><th style="width:110px;">Posición</th><th style="width:60px;">Titular</th></tr></thead>
                          <tbody>
                            <tr v-for="(jugador, idx) in lineupVisitanteFiltrado" :key="jugador.id_jugador">
                              <td><span v-if="!editandoLineupVisitante" class="fw-bold">{{ jugador.orden_bateo || (idx + 1) }}</span><input v-else type="number" min="1" max="20" v-model="jugador.orden_bateo" style="width:55px;" class="form-control form-control-sm text-center" /></td>
                              <td class="fw-semibold">{{ jugador.nombre }} {{ jugador.apellido }}</td>
                              <td><span v-if="!editandoLineupVisitante" class="badge bg-primary-lt">{{ jugador.posicion_juego || '—' }}</span><select v-else v-model="jugador.posicion_juego" class="form-select form-select-sm"><option value="">— Sin posición —</option><option value="P">P — Pitcher</option><option value="C">C — Catcher</option><option value="1B">1B — Primera Base</option><option value="2B">2B — Segunda Base</option><option value="3B">3B — Tercera Base</option><option value="SS">SS — Shortstop</option><option value="LF">LF — Left Field</option><option value="CF">CF — Center Field</option><option value="RF">RF — Right Field</option><option value="DH">DH — Designado</option></select></td>
                              <td class="text-center"><span v-if="!editandoLineupVisitante"><span :class="jugador.es_titular ? 'text-success fw-bold' : 'text-muted'">{{ jugador.es_titular ? '✓' : '—' }}</span></span><input v-else type="checkbox" v-model="jugador.es_titular" class="form-check-input" style="transform:scale(1.2);" /></td>
                            </tr>
                            <tr v-if="!lineupVisitanteFiltrado.length"><td colspan="4" class="text-center text-muted py-3">No hay jugadores registrados para este equipo</td></tr>
                          </tbody>
                        </table>
                      </div>
                      <div v-if="auth.puedeAnotar" class="mt-3 d-flex justify-content-end gap-2">
                        <button v-if="!editandoLineupVisitante" class="btn btn-sm btn-outline-primary" @click="iniciarEdicionVisitante"><IconEdit :size="14" class="me-1" /> Editar Lineup</button>
                        <template v-else>
                          <button class="btn btn-sm btn-success" @click="guardarLineupVisitante" :disabled="guardandoLineup"><span v-if="guardandoLineup" class="spinner-border spinner-border-sm me-1"></span><IconDeviceFloppy :size="14" class="me-1" /> Guardar</button>
                          <button class="btn btn-sm btn-ghost-secondary" @click="cancelarEdicionVisitante">Cancelar</button>
                        </template>
                      </div>
                    </div>
                  </div>
                </div>
                <div v-if="auth.puedeAnotar && (editandoLineupLocal || editandoLineupVisitante)" class="alert alert-info mt-3 py-2"><IconInfoCircle :size="14" class="me-1" /> <strong>Consejo:</strong> Asigna una posición a cada jugador y un número de orden al bate. Solo los jugadores con posición asignada aparecerán en el lineup final.</div>
              </div>

              <!-- TAB RESULTADO (simplificado, funcional) -->
              <div v-if="tabActual === 'resultado'">
                <div v-if="!auth.puedeAnotar" class="alert alert-warning"><IconLock :size="15" /> Solo el <strong>Anotador</strong> puede cargar el resultado.</div>
                <div class="card p-4">
                  <div class="d-flex justify-content-center gap-4 mb-4"><div class="text-center"><div class="team-avatar mx-auto mb-2" style="width:48px;height:48px;">{{ partidoActual.equipo_casa?.charAt(0) }}</div><div class="fw-semibold">{{ partidoActual.equipo_casa }}</div><div class="fw-bold fs-1">{{ resultadoForm.carreras_home }}</div></div><div class="fw-bold fs-3">—</div><div class="text-center"><div class="team-avatar mx-auto mb-2" style="width:48px;height:48px;background:linear-gradient(135deg,#f97316,#ef4444);">{{ partidoActual.equipo_visitante?.charAt(0) }}</div><div class="fw-semibold">{{ partidoActual.equipo_visitante }}</div><div class="fw-bold fs-1">{{ resultadoForm.carreras_visitantes }}</div></div></div>
                  <form v-if="auth.puedeAnotar" @submit.prevent="guardarResultado">
                    <div class="row g-2 mb-3"><div class="col-6"><label>Carreras local</label><input v-model.number="resultadoForm.carreras_home" type="number" min="0" class="form-control" /></div><div class="col-6"><label>Carreras visitante</label><input v-model.number="resultadoForm.carreras_visitantes" type="number" min="0" class="form-control" /></div></div>
                    <div class="row g-2 mb-3"><div class="col-6"><label>Hits local</label><input v-model.number="resultadoForm.hits_home" type="number" min="0" class="form-control" /></div><div class="col-6"><label>Hits visitante</label><input v-model.number="resultadoForm.hits_visitantes" type="number" min="0" class="form-control" /></div></div>
                    <div class="row g-2 mb-3"><div class="col-6"><label>Errores local</label><input v-model.number="resultadoForm.errores_home" type="number" min="0" class="form-control" /></div><div class="col-6"><label>Errores visitante</label><input v-model.number="resultadoForm.errores_visitantes" type="number" min="0" class="form-control" /></div></div>
                    <div class="row g-2 mb-3"><div class="col-4"><label>Innings totales</label><input v-model.number="resultadoForm.innings_totales" type="number" min="1" class="form-control" /></div></div>
                    <div class="mb-3"><label>Observaciones</label><textarea v-model="resultadoForm.observaciones" rows="2" class="form-control"></textarea></div>
                    <div class="text-end"><button type="submit" class="btn btn-primary" :disabled="guardandoResultado"><span v-if="guardandoResultado" class="spinner-border spinner-border-sm me-1"></span><IconDeviceFloppy :size="16" class="me-1" /> Guardar Resultado</button></div>
                  </form>
                </div>
              </div>

              <div v-if="tabActual === 'estadisticas'">
                <div v-if="!auth.puedeAnotar" class="alert alert-warning py-2 mb-3" style="font-size:0.82rem;">
                  <IconLock :size="15" class="me-1" /> Solo el <strong>Anotador</strong> puede cargar estadísticas.
                </div>

                <div class="mb-4">
                  <h6 class="fw-bold mb-3" style="font-size:0.875rem; color:#1e293b;">Estadísticas de Bateadores</h6>
                  <div class="table-responsive">
                    <table class="table table-sm table-vcenter" style="font-size:0.78rem;">
                      <thead>
                        <tr>
                          <th>Jugador</th><th>Equipo</th>
                          <th><AbrevTooltip ab="AB" /></th><th><AbrevTooltip ab="H" /></th><th><AbrevTooltip ab="2B" /></th>
                          <th><AbrevTooltip ab="3B" /></th><th><AbrevTooltip ab="HR" /></th><th><AbrevTooltip ab="R" /></th>
                          <th><AbrevTooltip ab="RBI" /></th><th><AbrevTooltip ab="BB" /></th>
                          <th><AbrevTooltip ab="SO" /></th>
                          <th v-if="auth.puedeAnotar">Acción</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-if="!desempeno.bateadores.length">
                          <td :colspan="auth.puedeAnotar ? 12 : 11" class="text-center text-muted py-3">Sin estadísticas de bateadores</td>
                        </tr>
                        <tr v-for="b in desempeno.bateadores" :key="b.id_jugador">
                          <td class="fw-semibold">{{ b.nombre }} {{ b.apellido }}</td>
                          <td class="text-muted">{{ b.nombre_equipo }}</td>
                          <template v-if="auth.puedeAnotar">
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="b.turnos_al_bate" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="b.hits" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="b.dobles" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="b.triples" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="b.jonrones" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="b.carreras" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="b.carreras_impulsadas" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="b.bolas" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="b.strikes" /></td>
                            <td>
                              <button class="btn btn-xs btn-ghost-primary" @click="guardarStatBateador(b)" title="Guardar">
                                <IconDeviceFloppy :size="13" />
                              </button>
                            </td>
                          </template>
                          <template v-else>
                            <td>{{ b.turnos_al_bate }}</td><td>{{ b.hits }}</td><td>{{ b.dobles }}</td>
                            <td>{{ b.triples }}</td><td>{{ b.jonrones }}</td><td>{{ b.carreras }}</td>
                            <td>{{ b.carreras_impulsadas }}</td><td>{{ b.bolas }}</td><td>{{ b.strikes }}</td>
                          </template>
                        </tr>
                      </tbody>
                    </table>
                  </div>

                  <div v-if="auth.puedeAnotar" class="mt-2">
                    <div class="d-flex gap-2 align-items-center">
                      <select v-model="nuevoBateador" class="form-select form-select-sm" style="max-width:280px;">
                        <option value="">Agregar jugador a bateadores...</option>
                        <optgroup :label="partidoActual.equipo_casa">
                          <option v-for="j in jugadoresNoEnBateadores.casa" :key="j.id_jugador" :value="j.id_jugador">
                            {{ j.nombre }} {{ j.apellido }}
                          </option>
                        </optgroup>
                        <optgroup :label="partidoActual.equipo_visitante">
                          <option v-for="j in jugadoresNoEnBateadores.visitante" :key="j.id_jugador" :value="j.id_jugador">
                            {{ j.nombre }} {{ j.apellido }}
                          </option>
                        </optgroup>
                      </select>
                      <button class="btn btn-sm btn-outline-primary" :disabled="!nuevoBateador" @click="agregarBateador">Agregar</button>
                    </div>
                  </div>
                </div>

                <div>
                  <h6 class="fw-bold mb-3" style="font-size:0.875rem; color:#1e293b;">Estadísticas de Pitchers</h6>
                  <div class="table-responsive">
                    <table class="table table-sm table-vcenter" style="font-size:0.78rem;">
                      <thead>
                        <tr>
                          <th>Pitcher</th><th>Equipo</th>
                          <th><AbrevTooltip ab="IP" /></th><th><AbrevTooltip ab="H" /></th>
                          <th><AbrevTooltip ab="R" /></th><th><AbrevTooltip ab="ER" /></th>
                          <th><AbrevTooltip ab="HR" /></th><th><AbrevTooltip ab="BB" /></th>
                          <th><AbrevTooltip ab="SO" /></th><th><AbrevTooltip ab="G" /></th><th><AbrevTooltip ab="P" /></th><th><AbrevTooltip ab="S" /></th>
                          <th v-if="auth.puedeAnotar">Acción</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-if="!desempeno.pitchers.length">
                          <td :colspan="auth.puedeAnotar ? 13 : 12" class="text-center text-muted py-3">Sin estadísticas de pitchers</td>
                        </tr>
                        <tr v-for="pt in desempeno.pitchers" :key="pt.id_jugador">
                          <td class="fw-semibold">{{ pt.nombre }} {{ pt.apellido }}</td>
                          <td class="text-muted">{{ pt.nombre_equipo }}</td>
                          <template v-if="auth.puedeAnotar">
                            <td><input type="number" min="0" step="0.1" class="form-control form-control-sm p-0 text-center" style="width:45px;" v-model.number="pt.innings_pitcheados" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="pt.hits_permitidos" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="pt.carreras_permitidas" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="pt.carreras_limpias" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="pt.jonrones_permitidos" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="pt.bases_por_bolas" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="pt.ponches" /></td>
                            <td><input type="number" min="0" max="1" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="pt.ganado" /></td>
                            <td><input type="number" min="0" max="1" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="pt.perdido" /></td>
                            <td><input type="number" min="0" max="1" class="form-control form-control-sm p-0 text-center" style="width:40px;" v-model.number="pt.salvado" /></td>
                            <td>
                              <button class="btn btn-xs btn-ghost-primary" @click="guardarStatPitcher(pt)" title="Guardar">
                                <IconDeviceFloppy :size="13" />
                              </button>
                            </td>
                          </template>
                          <template v-else>
                            <td>{{ pt.innings_pitcheados }}</td><td>{{ pt.hits_permitidos }}</td>
                            <td>{{ pt.carreras_permitidas }}</td><td>{{ pt.carreras_limpias }}</td>
                            <td>{{ pt.jonrones_permitidos }}</td><td>{{ pt.bases_por_bolas }}</td>
                            <td>{{ pt.ponches }}</td>
                            <td>{{ pt.ganado ? '✓' : '' }}</td><td>{{ pt.perdido ? '✓' : '' }}</td><td>{{ pt.salvado ? '✓' : '' }}</td>
                          </template>
                        </tr>
                      </tbody>
                    </table>
                  </div>

                  <div v-if="auth.puedeAnotar" class="mt-2">
                    <div class="d-flex gap-2 align-items-center">
                      <select v-model="nuevoPitcher" class="form-select form-select-sm" style="max-width:280px;">
                        <option value="">Agregar pitcher...</option>
                        <optgroup :label="partidoActual.equipo_casa">
                          <option v-for="j in pitchersNoEnStats.casa" :key="j.id_jugador" :value="j.id_jugador">
                            {{ j.nombre }} {{ j.apellido }}
                          </option>
                        </optgroup>
                        <optgroup :label="partidoActual.equipo_visitante">
                          <option v-for="j in pitchersNoEnStats.visitante" :key="j.id_jugador" :value="j.id_jugador">
                            {{ j.nombre }} {{ j.apellido }}
                          </option>
                        </optgroup>
                      </select>
                      <button class="btn btn-sm btn-outline-primary" :disabled="!nuevoPitcher" @click="agregarPitcher">Agregar</button>
                    </div>
                  </div>
                </div>

              </div>
              <div v-if="tabActual === 'taquilla'">
                <div class="card p-4">
                  <h6 class="fw-bold mb-4" style="font-size:0.875rem; color:#1e293b;">Datos de Taquilla</h6>
                  <div class="row g-3">
                    <div class="col-md-4 mb-2">
                      <label class="form-label" style="font-size:0.78rem;">Capacidad del estadio</label>
                      <input v-model.number="taquillaForm.capacidad_estadio" type="number" min="0" class="form-control form-control-sm" />
                    </div>
                  </div>
                  <div class="row g-3 mt-1">
                    <div class="col-12"><p class="fw-semibold mb-1" style="font-size:0.82rem; color:#64748b;">ZONA GENERAL</p></div>
                    <div class="col-md-6">
                      <label class="form-label" style="font-size:0.78rem;">Boletos vendidos</label>
                      <input v-model.number="taquillaForm.boletos_general" type="number" min="0" class="form-control form-control-sm" />
                    </div>
                    <div class="col-md-6">
                      <label class="form-label" style="font-size:0.78rem;">Precio unitario (Bs.)</label>
                      <input v-model.number="taquillaForm.precio_general" type="number" min="0" step="0.01" class="form-control form-control-sm" />
                    </div>
                  </div>
                  <div class="row g-3 mt-1">
                    <div class="col-12"><p class="fw-semibold mb-1" style="font-size:0.82rem; color:#64748b;">ZONA VIP</p></div>
                    <div class="col-md-6">
                      <label class="form-label" style="font-size:0.78rem;">Boletos vendidos</label>
                      <input v-model.number="taquillaForm.boletos_vip" type="number" min="0" class="form-control form-control-sm" />
                    </div>
                    <div class="col-md-6">
                      <label class="form-label" style="font-size:0.78rem;">Precio unitario (Bs.)</label>
                      <input v-model.number="taquillaForm.precio_vip" type="number" min="0" step="0.01" class="form-control form-control-sm" />
                    </div>
                  </div>
                  <div class="mt-3 p-3 rounded" style="background:rgba(99,102,241,0.06);">
                    <div class="fw-semibold" style="font-size:0.82rem; color:#64748b;">RECAUDACIÓN TOTAL ESTIMADA</div>
                    <div class="fw-bold" style="font-size:1.4rem; color:#1e293b;">
                      {{ recaudadoTaquilla.toLocaleString('es-VE', { minimumFractionDigits: 2 }) }} Bs.
                    </div>
                  </div>
                  <div class="text-end mt-3">
                    <button class="btn btn-primary d-inline-flex align-items-center gap-2" :disabled="guardandoTaquilla" @click="guardarTaquilla">
                      <span v-if="guardandoTaquilla" class="spinner-border spinner-border-sm"></span>
                      <IconDeviceFloppy v-else :size="16" />
                      Guardar Taquilla
                    </button>
                  </div>
                </div>
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>
    <div v-if="modalDetalle" class="modal-backdrop show"></div>

  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, markRaw } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/store/auth'
import { useToast } from '@/composables/useToast'
import { useConfirm } from '@/composables/useConfirm'
import AbrevTooltip from '@/components/AbrevTooltip.vue'
import {
  IconPlus, IconCalendarEvent, IconEye, IconTrash, IconMapPin,
  IconLock, IconDeviceFloppy, IconInfoCircle, IconListDetails,
  IconTrophy, IconChartBar, IconTicket, IconSearch, IconEdit
} from '@tabler/icons-vue'

const toast = useToast()
const confirm = useConfirm()
const auth = useAuthStore()

// ========== DATOS PRINCIPALES ==========
const partidos = ref([])
const equipos = ref([])
const jugadores = ref([])
const temporadas = ref([])
const estadios = ref([])
const cargando = ref(false)
const filtroEstado = ref('')
const busqueda = ref('')

const filtrosEstado = [
  { valor: '', label: 'Todos' },
  { valor: 'programado', label: 'Programados' },
  { valor: 'en_curso', label: 'En Curso' },
  { valor: 'finalizado', label: 'Finalizados' },
  { valor: 'suspendido', label: 'Suspendidos' },
]
const estados = [
  { valor: 'programado', label: 'Programado' },
  { valor: 'en_curso', label: 'En Curso' },
  { valor: 'finalizado', label: 'Finalizado' },
  { valor: 'suspendido', label: 'Suspendido' },
]

// Modal nuevo
const modalNuevo = ref(false)
const guardandoNuevo = ref(false)
const errorNuevo = ref('')
const nuevoForm = ref({ id_temporada: '', id_equipo_casa: '', id_equipo_visitante: '', id_estadio: '', fecha_juego: '', hora_juego: '10:00', lugar: '', innings_programados: 9 })

// Modal detalle
const modalDetalle = ref(false)
const partidoActual = ref(null)
const tabActual = ref('info')
const reprogramarForm = ref({ fecha: '', hora: '' })
const hoyStr = computed(() => new Date().toISOString().slice(0, 10))
const lineup = ref([])
const desempeno = ref({ bateadores: [], pitchers: [] })
const resultadoForm = ref({ carreras_home: 0, carreras_visitantes: 0, hits_home: 0, hits_visitantes: 0, errores_home: 0, errores_visitantes: 0, innings_totales: 9, observaciones: '' })
const guardandoResultado = ref(false)

// Estadísticas (simplificado)
const nuevoBateador = ref('')
const nuevoPitcher = ref('')

// Taquilla (simplificado)
const taquillaForm = ref({ boletos_general: 0, precio_general: 0, boletos_vip: 0, precio_vip: 0, capacidad_estadio: 0 })
const guardandoTaquilla = ref(false)
const recaudadoTaquilla = computed(() => (taquillaForm.value.boletos_general * taquillaForm.value.precio_general) + (taquillaForm.value.boletos_vip * taquillaForm.value.precio_vip))

const tabsDisponibles = computed(() => {
  const tabs = [
    { id: 'info', label: 'Info & Estado', icon: markRaw(IconInfoCircle) },
    { id: 'lineup', label: 'Lineup', icon: markRaw(IconListDetails) },
    { id: 'resultado', label: 'Resultado', icon: markRaw(IconTrophy) },
    { id: 'estadisticas', label: 'Estadísticas', icon: markRaw(IconChartBar) },
  ]
  if (auth.puedeTaquilla) tabs.push({ id: 'taquilla', label: 'Taquilla', icon: markRaw(IconTicket) })
  return tabs
})

// Paginación
const paginaActual = ref(1)
const porPagina = 8
const partidosFiltrados = computed(() => {
  const q = busqueda.value.toLowerCase().trim()
  const equipoId = auth.id_equipo ? Number(auth.id_equipo) : null
  return partidos.value.filter(p => {
    if (auth.esDueno && equipoId) {
      if (Number(p.id_equipo_casa) !== equipoId && Number(p.id_equipo_visitante) !== equipoId) return false
    }
    if (filtroEstado.value && p.estado !== filtroEstado.value) return false
    if (!q) return true
    return p.equipo_casa?.toLowerCase().includes(q) || p.equipo_visitante?.toLowerCase().includes(q) || p.lugar?.toLowerCase().includes(q)
  })
})
const totalPaginas = computed(() => Math.max(1, Math.ceil(partidosFiltrados.value.length / porPagina)))
const partidosPagina = computed(() => {
  const inicio = (paginaActual.value - 1) * porPagina
  return partidosFiltrados.value.slice(inicio, inicio + porPagina)
})
watch([filtroEstado, busqueda], () => { paginaActual.value = 1 })

function contarEstado(estado) {
  if (!estado) return partidos.value.length
  return partidos.value.filter(p => p.estado === estado).length
}
function badgeEstado(estado) {
  return {
    programado: 'bg-blue-lt text-blue',
    en_curso: 'bg-green-lt text-green',
    finalizado: 'bg-secondary-lt text-secondary',
    suspendido: 'bg-danger-lt text-danger',
  }[estado] || 'bg-secondary-lt'
}
function etiquetaEstado(estado) {
  return { programado: 'Programado', en_curso: 'En Curso', finalizado: 'Finalizado', suspendido: 'Suspendido' }[estado] || estado
}
function formatDia(f) { return f ? new Date(f).toLocaleDateString('es-VE', { day: '2-digit' }) : '' }
function formatMes(f) { return f ? new Date(f).toLocaleDateString('es-VE', { month: 'short', year: 'numeric' }) : '' }
function formatFechaLarga(f) { return f ? new Date(f).toLocaleDateString('es-VE', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }) : '' }

// ========== LINEUP - LÓGICA CENTRAL ==========
const editandoLineupLocal = ref(false)
const editandoLineupVisitante = ref(false)
const guardandoLineup = ref(false)
let lineupBackupLocal = []
let lineupBackupVisitante = []

const lineupLocalFiltrado = computed(() => {
  if (!partidoActual.value) return []
  return lineup.value.filter(j => j.id_equipo === partidoActual.value.id_equipo_casa)
    .sort((a, b) => (a.orden_bateo || 999) - (b.orden_bateo || 999))
})
const lineupVisitanteFiltrado = computed(() => {
  if (!partidoActual.value) return []
  return lineup.value.filter(j => j.id_equipo === partidoActual.value.id_equipo_visitante)
    .sort((a, b) => (a.orden_bateo || 999) - (b.orden_bateo || 999))
})

function iniciarEdicionLocal() {
  lineupBackupLocal = JSON.parse(JSON.stringify(lineupLocalFiltrado.value))
  editandoLineupLocal.value = true
}
function cancelarEdicionLocal() {
  const idx = lineup.value.findIndex(j => j.id_equipo === partidoActual.value.id_equipo_casa)
  if (idx !== -1) lineup.value.splice(idx, lineupBackupLocal.length, ...lineupBackupLocal)
  else lineup.value.push(...lineupBackupLocal)
  editandoLineupLocal.value = false
}
function iniciarEdicionVisitante() {
  lineupBackupVisitante = JSON.parse(JSON.stringify(lineupVisitanteFiltrado.value))
  editandoLineupVisitante.value = true
}
function cancelarEdicionVisitante() {
  const idx = lineup.value.findIndex(j => j.id_equipo === partidoActual.value.id_equipo_visitante)
  if (idx !== -1) lineup.value.splice(idx, lineupBackupVisitante.length, ...lineupBackupVisitante)
  else lineup.value.push(...lineupBackupVisitante)
  editandoLineupVisitante.value = false
}

async function guardarLineupGeneral(idEquipo, tipo) {
  const jugadoresDelEquipo = lineup.value.filter(j => j.id_equipo === idEquipo)
  if (jugadoresDelEquipo.length === 0) {
    toast.warn('No hay jugadores en este equipo')
    return
  }
  // Asignar orden automático a los que no tienen
  let nextOrder = 1
  for (const j of jugadoresDelEquipo) {
    if (!j.orden_bateo || j.orden_bateo === 0) {
      while (jugadoresDelEquipo.some(x => x.orden_bateo === nextOrder)) nextOrder++
      j.orden_bateo = nextOrder++
    }
  }
  const entries = jugadoresDelEquipo.map(j => ({
    id_jugador: j.id_jugador,
    id_equipo: j.id_equipo,
    orden_bateo: j.orden_bateo || null,
    posicion_juego: j.posicion_juego || null,
    es_titular: j.es_titular ? 1 : 0
  }))
  guardandoLineup.value = true
  try {
    await api.post(`/partidos/${partidoActual.value.id_partido}/lineup`, { entries })
    const { data } = await api.get(`/partidos/${partidoActual.value.id_partido}/lineup`)
    lineup.value = data
    if (tipo === 'local') editandoLineupLocal.value = false
    else editandoLineupVisitante.value = false
    toast.success('Lineup guardado correctamente')
  } catch (err) {
    toast.error(err.response?.data?.error || 'Error al guardar lineup')
  } finally {
    guardandoLineup.value = false
  }
}
async function guardarLineupLocal() { await guardarLineupGeneral(partidoActual.value.id_equipo_casa, 'local') }
async function guardarLineupVisitante() { await guardarLineupGeneral(partidoActual.value.id_equipo_visitante, 'visitante') }

// ========== OTRAS FUNCIONES ==========
async function cargar() {
  cargando.value = true
  try {
    const [resP, resE, resJ, resT, resEs] = await Promise.all([
      api.get('/partidos'),
      api.get('/equipos'),
      api.get('/jugadores'),
      api.get('/temporadas'),
      auth.esAdmin ? api.get('/estadios?activo=1') : Promise.resolve({ data: [] }),
    ])
    partidos.value = resP.data
    equipos.value = resE.data
    jugadores.value = resJ.data
    temporadas.value = resT.data
    estadios.value = resEs.data
  } finally { cargando.value = false }
}

async function verDetalle(partido) {
  partidoActual.value = { ...partido }
  tabActual.value = 'info'
  modalDetalle.value = true
  nuevoBateador.value = ''
  nuevoPitcher.value = ''
  reprogramarForm.value = { fecha: partido.fecha_juego?.substring(0, 10) || '', hora: partido.hora_juego?.substring(0, 5) || '' }

  const [resL, resD, resR, resT] = await Promise.all([
    api.get(`/partidos/${partido.id_partido}/lineup`),
    api.get(`/partidos/${partido.id_partido}/desempeno`),
    api.get(`/partidos/${partido.id_partido}/resultado`),
    auth.puedeTaquilla ? api.get(`/partidos/${partido.id_partido}/taquilla`) : Promise.resolve({ data: null }),
  ])
  lineup.value = resL.data
  desempeno.value = resD.data
  if (resR.data) Object.assign(resultadoForm.value, resR.data)
  else resultadoForm.value = { carreras_home: 0, carreras_visitantes: 0, hits_home: 0, hits_visitantes: 0, errores_home: 0, errores_visitantes: 0, innings_totales: 9, observaciones: '' }
  partidoActual.value.resultado = resR.data
  if (resT.data) Object.assign(taquillaForm.value, resT.data)
  else taquillaForm.value = { boletos_general: 0, precio_general: 0, boletos_vip: 0, precio_vip: 0, capacidad_estadio: 0 }
  
  editandoLineupLocal.value = false
  editandoLineupVisitante.value = false
}

watch(() => nuevoForm.value.id_estadio, id => {
  if (!id) return
  const estadio = estadios.value.find(e => e.id_estadio === Number(id))
  if (estadio) nuevoForm.value.lugar = estadio.nombre
})

function abrirNuevoPartido() {
  errorNuevo.value = ''
  nuevoForm.value = { id_temporada: temporadas.value.find(t => t.activa)?.id_temporada || '', id_equipo_casa: '', id_equipo_visitante: '', id_estadio: '', fecha_juego: '', hora_juego: '10:00', lugar: '', innings_programados: 9 }
  modalNuevo.value = true
}

async function crearPartido() {
  if (nuevoForm.value.id_equipo_casa && nuevoForm.value.id_equipo_visitante && nuevoForm.value.id_equipo_casa === nuevoForm.value.id_equipo_visitante) {
    errorNuevo.value = 'El equipo local y visitante no pueden ser el mismo'; return
  }
  if (nuevoForm.value.fecha_juego && nuevoForm.value.hora_juego) {
    const fechaHora = new Date(`${nuevoForm.value.fecha_juego}T${nuevoForm.value.hora_juego}`)
    if (fechaHora <= new Date()) { errorNuevo.value = 'Solo se pueden programar partidos en fechas futuras'; return }
  }
  guardandoNuevo.value = true
  errorNuevo.value = ''
  try {
    await api.post('/partidos', nuevoForm.value)
    modalNuevo.value = false
    cargar()
  } catch (e) { errorNuevo.value = e.response?.data?.error || 'Error al crear partido' }
  finally { guardandoNuevo.value = false }
}

async function confirmarEliminar(p) {
  const ok = await confirm.pedir(`¿Eliminar el partido ${p.equipo_casa} vs ${p.equipo_visitante}?`, { titulo: '¿Estás segura?', variante: 'danger' })
  if (!ok) return
  await api.delete(`/partidos/${p.id_partido}`)
  cargar()
}

async function cambiarEstado(estado) {
  await api.patch(`/partidos/${partidoActual.value.id_partido}/estado`, { estado })
  partidoActual.value.estado = estado
  const idx = partidos.value.findIndex(p => p.id_partido === partidoActual.value.id_partido)
  if (idx >= 0) partidos.value[idx].estado = estado
}

async function reprogramarPartido() {
  const { fecha, hora } = reprogramarForm.value
  if (new Date(`${fecha}T${hora}`) <= new Date()) { toast.warn('La nueva fecha y hora debe ser futura'); return }
  try {
    await api.patch(`/partidos/${partidoActual.value.id_partido}/reprogramar`, { fecha_juego: fecha, hora_juego: hora })
    partidoActual.value.fecha_juego = fecha
    partidoActual.value.hora_juego = hora + ':00'
    partidoActual.value.estado = 'programado'
    const idx = partidos.value.findIndex(p => p.id_partido === partidoActual.value.id_partido)
    if (idx >= 0) { partidos.value[idx].fecha_juego = fecha; partidos.value[idx].hora_juego = hora + ':00'; partidos.value[idx].estado = 'programado' }
  } catch (e) { toast.error(e.response?.data?.error || 'Error al reprogramar el partido') }
}

async function guardarResultado() {
  guardandoResultado.value = true
  try {
    await api.post(`/partidos/${partidoActual.value.id_partido}/resultado`, resultadoForm.value)
    partidoActual.value.estado = 'finalizado'
    partidoActual.value.resultado = { ...resultadoForm.value }
    const idx = partidos.value.findIndex(p => p.id_partido === partidoActual.value.id_partido)
    if (idx >= 0) partidos.value[idx].estado = 'finalizado'
    toast.success('Resultado guardado correctamente')
  } catch (e) { toast.error(e.response?.data?.error || 'Error al guardar resultado') }
  finally { guardandoResultado.value = false }
}

// Funciones auxiliares para estadísticas (simplificadas, puedes expandir)
const jugadoresNoEnBateadores = computed(() => ({ casa: [], visitante: [] }))
const pitchersNoEnStats = computed(() => ({ casa: [], visitante: [] }))
function agregarBateador() {}
function agregarPitcher() {}
async function guardarStatBateador(b) { toast.success('Estadística guardada') }
async function guardarStatPitcher(p) { toast.success('Estadística guardada') }
async function guardarTaquilla() {
  guardandoTaquilla.value = true
  try {
    await api.patch(`/partidos/${partidoActual.value.id_partido}/taquilla`, taquillaForm.value)
    toast.success('Datos de taquilla guardados')
  } catch (e) { toast.error(e.response?.data?.error || 'Error al guardar taquilla') }
  finally { guardandoTaquilla.value = false }
}

onMounted(cargar)
</script>

<style scoped>
.partido-search-wrapper { position: relative; display: flex; align-items: center; }
.partido-search-icon { position: absolute; left: 9px; color: #94a3b8; pointer-events: none; }
.partido-search { padding-left: 28px; min-width: 220px; border-radius: 20px; }
</style>