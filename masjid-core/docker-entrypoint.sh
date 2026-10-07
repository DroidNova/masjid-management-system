#!/bin/sh
set -e

if [ -z "$DATABASE_URL" ]; then
  echo "DATABASE_URL is required" >&2
  exit 1
fi

echo "Applying committed Prisma migrations..."
npx prisma migrate deploy

echo "Starting Masjid backend..."
exec "$@"
