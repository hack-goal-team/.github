#!/bin/sh
set -eu

cd "$(dirname "$0")"
docker compose version >/dev/null
docker compose up --build -d
docker compose ps
printf '\nOpen http://localhost:8088/ and wait for /health to report UP.\n'
