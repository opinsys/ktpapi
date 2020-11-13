#!/bin/bash
# KTP-API-asennuspaketti
# (c) Opinsys Oy, 2020

set -eu

echo 'Puretaan asennuspakettia'

tmpdir=$(mktemp -d /tmp/purku.XXXXXX)

ARCHIVE=$(awk '/^___ARCHIVE_BELOW___/ { print NR + 1; exit 0 }' "$0")

tail -n+$ARCHIVE "$0" | tar -C "$tmpdir" -xz

(
  cd "$tmpdir"
  ./installer.sh "$@"
)

rm -rf "$tmpdir"

exit 0
