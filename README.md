# Masjid Management System Docker Setup

This repository contains a NestJS/Prisma backend, a Flutter Web frontend, and PostgreSQL. Docker lets a new developer run everything without installing Node, Flutter, PostgreSQL, or Nginx locally.

## Prerequisites

1. Git
2. Docker Desktop
3. Docker Compose plugin (`docker compose version`)

## First-time setup

1. Clone the repository.
2. Open the project directory:
   ```sh
   cd masjid-management-system
   ```
3. Copy environment examples:
   ```sh
   cp .env.example .env
   cp masjid-core/.env.example masjid-core/.env
   ```
   Windows PowerShell:
   ```powershell
   Copy-Item .env.example .env
   Copy-Item masjid-core/.env.example masjid-core/.env
   ```
4. Fill required values in `.env` and `masjid-core/.env`. Do not commit real `.env` files.
5. Start the complete application:
   ```sh
   docker compose up --build -d
   ```
6. Check containers:
   ```sh
   docker compose ps
   ```
7. Open:
   - Frontend: <http://localhost:8080>
   - Backend Swagger: <http://localhost:3000/api>
   - Backend health: <http://localhost:3000/api/v1/health>
   - PostgreSQL from DBeaver/pgAdmin on Windows/macOS/Linux:
     - host: `localhost`
     - port: `5433`
     - database/user/password: values from root `.env`

Inside Docker, the backend connects to PostgreSQL with hostname `postgres`. From your host tools, use `localhost:5433`.

## Optional seed/bootstrap commands

Migrations run automatically with `prisma migrate deploy` when the backend container starts. Seeds and superadmin bootstrap do **not** run automatically.

Run these only when required:

```sh
docker compose exec backend npm run prisma:seed
docker compose exec backend npm run bootstrap:super-admin
```

Create a new development migration from your host after editing `schema.prisma`:

```sh
cd masjid-core
npm run prisma:migrate -- --name your_migration_name
```

Commit the generated folder under `masjid-core/prisma/migrations`.

## Useful commands

```sh
docker compose up -d
docker compose up --build -d
docker compose down
# WARNING: deletes PostgreSQL data volume
docker compose down -v
docker compose logs -f
docker compose logs -f backend
docker compose restart backend
docker compose exec backend sh
docker compose exec postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
docker compose build frontend
docker compose ps
```

## Helper scripts

Linux/macOS:

```sh
./scripts/setup.sh
./scripts/start.sh
./scripts/logs.sh
./scripts/stop.sh
```

Windows PowerShell:

```powershell
./scripts/setup.ps1
./scripts/start.ps1
./scripts/logs.ps1
./scripts/stop.ps1
```

The setup scripts copy `.env.example` files only when the matching `.env` file does not already exist.

## Development backend hot reload

The normal `docker compose up --build -d` command uses production-style images. For backend hot reload, use the separate dev compose file:

```sh
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build -d backend
```

This bind-mounts `masjid-core`, keeps `node_modules` in a Docker volume, regenerates Prisma client, and runs `npm run start:dev`.

## Troubleshooting

- **Docker Desktop not running**: start Docker Desktop and retry `docker compose ps`.
- **Port 5433 already in use**: stop the other PostgreSQL instance or change the host port in `docker-compose.yml`.
- **Port 3000 already in use**: stop the other backend process or change the backend host port mapping.
- **Port 8080 already in use**: stop the other web server or change the frontend host port mapping.
- **Backend cannot connect to PostgreSQL**: confirm `postgres` is healthy with `docker compose ps`; inside containers the database host must be `postgres`, not `localhost`.
- **Flutter frontend cannot call backend**: set `FRONTEND_API_BASE_URL=http://localhost:3000/api/v1` in root `.env` and rebuild the frontend with `docker compose build frontend`.
- **CORS errors**: set `CORS_ALLOWED_ORIGINS=http://localhost:8080` in root `.env` and `masjid-core/.env`, then restart backend.
- **Prisma migration failures**: inspect `docker compose logs -f backend`. Do not run destructive reset commands unless you intentionally want to delete local data.
- **Rebuilding after dependency changes**: run `docker compose up --build -d` after changing `package-lock.json` or `pubspec.lock`.
- **Clean containers without deleting database**: run `docker compose down`. The named `postgres_data` volume remains.
- **Intentional local database reset**: run `docker compose down -v` only when you accept deleting all local PostgreSQL data.

## Production notes

- Do not expose PostgreSQL publicly in production.
- Replace all placeholder passwords and JWT secrets with long random values.
- Keep `.env` files out of Git.
- Review `FRONTEND_API_BASE_URL` for the production public backend URL before building the frontend image.
