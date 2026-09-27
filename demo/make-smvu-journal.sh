#!/usr/bin/env bash
# Разово: срез журнала для мока СМВУ, результат коммитится в demo/smvu/.
# ./demo/make-smvu-journal.sh Sources/dataset/ext-journal-2025.csv
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
journal=${1:?укажи путь к ext-journal-2025.csv}
months=${SMVU_MONTHS:-2025-09,2025-10}
# Каналы реестра из backend/mocks/registry/data/channels.csv.
channels=${SMVU_CHANNELS:-120298,196736,196737,196738}

{
    echo "COPY journal (src_ts, event_id, channel_id, is_alarm, raw_value) FROM stdin;"
    LC_ALL=C awk -F, -v months=",$months," -v channels=",$channels," '
        index(channels, "," $2 ",") && index(months, "," substr($3, 1, 7) ",") {
            v = $6; for (i = 7; i <= NF; i++) v = v "," $i
            print $3 " " $4 "+03" "\t" $1 "\t" $2 "\t" $5 "\t" v
        }' "$journal"
    printf '%s\n' '\.' "ANALYZE journal;"
} | gzip -n -9 > "$here/smvu/02-journal.sql.gz"
ls -l "$here/smvu/02-journal.sql.gz"
