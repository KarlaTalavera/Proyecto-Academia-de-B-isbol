# Liga Diamante — Sistema de Gestión

Stack: Node.js + Express (backend) | Vue 3 + Vite (frontend) | MariaDB

## Requisitos previos
- Node.js >= 18
- MariaDB / MySQL >= 10.4
- pnpm o npm

## 1. Base de Datos

```bash
mysql -u root -p < liga-diamante-v2.sql
```

## 2. Backend

```bash
cd backend
cp .env.example .env        # Configura tus credenciales de BD
npm install
npm run dev                 # Escucha en http://localhost:3000
```

## 3. Frontend

```bash
cd frontend
npm install
npm run dev                 # Escucha en http://localhost:5173
```

## Estructura del proyecto

```
liga-de-beisbol/
├── backend/
│   └── src/
│       ├── config/         # Conexión a la BD
│       ├── models/         # Capa de datos (SQL)
│       ├── controllers/    # Lógica de negocio
│       ├── routes/         # Endpoints Express
│       ├── middlewares/    # JWT + Roles
│       └── app.js
├── frontend/
│   └── src/
│       ├── components/     # AppLayout (sidebar + nav)
│       ├── views/          # Vistas por módulo
│       ├── store/          # Pinia (auth)
│       ├── router/         # Vue Router
│       └── services/api.js # Axios configurado
├── liga-diamante.sql       # Schema original (respaldo)
└── liga-diamante-v2.sql    # Schema corregido (usar este)
```

## Roles de acceso

| Rol | Permisos |
|---|---|
| `administrador` | Acceso total |
| `dueno` | Equipos, jugadores, partidos, resultados |
| `caja` | Ingresos y egresos |
| `publico` | Solo lectura de resultados y estadísticas |
