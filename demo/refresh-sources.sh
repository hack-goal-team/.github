#!/bin/sh
# Разовая загрузка источников сразу после старта; дальше их тянет расписание.
set -eu

api=http://backend:8080/api/v1
jar=/tmp/cookies

attempt=0
until curl -fs -o /dev/null http://backend:8080/actuator/health; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 90 ]; then
        echo 'Бэкенд не поднялся за 180 секунд' >&2
        exit 1
    fi
    sleep 2
done

curl -sS -c "$jar" -o /dev/null "$api/auth/me" || true
token=$(awk '$6 == "XSRF-TOKEN" { print $7 }' "$jar")
curl -fsS -b "$jar" -c "$jar" -o /dev/null -H "X-XSRF-TOKEN: $token" \
    -H 'Content-Type: application/json' \
    -d '{"username":"admin","password":"demo1234"}' "$api/auth/login"
token=$(awk '$6 == "XSRF-TOKEN" { print $7 }' "$jar")

# Реестр первым: заявки ОДС и погода привязываются к объектам из него.
for source in registry ods weather; do
    if curl -fsS -b "$jar" -H "X-XSRF-TOKEN: $token" -X POST "$api/admin/$source/refresh"; then
        echo " <- $source"
    else
        echo "Не удалось загрузить $source, повторит расписание" >&2
    fi
done
