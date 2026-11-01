#!/usr/bin/env python3
"""Validate that real ndnSIM smoke-test artifacts exist and have data rows.

This does not build the HCRAF Forwarding Episode dataset; it only validates
standard built-in tracers created by official ndnSIM examples.
"""
import json
import sys
from datetime import datetime, timezone
from pathlib import Path


EXPECTED = {
    "rate-trace.txt": ("Time", "Node", "FaceId", "Type"),
    "app-delays-trace.txt": ("Time", "Node", "AppId", "SeqNo"),
}


def inspect(path: Path, required: tuple[str, ...]) -> dict:
    if not path.is_file():
        raise ValueError(f"Trace not found: {path}")
    if path.stat().st_size == 0:
        raise ValueError(f"Trace is empty: {path}")
    with path.open("r", encoding="utf-8-sig", errors="replace") as inp:
        content = [line.strip() for line in inp if line.strip()]
    if len(content) <= 1:
        raise ValueError(f"No data rows after header in: {path}")
    header = content[0].lstrip("# ").split()
    missing = sorted(set(required) - set(header))
    if missing:
        raise ValueError(f"Missing columns in {path}: {missing} (header={header})")
    n_rows = sum(not row.lstrip().startswith("#") for row in content[1:])
    if n_rows == 0:
        raise ValueError(f"No valid data rows in: {path}")
    return {"filename": path.name, "data_rows": n_rows,
            "size_bytes": path.stat().st_size, "header": header}


def main(folder: Path) -> int:
    report = {"type": "OFFICIAL_NDNSIM_SMOKE_TEST_NOT_HCRAF_DATASET",
              "checked_at_utc": datetime.now(timezone.utc).isoformat(),
              "traces": []}
    try:
        for filename, required in EXPECTED.items():
            report["traces"].append(inspect(folder / filename, required))
        report["status"] = "PASS"
        report["note"] = "Only built-in tracer schema and nonempty rows are validated."
    except Exception as exc:
        report["status"] = "FAIL"
        report["error"] = str(exc)
    folder.mkdir(parents=True, exist_ok=True)
    (folder / "trace_verification.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pilot_output_directory>", file=sys.stderr)
        sys.exit(2)
    sys.exit(main(Path(sys.argv[1])))
