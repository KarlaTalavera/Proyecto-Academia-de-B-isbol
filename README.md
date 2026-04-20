# Liga Diamante — Sistema de Gestión

Sistema de gestión para la Liga Diamante de Béisbol, incluyendo página pública para fanáticos y panel administrativo por roles.

**Stack:** Node.js + Express · Vue 3 + Vite · MySQL / MariaDB

---

## Requisitos previos

Instala esto antes de empezar:

| Herramienta | Versión mínima | Descarga |
|---|---|---|
| Node.js | 18 | https://nodejs.org |
| MySQL o MariaDB | 10.4 / 8.0 | phpMyAdmin, XAMPP, HeidiSQL, etc. |
| Git | cualquiera | https://git-scm.com |

> **Verificar que tienes lo necesario:**
> ```bash
> node -v      # debe mostrar v18.x.x o superior
> npm -v       # viene con Node
> mysql --version
> ```

---

## Paso 1 — Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd liga-de-beisbol
```

---

## Paso 2 — Base de datos

### 2.1 Crear la base de datos

Abre tu cliente de MySQL (phpMyAdmin, HeidiSQL, MySQL Workbench o terminal) y ejecuta:

```sql
CREATE DATABASE liga_diamante CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 2.2 Importar el esquema

Desde la terminal, en la raíz del proyecto:

```bash
mysql -u root -p liga_diamante < liga-diamante-v2.sql
```

> Si tienes contraseña en MySQL te la pedirá. Si no tienes contraseña, quita el `-p`.

También puedes importar el archivo `liga-diamante-v2.sql` directamente desde phpMyAdmin:
**Seleccionar base de datos → Importar → Elegir archivo → Ejecutar**

### 2.3 (Opcional) Cargar datos de prueba

```bash
mysql -u root -p liga_diamante < test-data.sql
```

---

## Paso 3 — Configurar el Backend

### 3.1 Crear el archivo .env

```bash
cd backend
cp .env.example .env
```

> En Windows sin Git Bash: copia el archivo `.env.example` manualmente y renómbralo a `.env`

### 3.2 Editar el .env

Abre `backend/.env` y ajusta estos valores:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=          # ← tu contraseña de MySQL (déjalo vacío si no tienes)
DB_NAME=liga_diamante

JWT_SECRET=escribe_aqui_cualquier_texto_largo    # ← IMPORTANTE: no dejar vacío
JWT_EXPIRES_IN=8h

PORT=3000
FRONTEND_URL=http://localhost:5173
```

**¿Qué poner en JWT_SECRET?**
Puede ser cualquier texto largo y aleatorio. Para generar uno automáticamente:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```
Copia el resultado y pégalo como valor de `JWT_SECRET`.

> importante: Si dejas `JWT_SECRET` vacío el backend arranca pero el login no funcionará.

### 3.3 Instalar dependencias y arrancar

```bash
# Desde la carpeta backend/
npm install
npm run dev
```

Deberías ver:
```
API Liga Diamante escuchando en http://localhost:3000
```

---

## Paso 4 — Configurar el Frontend

El frontend **no necesita archivo .env** para desarrollo local. El proxy de Vite se encarga de redirigir las llamadas a la API automáticamente.

```bash
# Desde la carpeta frontend/
cd ../frontend
npm install
npm run dev
```

Deberías ver:
```
  VITE v5.x.x  ready in xxx ms
  ➜  Local:   http://localhost:5173/
```

---

## Acceder al sistema

Con ambos servidores corriendo:

| URL | Descripción |
|---|---|
| http://localhost:5173 | Página pública (fanáticos) |
| http://localhost:5173/login | Login del sistema administrativo |
| http://localhost:3000/api | API REST (backend) |

---

## Roles de acceso

| Rol | Qué puede hacer |
|---|---|
| `administrador` | Acceso total al sistema |
| `dueno` | Equipos, jugadores, partidos, noticias, inscripciones |
| `caja` | Finanzas (ingresos y egresos) |
| `anotador` | Cargar lineups, cambiar estado de partidos, anotar estadísticas |
| `publico` | Solo ver resultados y estadísticas (zona fanático) |

> Los usuarios se crean desde el módulo **Usuarios** con rol `administrador`.

---

## Estructura del proyecto

```
liga-de-beisbol/
├── backend/
│   ├── src/
│   │   ├── config/         # Conexión a la BD
│   │   ├── controllers/    # Lógica de negocio
│   │   ├── middlewares/    # JWT + control de roles
│   │   ├── models/         # Consultas SQL
│   │   ├── routes/         # Endpoints Express
│   │   └── app.js          # Entrada principal
│   ├── uploads/            # Fotos subidas (generado automáticamente)
│   ├── .env                # Variables de entorno (NO se sube al repo)
│   └── .env.example        # Plantilla del .env
├── frontend/
│   └── src/
│       ├── components/     # Layout, header, componentes reutilizables
│       ├── views/          # Vistas por módulo
│       ├── store/          # Estado global (Pinia — auth)
│       ├── router/         # Rutas Vue Router
│       └── services/api.js # Axios configurado
├── liga-diamante-v2.sql    # Esquema de la BD (importar este)
├── test-data.sql           # Datos de prueba opcionales
└── README.md
```

---

## Problemas comunes

### "Cannot connect to database" / "Access denied"
→ Revisa `DB_USER`, `DB_PASSWORD` y `DB_NAME` en el `.env`. Asegúrate de que la base de datos `liga_diamante` existe.

### El login devuelve error 500 o "Token inválido"
→ `JWT_SECRET` está vacío en el `.env`. Ponle cualquier texto largo.

### El frontend dice "Network Error" o no carga datos
→ Verifica que el backend esté corriendo en el puerto 3000. Deben estar los dos servidores activos al mismo tiempo.

### "npm install" falla con errores de permisos (Windows)
→ Abre la terminal como **Administrador** o usa `npm install --legacy-peer-deps`.

### Las fotos subidas no aparecen
→ La carpeta `backend/uploads/` se crea automáticamente. Si no existe, créala manualmente.
