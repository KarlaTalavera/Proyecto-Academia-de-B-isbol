<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Partidos</h2>
        <p class="page-subtitle">Calendario y gestión de juegos</p>
      </div>
      <button v-if="auth.puedeEditar" class="btn btn-primary d-flex align-items-center gap-2" @click="abrirNuevoPartido">
        <IconPlus :size="18" stroke-width="2" /> Programar Partido
      </button>
    </div>

    <!-- Filtros de estado -->
    <div class="d-flex gap-2 mb-3 flex-wrap">
      <button
        v-for="f in filtrosEstado" :key="f.valor"
        class="btn btn-sm"
        :class="filtroEstado === f.valor ? 'btn-primary' : 'btn-ghost-secondary'"
        style="border-radius:20px; font-size:0.8rem;"
        @click="filtroEstado = f.valor"
      >
        {{ f.label }}
        <span class="ms-1 badge" style="background:rgba(255,255,255,0.25); font-size:0.65rem;">
          {{ contarEstado(f.valor) }}
        </span>
      </button>
    </div>

    <!-- Lista de partidos -->
    <div v-if="cargando" class="text-center py-5 text-muted">
      <span class="spinner-border text-primary me-2"></span> Cargando partidos...
    </div>

    <div v-else-if="!partidosFiltrados.length" class="card">
      <div class="card-body text-center py-5 text-muted">
        <IconCalendarEvent :size="40" stroke-width="1.2" class="mb-2" style="opacity:0.3;" />
        <p class="mb-0">No hay partidos{{ filtroEstado ? ' con estado "' + filtroEstado + '"' : '' }}</p>
      </div>
    </div>

    <div v-else class="row g-3">
      <div v-for="p in partidosFiltrados" :key="p.id_partido" class="col-12">
        <div class="card" style="transition: transform 0.15s; cursor:default;">
          <div class="card-body py-3">
            <div class="d-flex align-items-center flex-wrap gap-3">

              <!-- Fecha/Hora -->
              <div class="text-center" style="min-width:70px;">
                <div class="fw-bold" style="font-size:1.3rem; color:#1e293b; line-height:1;">
                  {{ formatDia(p.fecha_juego) }}
                </div>
                <div class="text-muted" style="font-size:0.72rem;">{{ formatMes(p.fecha_juego) }}</div>
                <div class="text-muted" style="font-size:0.72rem;">{{ p.hora_juego?.substring(0,5) }}</div>
              </div>

              <!-- Versus -->
              <div class="flex-grow-1">
                <div class="d-flex align-items-center justify-content-center gap-3">
                  <div class="text-center">
                    <div class="team-avatar mx-auto mb-1">{{ p.equipo_casa?.charAt(0) }}</div>
                    <div class="fw-semibold" style="font-size:0.82rem; color:#1e293b; max-width:100px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">{{ p.equipo_casa }}</div>
                    <div class="text-muted" style="font-size:0.7rem;">Local</div>
                  </div>
                  <div class="px-2">
                    <span v-if="p.estado === 'finalizado' && p.resultado" class="fw-bold" style="font-size:1.4rem; color:#1e293b;">
                      {{ p.resultado.carreras_home }} — {{ p.resultado.carreras_visitantes }}
                    </span>
                    <span v-else class="text-muted fw-bold" style="font-size:1.1rem;">VS</span>
                  </div>
                  <div class="text-center">
                    <div class="team-avatar mx-auto mb-1" style="background:linear-gradient(135deg,#f97316,#ef4444);">{{ p.equipo_visitante?.charAt(0) }}</div>
                    <div class="fw-semibold" style="font-size:0.82rem; color:#1e293b; max-width:100px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">{{ p.equipo_visitante }}</div>
                    <div class="text-muted" style="font-size:0.7rem;">Visitante</div>
                  </div>
                </div>
              </div>

              <!-- Info + acciones -->
              <div class="d-flex flex-column align-items-end gap-2" style="min-width:160px;">
                <span class="badge" :class="badgeEstado(p.estado)">{{ etiquetaEstado(p.estado) }}</span>
                <div v-if="p.lugar" class="text-muted d-flex align-items-center gap-1" style="font-size:0.75rem;">
                  <IconMapPin :size="12" /> {{ p.lugar }}
                </div>
                <div class="d-flex gap-1 mt-1">
                  <button class="btn btn-sm btn-ghost-primary" @click="verDetalle(p)">
                    <IconEye :size="15" /> Detalle
                  </button>
                  <button v-if="auth.puedeEditar" class="btn btn-sm btn-ghost-danger" @click="confirmarEliminar(p)">
                    <IconTrash :size="15" />
                  </button>
                </div>
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ===================== MODAL NUEVO PARTIDO ===================== -->
    <div v-if="modalNuevo" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title d-flex align-items-center gap-2">
              <IconCalendarEvent :size="20" /> Programar Partido
            </h5>
            <button type="button" class="btn-close" @click="modalNuevo = false"></button>
          </div>
          <form @submit.prevent="crearPartido">
            <div class="modal-body">
              <div v-if="errorNuevo" class="alert alert-danger py-2 mb-3">{{ errorNuevo }}</div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Temporada <span class="text-danger">*</span></label>
                  <select v-model="nuevoForm.id_temporada" class="form-select" required>
                    <option value="">— Seleccionar —</option>
                    <option v-for="t in temporadas" :key="t.id_temporada" :value="t.id_temporada">{{ t.nombre }} ({{ t.anio }})</option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Lugar</label>
                  <input v-model="nuevoForm.lugar" class="form-control" placeholder="Estadio..." />
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Equipo Local <span class="text-danger">*</span></label>
                  <select v-model="nuevoForm.id_equipo_casa" class="form-select" required>
                    <option value="">— Seleccionar —</option>
                    <option v-for="eq in equipos" :key="eq.id_equipo" :value="eq.id_equipo">{{ eq.nombre_equipo }}</option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Equipo Visitante <span class="text-danger">*</span></label>
                  <select v-model="nuevoForm.id_equipo_visitante" class="form-select" required>
                    <option value="">— Seleccionar —</option>
                    <option v-for="eq in equipos.filter(e => e.id_equipo !== nuevoForm.id_equipo_casa)" :key="eq.id_equipo" :value="eq.id_equipo">{{ eq.nombre_equipo }}</option>
                  </select>
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Fecha <span class="text-danger">*</span></label>
                  <input v-model="nuevoForm.fecha_juego" type="date" class="form-control" required />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Hora <span class="text-danger">*</span></label>
                  <input v-model="nuevoForm.hora_juego" type="time" class="form-control" required />
                </div>
              </div>
              <div class="mb-3">
                <label class="form-label fw-semibold" style="font-size:0.82rem;">Innings programados</label>
                <input v-model.number="nuevoForm.innings_programados" type="number" min="1" max="15" class="form-control" style="max-width:120px;" />
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-ghost-secondary" @click="modalNuevo = false">Cancelar</button>
              <button type="submit" class="btn btn-primary d-flex align-items-center gap-2" :disabled="guardandoNuevo">
                <span v-if="guardandoNuevo" class="spinner-border spinner-border-sm"></span>
                <IconDeviceFloppy v-else :size="16" />
                {{ guardandoNuevo ? 'Guardando...' : 'Programar' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="modalNuevo" class="modal-backdrop show"></div>

    <!-- ===================== MODAL DETALLE ===================== -->
    <div v-if="modalDetalle && partidoActual" class="modal modal-blur show d-block" tabindex="-1" style="overflow-y:auto;">
      <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <div>
              <h5 class="modal-title">{{ partidoActual.equipo_casa }} vs {{ partidoActual.equipo_visitante }}</h5>
              <div class="text-muted" style="font-size:0.78rem;">
                {{ formatFechaLarga(partidoActual.fecha_juego) }} · {{ partidoActual.hora_juego?.substring(0,5) }}
                <span v-if="partidoActual.lugar"> · {{ partidoActual.lugar }}</span>
                <span class="badge ms-2" :class="badgeEstado(partidoActual.estado)">{{ etiquetaEstado(partidoActual.estado) }}</span>
              </div>
            </div>
            <button type="button" class="btn-close" @click="modalDetalle = false"></button>
          </div>

          <!-- Tabs -->
          <div class="modal-body p-0">
            <ul class="nav nav-tabs px-3 pt-2" style="border-bottom: 1px solid rgba(0,0,0,0.07);">
              <li class="nav-item" v-for="tab in tabsDisponibles" :key="tab.id">
                <button class="nav-link" :class="{ active: tabActual === tab.id }" @click="tabActual = tab.id"
                  style="font-size:0.82rem; font-weight:600;">
                  <component :is="tab.icon" :size="15" class="me-1" />
                  {{ tab.label }}
                </button>
              </li>
            </ul>

            <div class="p-4">

              <!-- TAB: INFO / ESTADO -->
              <div v-if="tabActual === 'info'">
                <div v-if="auth.puedeEditar" class="card p-3">
                  <p class="fw-semibold mb-3" style="font-size:0.85rem;">Cambiar estado del partido</p>
                  <div class="d-flex gap-2 flex-wrap">
                    <button v-for="e in estados" :key="e.valor"
                      class="btn btn-sm"
                      :class="partidoActual.estado === e.valor ? 'btn-primary' : 'btn-ghost-secondary'"
                      @click="cambiarEstado(e.valor)">
                      {{ e.label }}
                    </button>
                  </div>
                </div>
                <div v-else class="text-muted text-center py-3" style="font-size:0.85rem;">
                  Solo administradores y dueños pueden cambiar el estado.
                </div>
              </div>

              <!-- TAB: LINEUP -->
              <div v-if="tabActual === 'lineup'">
                <div v-if="!auth.puedeAnotar" class="alert alert-warning py-2 mb-3" style="font-size:0.82rem;">
                  <IconLock :size="15" class="me-1" /> Solo el <strong>Anotador</strong> puede cargar el lineup.
                </div>

                <div class="row g-3">
                  <div v-for="(equipo, idx) in [{ id: partidoActual.id_equipo_casa, nombre: partidoActual.equipo_casa }, { id: partidoActual.id_equipo_visitante, nombre: partidoActual.equipo_visitante }]"
                    :key="equipo.id" class="col-md-6">
                    <div class="card p-3">
                      <div class="d-flex align-items-center gap-2 mb-3">
                        <div class="team-avatar" :style="idx === 0 ? '' : 'background:linear-gradient(135deg,#f97316,#ef4444);'">{{ equipo.nombre?.charAt(0) }}</div>
                        <span class="fw-bold" style="font-size:0.875rem;">{{ equipo.nombre }}</span>
                        <span class="badge bg-secondary-lt ms-auto" style="font-size:0.7rem;">{{ idx === 0 ? 'Local' : 'Visitante' }}</span>
                      </div>
                      <div class="table-responsive">
                        <table class="table table-sm table-vcenter mb-2">
                          <thead>
                            <tr style="font-size:0.72rem;">
                              <th>#</th><th>Jugador</th><th>Pos. Juego</th><th>Titular</th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr v-for="row in lineupEquipo(equipo.id)" :key="row.id_jugador" style="font-size:0.8rem;">
                              <td>{{ row.orden_bateo }}</td>
                              <td>{{ row.nombre }} {{ row.apellido }}</td>
                              <td>{{ row.posicion_juego }}</td>
                              <td><span :class="row.es_titular ? 'text-success' : 'text-muted'">{{ row.es_titular ? '✓' : '—' }}</span></td>
                            </tr>
                            <tr v-if="!lineupEquipo(equipo.id).length">
                              <td colspan="4" class="text-center text-muted py-2" style="font-size:0.78rem;">Sin lineup cargado</td>
                            </tr>
                          </tbody>
                        </table>
                      </div>

                      <!-- Formulario agregar al lineup (solo anotador) -->
                      <div v-if="auth.puedeAnotar">
                        <hr class="my-2" />
                        <p style="font-size:0.75rem; color:#64748b; font-weight:600;" class="mb-2">Agregar jugador al lineup</p>
                        <div class="row g-1 align-items-end">
                          <div class="col-12 mb-1">
                            <select v-model="lineupInput[equipo.id].id_jugador" class="form-select form-select-sm">
                              <option value="">— Jugador —</option>
                              <option v-for="j in jugadoresPorEquipo(equipo.id)" :key="j.id_jugador" :value="j.id_jugador">
                                {{ j.nombre }} {{ j.apellido }}
                              </option>
                            </select>
                          </div>
                          <div class="col-5">
                            <input v-model.number="lineupInput[equipo.id].orden_bateo" type="number" min="1" max="20" class="form-control form-control-sm" placeholder="Orden" />
                          </div>
                          <div class="col-7">
                            <input v-model="lineupInput[equipo.id].posicion_juego" class="form-control form-control-sm" placeholder="Posición en juego" />
                          </div>
                          <div class="col-12 d-flex align-items-center gap-2 mt-1">
                            <input type="checkbox" v-model="lineupInput[equipo.id].es_titular" class="form-check-input m-0" id="titular" />
                            <label for="titular" style="font-size:0.78rem; cursor:pointer;">Titular</label>
                            <button class="btn btn-sm btn-primary ms-auto" @click="agregarLineup(equipo.id)" :disabled="!lineupInput[equipo.id].id_jugador">
                              Agregar
                            </button>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- TAB: RESULTADO -->
              <div v-if="tabActual === 'resultado'">
                <div v-if="!auth.puedeAnotar" class="alert alert-warning py-2 mb-3" style="font-size:0.82rem;">
                  <IconLock :size="15" class="me-1" /> Solo el <strong>Anotador</strong> puede cargar el resultado.
                </div>

                <div class="card p-4">
                  <!-- Marcador visual -->
                  <div class="d-flex align-items-center justify-content-center gap-4 mb-4 p-3" style="background:rgba(99,102,241,0.06); border-radius:14px;">
                    <div class="text-center">
                      <div class="team-avatar mx-auto mb-2" style="width:48px;height:48px;font-size:1.1rem;">{{ partidoActual.equipo_casa?.charAt(0) }}</div>
                      <div class="fw-semibold" style="font-size:0.82rem;">{{ partidoActual.equipo_casa }}</div>
                      <div class="fw-800 mt-1" style="font-size:2.5rem; color:#1e293b; line-height:1;">{{ resultadoForm.carreras_home }}</div>
                    </div>
                    <div class="text-muted fw-bold" style="font-size:1.2rem;">—</div>
                    <div class="text-center">
                      <div class="team-avatar mx-auto mb-2" style="width:48px;height:48px;font-size:1.1rem;background:linear-gradient(135deg,#f97316,#ef4444);">{{ partidoActual.equipo_visitante?.charAt(0) }}</div>
                      <div class="fw-semibold" style="font-size:0.82rem;">{{ partidoActual.equipo_visitante }}</div>
                      <div class="fw-800 mt-1" style="font-size:2.5rem; color:#1e293b; line-height:1;">{{ resultadoForm.carreras_visitantes }}</div>
                    </div>
                  </div>

                  <form v-if="auth.puedeAnotar" @submit.prevent="guardarResultado">
                    <div class="row g-2 mb-3">
                      <div class="col-12"><p class="fw-semibold mb-1" style="font-size:0.82rem; color:#64748b;">CARRERAS</p></div>
                      <div class="col-6"><label class="form-label" style="font-size:0.78rem;">{{ partidoActual.equipo_casa }}</label>
                        <input v-model.number="resultadoForm.carreras_home" type="number" min="0" class="form-control form-control-sm" /></div>
                      <div class="col-6"><label class="form-label" style="font-size:0.78rem;">{{ partidoActual.equipo_visitante }}</label>
                        <input v-model.number="resultadoForm.carreras_visitantes" type="number" min="0" class="form-control form-control-sm" /></div>
                    </div>
                    <div class="row g-2 mb-3">
                      <div class="col-12"><p class="fw-semibold mb-1" style="font-size:0.82rem; color:#64748b;">HITS</p></div>
                      <div class="col-6"><input v-model.number="resultadoForm.hits_home" type="number" min="0" class="form-control form-control-sm" placeholder="Hits local" /></div>
                      <div class="col-6"><input v-model.number="resultadoForm.hits_visitantes" type="number" min="0" class="form-control form-control-sm" placeholder="Hits visitante" /></div>
                    </div>
                    <div class="row g-2 mb-3">
                      <div class="col-12"><p class="fw-semibold mb-1" style="font-size:0.82rem; color:#64748b;">ERRORES</p></div>
                      <div class="col-6"><input v-model.number="resultadoForm.errores_home" type="number" min="0" class="form-control form-control-sm" placeholder="Errores local" /></div>
                      <div class="col-6"><input v-model.number="resultadoForm.errores_visitantes" type="number" min="0" class="form-control form-control-sm" placeholder="Errores visitante" /></div>
                    </div>
                    <div class="row g-2 mb-3">
                      <div class="col-4">
                        <label class="form-label" style="font-size:0.78rem;">Innings totales</label>
                        <input v-model.number="resultadoForm.innings_totales" type="number" min="1" max="20" class="form-control form-control-sm" />
                      </div>
                    </div>
                    <div class="row g-2 mb-3">
                      <div class="col-12"><p class="fw-semibold mb-1" style="font-size:0.82rem; color:#64748b;">DECISIONES PITCHER</p></div>
                      <div class="col-md-4">
                        <label class="form-label" style="font-size:0.78rem;">Ganador</label>
                        <select v-model="resultadoForm.id_pitcher_ganador" class="form-select form-select-sm">
                          <option :value="null">— Ninguno —</option>
                          <option v-for="j in pitchersEnLineup" :key="j.id_jugador" :value="j.id_jugador">{{ j.nombre }} {{ j.apellido }}</option>
                        </select>
                      </div>
                      <div class="col-md-4">
                        <label class="form-label" style="font-size:0.78rem;">Perdedor</label>
                        <select v-model="resultadoForm.id_pitcher_perdedor" class="form-select form-select-sm">
                          <option :value="null">— Ninguno —</option>
                          <option v-for="j in pitchersEnLineup" :key="j.id_jugador" :value="j.id_jugador">{{ j.nombre }} {{ j.apellido }}</option>
                        </select>
                      </div>
                      <div class="col-md-4">
                        <label class="form-label" style="font-size:0.78rem;">Salvador</label>
                        <select v-model="resultadoForm.id_pitcher_salvador" class="form-select form-select-sm">
                          <option :value="null">— Ninguno —</option>
                          <option v-for="j in pitchersEnLineup" :key="j.id_jugador" :value="j.id_jugador">{{ j.nombre }} {{ j.apellido }}</option>
                        </select>
                      </div>
                    </div>
                    <div class="mb-3">
                      <label class="form-label" style="font-size:0.78rem;">Observaciones</label>
                      <textarea v-model="resultadoForm.observaciones" class="form-control form-control-sm" rows="2"></textarea>
                    </div>
                    <div class="text-end">
                      <button type="submit" class="btn btn-primary d-inline-flex align-items-center gap-2" :disabled="guardandoResultado">
                        <span v-if="guardandoResultado" class="spinner-border spinner-border-sm"></span>
                        <IconDeviceFloppy v-else :size="16" />
                        Guardar Resultado (marca partido como Finalizado)
                      </button>
                    </div>
                  </form>

                  <div v-else class="text-muted text-center py-3" style="font-size:0.82rem;">
                    El resultado debe ser cargado por el Anotador.
                  </div>
                </div>
              </div>

              <!-- TAB: ESTADÍSTICAS -->
              <div v-if="tabActual === 'estadisticas'">
                <div v-if="!auth.puedeAnotar" class="alert alert-warning py-2 mb-3" style="font-size:0.82rem;">
                  <IconLock :size="15" class="me-1" /> Solo el <strong>Anotador</strong> puede cargar estadísticas.
                </div>

                <!-- Bateadores -->
                <div class="mb-4">
                  <h6 class="fw-bold mb-3" style="font-size:0.875rem; color:#1e293b;">Estadísticas de Bateadores</h6>
                  <div class="table-responsive">
                    <table class="table table-sm table-vcenter" style="font-size:0.78rem;">
                      <thead>
                        <tr>
                          <th>Jugador</th><th>Equipo</th>
                          <th title="Turnos al bate">AB</th><th title="Hits">H</th><th title="Dobles">2B</th>
                          <th title="Triples">3B</th><th title="Jonrones">HR</th><th title="Carreras">R</th>
                          <th title="Carreras Impulsadas">RBI</th><th title="Bases por Bolas">BB</th>
                          <th title="Ponches">SO</th>
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

                  <!-- Agregar bateador (anotador) -->
                  <div v-if="auth.puedeAnotar" class="mt-2">
                    <div class="d-flex gap-2 align-items-center">
                      <select v-model="nuevoBateador" class="form-select form-select-sm" style="max-width:220px;">
                        <option value="">Agregar jugador a bateadores...</option>
                        <option v-for="j in jugadoresNoEnBateadores" :key="j.id_jugador" :value="j.id_jugador">
                          {{ j.nombre }} {{ j.apellido }} ({{ j.nombre_equipo }})
                        </option>
                      </select>
                      <button class="btn btn-sm btn-outline-primary" :disabled="!nuevoBateador" @click="agregarBateador">Agregar</button>
                    </div>
                  </div>
                </div>

                <!-- Pitchers -->
                <div>
                  <h6 class="fw-bold mb-3" style="font-size:0.875rem; color:#1e293b;">Estadísticas de Pitchers</h6>
                  <div class="table-responsive">
                    <table class="table table-sm table-vcenter" style="font-size:0.78rem;">
                      <thead>
                        <tr>
                          <th>Pitcher</th><th>Equipo</th>
                          <th title="Innings Pitcheados">IP</th><th title="Hits Permitidos">H</th>
                          <th title="Carreras Permitidas">R</th><th title="Carreras Limpias">ER</th>
                          <th title="Jonrones Permitidos">HR</th><th title="Bases por Bolas">BB</th>
                          <th title="Ponches">SO</th><th>G</th><th>P</th><th>S</th>
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

                  <!-- Agregar pitcher (anotador) -->
                  <div v-if="auth.puedeAnotar" class="mt-2">
                    <div class="d-flex gap-2 align-items-center">
                      <select v-model="nuevoPitcher" class="form-select form-select-sm" style="max-width:220px;">
                        <option value="">Agregar pitcher...</option>
                        <option v-for="j in pitchersNoEnStats" :key="j.id_jugador" :value="j.id_jugador">
                          {{ j.nombre }} {{ j.apellido }} ({{ j.nombre_equipo }})
                        </option>
                      </select>
                      <button class="btn btn-sm btn-outline-primary" :disabled="!nuevoPitcher" @click="agregarPitcher">Agregar</button>
                    </div>
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
import { ref, computed, onMounted, markRaw } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/store/auth'
import {
  IconPlus, IconCalendarEvent, IconEye, IconTrash, IconMapPin,
  IconLock, IconDeviceFloppy, IconInfoCircle, IconListDetails,
  IconTrophy, IconChartBar,
} from '@tabler/icons-vue'

const auth    = useAuthStore()
const partidos   = ref([])
const equipos    = ref([])
const jugadores  = ref([])
const temporadas = ref([])
const cargando   = ref(false)
const filtroEstado = ref('')

const filtrosEstado = [
  { valor: '', label: 'Todos' },
  { valor: 'programado',  label: 'Programados' },
  { valor: 'en_curso',    label: 'En Curso' },
  { valor: 'finalizado',  label: 'Finalizados' },
  { valor: 'suspendido',  label: 'Suspendidos' },
]
const estados = [
  { valor: 'programado', label: 'Programado' },
  { valor: 'en_curso',   label: 'En Curso' },
  { valor: 'finalizado', label: 'Finalizado' },
  { valor: 'suspendido', label: 'Suspendido' },
]

// Modal nuevo
const modalNuevo   = ref(false)
const guardandoNuevo = ref(false)
const errorNuevo   = ref('')
const nuevoForm    = ref({ id_temporada: '', id_equipo_casa: '', id_equipo_visitante: '', fecha_juego: '', hora_juego: '10:00', lugar: '', innings_programados: 9 })

// Modal detalle
const modalDetalle  = ref(false)
const partidoActual = ref(null)
const tabActual     = ref('info')
const lineup        = ref([])
const desempeno     = ref({ bateadores: [], pitchers: [] })
const resultadoForm = ref({ carreras_home: 0, carreras_visitantes: 0, hits_home: 0, hits_visitantes: 0, errores_home: 0, errores_visitantes: 0, innings_totales: 9, id_pitcher_ganador: null, id_pitcher_perdedor: null, id_pitcher_salvador: null, observaciones: '' })
const guardandoResultado = ref(false)

// Lineup input por equipo
const lineupInput = ref({})
const nuevoBateador = ref('')
const nuevoPitcher  = ref('')

const tabsDisponibles = computed(() => [
  { id: 'info',         label: 'Info & Estado',   icon: markRaw(IconInfoCircle) },
  { id: 'lineup',       label: 'Lineup',          icon: markRaw(IconListDetails) },
  { id: 'resultado',    label: 'Resultado',       icon: markRaw(IconTrophy) },
  { id: 'estadisticas', label: 'Estadísticas',    icon: markRaw(IconChartBar) },
])

const partidosFiltrados = computed(() =>
  partidos.value.filter(p => !filtroEstado.value || p.estado === filtroEstado.value)
)

function contarEstado(estado) {
  if (!estado) return partidos.value.length
  return partidos.value.filter(p => p.estado === estado).length
}

function badgeEstado(estado) {
  return {
    programado:  'bg-blue-lt text-blue',
    en_curso:    'bg-green-lt text-green',
    finalizado:  'bg-secondary-lt text-secondary',
    suspendido:  'bg-danger-lt text-danger',
  }[estado] || 'bg-secondary-lt'
}

function etiquetaEstado(estado) {
  return { programado: 'Programado', en_curso: 'En Curso', finalizado: 'Finalizado', suspendido: 'Suspendido' }[estado] || estado
}

function formatDia(f) {
  if (!f) return ''
  return new Date(f).toLocaleDateString('es-VE', { day: '2-digit' })
}
function formatMes(f) {
  if (!f) return ''
  return new Date(f).toLocaleDateString('es-VE', { month: 'short', year: 'numeric' })
}
function formatFechaLarga(f) {
  if (!f) return ''
  return new Date(f).toLocaleDateString('es-VE', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
}

function lineupEquipo(id_equipo) {
  return lineup.value.filter(l => l.id_equipo === id_equipo)
}

function jugadoresPorEquipo(id_equipo) {
  return jugadores.value.filter(j => j.id_equipo === id_equipo && j.activo)
}

const pitchersEnLineup = computed(() =>
  jugadores.value.filter(j =>
    lineup.value.some(l => l.id_jugador === j.id_jugador) &&
    (j.rol === 'pitcher' || j.rol === 'utilidad')
  )
)

const jugadoresNoEnBateadores = computed(() => {
  const ids = new Set(desempeno.value.bateadores.map(b => b.id_jugador))
  return jugadores.value.filter(j => !ids.has(j.id_jugador))
})

const pitchersNoEnStats = computed(() => {
  const ids = new Set(desempeno.value.pitchers.map(p => p.id_jugador))
  return jugadores.value.filter(j => !ids.has(j.id_jugador) && (j.rol === 'pitcher' || j.rol === 'utilidad'))
})

async function cargar() {
  cargando.value = true
  try {
    const [resP, resE, resJ, resT] = await Promise.all([
      api.get('/partidos'),
      api.get('/equipos'),
      api.get('/jugadores'),
      api.get('/temporadas'),
    ])
    partidos.value   = resP.data
    equipos.value    = resE.data
    jugadores.value  = resJ.data
    temporadas.value = resT.data
  } finally { cargando.value = false }
}

async function verDetalle(partido) {
  partidoActual.value = { ...partido }
  tabActual.value = 'info'
  modalDetalle.value = true
  nuevoBateador.value = ''
  nuevoPitcher.value  = ''

  // Inicializar lineupInput por equipo
  lineupInput.value = {
    [partido.id_equipo_casa]:       { id_jugador: '', orden_bateo: 1, posicion_juego: '', es_titular: true },
    [partido.id_equipo_visitante]:  { id_jugador: '', orden_bateo: 1, posicion_juego: '', es_titular: true },
  }

  const [resL, resD, resR] = await Promise.all([
    api.get(`/partidos/${partido.id_partido}/lineup`),
    api.get(`/partidos/${partido.id_partido}/desempeno`),
    api.get(`/partidos/${partido.id_partido}/resultado`),
  ])
  lineup.value = resL.data
  desempeno.value = resD.data

  // Precarga resultado si existe
  if (resR.data) {
    Object.assign(resultadoForm.value, resR.data)
  } else {
    resultadoForm.value = { carreras_home: 0, carreras_visitantes: 0, hits_home: 0, hits_visitantes: 0, errores_home: 0, errores_visitantes: 0, innings_totales: 9, id_pitcher_ganador: null, id_pitcher_perdedor: null, id_pitcher_salvador: null, observaciones: '' }
  }

  // Guardar resultado en partidoActual para mostrar el marcador
  partidoActual.value.resultado = resR.data
}

function abrirNuevoPartido() {
  errorNuevo.value = ''
  nuevoForm.value = { id_temporada: temporadas.value.find(t => t.activa)?.id_temporada || '', id_equipo_casa: '', id_equipo_visitante: '', fecha_juego: '', hora_juego: '10:00', lugar: '', innings_programados: 9 }
  modalNuevo.value = true
}

async function crearPartido() {
  guardandoNuevo.value = true
  errorNuevo.value = ''
  try {
    await api.post('/partidos', nuevoForm.value)
    modalNuevo.value = false
    cargar()
  } catch (e) {
    errorNuevo.value = e.response?.data?.error || 'Error al crear partido'
  } finally { guardandoNuevo.value = false }
}

async function confirmarEliminar(p) {
  if (!confirm(`¿Eliminar el partido ${p.equipo_casa} vs ${p.equipo_visitante}?`)) return
  await api.delete(`/partidos/${p.id_partido}`)
  cargar()
}

async function cambiarEstado(estado) {
  await api.patch(`/partidos/${partidoActual.value.id_partido}/estado`, { estado })
  partidoActual.value.estado = estado
  const idx = partidos.value.findIndex(p => p.id_partido === partidoActual.value.id_partido)
  if (idx >= 0) partidos.value[idx].estado = estado
}

async function agregarLineup(id_equipo) {
  const inp = lineupInput.value[id_equipo]
  if (!inp.id_jugador) return
  const entry = { id_partido: partidoActual.value.id_partido, id_equipo, ...inp }
  await api.post(`/partidos/${partidoActual.value.id_partido}/lineup`, { entries: [entry] })
  // Recargar lineup
  const { data } = await api.get(`/partidos/${partidoActual.value.id_partido}/lineup`)
  lineup.value = data
  inp.id_jugador = ''
}

async function guardarResultado() {
  guardandoResultado.value = true
  try {
    await api.post(`/partidos/${partidoActual.value.id_partido}/resultado`, resultadoForm.value)
    partidoActual.value.estado = 'finalizado'
    partidoActual.value.resultado = { ...resultadoForm.value }
    const idx = partidos.value.findIndex(p => p.id_partido === partidoActual.value.id_partido)
    if (idx >= 0) partidos.value[idx].estado = 'finalizado'
  } catch (e) {
    alert(e.response?.data?.error || 'Error al guardar resultado')
  } finally { guardandoResultado.value = false }
}

function agregarBateador() {
  const jugador = jugadores.value.find(j => j.id_jugador === Number(nuevoBateador.value) || j.id_jugador === nuevoBateador.value)
  if (!jugador) return
  desempeno.value.bateadores.push({
    id_jugador: jugador.id_jugador, id_equipo: jugador.id_equipo,
    nombre: jugador.nombre, apellido: jugador.apellido, nombre_equipo: jugador.nombre_equipo,
    turnos_al_bate: 0, hits: 0, dobles: 0, triples: 0, jonrones: 0,
    carreras: 0, carreras_impulsadas: 0, bolas: 0, strikes: 0, foul: 0, outs: 0, asistencias: 0,
  })
  nuevoBateador.value = ''
}

function agregarPitcher() {
  const jugador = jugadores.value.find(j => j.id_jugador === Number(nuevoPitcher.value) || j.id_jugador === nuevoPitcher.value)
  if (!jugador) return
  desempeno.value.pitchers.push({
    id_jugador: jugador.id_jugador, id_equipo: jugador.id_equipo,
    nombre: jugador.nombre, apellido: jugador.apellido, nombre_equipo: jugador.nombre_equipo,
    innings_pitcheados: 0, hits_permitidos: 0, carreras_permitidas: 0, carreras_limpias: 0,
    jonrones_permitidos: 0, golpes_bateador: 0, bases_por_bolas: 0, ponches: 0,
    ganado: 0, perdido: 0, salvado: 0,
  })
  nuevoPitcher.value = ''
}

async function guardarStatBateador(b) {
  await api.post(`/partidos/${partidoActual.value.id_partido}/desempeno/bateador`, { ...b, id_partido: partidoActual.value.id_partido })
}

async function guardarStatPitcher(pt) {
  await api.post(`/partidos/${partidoActual.value.id_partido}/desempeno/pitcher`, { ...pt, id_partido: partidoActual.value.id_partido })
}

onMounted(cargar)
</script>
