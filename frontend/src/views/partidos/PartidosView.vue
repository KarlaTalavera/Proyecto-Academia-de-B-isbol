<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Partidos</h2>
        <p class="page-subtitle">Calendario y gestión de juegos</p>
      </div>
      <button v-if="esAdministrador" class="btn btn-primary d-flex align-items-center gap-2" @click="abrirNuevoPartido">
        <IconPlus :size="18" stroke-width="2" /> Programar Partido
      </button>
    </div>

    <div class="d-flex align-items-center justify-content-between gap-3 mb-3 flex-wrap">
      <div class="d-flex gap-2 flex-wrap">
        <button v-for="f in filtrosEstado" :key="f.valor"
          class="btn btn-sm" :class="filtroEstado === f.valor ? 'btn-primary' : 'btn-ghost-secondary'"
          style="border-radius:20px; font-size:0.8rem;" @click="filtroEstado = f.valor">
          {{ f.label }} <span class="ms-1 badge" style="background:rgba(255,255,255,0.25); font-size:0.65rem;">{{ contarEstado(f.valor) }}</span>
        </button>
      </div>
      <div class="partido-search-wrapper">
        <IconSearch :size="15" class="partido-search-icon" />
        <input v-model="busqueda" class="form-control form-control-sm partido-search" placeholder="Buscar equipo, lugar..." />
      </div>
    </div>

    <div v-if="cargando" class="text-center py-5 text-muted">
      <span class="spinner-border text-primary me-2"></span> Cargando partidos...
    </div>

    <div v-else-if="!partidosFiltrados.length" class="card">
      <div class="card-body text-center py-5 text-muted">
        <IconCalendarEvent :size="40" stroke-width="1.2" class="mb-2" style="opacity:0.3;" />
        <p class="mb-0">No se encontraron partidos</p>
      </div>
    </div>

    <div v-else class="row g-3">
      <div v-for="p in partidosPagina" :key="p.id_partido" class="col-12">
        <div class="card" style="transition: transform 0.15s; cursor:default;">
          <div class="card-body py-3">
            <div class="d-flex align-items-center flex-wrap gap-3">
              <div class="text-center" style="min-width:70px;">
                <div class="fw-bold" style="font-size:1.3rem; color:#1e293b; line-height:1;">{{ formatDia(p.fecha_juego) }}</div>
                <div class="text-muted" style="font-size:0.72rem;">{{ formatMes(p.fecha_juego) }}</div>
                <div class="text-muted" style="font-size:0.72rem;">{{ p.hora_juego?.substring(0,5) }}</div>
              </div>

              <div class="flex-grow-1">
                <div class="d-flex align-items-center justify-content-center gap-3">
                  <div class="text-center">
                    <div class="team-avatar mx-auto mb-1">{{ p.equipo_casa?.charAt(0) }}</div>
                    <div class="fw-semibold" style="font-size:0.82rem; color:#1e293b;">{{ p.equipo_casa }}</div>
                  </div>
                  <div class="px-2">
                    <span v-if="p.estado === 'finalizado' && p.resultado" class="fw-bold" style="font-size:1.4rem; color:#1e293b;">
                      {{ p.resultado.carreras_home }} — {{ p.resultado.carreras_visitantes }}
                    </span>
                    <span v-else class="text-muted fw-bold" style="font-size:1.1rem;">VS</span>
                  </div>
                  <div class="text-center">
                    <div class="team-avatar mx-auto mb-1" style="background:linear-gradient(135deg,#f97316,#ef4444);">{{ p.equipo_visitante?.charAt(0) }}</div>
                    <div class="fw-semibold" style="font-size:0.82rem; color:#1e293b;">{{ p.equipo_visitante }}</div>
                  </div>
                </div>
              </div>

              <div class="d-flex flex-column align-items-end gap-2" style="min-width:160px;">
                <span class="badge" :class="badgeEstado(p.estado)">{{ etiquetaEstado(p.estado) }}</span>
                <div class="d-flex gap-1 mt-1">
                  <button class="btn btn-sm btn-ghost-primary" @click="verDetalle(p)"><IconEye :size="15" /> Detalle</button>
                  <button v-if="esAdministrador" class="btn btn-sm btn-ghost-danger" @click="confirmarEliminar(p)"><IconTrash :size="15" /></button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="totalPaginas > 1" class="d-flex align-items-center justify-content-between mt-3">
      <span class="text-muted" style="font-size:0.8rem;">
        Mostrando {{ (paginaActual - 1) * porPagina + 1 }}–{{ Math.min(paginaActual * porPagina, partidosFiltrados.length) }}
        de {{ partidosFiltrados.length }} partidos
      </span>
      <div class="d-flex gap-1">
        <button class="btn btn-sm btn-ghost-secondary" :disabled="paginaActual === 1" @click="paginaActual--">‹ Anterior</button>
        <button
          v-for="n in totalPaginas" :key="n"
          class="btn btn-sm" :class="n === paginaActual ? 'btn-primary' : 'btn-ghost-secondary'"
          style="min-width:34px;" @click="paginaActual = n"
        >{{ n }}</button>
        <button class="btn btn-sm btn-ghost-secondary" :disabled="paginaActual === totalPaginas" @click="paginaActual++">Siguiente ›</button>
      </div>
    </div>

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
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Estadio</label>
                  <select v-model="nuevoForm.id_estadio" class="form-select">
                    <option value="">— Seleccionar —</option>
                    <option v-for="estadio in estadios" :key="estadio.id_estadio" :value="estadio.id_estadio">
                      {{ estadio.nombre }} · {{ estadio.ciudad }}
                    </option>
                  </select>
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Lugar</label>
                  <input v-model="nuevoForm.lugar" class="form-control" :readonly="nuevoForm.id_estadio" :placeholder="nuevoForm.id_estadio ? 'Lugar tomado del estadio seleccionado' : 'Ingresar lugar del partido'" />
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
                  <input v-model="nuevoForm.fecha_juego" type="date" class="form-control" :min="hoyStr" required />
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

    <div v-if="modalDetalle && partidoActual" class="modal modal-blur show d-block" tabindex="-1" style="overflow-y:auto;">
      <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <div>
              <h5 class="modal-title">{{ partidoActual.equipo_casa }} vs {{ partidoActual.equipo_visitante }}</h5>
              <div class="text-muted" style="font-size:0.78rem;">
                {{ formatFechaLarga(partidoActual.fecha_juego) }} · {{ partidoActual.hora_juego?.substring(0,5) }}
                <span class="badge ms-2" :class="badgeEstado(partidoActual.estado)">{{ etiquetaEstado(partidoActual.estado) }}</span>
              </div>
            </div>
            <button type="button" class="btn-close" @click="modalDetalle = false"></button>
          </div>

          <div class="modal-body p-0">
            <ul class="nav nav-tabs px-3 pt-2" style="border-bottom: 1px solid rgba(0,0,0,0.07);">
              <li class="nav-item" v-for="tab in tabsDisponibles" :key="tab.id">
                <button class="nav-link" :class="{ active: tabActual === tab.id }" @click="tabActual = tab.id" style="font-size:0.82rem; font-weight:600;">
                  <component :is="tab.icon" :size="15" class="me-1" /> {{ tab.label }}
                </button>
              </li>
            </ul>

            <div class="p-4">
              <div v-if="tabActual === 'info'">
                <div v-if="esAnotadorOrAdmin" class="d-flex flex-column gap-3">
                  <div v-if="partidoActual.estado === 'finalizado'" class="alert alert-info py-2" style="font-size:0.82rem;">
                    <IconLock :size="15" class="me-1"/> El partido está finalizado. No puede cambiarse de estado ni ser reprogramado.
                  </div>
                  
                  <div v-else class="card p-3">
                    <p class="fw-semibold mb-3" style="font-size:0.85rem;">Cambiar estado del partido</p>
                    <div class="d-flex gap-2 flex-wrap">
                      <button v-for="e in estados" :key="e.valor"
                        class="btn btn-sm" :class="partidoActual.estado === e.valor ? 'btn-primary' : 'btn-ghost-secondary'"
                        @click="cambiarEstado(e.valor)">
                        {{ e.label }}
                      </button>
                    </div>
                  </div>

                  <div v-if="partidoActual.estado === 'programado' || partidoActual.estado === 'suspendido'" class="card p-3">
                    <p class="fw-semibold mb-3" style="font-size:0.85rem;">Reprogramar partido</p>
                    <div class="d-flex flex-wrap gap-2 align-items-end">
                      <div><label class="form-label mb-1" style="font-size:0.78rem;">Nueva fecha</label>
                        <input v-model="reprogramarForm.fecha" type="date" class="form-control form-control-sm" :min="hoyStr" /></div>
                      <div><label class="form-label mb-1" style="font-size:0.78rem;">Nueva hora</label>
                        <input v-model="reprogramarForm.hora" type="time" class="form-control form-control-sm" /></div>
                      <button class="btn btn-sm btn-outline-primary" :disabled="!reprogramarForm.fecha || !reprogramarForm.hora" @click="reprogramarPartido">
                        <IconCalendarEvent :size="14" class="me-1" /> Reprogramar
                      </button>
                    </div>
                  </div>
                </div>
                <div v-else class="text-muted text-center py-3" style="font-size:0.85rem;">
                  La gestión de reprogramaciones y estados es exclusiva del personal administrativo y anotadores.
                </div>
              </div>

              <div v-if="tabActual === 'lineup'">
                <div class="row g-3">
                  <div class="col-md-6">
                    <div class="card p-3">
                      <div class="d-flex align-items-center gap-2 mb-3">
                        <div class="team-avatar">{{ partidoActual.equipo_casa?.charAt(0) }}</div>
                        <span class="fw-bold" style="font-size:0.875rem;">{{ partidoActual.equipo_casa }}</span>
                      </div>

                      <div class="table-responsive">
                        <table class="table table-sm table-vcenter">
                          <thead>
                            <tr style="font-size:0.72rem;">
                              <th style="width: 55px;">#</th>
                              <th>Jugador</th>
                              <th style="width: 110px;">Posición</th>
                              <th style="width: 60px;">Titular</th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr v-for="(jugador, idx) in lineupEquipo(partidoActual.id_equipo_casa)" :key="jugador.id_jugador" :class="{'bg-success-lt': jugador.es_titular}">
                              <td>
                                <span v-if="!editandoLineupLocal" class="fw-bold">{{ jugador.orden_bateo || '—' }}</span>
                                <input v-else type="number" min="1" max="20" v-model.number.lazy="jugador.orden_bateo" 
                                  :disabled="!jugador.es_titular"
                                  @focus="jugador._viejoOrden = jugador.orden_bateo" @change="ajustarOrden(jugador, partidoActual.id_equipo_casa)" 
                                  style="width:55px;" class="form-control form-control-sm text-center" />
                              </td>
                              <td class="fw-semibold">
                                {{ jugador.nombre }} {{ jugador.apellido }}
                                <span v-if="jugador.posicion_natural === 'P'" class="badge bg-purple-lt ms-1" style="font-size:0.65rem;">P</span>
                              </td>
                              <td>
                                <span v-if="!editandoLineupLocal" class="badge" :class="jugador.posicion_juego === 'BN' ? 'bg-secondary-lt' : 'bg-primary-lt'">
                                  {{ jugador.posicion_juego || 'BN' }}
                                </span>
                                <select v-else v-model="jugador.posicion_juego" class="form-select form-select-sm" @change="onPosicionChange(jugador)">
                                  <option value="BN">Banca (BN)</option>
                                  <option value="P">P</option>
                                  <option value="C">C</option>
                                  <option value="1B">1B</option>
                                  <option value="2B">2B</option>
                                  <option value="3B">3B</option>
                                  <option value="SS">SS</option>
                                  <option value="LF">LF</option>
                                  <option value="CF">CF</option>
                                  <option value="RF">RF</option>
                                  <option value="DH">DH</option>
                                </select>
                              </td>
                              <td class="text-center">
                                <span v-if="!editandoLineupLocal">
                                  <span :class="jugador.es_titular ? 'text-success fw-bold' : 'text-muted'">{{ jugador.es_titular ? '✓' : '—' }}</span>
                                </span>
                                <input v-else type="checkbox" v-model="jugador.es_titular" class="form-check-input" @change="onTitularChange(jugador)" />
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </div>

                      <div v-if="puedeEditarLineupLocal && partidoActual.estado !== 'finalizado'" class="mt-3 d-flex justify-content-end gap-2">
                        <button v-if="!editandoLineupLocal" class="btn btn-sm btn-outline-primary" @click="editandoLineupLocal = true"><IconEdit :size="14" class="me-1" /> Editar Lineup</button>
                        <template v-else>
                          <button class="btn btn-sm btn-success" @click="guardarLineupCompleto(partidoActual.id_equipo_casa, 'local')" :disabled="guardandoLineup"><IconDeviceFloppy :size="14" class="me-1" /> Guardar</button>
                          <button class="btn btn-sm btn-ghost-secondary" @click="editandoLineupLocal = false; verDetalle(partidoActual)">Cancelar</button>
                        </template>
                      </div>
                    </div>
                  </div>

                  <div class="col-md-6">
                    <div class="card p-3">
                      <div class="d-flex align-items-center gap-2 mb-3">
                        <div class="team-avatar" style="background:linear-gradient(135deg,#f97316,#ef4444);">{{ partidoActual.equipo_visitante?.charAt(0) }}</div>
                        <span class="fw-bold" style="font-size:0.875rem;">{{ partidoActual.equipo_visitante }}</span>
                      </div>

                      <div class="table-responsive">
                        <table class="table table-sm table-vcenter">
                          <thead>
                            <tr style="font-size:0.72rem;">
                              <th style="width: 55px;">#</th>
                              <th>Jugador</th>
                              <th style="width: 110px;">Posición</th>
                              <th style="width: 60px;">Titular</th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr v-for="(jugador, idx) in lineupEquipo(partidoActual.id_equipo_visitante)" :key="jugador.id_jugador" :class="{'bg-success-lt': jugador.es_titular}">
                              <td>
                                <span v-if="!editandoLineupVisitante" class="fw-bold">{{ jugador.orden_bateo || '—' }}</span>
                                <input v-else type="number" min="1" max="20" v-model.number.lazy="jugador.orden_bateo" 
                                  :disabled="!jugador.es_titular"
                                  @focus="jugador._viejoOrden = jugador.orden_bateo" @change="ajustarOrden(jugador, partidoActual.id_equipo_visitante)" 
                                  style="width:55px;" class="form-control form-control-sm text-center" />
                              </td>
                              <td class="fw-semibold">
                                {{ jugador.nombre }} {{ jugador.apellido }}
                                <span v-if="jugador.posicion_natural === 'P'" class="badge bg-purple-lt ms-1" style="font-size:0.65rem;">P</span>
                              </td>
                              <td>
                                <span v-if="!editandoLineupVisitante" class="badge" :class="jugador.posicion_juego === 'BN' ? 'bg-secondary-lt' : 'bg-primary-lt'">
                                  {{ jugador.posicion_juego || 'BN' }}
                                </span>
                                <select v-else v-model="jugador.posicion_juego" class="form-select form-select-sm" @change="onPosicionChange(jugador)">
                                  <option value="BN">Banca (BN)</option>
                                  <option value="RP">Relevista (RP)</option>
                                  <option value="PH">Bat. Emergente (PH)</option>
                                  <option value="PR">Corr. Emergente (PR)</option>
                                  <option value="P">P</option>
                                  <option value="C">C</option>
                                  <option value="1B">1B</option>
                                  <option value="2B">2B</option>
                                  <option value="3B">3B</option>
                                  <option value="SS">SS</option>
                                  <option value="LF">LF</option>
                                  <option value="CF">CF</option>
                                  <option value="RF">RF</option>
                                  <option value="DH">DH</option>
                                </select>
                              </td>
                              <td class="text-center">
                                <span v-if="!editandoLineupVisitante">
                                  <span :class="jugador.es_titular ? 'text-success fw-bold' : 'text-muted'">{{ jugador.es_titular ? '✓' : '—' }}</span>
                                </span>
                                <input v-else type="checkbox" v-model="jugador.es_titular" class="form-check-input" @change="onTitularChange(jugador)" />
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </div>

                      <div v-if="puedeEditarLineupVisitante && partidoActual.estado !== 'finalizado'" class="mt-3 d-flex justify-content-end gap-2">
                        <button v-if="!editandoLineupVisitante" class="btn btn-sm btn-outline-primary" @click="editandoLineupVisitante = true"><IconEdit :size="14" class="me-1" /> Editar Lineup</button>
                        <template v-else>
                          <button class="btn btn-sm btn-success" @click="guardarLineupCompleto(partidoActual.id_equipo_visitante, 'visitante')" :disabled="guardandoLineup"><IconDeviceFloppy :size="14" class="me-1" /> Guardar</button>
                          <button class="btn btn-sm btn-ghost-secondary" @click="editandoLineupVisitante = false; verDetalle(partidoActual)">Cancelar</button>
                        </template>
                      </div>
                    </div>
                  </div>
                </div>
              </div>  

              <div v-if="tabActual === 'resultado'">
                <div v-if="!esAnotadorOrAdmin" class="alert alert-warning py-2 mb-3" style="font-size:0.82rem;">
                  <IconLock :size="15" class="me-1" /> Privilegios insuficientes. Solo los anotadores oficiales pueden cargar resultados.
                </div>
                <div v-else-if="!partidoYaComenzo" class="alert alert-warning py-2 mb-3" style="font-size:0.82rem;">
                  <IconInfoCircle :size="15" class="me-1" /> El partido aún no ha comenzado. No puedes registrar un resultado futuro.
                </div>
                <div v-else-if="partidoBloqueado24h" class="alert alert-warning py-2 mb-3" style="font-size:0.82rem; background-color:#fffbeb; color:#b45309; border-color:#fde68a;">
                  <IconAlertTriangle :size="15" class="me-1" /> Han pasado más de 24h desde el fin del encuentro. Cualquier corrección dejará un registro de auditoría.
                </div>

                <div class="card p-4">
                  <div class="d-flex align-items-center justify-content-center gap-4 mb-4 p-3" style="background:rgba(99,102,241,0.06); border-radius:14px;">
                    <div class="text-center">
                      <div class="team-avatar mx-auto mb-2" style="width:48px;height:48px;font-size:1.1rem;">{{ partidoActual.equipo_casa?.charAt(0) }}</div>
                      <div class="fw-semibold" style="font-size:0.82rem;">{{ partidoActual.equipo_casa }}</div>
                      <div class="fw-800 mt-1" style="font-size:2.5rem; color:#1e293b;">{{ resultadoForm.carreras_home }}</div>
                    </div>
                    <div class="text-muted fw-bold" style="font-size:1.2rem;">—</div>
                    <div class="text-center">
                      <div class="team-avatar mx-auto mb-2" style="width:48px;height:48px;font-size:1.1rem;background:linear-gradient(135deg,#f97316,#ef4444);">{{ partidoActual.equipo_visitante?.charAt(0) }}</div>
                      <div class="fw-semibold" style="font-size:0.82rem;">{{ partidoActual.equipo_visitante }}</div>
                      <div class="fw-800 mt-1" style="font-size:2.5rem; color:#1e293b;">{{ resultadoForm.carreras_visitantes }}</div>
                    </div>
                  </div>

                  <form v-if="esAnotadorOrAdmin && partidoYaComenzo" @submit.prevent="guardarResultado">
                    <div class="row g-2 mb-3">
                      <div class="col-6"><label class="form-label">Carreras Local</label><input v-model.number="resultadoForm.carreras_home" type="number" min="0" class="form-control" /></div>
                      <div class="col-6"><label class="form-label">Carreras Visitante</label><input v-model.number="resultadoForm.carreras_visitantes" type="number" min="0" class="form-control" /></div>
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
                      <div class="col-4"><label class="form-label">Innings totales</label><input v-model.number="resultadoForm.innings_totales" type="number" min="1" max="20" class="form-control" /></div>
                    </div>
                    <div class="mb-3">
                      <label class="form-label">Observaciones</label>
                      <textarea v-model="resultadoForm.observaciones" class="form-control form-control-sm" rows="2"></textarea>
                    </div>
                    <div class="text-end">
                      <button type="submit" class="btn btn-primary d-inline-flex align-items-center gap-2" :disabled="guardandoResultado">
                        <span v-if="guardandoResultado" class="spinner-border spinner-border-sm"></span><IconDeviceFloppy v-else :size="16" /> Guardar Resultado
                      </button>
                    </div>
                  </form>
                </div>
              </div>

              <div v-if="tabActual === 'estadisticas'">
                <div v-if="!esAnotadorOrAdmin" class="alert alert-warning py-2 mb-3" style="font-size:0.82rem;">
                  <IconLock :size="15" class="me-1" /> Privilegios insuficientes. Solo los anotadores oficiales pueden cargar estadísticas.
                </div>
                <div v-else-if="!partidoYaComenzo" class="alert alert-warning py-2 mb-3" style="font-size:0.82rem;">
                  <IconInfoCircle :size="15" class="me-1" /> El partido aún no ha comenzado.
                </div>
                <div v-else-if="partidoBloqueado24h" class="alert alert-warning py-2 mb-3" style="font-size:0.82rem; background-color:#fffbeb; color:#b45309; border-color:#fde68a;">
                  <IconAlertTriangle :size="15" class="me-1" /> Han pasado más de 24h desde el fin del encuentro. Cualquier corrección dejará un registro de auditoría.
                </div>

                <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                  <div class="btn-group" role="group">
                    <button type="button" class="btn btn-sm" :class="equipoStatsSeleccionado === 'local' ? 'btn-primary' : 'btn-outline-primary'" @click="equipoStatsSeleccionado = 'local'">
                      Local: {{ partidoActual.equipo_casa }}
                    </button>
                    <button type="button" class="btn btn-sm" :class="equipoStatsSeleccionado === 'visitante' ? 'btn-primary' : 'btn-outline-primary'" @click="equipoStatsSeleccionado = 'visitante'">
                      Visitante: {{ partidoActual.equipo_visitante }}
                    </button>
                  </div>
                  <button v-if="esAnotadorOrAdmin && partidoYaComenzo" class="btn btn-sm btn-info d-flex align-items-center gap-1" @click="sincronizarResultadoDesdeStats" title="Suma las carreras y hits de ambos equipos y los pasa al Resultado">
                    <IconChartBar :size="14" /> Sincronizar al Resultado
                  </button>
                </div>

                <div class="mb-4">
                  <h6 class="fw-bold mb-3" style="font-size:0.875rem;">Bateadores ({{ equipoStatsSeleccionado === 'local' ? partidoActual.equipo_casa : partidoActual.equipo_visitante }})</h6>
                  <div class="table-responsive">
                    <table class="table table-sm table-vcenter">
                      <thead>
                        <tr style="font-size: 0.75rem;">
                          <th>Jugador</th>
                          <th><AbrevTooltip ab="AB" /></th>
                          <th><AbrevTooltip ab="C" /></th>
                          <th><AbrevTooltip ab="H" /></th>
                          <th><AbrevTooltip ab="HR" /></th>
                          <th><AbrevTooltip ab="CI" /></th>
                          <th v-if="esAnotadorOrAdmin && partidoYaComenzo">Acción</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-if="!statsVisibles.bateadores.length">
                          <td colspan="7" class="text-center text-muted py-3">No hay bateadores registrados para este equipo. Verifica el Lineup.</td>
                        </tr>
                        <tr v-for="b in statsVisibles.bateadores" :key="b.id_jugador">
                          <td class="fw-semibold" style="font-size:0.8rem;">
                            <RouterLink
                              :to="{ name: 'EstadisticasJugador', params: { id: b.id_jugador } }"
                              class="text-decoration-none"
                              style="color:inherit;"
                            >
                              {{ b.nombre }} {{ b.apellido }}
                              <IconExternalLink :size="11" style="opacity:0.4; margin-left:2px;" />
                            </RouterLink>
                          </td>
                          <template v-if="esAnotadorOrAdmin && partidoYaComenzo">
                            <td><input type="number" min="0" class="form-control form-control-sm text-center px-1" style="width:45px;" v-model.number="b.turnos_al_bate" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm text-center px-1 bg-blue-lt" style="width:45px;" v-model.number="b.carreras" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm text-center px-1 bg-blue-lt" style="width:45px;" v-model.number="b.hits" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm text-center px-1" style="width:45px;" v-model.number="b.jonrones" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm text-center px-1" style="width:45px;" v-model.number="b.carreras_impulsadas" /></td>
                            <td><button class="btn btn-xs btn-ghost-primary" @click="guardarStatBateador(b)"><IconDeviceFloppy :size="14" /></button></td>
                          </template>
                          <template v-else>
                            <td class="text-center">{{ b.turnos_al_bate }}</td><td class="text-center">{{ b.carreras }}</td><td class="text-center">{{ b.hits }}</td><td class="text-center">{{ b.jonrones }}</td><td class="text-center">{{ b.carreras_impulsadas }}</td>
                          </template>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>

                <div>
                  <h6 class="fw-bold mb-3" style="font-size:0.875rem;">Pitchers ({{ equipoStatsSeleccionado === 'local' ? partidoActual.equipo_casa : partidoActual.equipo_visitante }})</h6>
                  <div class="table-responsive">
                    <table class="table table-sm table-vcenter">
                      <thead>
                        <tr style="font-size: 0.75rem;">
                          <th>Jugador</th>
                          <th><AbrevTooltip ab="IP" /></th>
                          <th><AbrevTooltip ab="H" /></th>
                          <th><AbrevTooltip ab="CP" /></th>
                          <th><AbrevTooltip ab="SO" /></th>
                          <th v-if="esAnotadorOrAdmin && partidoYaComenzo">Acción</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-if="!statsVisibles.pitchers.length">
                          <td colspan="6" class="text-center text-muted py-3">No hay pitchers registrados para este equipo. Verifica el Lineup.</td>
                        </tr>
                        <tr v-for="pt in statsVisibles.pitchers" :key="pt.id_jugador">
                          <td class="fw-semibold" style="font-size:0.8rem;">
                            <RouterLink
                              :to="{ name: 'EstadisticasJugador', params: { id: pt.id_jugador } }"
                              class="text-decoration-none"
                              style="color:inherit;"
                            >
                              {{ pt.nombre }} {{ pt.apellido }}
                              <IconExternalLink :size="11" style="opacity:0.4; margin-left:2px;" />
                            </RouterLink>
                          </td>
                          <template v-if="esAnotadorOrAdmin && partidoYaComenzo">
                            <td><input type="number" min="0" step="0.1" class="form-control form-control-sm text-center px-1" style="width:55px;" v-model.number="pt.innings_pitcheados" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm text-center px-1" style="width:50px;" v-model.number="pt.hits_permitidos" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm text-center px-1" style="width:50px;" v-model.number="pt.carreras_permitidas" /></td>
                            <td><input type="number" min="0" class="form-control form-control-sm text-center px-1" style="width:50px;" v-model.number="pt.ponches" /></td>
                            <td><button class="btn btn-xs btn-ghost-primary" @click="guardarStatPitcher(pt)"><IconDeviceFloppy :size="14" /></button></td>
                          </template>
                          <template v-else>
                            <td class="text-center">{{ pt.innings_pitcheados }}</td><td class="text-center">{{ pt.hits_permitidos }}</td><td class="text-center">{{ pt.carreras_permitidas }}</td><td class="text-center">{{ pt.ponches }}</td>
                          </template>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>

              <div v-if="tabActual === 'taquilla'">
                <div v-if="partidoBloqueado24h" class="alert alert-warning py-2 mb-3" style="font-size:0.82rem; background-color:#fffbeb; color:#b45309; border-color:#fde68a;">
                  <IconAlertTriangle :size="15" class="me-1" /> Han pasado más de 24h. Cualquier corrección a la taquilla dejará un registro de auditoría.
                </div>
                <div class="card p-4">
                  <h6 class="fw-bold mb-4" style="font-size:0.875rem; color:#1e293b;">Datos de Taquilla</h6>
                  <div>
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
    </div>
    <div v-if="modalDetalle" class="modal-backdrop show"></div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, markRaw } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/store/auth'
import { useToast }   from '@/composables/useToast'
import { useConfirm } from '@/composables/useConfirm'
import AbrevTooltip from '@/components/AbrevTooltip.vue'
import {
  IconPlus, IconCalendarEvent, IconEye, IconTrash, IconMapPin,
  IconLock, IconDeviceFloppy, IconInfoCircle, IconListDetails,
  IconTrophy, IconChartBar, IconTicket, IconSearch, IconEdit, IconAlertTriangle
} from '@tabler/icons-vue'

const toast   = useToast()
const confirm = useConfirm()
const auth    = useAuthStore()

// ========== DATOS PRINCIPALES ==========
const partidos   = ref([])
const equipos    = ref([])
const jugadores  = ref([])
const temporadas = ref([])
const estadios   = ref([])
const cargando   = ref(false)
const filtroEstado = ref('')
const busqueda     = ref('')

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
const nuevoForm    = ref({ id_temporada: '', id_equipo_casa: '', id_equipo_visitante: '', id_estadio: '', fecha_juego: '', hora_juego: '10:00', lugar: '', innings_programados: 9 })

// Modal detalle
const modalDetalle  = ref(false)
const partidoActual = ref(null)
const tabActual     = ref('info')
const reprogramarForm = ref({ fecha: '', hora: '' })
const hoyStr = computed(() => new Date().toISOString().slice(0, 10))
const lineup        = ref([])
const desempeno     = ref({ bateadores: [], pitchers: [] })
const resultadoForm = ref({ carreras_home: 0, carreras_visitantes: 0, hits_home: 0, hits_visitantes: 0, errores_home: 0, errores_visitantes: 0, innings_totales: 9, observaciones: '' })
const guardandoResultado = ref(false)

// Lineup Editable Variables
const editandoLineupLocal = ref(false)
const editandoLineupVisitante = ref(false)
const guardandoLineup = ref(false)
const nuevoBateador = ref('')
const nuevoPitcher  = ref('')
const equipoStatsSeleccionado = ref('local')

const statsLocal = computed(() => {
  if (!partidoActual.value) return { bateadores: [], pitchers: [] }
  return {
    bateadores: desempeno.value.bateadores.filter(b => b.id_equipo === partidoActual.value.id_equipo_casa),
    pitchers: desempeno.value.pitchers.filter(p => p.id_equipo === partidoActual.value.id_equipo_casa)
  }
})

const statsVisitante = computed(() => {
  if (!partidoActual.value) return { bateadores: [], pitchers: [] }
  return {
    bateadores: desempeno.value.bateadores.filter(b => b.id_equipo === partidoActual.value.id_equipo_visitante),
    pitchers: desempeno.value.pitchers.filter(p => p.id_equipo === partidoActual.value.id_equipo_visitante)
  }
})

const statsVisibles = computed(() => {
  return equipoStatsSeleccionado.value === 'local' ? statsLocal.value : statsVisitante.value
})
// Taquilla
const taquillaForm = ref({ boletos_general: 0, precio_general: 0, boletos_vip: 0, precio_vip: 0, capacidad_estadio: 0 })
const guardandoTaquilla = ref(false)
const recaudadoTaquilla = computed(() =>
  (taquillaForm.value.boletos_general * taquillaForm.value.precio_general) +
  (taquillaForm.value.boletos_vip     * taquillaForm.value.precio_vip)
)

// =====================================================================
// DEFINICIÓN PERFECTA DE ROLES (COMPUTADAS)
// =====================================================================
const esAdministrador = computed(() => auth.rol === 'administrador' || auth.esAdmin);
const esDueno = computed(() => auth.rol === 'dueno' || auth.esDueno);
const esAnotadorOrAdmin = computed(() => auth.rol === 'anotador' || esAdministrador.value);

const puedeEditarLineupLocal = computed(() => {
  if (esAnotadorOrAdmin.value) return true;
  if (esDueno.value && Number(auth.id_equipo) === Number(partidoActual.value?.id_equipo_casa)) return true;
  return false;
});

const puedeEditarLineupVisitante = computed(() => {
  if (esAnotadorOrAdmin.value) return true;
  if (esDueno.value && Number(auth.id_equipo) === Number(partidoActual.value?.id_equipo_visitante)) return true;
  return false;
});

const tabsDisponibles = computed(() => {
  const tabs = [
    { id: 'info',         label: 'Info & Estado',   icon: markRaw(IconInfoCircle) },
    { id: 'lineup',       label: 'Lineup',          icon: markRaw(IconListDetails) },
    { id: 'resultado',    label: 'Resultado',       icon: markRaw(IconTrophy) },
    { id: 'estadisticas', label: 'Estadísticas',    icon: markRaw(IconChartBar) },
  ]
  if (auth.puedeTaquilla) tabs.push({ id: 'taquilla', label: 'Taquilla', icon: markRaw(IconTicket) })
  return tabs
})

// =====================================================================
// VARIABLES COMPUTADAS PARA REGLAS DE TIEMPO (24H Y FUTURO)
// =====================================================================
const partidoYaComenzo = computed(() => {
  if (!partidoActual.value || !partidoActual.value.fecha_juego || !partidoActual.value.hora_juego) return false;
  const fechaStr = typeof partidoActual.value.fecha_juego === 'string' ? partidoActual.value.fecha_juego.split('T')[0] : partidoActual.value.fecha_juego.toISOString().split('T')[0];
  const fechaHoraJuego = new Date(`${fechaStr}T${partidoActual.value.hora_juego}`);
  return new Date() >= fechaHoraJuego;
});

const partidoBloqueado24h = computed(() => {
  if (!partidoActual.value || partidoActual.value.estado !== 'finalizado') return false;
  
  const fechaStr = typeof partidoActual.value.fecha_juego === 'string' ? partidoActual.value.fecha_juego.split('T')[0] : partidoActual.value.fecha_juego.toISOString().split('T')[0];
  const fechaJuego = new Date(`${fechaStr}T${partidoActual.value.hora_juego}`);
  
  const limiteEdicion = new Date(fechaJuego.getTime() + (30 * 60 * 60 * 1000));
  return new Date() > limiteEdicion;
});

// =====================================================================

const paginaActual   = ref(1)
const porPagina      = 8

const partidosFiltrados = computed(() => {
  const q = busqueda.value.toLowerCase().trim()
  const equipoId = auth.id_equipo ? Number(auth.id_equipo) : null
  return partidos.value.filter(p => {
    if (esDueno.value && equipoId) {
      if (Number(p.id_equipo_casa) !== equipoId && Number(p.id_equipo_visitante) !== equipoId) {
        return false
      }
    }
    if (filtroEstado.value && p.estado !== filtroEstado.value) return false
    if (!q) return true
    return (
      p.equipo_casa?.toLowerCase().includes(q) ||
      p.equipo_visitante?.toLowerCase().includes(q) ||
      p.lugar?.toLowerCase().includes(q)
    )
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
  return lineup.value
    .filter(l => l.id_equipo === id_equipo)
    .sort((a, b) => {
      const ordA = a.orden_bateo || 999;
      const ordB = b.orden_bateo || 999;
      return ordA - ordB;
    });
}

function ajustarOrden(jugadorModificado, id_equipo) {
  let nuevoOrden = jugadorModificado.orden_bateo;
  let viejoOrden = jugadorModificado._viejoOrden;

  if (!nuevoOrden || nuevoOrden < 1) {
    jugadorModificado.orden_bateo = null;
    jugadorModificado._viejoOrden = null;
    reindexarLineup(id_equipo);
    return;
  }

  if (nuevoOrden === viejoOrden) return;

  const equipoLineup = lineup.value.filter(j => j.id_equipo === id_equipo);

  equipoLineup.forEach(j => {
    if (j.id_jugador !== jugadorModificado.id_jugador && j.orden_bateo) {
      if ((!viejoOrden || viejoOrden > nuevoOrden) && j.orden_bateo >= nuevoOrden && j.orden_bateo < (viejoOrden || 999)) {
        j.orden_bateo++;
      } 
      else if (viejoOrden && viejoOrden < nuevoOrden && j.orden_bateo <= nuevoOrden && j.orden_bateo > viejoOrden) {
        j.orden_bateo--;
      }
    }
  });

  reindexarLineup(id_equipo);
}



function reindexarLineup(id_equipo) {
  const equipoLineup = lineup.value.filter(j => j.id_equipo === id_equipo);
  const ordenados = equipoLineup
    .filter(j => j.orden_bateo)
    .sort((a, b) => a.orden_bateo - b.orden_bateo);
    
  ordenados.forEach((j, idx) => { j.orden_bateo = idx + 1; });
}

async function guardarLineupCompleto(idEquipo, tipo) {
  // 1. Obtenemos los peloteros pertenecientes al equipo que se está guardando
  const jugadores = lineupEquipo(idEquipo);

  // 2. Filtramos los que actúan en el terreno (Titulares activos que no sean BN)
  const titulares = jugadores.filter(j => j.es_titular && j.posicion_juego !== 'BN');

  // REGLA 1: Validación estricta del Pitcher abridor único
  const pitchersAbridores = titulares.filter(j => j.posicion_juego === 'P');
  if (pitchersAbridores.length > 1) {
    toast.error(`Regla de Béisbol Rota: Solo puede haber 1 Lanzador (P) abridor en el terreno. Por favor, pasa los lanzadores relevistas a la 'Banca (BN)'.`);
    return; // Cancela el envío de información
  }

  // REGLA 2: No duplicar posiciones defensivas en el terreno de juego
  const posicionesOcupadas = new Set();
  for (const j of titulares) {
    if (posicionesOcupadas.has(j.posicion_juego)) {
      toast.error(`Conflicto de Posición: La posición defensiva '${j.posicion_juego}' ya está asignada a otro jugador titular.`);
      return; // Cancela el envío de información
    }
    posicionesOcupadas.add(j.posicion_juego);
  }

  // 3. Mapeo y saneamiento de datos seguro antes de enviar al servidor
  const entries = jugadores.map(j => ({
    id_partido: partidoActual.value.id_partido,
    id_jugador: j.id_jugador,
    id_equipo: idEquipo,
    orden_bateo: j.es_titular ? (j.orden_bateo || null) : null,
    posicion_juego: j.posicion_juego || 'BN', // Garantiza 'BN' en vez de cadenas vacías
    es_titular: j.es_titular ? 1 : 0
  }));

  guardandoLineup.value = true;
  try {
    // Se envía el lote correspondiente al backend
    await api.post(`/partidos/${partidoActual.value.id_partido}/lineup`, { entries });
    toast.success(`⚾ ¡Lineup ${tipo === 'local' ? 'Local' : 'Visitante'} guardado y validado con éxito!`);
    
    // Cerramos el modo edición de la columna correspondiente
    if (tipo === 'local') editandoLineupLocal.value = false;
    else editandoLineupVisitante.value = false;
    
    // Refrescamos los datos generales de la vista
    await verDetalle(partidoActual.value);
  } catch (e) {
    toast.error(e.response?.data?.error || 'Ocurrió un error al guardar la alineación.');
  } finally {
    guardandoLineup.value = false;
  }
}

function jugadoresPorEquipo(id_equipo) {
  return jugadores.value.filter(j => j.id_equipo === id_equipo && j.activo)
}

const jugadoresNoEnBateadores = computed(() => {
  if (!partidoActual.value) return { casa: [], visitante: [] }
  const ids = new Set(desempeno.value.bateadores.map(b => b.id_jugador))
  const casa = jugadores.value.filter(j => !ids.has(j.id_jugador) && j.id_equipo === partidoActual.value.id_equipo_casa)
  const visitante = jugadores.value.filter(j => !ids.has(j.id_jugador) && j.id_equipo === partidoActual.value.id_equipo_visitante)
  return { casa, visitante }
})

const pitchersNoEnStats = computed(() => {
  if (!partidoActual.value) return { casa: [], visitante: [] }
  const ids = new Set(desempeno.value.pitchers.map(p => p.id_jugador))
  const esPitcher = j => !ids.has(j.id_jugador) && (j.rol === 'pitcher' || j.rol === 'utilidad')
  const casa = jugadores.value.filter(j => esPitcher(j) && j.id_equipo === partidoActual.value.id_equipo_casa)
  const visitante = jugadores.value.filter(j => esPitcher(j) && j.id_equipo === partidoActual.value.id_equipo_visitante)
  return { casa, visitante }
})

async function cargar() {
  cargando.value = true
  try {
    const [resP, resE, resJ, resT, resEs] = await Promise.all([
      api.get('/partidos'),
      api.get('/equipos'),
      api.get('/jugadores'),
      api.get('/temporadas'),
      (auth.esAdmin || esAdministrador.value) ? api.get('/estadios?activo=1') : Promise.resolve({ data: [] }),
    ])
    partidos.value   = resP.data
    equipos.value    = resE.data
    jugadores.value  = resJ.data
    temporadas.value = resT.data
    estadios.value   = resEs.data
  } finally { cargando.value = false }
}

async function verDetalle(partido) {
  partidoActual.value = { ...partido }
  tabActual.value = 'info'
  modalDetalle.value = true
  nuevoBateador.value = ''
  nuevoPitcher.value  = ''
  reprogramarForm.value = { fecha: partido.fecha_juego?.substring(0, 10) || '', hora: partido.hora_juego?.substring(0, 5) || '' }
  
  editandoLineupLocal.value = false
  editandoLineupVisitante.value = false

  const [resL, resD, resR, resT] = await Promise.all([
    api.get(`/partidos/${partido.id_partido}/lineup`),
    api.get(`/partidos/${partido.id_partido}/desempeno`),
    api.get(`/partidos/${partido.id_partido}/resultado`),
    auth.puedeTaquilla ? api.get(`/partidos/${partido.id_partido}/taquilla`) : Promise.resolve({ data: null }),
  ])
  lineup.value = resL.data
  desempeno.value = resD.data

  if (resR.data) {
    Object.assign(resultadoForm.value, resR.data)
  } else {
    resultadoForm.value = { carreras_home: 0, carreras_visitantes: 0, hits_home: 0, hits_visitantes: 0, errores_home: 0, errores_visitantes: 0, innings_totales: 9, observaciones: '' }
  }

  partidoActual.value.resultado = resR.data

  if (resT.data) Object.assign(taquillaForm.value, resT.data)
  else taquillaForm.value = { boletos_general: 0, precio_general: 0, boletos_vip: 0, precio_vip: 0, capacidad_estadio: 0 }
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
  if (nuevoForm.value.id_equipo_casa && nuevoForm.value.id_equipo_visitante &&
      nuevoForm.value.id_equipo_casa === nuevoForm.value.id_equipo_visitante) {
    errorNuevo.value = 'El equipo local y visitante no pueden ser el mismo'; return
  }
  if (nuevoForm.value.fecha_juego && nuevoForm.value.hora_juego) {
    const fechaHora = new Date(`${nuevoForm.value.fecha_juego}T${nuevoForm.value.hora_juego}`)
    if (fechaHora <= new Date()) {
      errorNuevo.value = 'Solo se pueden programar partidos en fechas futuras'; return
    }
  }
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
  if (new Date(`${fecha}T${hora}`) <= new Date()) {
    toast.warn('La nueva fecha y hora debe ser futura'); return
  }
  try {
    await api.patch(`/partidos/${partidoActual.value.id_partido}/reprogramar`, { fecha_juego: fecha, hora_juego: hora })
    partidoActual.value.fecha_juego = fecha
    partidoActual.value.hora_juego  = hora + ':00'
    partidoActual.value.estado = 'programado'
    const idx = partidos.value.findIndex(p => p.id_partido === partidoActual.value.id_partido)
    if (idx >= 0) {
      partidos.value[idx].fecha_juego = fecha
      partidos.value[idx].hora_juego  = hora + ':00'
      partidos.value[idx].estado = 'programado'
    }
    toast.success('Partido reprogramado con éxito');
  } catch (e) {
    toast.error(e.response?.data?.error || 'Error al reprogramar el partido')
  }
}

function sincronizarResultadoDesdeStats() {
  let carrerasL = 0, hitsL = 0;
  statsLocal.value.bateadores.forEach(b => { 
    carrerasL += (b.carreras || 0); 
    hitsL += (b.hits || 0); 
  });

  let carrerasV = 0, hitsV = 0;
  statsVisitante.value.bateadores.forEach(b => { 
    carrerasV += (b.carreras || 0); 
    hitsV += (b.hits || 0); 
  });

  resultadoForm.value.carreras_home = carrerasL;
  resultadoForm.value.hits_home = hitsL;
  resultadoForm.value.carreras_visitantes = carrerasV;
  resultadoForm.value.hits_visitantes = hitsV;

  toast.success('📊 Carreras y Hits sincronizados desde las estadísticas.');
}

async function guardarResultado() {
  if (resultadoForm.value.carreras_home === resultadoForm.value.carreras_visitantes) {
    toast.warn('⚾ El béisbol no permite empates. Revisa las carreras antes de guardar.');
    return;
  }
  guardandoResultado.value = true
  try {
    await api.post(`/partidos/${partidoActual.value.id_partido}/resultado`, resultadoForm.value)
    partidoActual.value.estado = 'finalizado'
    partidoActual.value.resultado = { ...resultadoForm.value }
    const idx = partidos.value.findIndex(p => p.id_partido === partidoActual.value.id_partido)
    if (idx >= 0) partidos.value[idx].estado = 'finalizado'
    toast.success('Resultado sellado correctamente')
  } catch (e) {
    toast.error(e.response?.data?.error || 'Error al guardar resultado')
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

function onTitularChange(jugador) {
  if (!jugador.es_titular) {
    // Si se quita de titular, pasa inmediatamente a la Banca y pierde el turno de bateo
    jugador.posicion_juego = 'BN';
    jugador.orden_bateo = null;
  } else {
    // Si se activa como titular, se le pre-asigna su posición natural (si no es BN)
    if (jugador.posicion_juego === 'BN' || !jugador.posicion_juego) {
      jugador.posicion_juego = jugador.posicion_natural && jugador.posicion_natural !== 'BN' 
        ? jugador.posicion_natural 
        : 'DH'; // Por defecto Designado si no hay otra opción
    }
  }
}

function onPosicionChange(jugador) {
  if (jugador.posicion_juego === 'BN') {
    // Si el anotador elige "Banca (BN)" en el select, desmarcamos el estado titular
    jugador.es_titular = false;
    jugador.orden_bateo = null;
  } else {
    // Cualquier otra posición real en el campo lo convierte automáticamente en titular
    jugador.es_titular = true;
  }
}



async function guardarStatBateador(b) {
  // --- REGLAS INTELIGENTES DE BÉISBOL ---
  
  // 1. Un Jonrón (HR) cuenta obligatoriamente como Hit, Carrera y Carrera Impulsada
  if (b.jonrones > 0) {
    if (b.hits < b.jonrones) b.hits = b.jonrones;
    if (b.carreras < b.jonrones) b.carreras = b.jonrones;
    if (b.carreras_impulsadas < b.jonrones) b.carreras_impulsadas = b.jonrones;
  }

  // 2. Validación lógica
  if (b.hits > b.turnos_al_bate) {
    toast.warn('Matemática incorrecta: Los Hits no pueden superar los Turnos al Bate (AB)'); 
    return;
  }

  try {
    await api.post(`/partidos/${partidoActual.value.id_partido}/desempeno/bateador`, { ...b, id_partido: partidoActual.value.id_partido })
    toast.success('Estadística de bateador guardada')
  } catch (error) { 
    toast.error('Error al guardar estadística') 
  }
}

async function guardarStatPitcher(pt) {
  // --- REGLAS INTELIGENTES DE BÉISBOL ---
  
  // Toda Carrera Limpia (CP/ER) es por definición una Carrera Permitida. 
  // Si el anotador pone más limpias que permitidas, el sistema lo auto-corrige hacia arriba.
  if (pt.carreras_limpias > pt.carreras_permitidas) {
    pt.carreras_permitidas = pt.carreras_limpias;
  }

  try {
    await api.post(`/partidos/${partidoActual.value.id_partido}/desempeno/pitcher`, { ...pt, id_partido: partidoActual.value.id_partido })
    toast.success('Estadística de pitcher guardada')
  } catch (error) { 
    toast.error('Error al guardar estadística') 
  }
}

async function guardarTaquilla() {
  guardandoTaquilla.value = true
  try {
    await api.patch(`/partidos/${partidoActual.value.id_partido}/taquilla`, taquillaForm.value)
    toast.success('Datos de taquilla guardados correctamente.')
  } catch (e) {
    toast.error(e.response?.data?.error || 'Error al guardar taquilla')
  } finally { guardandoTaquilla.value = false }
}

onMounted(cargar)
</script>

<style scoped>
.partido-search-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}
.partido-search-icon {
  position: absolute;
  left: 9px;
  color: #94a3b8;
  pointer-events: none;
}
.partido-search {
  padding-left: 28px;
  min-width: 220px;
  border-radius: 20px;
}
</style>