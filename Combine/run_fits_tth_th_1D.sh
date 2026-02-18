#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOM'
Usage: run_fits_tth_th_1D.sh --steps <list> [options]

Steps (comma-separated):
  t2w        build workspace in Combine/output/<analysis-tag>
  scan       1D scans with full systematics (profiled other POI)
  scan-stat  1D scans with stat-only (freeze all constrained nuisances)
  collect    CollectFits for syst + stat-only
  plot       overlay syst + stat-only with plot1DScan.py

Options:
  --analysis-tag <tag>     Analysis tag (default: tth_th_analysis_fiducial_syst)
  --workdir <dir>          Output dir (default: Combine/output/<tag>/scan1d)
  --mass <value>           Higgs mass (default: 125.08)
  --pois <p1,p2,...>        POIs (default: r_tHq,r_ttH)
  --range-r_tHq <min,max>  Scan range for r_tHq (default: -10,25)
  --range-r_ttH <min,max>  Scan range for r_ttH (default: -0.5,3.0)
  --points <N>             Grid points (default: 50)
  --split-points <N>       Points per job (default: 1)
  --queue <name>           Condor queue (default: workday)
  --sub-opts <string>      Extra condor submit opts (default: empty)
  --translate <json>       plot1DScan.py --translate JSON
  --no-asimov              Run on observed data
  -h, --help               Show help

Examples:
  bash run_fits_tth_th_1D.sh --steps t2w,scan,scan-stat,collect,plot
  bash run_fits_tth_th_1D.sh --steps scan,scan-stat
EOM
}

ANALYSIS_TAG="tth_th_analysis_fiducial_syst"
MASS="125.08"
POIS="r_tHq,r_ttH"
RANGE_R_THQ="-10,25"
RANGE_R_TTH="-0.5,3.0"
POINTS="50"
SPLIT_POINTS="1"
QUEUE="workday"
SUB_OPTS=""
STEPS=""
WORKDIR=""
ASIMOV=1
TRANSLATE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --analysis-tag) ANALYSIS_TAG="$2"; shift 2 ;;
    --workdir) WORKDIR="$2"; shift 2 ;;
    --mass) MASS="$2"; shift 2 ;;
    --pois) POIS="$2"; shift 2 ;;
    --range-r_tHq) RANGE_R_THQ="$2"; shift 2 ;;
    --range-r_ttH) RANGE_R_TTH="$2"; shift 2 ;;
    --points) POINTS="$2"; shift 2 ;;
    --split-points) SPLIT_POINTS="$2"; shift 2 ;;
    --queue) QUEUE="$2"; shift 2 ;;
    --sub-opts) SUB_OPTS="$2"; shift 2 ;;
    --steps) STEPS="$2"; shift 2 ;;
    --no-asimov) ASIMOV=0; shift 1 ;;
    --translate) TRANSLATE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ -z "${STEPS}" ]]; then
  echo "[ERROR] --steps is required." >&2
  usage >&2
  exit 1
fi

if [[ -z "${WORKDIR}" ]]; then
  WORKDIR="${SCRIPT_DIR}/output/${ANALYSIS_TAG}/scan1d"
fi

DATACARD_TXT="${SCRIPT_DIR}/../Datacard/datacard_outputs/${ANALYSIS_TAG}/Datacard_${ANALYSIS_TAG}.txt"
OUTPUT_BASE="${SCRIPT_DIR}/output/${ANALYSIS_TAG}"
MODE="r_2D"
if [[ "${ANALYSIS_TAG}" == *"_fiducial"* ]]; then
  MODE="r_2D_fiducial"
fi
EXT="_${ANALYSIS_TAG}"

IFS=',' read -ra STEP_LIST <<< "${STEPS}"
declare -A DO
for s in "${STEP_LIST[@]}"; do
  s="${s// /}"
  DO["$s"]=1
done

ASIMOV_FLAG=""
if [[ ${ASIMOV} -ne 1 ]]; then
  ASIMOV_FLAG="--doObserved"
fi

mkdir -p "${WORKDIR}"

JSON_SYST="${WORKDIR}/inputs_1D_syst.json"
JSON_STAT="${WORKDIR}/inputs_1D_stat.json"

python3 - <<PY
import json
from pathlib import Path

mode = "${MODE}"
pois = "${POIS}".split(",")
points = "${POINTS}:${SPLIT_POINTS}"
range_r_thq = "${RANGE_R_THQ}"
range_r_tth = "${RANGE_R_TTH}"

def build_entry(statonly=False):
    fits = []
    points_list = []
    fit_opts = []
    base_opts = f"--freezeParameters MH --setParameterRanges r_tHq={range_r_thq}:r_ttH={range_r_tth} --saveSpecifiedNuis all"
    if statonly:
        base_opts = base_opts.replace("--freezeParameters MH", "--freezeParameters MH,allConstrainedNuisances")
    for p in pois:
        p = p.strip()
        if not p:
            continue
        fits.append(f"profile1D:{'stat' if statonly else 'syst'}:{p}")
        points_list.append(points)
        fit_opts.append(base_opts)
    return {
        "pois": ",".join(pois),
        "fits": "+".join(fits),
        "points": "+".join(points_list),
        "fit_opts": "+".join(fit_opts),
    }

syst = {mode: build_entry(statonly=False)}
stat = {mode: build_entry(statonly=True)}

Path("${JSON_SYST}").write_text(json.dumps(syst, indent=2))
Path("${JSON_STAT}").write_text(json.dumps(stat, indent=2))
print("Wrote", "${JSON_SYST}", "and", "${JSON_STAT}")
PY

if [[ -n "${DO[t2w]:-}" ]]; then
  if [[ ! -d "${OUTPUT_BASE}/Models/background" ]]; then
    echo "[ERROR] Missing Models/background in ${OUTPUT_BASE}. Cannot run text2workspace." >&2
    exit 1
  fi
  if [[ ! -f "${DATACARD_TXT}" ]]; then
    echo "[ERROR] Datacard txt not found: ${DATACARD_TXT}" >&2
    exit 1
  fi
  mkdir -p "${OUTPUT_BASE}"
  cp -v "${DATACARD_TXT}" "${OUTPUT_BASE}/Datacard_${ANALYSIS_TAG}.txt"
  (cd "${OUTPUT_BASE}" && python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode "${MODE}" --batch local --ext "${ANALYSIS_TAG}")
fi

if [[ -n "${DO[scan]:-}" ]]; then
  (cd "${WORKDIR}" && python3 "${SCRIPT_DIR}/RunFits.py" --inputJson "${JSON_SYST}" --mode "${MODE}" \
    --mass "${MASS}" --queue "${QUEUE}" --batch condor --datacardDir "${OUTPUT_BASE}" --ext "${EXT}" ${ASIMOV_FLAG} \
    --subOpts "${SUB_OPTS}")
fi

if [[ -n "${DO[scan-stat]:-}" ]]; then
  (cd "${WORKDIR}" && python3 "${SCRIPT_DIR}/RunFits.py" --inputJson "${JSON_STAT}" --mode "${MODE}" \
    --mass "${MASS}" --queue "${QUEUE}" --batch condor --datacardDir "${OUTPUT_BASE}" --ext "${EXT}" ${ASIMOV_FLAG} \
    --subOpts "${SUB_OPTS}")
fi

if [[ -n "${DO[collect]:-}" ]]; then
  (cd "${WORKDIR}" && python3 "${SCRIPT_DIR}/CollectFits.py" --inputJson "${JSON_SYST}" --mode "${MODE}" --ext "${EXT}" ${ASIMOV_FLAG})
  (cd "${WORKDIR}" && python3 "${SCRIPT_DIR}/CollectFits.py" --inputJson "${JSON_STAT}" --mode "${MODE}" --ext "${EXT}" ${ASIMOV_FLAG})
fi

if [[ -n "${DO[plot]:-}" ]]; then
  if [[ -n "${TRANSLATE}" && ! -f "${TRANSLATE}" ]]; then
    if [[ -f "${SCRIPT_DIR}/${TRANSLATE}" ]]; then
      TRANSLATE="${SCRIPT_DIR}/${TRANSLATE}"
    elif [[ -f "${WORKDIR}/${TRANSLATE}" ]]; then
      TRANSLATE="${WORKDIR}/${TRANSLATE}"
    else
      echo "[ERROR] translate JSON not found: ${TRANSLATE}" >&2
      exit 1
    fi
  fi
  RUNFITS_DIR="${WORKDIR}/runFits${EXT}_${MODE}"
  IFS=',' read -ra POI_LIST <<< "${POIS}"
  for poi in "${POI_LIST[@]}"; do
    poi="${poi// /}"
    [[ -z "${poi}" ]] && continue
    syst_root="${RUNFITS_DIR}/profile1D_syst_${poi}.root"
    stat_root="${RUNFITS_DIR}/profile1D_stat_${poi}.root"
    if [[ ! -f "${syst_root}" ]]; then
      echo "[WARN] Missing ${syst_root}. Run --steps collect after scans." >&2
      continue
    fi
    if [[ -f "${stat_root}" ]]; then
      if [[ -n "${TRANSLATE}" ]]; then
        plot1DScan.py "${syst_root}" --POI "${poi}" --others "${stat_root}:stat-only:2" \
          --translate "${TRANSLATE}" -o "${WORKDIR}/scan1D_${poi}_statsyst"
      else
        plot1DScan.py "${syst_root}" --POI "${poi}" --others "${stat_root}:stat-only:2" \
          -o "${WORKDIR}/scan1D_${poi}_statsyst"
      fi
    else
      if [[ -n "${TRANSLATE}" ]]; then
        plot1DScan.py "${syst_root}" --POI "${poi}" --translate "${TRANSLATE}" -o "${WORKDIR}/scan1D_${poi}_syst"
      else
        plot1DScan.py "${syst_root}" --POI "${poi}" -o "${WORKDIR}/scan1D_${poi}_syst"
      fi
    fi
  done
fi

echo "Done. Outputs in ${WORKDIR}"
