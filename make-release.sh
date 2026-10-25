#!/usr/bin/env bash
set -euo pipefail

readonly ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly VERSION=$(<"$ROOT_DIR/VERSION")
readonly NAME="stereo-matrix-virtualizer-${VERSION}"
readonly OUTPUT_DIR="$ROOT_DIR/dist"
readonly OUTPUT="$OUTPUT_DIR/${NAME}.tar.gz"

mkdir -p "$OUTPUT_DIR"
tar \
    --sort=name \
    --mtime='UTC 2020-01-01' \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    --exclude='./.git' \
    --exclude='./dist' \
    --exclude='__pycache__' \
    --transform="s#^\.#${NAME}#" \
    -C "$ROOT_DIR" \
    -cf - . | gzip -n >"$OUTPUT"

sha256sum "$OUTPUT" >"$OUTPUT.sha256"
printf 'Created %s\n' "$OUTPUT"
