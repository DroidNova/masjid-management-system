#!/usr/bin/env sh
set -e
if [ "$#" -gt 0 ]; then
  docker compose logs -f "$@"
else
  docker compose logs -f
fi
