#!/bin/sh
set -eu

attempt=0
while [ "$attempt" -lt 90 ]; do
    ready=$(psql -h postgres -U goal -d goal -Atqc \
        "SELECT EXISTS(SELECT 1 FROM pg_roles WHERE rolname = 'inference')::int * EXISTS(SELECT 1 FROM dim_channels_current)::int" \
        2>/dev/null || true)
    if [ "$ready" = 1 ]; then
        psql -h postgres -U goal -d goal -v ON_ERROR_STOP=1 \
            -c "ALTER ROLE inference LOGIN PASSWORD 'inference_demo_local'"
        exit 0
    fi
    attempt=$((attempt + 1))
    sleep 2
done

echo 'Не удалось дождаться миграций и загрузки реестра за 180 секунд' >&2
exit 1
