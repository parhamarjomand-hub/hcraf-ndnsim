#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$PROJECT_DIR/ndnsim_sources/ns-3"
OUT_DIR="$PROJECT_DIR/pilot_output"
mkdir -p "$OUT_DIR"
cd "$SRC_DIR"

printf '[1/3] Running official ndn-simple scenario...\n'
python3 ./waf --run=ndn-simple

printf '[2/3] Running official ndn-tree-tracers scenario...\n'
python3 ./waf --run=ndn-tree-tracers

printf '[3/3] Running official ndn-tree-app-delay-tracer scenario...\n'
python3 ./waf --run=ndn-tree-app-delay-tracer

# The two filenames are those documented for the respective official examples.
for f in rate-trace.txt app-delays-trace.txt; do
  if [[ ! -s "$f" ]]; then
    echo "ERROR: missing or empty official trace: $SRC_DIR/$f" >&2
    exit 1
  fi
  cp "$f" "$OUT_DIR/$f"
done

printf '%s\n' 'Real traces copied to pilot_output/.'
ls -lh "$OUT_DIR"/*trace.txt
