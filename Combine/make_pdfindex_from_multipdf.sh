#!/usr/bin/env bash
set -e

# Build a pdfindex_<analysis>.json using the default indices stored in the
# background MultiPdf workspaces (created by the fTest step).

if [[ -z "${CMSSW_BASE:-}" ]]; then
  echo "[ERROR] CMSSW not set. Run 'cmsenv' first." >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
COMBINE_DIR="${SCRIPT_DIR}"

ANALYSIS_TAG="tth_th_analysis_fiducial"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --analysis)
      ANALYSIS_TAG="$2"
      shift 2
      ;;
    --models-dir)
      MODELS_DIR_OVERRIDE="$2"
      shift 2
      ;;
    --output-json)
      OUTPUT_JSON_OVERRIDE="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--analysis <tag>] [--models-dir <path>] [--output-json <path>]"
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

OUTPUT_BASE="${OUTPUT_BASE:-${COMBINE_DIR}/output/${ANALYSIS_TAG}}"
MODELS_DIR="${MODELS_DIR_OVERRIDE:-${MODELS_DIR:-${OUTPUT_BASE}/Models/background}}"
OUTPUT_JSON="${OUTPUT_JSON_OVERRIDE:-${OUTPUT_JSON:-${OUTPUT_BASE}/pdfindex_${ANALYSIS_TAG}.json}}"

if [[ ! -d "${MODELS_DIR}" ]]; then
  echo "[ERROR] Models dir not found: ${MODELS_DIR}" >&2
  echo "  Override with MODELS_DIR=/path/to/Models/background" >&2
  exit 1
fi

shopt -s nullglob
files=("${MODELS_DIR}"/CMS-HGG_multipdf_*.root)
if (( ${#files[@]} == 0 )); then
  echo "[ERROR] No multipdf ROOT files found under ${MODELS_DIR}" >&2
  exit 1
fi

python3 - "${MODELS_DIR}" "${OUTPUT_JSON}" <<'PY'
import glob
import json
import os
import sys
import ROOT

models_dir, out_json = sys.argv[1:3]
ROOT.gROOT.SetBatch(True)

out = {}
conflicts = []
for path in sorted(glob.glob(os.path.join(models_dir, "CMS-HGG_multipdf_*.root"))):
    f = ROOT.TFile.Open(path)
    if not f or f.IsZombie():
        print(f"[WARN] Cannot open {path}")
        continue
    ws = f.Get("multipdf")
    if not ws:
        print(f"[WARN] Workspace 'multipdf' not found in {path}")
        f.Close()
        continue
    cats = ws.allCats()
    it = cats.createIterator()
    while True:
        cat = it.Next()
        if not cat:
            break
        name = cat.GetName()
        if not name.startswith("pdfindex_"):
            continue
        val = int(cat.getIndex())
        if name in out and out[name] != val:
            conflicts.append((name, out[name], val, path))
        out[name] = val
    f.Close()

if not out:
    raise SystemExit("[ERROR] No pdfindex_* categories found.")

with open(out_json, "w") as handle:
    json.dump(out, handle, indent=2, sort_keys=True)

print(f"[INFO] Wrote {len(out)} pdfindex values to {out_json}")
if conflicts:
    print("[WARN] Conflicting indices detected (later value kept):")
    for name, old, new, path in conflicts:
        print(f"  {name}: {old} -> {new} ({path})")
PY

echo "[INFO] Source dir: ${MODELS_DIR}"
echo "[INFO] Output: ${OUTPUT_JSON}"
