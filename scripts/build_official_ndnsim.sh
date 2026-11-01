#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$PROJECT_DIR/ndnsim_sources"
OUT_DIR="$PROJECT_DIR/pilot_output"
mkdir -p "$OUT_DIR" "$SRC_DIR"

printf '\n[1/4] Official source repositories\n'
cd "$SRC_DIR"
# Fetch the exact source commits from the successful pilot.
fetch_pinned() {
    local repo_url="$1"
    local target_dir="$2"
    local commit_sha="$3"

    git init "$target_dir"
    git -C "$target_dir" remote add origin "$repo_url"
    git -C "$target_dir" fetch --depth 1 origin "$commit_sha"
    git -C "$target_dir" checkout --detach "$commit_sha"

    test "$(git -C "$target_dir" rev-parse HEAD)" = "$commit_sha"
}

fetch_pinned \
    https://github.com/named-data-ndnSIM/ns-3-dev.git \
    ns-3 \
    1b3bab9b6dba5f1e616c0b286eb889e9ce3d5d59

fetch_pinned \
    https://github.com/named-data-ndnSIM/pybindgen.git \
    pybindgen \
    a619e22a1492e586f42a688b015c551ea1facd7b

fetch_pinned \
    https://github.com/named-data-ndnSIM/ndnSIM.git \
    ns-3/src/ndnSIM \
    90d50396654dabad54b6979f2dc8fa929ade544c

git -C ns-3/src/ndnSIM submodule sync --recursive
git -C ns-3/src/ndnSIM submodule update --init --recursive

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
