#!/usr/bin/env bash
set -euo pipefail

# NOTE ON SNAPSHOT USAGE
# - For Asimov scans, a postfit snapshot is REQUIRED.
# - For observed stat-only scans from the full syst workspace, an observed postfit
#   snapshot is REQUIRED so constrained nuisances are frozen at observed postfit values.
# - Observed full-syst scans use the workspace directly and do not require a snapshot.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOM'
Usage: bash run_fits_tth_th_1D.sh --steps <list> [options]

Steps (comma-separated):
  t2w        build workspace in Combine/output/<analysis-tag>
  snapshot   save a postfit snapshot; Asimov with default settings, or observed with --no-asimov
  snapshot-observed
             alias for: --steps snapshot --no-asimov
  scan       1D scans with full systematics (profiled other POI)
  scan-stat  1D scans with stat-only (freeze all constrained nuisances)
  limit-tH   expected upper limit on tH (r_tHq), profiling ttH by default
  limit-tH-hybrid-submit
             submit HybridNew toy jobs for the tH limit on a fixed r_tHq grid
  limit-tH-hybrid-collect
             merge completed HybridNew toys and extract the final tH limit
  significance-tth
             expected significance for ttH (r_ttH), profiling tH by default
  collect    CollectFits for syst + stat-only
  plot       overlay syst + stat-only with plot1DScan.py

Options:
  --analysis-tag <tag>     Analysis tag (default: tth_th_analysis_fiducial_syst)
  --workdir <dir>          Output dir (default: Combine/output/<tag>/scan1d or scan1d_unblinded)
  --mass <value>           Higgs mass (default: 125.08)
  --pois <p1,p2,...>        POIs (default: r_tHq,r_ttH)
  --range-r_tHq <min,max>  Scan range for r_tHq (default: -20,25)
  --range-r_ttH <min,max>  Scan range for r_ttH (default: -0.5,3.0)
  --points <N>             Grid points (default: 50)
  --split-points <N>       Points per job (default: 1)
  --queue <name>           Condor queue (default: workday)
  --sub-opts <string>      Extra condor submit opts (default: empty)
  --max-materialize <N>    Limit the number of materialized HybridNew condor jobs
  --translate <json>       plot1DScan.py --translate JSON
  --stat-only              For limit/significance steps: freeze all constrained nuisances
  --freeze-other-poi       For limit/significance steps: freeze the non-tested POI to its SM value
  --hybrid-new             Legacy shortcut for HybridNew submit via --steps limit-tH
  --no-asimov              Run on observed data
  -h, --help               Show help

Examples:
  bash run_fits_tth_th_1D.sh --steps t2w,snapshot,scan,scan-stat,collect,plot
  # If snapshot already exists:
  bash run_fits_tth_th_1D.sh --steps scan,scan-stat
EOM
}

ANALYSIS_TAG="tth_th_analysis_fiducial_syst"
MASS="125.08"
POIS="r_tHq,r_ttH"
RANGE_R_THQ="-20,25"
RANGE_R_TTH="-0.5,3.0"
POINTS="50"
SPLIT_POINTS="1"
QUEUE="workday"
SUB_OPTS=""
STEPS=""
WORKDIR=""
WORKDIR_GIVEN=0
ASIMOV=1
TRANSLATE=""
STAT_ONLY=0
FREEZE_OTHER_POI=0
HYBRID_NEW=0
HYBRID_TOYS_PER_CYCLE=10
HYBRID_CYCLES=0
HYBRID_MIN_TOYS=500
HYBRID_MAX_TOYS=5000
HYBRID_POINTS=25
HYBRID_RANGE_MIN=0
HYBRID_RANGE_MAX=30
MAX_MATERIALIZE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --analysis-tag) ANALYSIS_TAG="$2"; shift 2 ;;
    --workdir) WORKDIR="$2"; WORKDIR_GIVEN=1; shift 2 ;;
    --mass) MASS="$2"; shift 2 ;;
    --pois) POIS="$2"; shift 2 ;;
    --range-r_tHq) RANGE_R_THQ="$2"; shift 2 ;;
    --range-r_ttH) RANGE_R_TTH="$2"; shift 2 ;;
    --points) POINTS="$2"; shift 2 ;;
    --split-points) SPLIT_POINTS="$2"; shift 2 ;;
    --queue) QUEUE="$2"; shift 2 ;;
    --sub-opts) SUB_OPTS="$2"; shift 2 ;;
    --max-materialize) MAX_MATERIALIZE="$2"; shift 2 ;;
    --steps) STEPS="$2"; shift 2 ;;
    --stat-only) STAT_ONLY=1; shift 1 ;;
    --freeze-other-poi) FREEZE_OTHER_POI=1; shift 1 ;;
    --hybrid-new) HYBRID_NEW=1; shift 1 ;;
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

if [[ ${HYBRID_CYCLES} -le 0 ]]; then
  HYBRID_CYCLES=$(( (HYBRID_MIN_TOYS + HYBRID_TOYS_PER_CYCLE - 1) / HYBRID_TOYS_PER_CYCLE ))
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
  if [[ "${s}" == "snapshot-observed" ]]; then
    ASIMOV=0
    s="snapshot"
  fi
  DO["$s"]=1
done

if [[ ${WORKDIR_GIVEN} -eq 0 ]]; then
  if [[ ${ASIMOV} -eq 1 ]]; then
    WORKDIR="${SCRIPT_DIR}/output/${ANALYSIS_TAG}/scan1d"
  else
    WORKDIR="${SCRIPT_DIR}/output/${ANALYSIS_TAG}/scan1d_unblinded"
  fi
fi

ASIMOV_FLAG=""
if [[ ${ASIMOV} -ne 1 ]]; then
  ASIMOV_FLAG="--doObserved"
fi

mkdir -p "${WORKDIR}"

JSON_SYST="${WORKDIR}/inputs_1D_syst.json"
JSON_STAT="${WORKDIR}/inputs_1D_stat.json"
SNAPSHOT_WS="${WORKDIR}/higgsCombine_AsimovPostfit.MultiDimFit.mH${MASS}.root"
OBSERVED_SNAPSHOT_WS="${WORKDIR}/higgsCombine_ObservedPostfit.MultiDimFit.mH${MASS}.root"

python3 - <<PY
import json
from pathlib import Path

mode = "${MODE}"
pois = "${POIS}".split(",")
points = "${POINTS}:${SPLIT_POINTS}"
range_r_thq = "${RANGE_R_THQ}"
range_r_tth = "${RANGE_R_TTH}"
mass = "${MASS}"

def build_entry(statonly=False):
    fits = []
    points_list = []
    fit_opts = []
    base_opts = f"--freezeParameters MH --setParameters MH={mass},r_tHq=1,r_ttH=1 --setParameterRanges r_tHq={range_r_thq}:r_ttH={range_r_tth} --saveSpecifiedNuis all"
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

run_snapshot() {
  if [[ ! -f "${OUTPUT_BASE}/Datacard_${ANALYSIS_TAG}.root" ]]; then
    echo "[ERROR] Missing ${OUTPUT_BASE}/Datacard_${ANALYSIS_TAG}.root. Run --steps t2w first." >&2
    exit 1
  fi
  if [[ ${ASIMOV} -eq 1 ]]; then
    (cd "${WORKDIR}" && combine -M MultiDimFit "${OUTPUT_BASE}/Datacard_${ANALYSIS_TAG}.root" -m "${MASS}" -t -1 \
      --setParameters r_tHq=1,r_ttH=1,MH="${MASS}" --freezeParameters MH \
      --saveWorkspace --saveFitResult -n _AsimovPostfit \
      -P r_tHq -P r_ttH --floatOtherPOIs 1 \
      --cminDefaultMinimizerStrategy 0 --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants \
      --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2)
    if [[ ! -f "${SNAPSHOT_WS}" ]]; then
      echo "[ERROR] Snapshot not found at ${SNAPSHOT_WS}" >&2
      exit 1
    fi
  else
    (cd "${WORKDIR}" && combine -M MultiDimFit "${OUTPUT_BASE}/Datacard_${ANALYSIS_TAG}.root" -m "${MASS}" \
      --setParameters r_tHq=1,r_ttH=1,MH="${MASS}" --freezeParameters MH \
      --saveWorkspace --saveFitResult -n _ObservedPostfit \
      -P r_tHq -P r_ttH --floatOtherPOIs 1 \
      --cminDefaultMinimizerStrategy 0 --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants \
      --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2)
    if [[ ! -f "${OBSERVED_SNAPSHOT_WS}" ]]; then
      echo "[ERROR] Snapshot not found at ${OBSERVED_SNAPSHOT_WS}" >&2
      exit 1
    fi
  fi
}

ensure_asimov_snapshot() {
  if [[ ! -f "${SNAPSHOT_WS}" ]]; then
    echo "[INFO] Snapshot missing. Running snapshot step first..."
    local old_asimov="${ASIMOV}"
    ASIMOV=1
    run_snapshot
    ASIMOV="${old_asimov}"
  fi
}

ensure_observed_snapshot() {
  if [[ ! -f "${OBSERVED_SNAPSHOT_WS}" ]]; then
    echo "[INFO] Observed snapshot missing. Running snapshot step first..."
    local old_asimov="${ASIMOV}"
    ASIMOV=0
    run_snapshot
    ASIMOV="${old_asimov}"
  fi
}

if [[ -n "${DO[snapshot]:-}" ]]; then
  run_snapshot
fi

SNAPSHOT_OPTS=""
  if [[ ${ASIMOV} -eq 1 ]]; then
    # Only attach the snapshot if it already exists; do not auto-run it here.
    if [[ -f "${SNAPSHOT_WS}" ]]; then
      SNAPSHOT_OPTS="--snapshotWSFile ${SNAPSHOT_WS}"
    else
      echo "[WARN] Snapshot missing at ${SNAPSHOT_WS}. Run --steps snapshot first (or include it in the same command)."
    fi
  fi

build_workspace_arg() {
  if [[ ${ASIMOV} -eq 1 ]]; then
    echo "${SNAPSHOT_WS} --snapshotName MultiDimFit"
  else
    echo "${OUTPUT_BASE}/Datacard_${ANALYSIS_TAG}.root"
  fi
}

build_common_asimov_opts() {
  local freeze_extra="${1:-}"
  local set_params="MH=${MASS},r_tHq=1,r_ttH=1"
  local freeze_params="MH"
  if [[ -n "${freeze_extra}" ]]; then
    freeze_params="${freeze_params},${freeze_extra}"
  fi
  if [[ ${STAT_ONLY} -eq 1 ]]; then
    freeze_params="${freeze_params},allConstrainedNuisances"
  fi

  local opts="--setParameters ${set_params} --freezeParameters ${freeze_params}"
  if [[ ${ASIMOV} -eq 1 ]]; then
    opts="${opts} -t -1"
  fi
  echo "${opts}"
}

build_limit_mode_opts() {
  if [[ ${ASIMOV} -eq 1 ]]; then
    echo "--run expected"
  fi
}

run_single_combine() {
  local outdir="$1"
  local label="$2"
  shift 2
  mkdir -p "${outdir}"
  (cd "${outdir}" && combine "$@" -n "${label}")
}

collect_limits_if_present() {
  local outdir="$1"
  local output_json="$2"
  shift 2
  local pattern=("$@")
  local files=()
  for p in "${pattern[@]}"; do
    for f in ${p}; do
      [[ -f "${f}" ]] && files+=("${f}")
    done
  done
  if [[ ${#files[@]} -gt 0 ]]; then
    (cd "${outdir}" && combineTool.py -M CollectLimits "${files[@]##${outdir}/}" -o "${output_json}")
  fi
}

write_hybrid_limit_tH_inputs() {
  local outdir="$1"
  local workspace_arg="$2"

  mkdir -p "${outdir}"

  local freeze_csv=""
  if [[ ${FREEZE_OTHER_POI} -eq 1 ]]; then
    freeze_csv="r_ttH"
  fi
  if [[ ${STAT_ONLY} -eq 1 ]]; then
    if [[ -n "${freeze_csv}" ]]; then
      freeze_csv="${freeze_csv},allConstrainedNuisances"
    else
      freeze_csv="allConstrainedNuisances"
    fi
  fi

  python3 - <<PY
import json

mass = "${MASS}"
range_min = float("${HYBRID_RANGE_MIN}")
range_max = float("${HYBRID_RANGE_MAX}")

# HybridNewGrid's --from-asymptotic helper expands the input span [a, b] to
# [max(0, a - 0.3(b-a)), b + 0.3(b-a)]. Choose a = 0 and b = range_max / 1.3
# so that the resulting grid is exactly [0, range_max].
seed_max = range_max / 1.3
seed = {
    mass: {
        "obs": range_min,
        "exp0": seed_max
    }
}
with open("${outdir}/hybrid_seed_range.json", "w") as f:
    json.dump(seed, f, indent=2)
PY

  python3 - <<PY
import json
cfg = {
  "grids": [],
  "POIs": ["MH", "r_tHq"],
  "opts": "-d ${workspace_arg} --testStat=LHC --LHCmode LHC-limits "
          "--redefineSignalPOI r_tHq "
          "--cminDefaultMinimizerStrategy 0 "
          "--X-rtd MINIMIZER_freezeDisassociatedParams "
          "--X-rtd MINIMIZER_multiMin_hideConstants "
          "--X-rtd MINIMIZER_multiMin_maskConstraints "
          "--X-rtd MINIMIZER_multiMin_maskChannels=2"
          + (" --setParameters r_ttH=1" if "${FREEZE_OTHER_POI}" == "1" else "")
          + (" --freezeParameters ${freeze_csv}" if "${freeze_csv}" else ""),
  "toys_per_cycle": ${HYBRID_TOYS_PER_CYCLE},
  "min_toys": ${HYBRID_MIN_TOYS},
  "max_toys": ${HYBRID_MAX_TOYS},
  "CL": 0.95,
  "signif": 3.0,
  "verbose": False,
  "from_asymptotic_settings": {"points": ${HYBRID_POINTS}}
}
with open("${outdir}/hybrid_grid.json", "w") as f:
    json.dump(cfg, f, indent=2)
PY
}

build_hybrid_condor_sub_opts() {
  local opts="+JobFlavour = \"${QUEUE}\""
  if [[ -n "${SUB_OPTS}" ]]; then
    opts+=$'\n'"${SUB_OPTS}"
  fi
  if [[ -n "${MAX_MATERIALIZE}" ]]; then
    opts+=$'\n'"max_materialize = ${MAX_MATERIALIZE}"
  fi
  printf '%s' "${opts}"
}

run_hybrid_limit_tH_submit() {
  local outdir="$1"
  local label_suffix="$2"
  local workspace_arg="$3"
  local common_opts="$4"

  write_hybrid_limit_tH_inputs "${outdir}" "${workspace_arg}"
  local condor_sub_opts
  condor_sub_opts="$(build_hybrid_condor_sub_opts)"
  (
    cd "${outdir}"
    combineTool.py -M HybridNewGrid hybrid_grid.json \
      --cycles "${HYBRID_CYCLES}" \
      --from-asymptotic hybrid_seed_range.json \
      --job-mode condor \
      --task-name "limit_tH_hybrid_${label_suffix}" \
      --sub-opts "${condor_sub_opts}"
  )
}

run_hybrid_limit_tH_collect() {
  local outdir="$1"
  local workspace_arg="$2"

  write_hybrid_limit_tH_inputs "${outdir}" "${workspace_arg}"
  (
    cd "${outdir}"
    combineTool.py -M HybridNewGrid hybrid_grid.json \
      --cycles 0 \
      --output \
      --from-asymptotic hybrid_seed_range.json
  )
  collect_limits_if_present "${outdir}" "limits_hybridnew.json" \
    "${outdir}"/higgsCombine.final.MH.*.r_tHq.HybridNew.mH*.root
}

if [[ -n "${DO[scan]:-}" ]]; then
  if [[ ${ASIMOV} -eq 1 ]]; then
    ensure_asimov_snapshot
  fi
  (cd "${WORKDIR}" && python3 "${SCRIPT_DIR}/RunFits.py" --inputJson "${JSON_SYST}" --mode "${MODE}" \
    --mass "${MASS}" --queue "${QUEUE}" --batch condor --datacardDir "${OUTPUT_BASE}" --ext "${EXT}" ${ASIMOV_FLAG} ${SNAPSHOT_OPTS} \
    --subOpts "${SUB_OPTS}")
fi

if [[ -n "${DO[scan-stat]:-}" ]]; then
  if [[ ${ASIMOV} -eq 1 ]]; then
    ensure_asimov_snapshot
    (cd "${WORKDIR}" && python3 "${SCRIPT_DIR}/RunFits.py" --inputJson "${JSON_STAT}" --mode "${MODE}" \
      --mass "${MASS}" --queue "${QUEUE}" --batch condor --datacardDir "${OUTPUT_BASE}" --ext "${EXT}" ${ASIMOV_FLAG} ${SNAPSHOT_OPTS} \
      --subOpts "${SUB_OPTS}")
  else
    ensure_observed_snapshot
    (cd "${WORKDIR}" && python3 "${SCRIPT_DIR}/RunFits.py" --inputJson "${JSON_STAT}" --mode "${MODE}" \
      --mass "${MASS}" --queue "${QUEUE}" --batch condor --datacardDir "${OUTPUT_BASE}" --ext "${EXT}" ${ASIMOV_FLAG} \
      --snapshotWSFile "${OBSERVED_SNAPSHOT_WS}" --subOpts "${SUB_OPTS}")
  fi
fi

if [[ -n "${DO[limit-tH]:-}" ]]; then
  if [[ ${ASIMOV} -eq 1 ]]; then
    ensure_asimov_snapshot
  fi
  if [[ ${ASIMOV} -eq 0 && ${STAT_ONLY} -eq 1 ]]; then
    echo "[ERROR] Observed stat-only limits are not implemented in this script." >&2
    exit 1
  fi
  WORKSPACE_ARG="$(build_workspace_arg)"
  FREEZE_EXTRA=""
  if [[ ${FREEZE_OTHER_POI} -eq 1 ]]; then
    FREEZE_EXTRA="r_ttH"
  fi
  COMMON_OPTS="$(build_common_asimov_opts "${FREEZE_EXTRA}")"
  LIMIT_MODE_OPTS="$(build_limit_mode_opts)"
  LIMIT_DIR="${WORKDIR}/limit_tH"
  LABEL_SUFFIX="syst"
  if [[ ${STAT_ONLY} -eq 1 ]]; then
    LABEL_SUFFIX="stat"
  fi
  if [[ ${FREEZE_OTHER_POI} -eq 1 ]]; then
    LABEL_SUFFIX="${LABEL_SUFFIX}_fixedOtherPOI"
  fi
  if [[ ${HYBRID_NEW} -eq 1 ]]; then
    HYBRID_DIR="${LIMIT_DIR}/hybridnew_${LABEL_SUFFIX}"
    run_hybrid_limit_tH_submit "${HYBRID_DIR}" "${LABEL_SUFFIX}" "${WORKSPACE_ARG}" "${COMMON_OPTS}"
  else
    run_single_combine "${LIMIT_DIR}" "_limit_tH_${LABEL_SUFFIX}" \
      -M AsymptoticLimits ${WORKSPACE_ARG} -m "${MASS}" ${LIMIT_MODE_OPTS} \
      --redefineSignalPOI r_tHq --rMin 0 --rMax 25 ${COMMON_OPTS} \
      --cminDefaultMinimizerStrategy 0 \
      --X-rtd MINIMIZER_freezeDisassociatedParams \
      --X-rtd MINIMIZER_multiMin_hideConstants \
      --X-rtd MINIMIZER_multiMin_maskConstraints \
      --X-rtd MINIMIZER_multiMin_maskChannels=2
  fi
fi

if [[ -n "${DO[limit-tH-hybrid-submit]:-}" ]]; then
  if [[ ${ASIMOV} -eq 1 ]]; then
    ensure_asimov_snapshot
  fi
  if [[ ${ASIMOV} -eq 0 && ${STAT_ONLY} -eq 1 ]]; then
    echo "[ERROR] Observed stat-only HybridNew limits are not implemented in this script." >&2
    exit 1
  fi
  WORKSPACE_ARG="$(build_workspace_arg)"
  FREEZE_EXTRA=""
  if [[ ${FREEZE_OTHER_POI} -eq 1 ]]; then
    FREEZE_EXTRA="r_ttH"
  fi
  COMMON_OPTS="$(build_common_asimov_opts "${FREEZE_EXTRA}")"
  LIMIT_DIR="${WORKDIR}/limit_tH"
  LABEL_SUFFIX="syst"
  if [[ ${STAT_ONLY} -eq 1 ]]; then
    LABEL_SUFFIX="stat"
  fi
  if [[ ${FREEZE_OTHER_POI} -eq 1 ]]; then
    LABEL_SUFFIX="${LABEL_SUFFIX}_fixedOtherPOI"
  fi
  HYBRID_DIR="${LIMIT_DIR}/hybridnew_${LABEL_SUFFIX}"
  run_hybrid_limit_tH_submit "${HYBRID_DIR}" "${LABEL_SUFFIX}" "${WORKSPACE_ARG}" "${COMMON_OPTS}"
fi

if [[ -n "${DO[limit-tH-hybrid-collect]:-}" ]]; then
  if [[ ${ASIMOV} -eq 1 ]]; then
    ensure_asimov_snapshot
  fi
  if [[ ${ASIMOV} -eq 0 && ${STAT_ONLY} -eq 1 ]]; then
    echo "[ERROR] Observed stat-only HybridNew limits are not implemented in this script." >&2
    exit 1
  fi
  WORKSPACE_ARG="$(build_workspace_arg)"
  FREEZE_EXTRA=""
  if [[ ${FREEZE_OTHER_POI} -eq 1 ]]; then
    FREEZE_EXTRA="r_ttH"
  fi
  COMMON_OPTS="$(build_common_asimov_opts "${FREEZE_EXTRA}")"
  LIMIT_DIR="${WORKDIR}/limit_tH"
  LABEL_SUFFIX="syst"
  if [[ ${STAT_ONLY} -eq 1 ]]; then
    LABEL_SUFFIX="stat"
  fi
  if [[ ${FREEZE_OTHER_POI} -eq 1 ]]; then
    LABEL_SUFFIX="${LABEL_SUFFIX}_fixedOtherPOI"
  fi
  HYBRID_DIR="${LIMIT_DIR}/hybridnew_${LABEL_SUFFIX}"
  run_hybrid_limit_tH_collect "${HYBRID_DIR}" "${WORKSPACE_ARG}"
fi

if [[ -n "${DO[significance-tth]:-}" ]]; then
  if [[ ${HYBRID_NEW} -eq 1 ]]; then
    echo "[ERROR] --hybrid-new is only supported for --steps limit-tH." >&2
    exit 1
  fi
  if [[ ${ASIMOV} -eq 1 ]]; then
    ensure_asimov_snapshot
  fi
  if [[ ${ASIMOV} -eq 0 && ${STAT_ONLY} -eq 1 ]]; then
    echo "[ERROR] Observed stat-only significances are not implemented in this script." >&2
    exit 1
  fi
  WORKSPACE_ARG="$(build_workspace_arg)"
  FREEZE_EXTRA=""
  if [[ ${FREEZE_OTHER_POI} -eq 1 ]]; then
    FREEZE_EXTRA="r_tHq"
  fi
  COMMON_OPTS="$(build_common_asimov_opts "${FREEZE_EXTRA}")"
  SIGNIF_DIR="${WORKDIR}/significance_ttH"
  LABEL_SUFFIX="syst"
  if [[ ${STAT_ONLY} -eq 1 ]]; then
    LABEL_SUFFIX="stat"
  fi
  if [[ ${FREEZE_OTHER_POI} -eq 1 ]]; then
    LABEL_SUFFIX="${LABEL_SUFFIX}_fixedOtherPOI"
  fi
  run_single_combine "${SIGNIF_DIR}" "_significance_ttH_${LABEL_SUFFIX}" \
    -M Significance ${WORKSPACE_ARG} -m "${MASS}" \
    --redefineSignalPOI r_ttH --rMin 0 --rMax 5 ${COMMON_OPTS} \
    --cminDefaultMinimizerStrategy 0 \
    --X-rtd MINIMIZER_freezeDisassociatedParams \
    --X-rtd MINIMIZER_multiMin_hideConstants \
    --X-rtd MINIMIZER_multiMin_maskConstraints \
    --X-rtd MINIMIZER_multiMin_maskChannels=2
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
