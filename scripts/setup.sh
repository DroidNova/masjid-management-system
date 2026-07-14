#!/usr/bin/env sh
set -e

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not on PATH." >&2
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose is not available. Install Docker Desktop or the Docker Compose plugin." >&2
  exit 1
fi

copy_if_missing() {
  src="$1"
  dest="$2"
  if [ -f "$dest" ]; then
    echo "Keeping existing $dest"
  else
    cp "$src" "$dest"
    echo "Created $dest from $src"
  fi
}

copy_if_missing .env.example .env
copy_if_missing masjid-core/.env.example masjid-core/.env

echo "Review .env and masjid-core/.env, then run: docker compose up --build -d"
