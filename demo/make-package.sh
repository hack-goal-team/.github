#!/usr/bin/env bash
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
output=${1:-"$PWD/moscollector-demo.zip"}
case "$output" in
    /*) ;;
    *) output="$PWD/$output" ;;
esac
if [ -e "$output" ]; then
    echo "Файл уже существует: $output" >&2
    exit 1
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
package="$work/moscollector-demo"
mkdir -p "$package"

for repo in backend frontend ml; do
    git clone --quiet --depth 1 --branch main \
        "https://github.com/hack-goal-team/$repo.git" "$work/$repo"
    mkdir "$package/$repo"
    git -C "$work/$repo" archive HEAD | tar -x -C "$package/$repo"
    printf '%s %s\n' "$repo" "$(git -C "$work/$repo" rev-parse HEAD)" \
        >> "$package/SOURCES.txt"
done

cp "$here/compose.yaml" "$here/Dockerfile.frontend" \
    "$here/Dockerfile.inference-setup" "$here/nginx.conf" \
    "$here/setup-inference.sh" "$here/.dockerignore" \
    "$here/start.sh" "$here/start.cmd" "$package/"
cp "$here/Dockerfile.backend" "$package/backend/Dockerfile.demo"
cp "$here/README.md" "$package/README.md"

python3 - "$package/start.cmd" <<'PY'
from pathlib import Path
from sys import argv

path = Path(argv[1])
path.write_bytes(path.read_bytes().replace(b"\r\n", b"\n").replace(b"\n", b"\r\n"))
PY

python3 - "$work" "$output" <<'PY'
from pathlib import Path
from sys import argv
from zipfile import ZIP_DEFLATED, ZipFile

base = Path(argv[1])
target = Path(argv[2])
with ZipFile(target, "w", compression=ZIP_DEFLATED, compresslevel=6) as archive:
    for path in sorted((base / "moscollector-demo").rglob("*")):
        if path.is_file():
            archive.write(path, path.relative_to(base))
PY
echo "Готово: $output"
