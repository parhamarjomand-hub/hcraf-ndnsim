#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$PROJECT_DIR/ndnsim_sources"
OUT_DIR="$PROJECT_DIR/pilot_output"
mkdir -p "$OUT_DIR" "$SRC_DIR"

printf '\n[1/4] Official source repositories\n'
cd "$SRC_DIR"
git clone --depth 1 https://github.com/named-data-ndnSIM/ns-3-dev.git ns-3
git clone --depth 1 https://github.com/named-data-ndnSIM/pybindgen.git pybindgen
git clone --depth 1 --recursive https://github.com/named-data-ndnSIM/ndnSIM.git ns-3/src/ndnSIM

printf '\n[2/4] Record exact versions for reproducibility\n'
{
    printf 'UTC: '; date -u '+%Y-%m-%dT%H:%M:%SZ'
    printf 'ns-3-dev SHA: '; git -C "$SRC_DIR/ns-3" rev-parse HEAD
    printf 'pybindgen SHA: '; git -C "$SRC_DIR/pybindgen" rev-parse HEAD
    printf 'ndnSIM SHA: '; git -C "$SRC_DIR/ns-3/src/ndnSIM" rev-parse HEAD
    printf '\nndnSIM submodules:\n'
    git -C "$SRC_DIR/ns-3/src/ndnSIM" submodule status --recursive
    printf '\nCompiler:\n'; g++ --version | head -n 1
    printf '\nPython:\n'; python3 --version
} > "$OUT_DIR/source_versions.txt"
cat "$OUT_DIR/source_versions.txt"

printf '\n[3/4] Configure NS-3/ndnSIM (no Python bindings)\n'
cd "$SRC_DIR/ns-3"
python3 ./waf configure --disable-python --enable-examples

printf '\n[4/4] Compile official ndnSIM examples\n'
python3 ./waf -j 2
