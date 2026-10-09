# Docker in this project

How this app runs in Docker, the commands you need every day, and the mistakes
that cost us time. Read it once end to end before you touch `docker-compose.yml`.

## Why Docker

Without Docker, every developer installs the right Node, PostgreSQL, and Flutter
versions by hand and configures them the same way. With Docker, one command
starts the whole app with the exact versions the project expects, and the same
setup will later run on the server.

Four words to know:

| Word | Meaning |
|---|---|
| **Image** | A packaged, read-only app: code + runtime + dependencies. Built from a `Dockerfile`. |
| **Container** | A running copy of an image. You can stop, delete, and recreate it at any time. |
| **Volume** | Storage that lives outside containers. Our database files live here, so deleting a container never deletes data. |
| **Compose** | Runs several containers together from one file, `docker-compose.yml`. |

## What runs

```
 Phone (APK) / Browser
        |
        |  https://<ngrok domain>        (only public entry point)
        v
 +-------------+      +------------------+      +-------------+      +--------------+
 |   tunnel    | ---> |     frontend     | ---> |   backend   | ---> |   postgres   |
 |   (ngrok)   |      | nginx: Flutter   |      |   NestJS    |      | PostgreSQL 18|
 |  optional   |      | web + /api/ proxy|      |  port 3000  |      |  volume:     |
 +-------------+      +------------------+      +-------------+      |  pgdata      |
                        localhost:8080          localhost:3000       +--------------+
                                                                      localhost:5433
```

| Service | Container | What it does | On your PC |
|---|---|---|---|
| `postgres` | `masjid-postgres` | The database. Data lives in the `pgdata` volume. | `localhost:5433` |
| `backend` | `masjid-backend` | NestJS API. Applies Prisma migrations on every start. | `localhost:3000` (Swagger at `/api`) |
| `frontend` | `masjid-frontend` | nginx serving the Flutter web build, and forwarding `/api/` to the backend. | `localhost:8080` |
| `tunnel` | `masjid-tunnel` | ngrok. Gives the app a public HTTPS address so the APK and website work away from this PC. Optional. | none |

Containers talk to each other by **service name**: the backend connects to the
database at `postgres:5432`, and nginx forwards to `backend:3000`. Inside a
container, `localhost` means *that container itself*, never your PC.

The website and the API share one public domain: `/` is the site, `/api/v1` is
the API. The APK uses `https://<domain>/api/v1`.

## Files

| File | Purpose | In git? |
|---|---|---|
| `docker-compose.yml` | The four services, their ports, volumes, health checks. | yes |
| `docker-compose.dev.yml` | Overlay that runs the backend with hot reload. | yes |
| `masjid-core/Dockerfile` | Backend image: build TypeScript, then a small runtime image running as a non-root user. | yes |
| `masjid-core/Dockerfile.dev` | Backend image for hot reload. | yes |
| `masjid-core/docker-entrypoint.sh` | Runs `prisma migrate deploy`, then starts the server. | yes |
| `masjid-core-frontend/Dockerfile` | Builds Flutter web, serves it with nginx. | yes |
| `masjid-core-frontend/nginx.conf` | nginx config, including the `/api/` proxy. | yes |
| `.env` | Database name, user, password; frontend API URL; CORS; tunnel settings. Copy from `.env.example`. | **no** |
| `masjid-core/.env` | Backend settings: JWT secrets, super admin, logging. Copy from `masjid-core/.env.example`. | **no** |
| `.env.tunnel` | `NGROK_AUTHTOKEN=...` only. | **no** |
| `.gitattributes` | Forces LF line endings on `*.sh` (see Troubleshooting). | yes |

**Never commit a `.env` file.** They hold passwords and tokens. `.gitignore`
already excludes them; do not force-add them.

`DATABASE_URL` in `masjid-core/.env` is ignored inside Docker. Compose builds the
real one from the root `.env` and points it at `postgres:5432`.

## Run the app on your PC (step by step)

For a new developer on Windows. You do **not** need Node, PostgreSQL, or
Flutter installed for this; Docker brings them. You end up with the website,
API, and database running locally. The public tunnel is not needed.

### 1. Install the tools (once)

1. **Git:** <https://git-scm.com/download/win>. Defaults are fine.
2. **Docker Desktop:** <https://www.docker.com/products/docker-desktop/>.
   Accept the WSL 2 option when asked, restart Windows if it says so.
3. Open Docker Desktop and wait until the bottom-left says **Engine running**.
4. Check in PowerShell:

   ```powershell
   git --version
   docker --version
   docker compose version
   ```

   All three must print a version. If `docker` is not recognized, Docker
   Desktop is not running or needs a restart of PowerShell.

### 2. Get the code (once)

```powershell
cd D:\
git clone https://github.com/DroidNova/masjid-management-system.git
cd masjid-management-system
```

Every command below runs from this folder.

### 3. Create the settings files (once)

```powershell
Copy-Item .env.example .env
Copy-Item masjid-core/.env.example masjid-core/.env
```

Generate random secrets. Run this three times and copy each result:

```powershell
[Convert]::ToBase64String((1..36 | ForEach-Object { Get-Random -Maximum 256 }))
```

Open both files in VS Code (`code .env masjid-core/.env`) and change:

| File | Setting | Set it to |
|---|---|---|
| `.env` | `POSTGRES_PASSWORD` | secret 1 |
| `masjid-core/.env` | `JWT_ACCESS_SECRET` | secret 2 |
| `masjid-core/.env` | `JWT_REFRESH_SECRET` | secret 3 |
| `masjid-core/.env` | `SUPER_ADMIN_PHONE` | your own test phone number, e.g. `9876543210` |
| `masjid-core/.env` | `SUPER_ADMIN_PASSWORD` | a password you will remember |

Leave everything else as it is. Do not uncomment `COMPOSE_PROFILES`; that is
for the public tunnel only.

### 4. Build and start (first time: 5 to 15 minutes)

```powershell
docker compose up -d --build
```

The first run downloads images and builds the backend and the Flutter website,
so it is slow. Later starts take seconds. When it finishes:

```powershell
docker compose ps
```

You should see three containers, all `Up` and `(healthy)`:
`masjid-postgres`, `masjid-backend`, `masjid-frontend`. If one is not healthy,
read its log: `docker compose logs backend` (see Troubleshooting).

### 5. Create the roles and the super admin (once)

```powershell
docker compose exec backend npm run prisma:seed:prod
docker compose exec backend npm run bootstrap:super-admin:prod
```

The database tables already exist: the backend applies migrations every time it starts.

### 6. Open the app

| What | Address |
|---|---|
| Website | <http://localhost:8080> |
| API docs (Swagger) | <http://localhost:3000/api> |
| API health check | <http://localhost:3000/api/v1/health> |

Log in as super admin with `SUPER_ADMIN_PHONE` and `SUPER_ADMIN_PASSWORD`.
In development every OTP is **1111**, and new imams and committee members get
the password **12345678**.

### 7. Stop and start again later

```powershell
docker compose down     # stop (your data is kept)
docker compose up -d    # start again, seconds
```

After you pull new code (`git pull`), rebuild: `docker compose up -d --build`.

### Run the Android app against your local backend

The phone or emulator needs the backend address. With the Android emulator:

```powershell
cd masjid-core-frontend
flutter run --dart-define-from-file=env/dev-android-emulator.json
```

`10.0.2.2` in that file is the emulator's name for your PC. This needs Flutter
installed (JDK 17 for Gradle, see "The APK").

## Everyday commands

Run them in the project folder. Docker picks the project from the
`docker-compose.yml` in the **current folder**.

| Task | Command |
|---|---|
| Start everything | `docker compose up -d` |
| Stop everything (data kept) | `docker compose down` |
| What is running? | `docker compose ps` |
| Follow backend logs | `docker compose logs -f backend` (Ctrl+C to leave) |
| Last 100 lines of all logs | `docker compose logs --tail 100` |
| Restart one service | `docker compose restart backend` |
| Shell inside the backend | `docker compose exec backend sh` |
| All projects on this PC | `docker compose ls` |

`-d` means "detached": containers run in the background and the terminal is
yours again.

### After you change code

Containers run a **built image**, not your files. Editing code changes nothing
until you rebuild that service:

| You changed | Run |
|---|---|
| Backend code (`masjid-core/`) | `docker compose up -d --build backend` |
| Flutter code (website) | `docker compose up -d --build frontend` |
| A new Prisma migration | `docker compose up -d --build backend` (migrations apply on start) |
| `.env` or `docker-compose.yml` | `docker compose up -d` (recreates what changed) |
| The APK | not Docker; see "The APK" below |

### Backend hot reload

For fast backend work, run the backend from your source folder with reload on save:

```powershell
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build backend
```

This replaces the `backend` image with the dev one (same name). When you are
done, go back to the normal image, or the next plain `up` may start a broken
backend:

```powershell
docker compose up -d --build backend
```

## The database

Data lives in the Docker volume `masjid-management-system_pgdata`. It survives
`down`, restarts, and rebuilds.

**Danger:** `docker compose down -v` deletes volumes, which means **the whole
database**. Do not use `-v` unless you mean it, and take a backup first.

Open a SQL prompt:

```powershell
docker compose exec postgres psql -U masjid_user -d masjid_management
```

GUI tools (DBeaver, pgAdmin) connect to `localhost:5433` with the user and
password from the root `.env`.

Back up and restore (run in PowerShell from the project folder):

```powershell
# Backup to a file
docker compose exec -T postgres pg_dump -U masjid_user masjid_management > backup.sql

# Restore into an empty database
docker compose exec -T postgres psql -U masjid_user -d masjid_management < backup.sql
```

Take a backup before risky migrations or before deleting anything.

## Public access (tunnel)

The `tunnel` service only runs when the `tunnel` profile is on. The owner's
`.env` has `COMPOSE_PROFILES=tunnel`, so a plain `docker compose up -d` starts
it. Without that line you get the three local services only, and that is fine
for development.

To set it up on your machine:

1. Create a free ngrok account, copy the **authtoken**, claim a free **static domain**.
2. Put `NGROK_AUTHTOKEN=<token>` in `.env.tunnel`.
3. In `.env`: `COMPOSE_PROFILES=tunnel`, `NGROK_DOMAIN=<domain>`, and add
   `https://<domain>` to `CORS_ALLOWED_ORIGINS`. Keep
   `FRONTEND_API_BASE_URL=/api/v1`: the website then calls the API at its
   own address, whether opened on localhost:8080 or through the tunnel. (A
   full tunnel URL here makes localhost:8080 call the tunnel, and free ngrok's
   warning page blocks those calls.) The APK still uses the full
   `https://<domain>/api/v1`.
4. `docker compose up -d --build frontend` (the web build bakes in the API URL), then `docker compose up -d`.
5. In `.env` set `BACKEND_NODE_ENV=staging`, and in `masjid-core/.env` set
   `SWAGGER_ENABLED=false` and `LOG_LEVEL=info`. Staging refuses to start with
   JWT secrets under 32 characters, needs `CORS_ALLOWED_ORIGINS`, and keeps the
   test login code (`AUTH_DEV_MODE=true`). Then `docker compose up -d backend`.

Facts about the tunnel:

- The app is reachable only while this PC is on and Docker is running.
- A free ngrok domain can be used by **one** tunnel at a time.
- Browsers see a one-time ngrok warning page; visitors click "Visit Site".
- Run ngrok only through Docker. Windows Defender quarantines the native `ngrok.exe`.
- This is for testing before deployment. Production will run on a VPS (plan milestone M6).

## The APK

The APK is built with Flutter on your PC, not in Docker. It talks to whatever
URL it was built with:

```powershell
cd masjid-core-frontend
flutter build apk --release --split-per-abi --dart-define-from-file=env/tunnel.json
# Output: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk (most phones)
# and app-armeabi-v7a-release.apk (old phones), about 20 MB each.
```

Release builds are signed with the key named in `android/key.properties`
(not in git; the owner's key lives in `C:\Users\ashim\.masjid-keys`). Without
that file the build falls back to the debug key, and phones then refuse to
update over an APK signed with the real key. Sharing the APK with the team:
see `docs/TEAM_TESTING.md`.

`env/tunnel.json` points at the ngrok domain. Gradle 8.14 needs JDK 17 (JDK 25
fails with a bare "25.0.2" error); see `flutter config --jdk-dir`.

## Restarting the laptop

Nothing to do before shutdown. Every service has `restart: unless-stopped`, so
when Docker Desktop starts again, the containers that were running come back by
themselves. Turn on Docker Desktop > Settings > General > "Start Docker Desktop
when you sign in" so that happens without opening Docker by hand.

A project you stopped with `docker compose down` stays stopped until you `up` it.

## Safety rules

- Database, backend, and website ports are bound to `127.0.0.1`: only this PC
  can reach them, not other devices on the Wi-Fi. Keep it that way. The tunnel is
  the only public way in.
- `.env` files stay out of git. If a secret leaks (chat, screenshot, commit),
  change it.
- The backend image runs as the non-root `node` user.
- Backend `TRUST_PROXY=true` is required behind nginx and ngrok so rate limits
  see each visitor's real IP. Without it, every visitor shares one IP and one
  rate limit.
- `AUTH_DEV_MODE` is on in this stack (OTP `1111`, password `12345678`). Fine for
  testing; never for real users.

## Several Docker projects on one PC

- Each project is named after its folder. Commands act on the folder you are in,
  or use `docker compose -p <project-name> down` from anywhere.
- Two projects cannot use the same host port at once. This one uses 3000, 5433, and 8080.
- Container names (`masjid-backend`, ...) must be unique across projects.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `./docker-entrypoint.sh: No such file or directory`, backend restarts forever | The `.sh` file has Windows (CRLF) line endings. | `.gitattributes` now forces LF. To fix a file: `git add --renormalize .` or convert it to LF in VS Code (bottom-right "CRLF" > "LF"). Rebuild. |
| Container stays `unhealthy` but the app works | The health check used `localhost`, which resolves to IPv6 in Alpine while nginx listens on IPv4. | Health checks use `127.0.0.1`. Keep it that way. |
| Build fails: `Cannot resolve environment variable: DATABASE_URL` | `prisma.config.ts` needs `DATABASE_URL` even for `prisma generate`. | The Dockerfiles set a placeholder for the build step. Keep it. |
| `port is already allocated` | Another container or program uses 3000, 5433, or 8080. | `docker ps` to find it; stop it or change the port in `docker-compose.yml`. |
| `dependency failed to start: container ... is unhealthy` | A service the others wait for did not pass its health check. | `docker compose logs <service>`; fix the error it shows. |
| Code change has no effect | Containers run the image, not your files. | `docker compose up -d --build <service>`. |
| Tunnel starts but the domain shows an ngrok error | Backend or frontend down, or the token/domain is wrong. | `docker compose ps`, `docker compose logs tunnel`. |
| `docker` not recognized / cannot connect to the Docker daemon | Docker Desktop is not running. | Start Docker Desktop, wait for "Engine running". |
