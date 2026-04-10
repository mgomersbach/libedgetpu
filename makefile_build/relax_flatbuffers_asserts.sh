#!/usr/bin/env bash
set -euo pipefail

TFROOT="${1:?usage: $0 <tfroot>}"

while IFS= read -r -d '' f; do
  if grep -q '^[[:space:]]*static_assert(FLATBUFFERS_VERSION_MAJOR' "${f}"; then
    sed -i '/static_assert(FLATBUFFERS_VERSION_MAJOR/,/Non-compatible flatbuffers version included/ s/^/\/\//' "${f}"
  fi
done < <(find "${TFROOT}" -type f -name '*_generated.h' -print0)
