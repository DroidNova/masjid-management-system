#!/usr/bin/env sh
# Saves a compressed copy of the database to backups/ and keeps the newest 14.
# Restore: gunzip -c backups/<file>.sql.gz | docker compose exec -T postgres \
#   sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
set -e
cd "$(dirname "$0")/.."
mkdir -p backups
file="backups/masjid-$(date +%Y%m%d-%H%M%S).sql.gz"
docker compose exec -T postgres sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --clean --if-exists' | gzip > "$file"
echo "Saved $file"
ls -1t backups/masjid-*.sql.gz | tail -n +15 | xargs -r rm --
