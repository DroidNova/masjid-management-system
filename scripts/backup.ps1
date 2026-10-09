# Saves a compressed copy of the database to backups\ and keeps the newest 14.
# Restore: see scripts/backup.sh.
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
New-Item -ItemType Directory -Force backups | Out-Null
$file = "backups\masjid-$(Get-Date -Format yyyyMMdd-HHmmss).sql.gz"
# Dump and compress inside the container, then copy the file out unchanged.
docker compose exec -T postgres sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --clean --if-exists | gzip > /tmp/backup.sql.gz'
docker compose cp postgres:/tmp/backup.sql.gz $file
docker compose exec -T postgres rm /tmp/backup.sql.gz
Write-Output "Saved $file"
Get-ChildItem backups\masjid-*.sql.gz | Sort-Object LastWriteTime -Descending | Select-Object -Skip 14 | Remove-Item
