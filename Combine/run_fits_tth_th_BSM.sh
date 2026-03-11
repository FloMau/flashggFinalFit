#!/usr/bin/env bash

# Wrapper to run BSM fits for the ttH/tH analysis.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Steps:
#   0 / models      : sync signal/background Models into output/<analysis>/Models
#   1 / asimov-sm   : build the SM Asimov dataset (for non-SM AsimovLabel use step 3)
#   1b / asimov-postfit : fit AsimovLabel dataset once and save snapshot (for postfit Asimov regeneration)
#   1c / asimov-regen   : regenerate AsimovLabel dataset from postfit snapshot (r=1)
#   2 / typeA (alias: smfits) : fixed AsimovLabel dataset (postfit-regenerated), scan over signal models (--couplings)
#   3 / bsmasimov   : build BSM Asimov datasets
#   3b / bsm-postfit: fit each BSM Asimov with its own signal model and save snapshot
#   3c / bsm-regen  : regenerate each BSM Asimov dataset from its postfit snapshot (r=1)
#   4 / bsmfit (Type-B): fixed SM signal model, scan over datasets (postfit-regenerated BSM Asimovs)
#   5 / plot        : collect and plot 2D scans
#
# Prerequisites:
#   - Datacards produced by runDatacardSteps.sh for all coupling scenarios.
#   - SM Asimov toy built once (see STEP 0 below).
#   - Models and input JSON already include the new coupling labels.
#
# How to run:
#   bash run_fits_tth_th_BSM.sh --step 0
#   bash run_fits_tth_th_BSM.sh --steps 1,3
#   bash run_fits_tth_th_BSM.sh --steps 2,5
#   bash run_fits_tth_th_BSM.sh --step plot
#   bash run_fits_tth_th_BSM.sh --step 2 --max-materialize 10
#
# Condor throttling:
#   --max-materialize N limits how many jobs are materialized at once for each
#   submitted fit task (i.e. each coupling/mode batch submitted by RunFits.py).
#   This helps reduce filesystem pressure when many points are queued.



##################################################################################
# FIDUCIAL MODE
# Set FIDUCIAL=true to run in fiducial mode (requires fiducial datacards and models).
FIDUCIAL=true
# Set USE_NODECO=1 or pass --noDeco to use noDeco inputs/outputs.
USE_NODECO=0
##################################################################################

print_usage() {
  cat <<'EOF'
Usage: run_fits_tth_th_BSM.sh --step <list>
  --step/--steps accepts comma-separated values (names or numbers):
    0 / models
    1 / asimov-sm (SM only; for non-SM AsimovLabel use step 3)
    1b / asimov-postfit (fit AsimovLabel dataset once, save snapshot)
    1c / asimov-regen (regenerate AsimovLabel dataset from snapshot, r=1)
    2 / typeA (alias: smfits) (fixed AsimovLabel dataset, scan signal models from --couplings)
    3 / bsmasimov (build each BSM Asimov dataset)
    3b / bsm-postfit (fit each BSM Asimov with its own model, save snapshot)
    3c / bsm-regen (regenerate each BSM Asimov from snapshot, r=1)
    4 / bsmfit (Type-B: fixed SM signal model, scan regenerated BSM Asimov datasets)
    5 / plot
  Example: --steps 0,1,5
  Optional:
    --asimov-snapshot <path>  override SM Asimov snapshot root file path
    --noDeco      use noDeco analysis tag and model paths
    --syst        use syst datacards and signal models (appends _syst to analysis tag)
    --freeze-constrained-nuisances  run stat-only scans using the syst workspace
                   (adds allConstrainedNuisances to --freezeParameters at runtime).
                   Intended for Type-A/Type-B scans with --syst so outputs stay
                   in the syst directory while profiling is stat-only.
                   Results are written to runFits*_*_statOnlyFromSyst to avoid
                   clobbering the full-syst scans.
    --asimovLabel <SM|CPodd|Ktm1Ktt0|...>  use this Asimov dataset for type-A scans (default: SM)
    --couplings <basic-bsm|extended-bsm|sm-only|all>  select coupling set (default: basic-bsm), affects steps 2, 3, 4, 5
    --max-materialize <N>  pass Condor max_materialize to RunFits submissions
  example for step 5:
    bash run_fits_tth_th_BSM.sh --step 5 --asimovLabel CPodd
EOF
}

STEPS_RAW=""
ASIMOV_LABEL="SM"
COUPLINGS_SET="basic-bsm"
MAX_MATERIALIZE=""
USE_SYST=0
FREEZE_CONSTRAINED=0
MASS=125.08
ASIMOV_SNAPSHOT_OVERRIDE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --step|--steps)
      if [[ -n "${STEPS_RAW}" ]]; then
        STEPS_RAW="${STEPS_RAW},$2"
      else
        STEPS_RAW="$2"
      fi
      shift 2
      ;;
    --all)
      STEPS_RAW="0,1,2,3,4,5"
      shift 1
      ;;
    --use-asimov-snapshot)
      echo "[INFO] --use-asimov-snapshot is now the default; ignoring." >&2
      shift 1
      ;;
    --asimov-snapshot)
      ASIMOV_SNAPSHOT_OVERRIDE="$2"
      shift 2
      ;;
    --noDeco)
      USE_NODECO=1
      shift 1
      ;;
    --syst)
      USE_SYST=1
      shift 1
      ;;
    --freeze-constrained-nuisances|--stat-only-from-syst)
      FREEZE_CONSTRAINED=1
      shift 1
      ;;
    --asimovLabel)
      ASIMOV_LABEL="$2"
      shift 2
      ;;
    --couplings)
      COUPLINGS_SET="$2"
      shift 2
      ;;
    --max-materialize)
      MAX_MATERIALIZE="$2"
      shift 2
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "${STEPS_RAW}" ]]; then
  echo "[ERROR] No steps selected. Use --step/--steps." >&2
  print_usage >&2
  exit 1
fi

if [[ ${FREEZE_CONSTRAINED} -eq 1 && ${USE_SYST} -eq 0 ]]; then
  echo "[WARN] --freeze-constrained-nuisances is intended for --syst runs; continuing anyway." >&2
fi

RUN_EXT_SUFFIX=""
if [[ ${FREEZE_CONSTRAINED} -eq 1 ]]; then
  RUN_EXT_SUFFIX="_statOnlyFromSyst"
fi
RUNFITS_FREEZE_OPT=""
if [[ ${FREEZE_CONSTRAINED} -eq 1 ]]; then
  RUNFITS_FREEZE_OPT="--freezeConstrainedNuisances"
fi

RUNFITS_SUBOPTS=""
if [[ -n "${MAX_MATERIALIZE}" ]]; then
  if ! [[ "${MAX_MATERIALIZE}" =~ ^[0-9]+$ ]]; then
    echo "[ERROR] --max-materialize must be an integer (got '${MAX_MATERIALIZE}')." >&2
    exit 1
  fi
  RUNFITS_SUBOPTS="max_materialize = ${MAX_MATERIALIZE}"
fi

DO_SYNC_MODELS=0
DO_ASIMOV_SM=0
DO_ASIMOV_POSTFIT=0
DO_ASIMOV_REGEN=0
DO_SM_FITS=0
DO_BSM_ASIMOV=0
DO_BSM_POSTFIT=0
DO_BSM_REGEN=0
DO_BSM_FITS=0
DO_PLOT=0

IFS=',' read -ra STEP_LIST <<< "${STEPS_RAW}"
for step in "${STEP_LIST[@]}"; do
  step="${step// /}"
  case "${step}" in
    0|models|sync-models|sync_models) DO_SYNC_MODELS=1 ;;
    1|asimov|asimov-sm|sm_asimov) DO_ASIMOV_SM=1 ;;
    1b|asimov-postfit|asimov_postfit|postfit|snapshot) DO_ASIMOV_POSTFIT=1 ;;
    1c|asimov-regen|asimov_regen|regen|postfit-asimov) DO_ASIMOV_REGEN=1 ;;
    2|typeA|typea|smfits|fit-sm|fit-sm-asimov) DO_SM_FITS=1 ;;
    3|bsmasimov|asimov-bsm|bsm-asimov) DO_BSM_ASIMOV=1 ;;
    3b|bsm-postfit|bsm_postfit|postfit-bsm) DO_BSM_POSTFIT=1 ;;
    3c|bsm-regen|bsm_regen|regen-bsm) DO_BSM_REGEN=1 ;;
    4|bsmfit|fit-bsm|fit-bsm-asimov) DO_BSM_FITS=1 ;;
    5|plot|plots) DO_PLOT=1 ;;
    *)
      echo "[ERROR] Unknown step '${step}'." >&2
      print_usage >&2
      exit 1
      ;;
  esac
done


# Models are resolved via the relative ./Models paths in the datacards,
# so we keep them inside the analysis-specific output directory.



source "${SCRIPT_DIR}/../setup.sh"
if [[ -z "${CMSSW_BASE:-}" ]]; then
  export CMSSW_BASE="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
fi

################################################################################
# MODE SELECTION (inclusive vs fiducial)
################################################################################
ANALYSIS_TAG="tth_th_analysis"
MODE_SUFFIX=""
ASIMOV_SUFFIX=""

if [[ "${FIDUCIAL}" == "true" ]]; then
  ANALYSIS_TAG="tth_th_analysis_fiducial"
  MODE_SUFFIX="_fiducial"
  ASIMOV_SUFFIX="_fiducial"
fi
if [[ ${USE_NODECO} -eq 1 ]]; then
  ANALYSIS_TAG="${ANALYSIS_TAG}_noDeco"
fi
if [[ ${USE_SYST} -eq 1 ]]; then
  ANALYSIS_TAG="${ANALYSIS_TAG}_syst"
fi
INPUT_JSON_BASE="${SCRIPT_DIR}/inputs_statonly_tth_th.json"
OUTPUT_BASE="${SCRIPT_DIR}/output/${ANALYSIS_TAG}"
mkdir -p "${OUTPUT_BASE}"
SNAPSHOT_DIR="${OUTPUT_BASE}/snapshots"
mkdir -p "${SNAPSHOT_DIR}"
SCALED_JSON_DIR="${OUTPUT_BASE}/inputs_scaled"
mkdir -p "${SCALED_JSON_DIR}"
DATACARD_BASE="${SCRIPT_DIR}/../Datacard/datacard_outputs/${ANALYSIS_TAG}"
MODEL_DIR="${OUTPUT_BASE}/Models"
MODEL_SIGNAL_DIR="${MODEL_DIR}/signal"
MODEL_BACKGROUND_DIR="${MODEL_DIR}/background"
DEFAULT_SIGNAL_DIR="${SCRIPT_DIR}/../Signal/outdir_packaged_${ANALYSIS_TAG}"
MODEL_SRC_SIGNAL="${MODEL_SRC_SIGNAL:-${DEFAULT_SIGNAL_DIR}}"

BASE_ANALYSIS_TAG="${ANALYSIS_TAG%%_fiducial*}"
if [[ "${ANALYSIS_TAG}" == *"_noDeco"* && "${BASE_ANALYSIS_TAG}" != *"_noDeco" ]]; then
  BASE_ANALYSIS_TAG="${BASE_ANALYSIS_TAG}_noDeco"
fi
DEFAULT_BKG_DIR="${SCRIPT_DIR}/../Background/outdir_${ANALYSIS_TAG}"
if [[ "${ANALYSIS_TAG}" == *"_fiducial"* ]]; then
  DEFAULT_BKG_DIR="${SCRIPT_DIR}/../Background/outdir_${BASE_ANALYSIS_TAG}"
fi
MODEL_SRC_BACKGROUND="${MODEL_SRC_BACKGROUND:-${DEFAULT_BKG_DIR}}"

echo "[INFO] Type-A scans use regenerated postfit Asimov dataset (auto-built when missing)."

SM_ASIMOV_TAG=${SM_ASIMOV_TAG:-${ASIMOV_LABEL}_Asimov}
BSM_ASIMOV_TAG=${BSM_ASIMOV_TAG:-BSM_Asimov}
POINTS_2D_TOTAL=${POINTS_2D_TOTAL:-10000}
POINTS_2D_SPLIT=${POINTS_2D_SPLIT:-200}

# For --syst runs, reduce points per job to avoid overly long condor jobs.
if [[ ${USE_SYST} -eq 1 ]]; then
  if [[ "${POINTS_2D_SPLIT}" =~ ^[0-9]+$ && "${POINTS_2D_SPLIT}" -gt 1 ]]; then
    POINTS_2D_SPLIT=$(( POINTS_2D_SPLIT / 10 ))
    if [[ "${POINTS_2D_SPLIT}" -lt 1 ]]; then
      POINTS_2D_SPLIT=1
    fi
  fi
fi
POINTS_2D="${POINTS_2D_TOTAL}:${POINTS_2D_SPLIT}"

FIDUCIAL_YAML_DEFAULT="/net/data_cms3a-1/mausolf/HttCPAnalysis/modelDependenceStudies/fiducial_fractions_2022postEE.yaml"
FIDUCIAL_YAML=${FIDUCIAL_YAML:-${FIDUCIAL_YAML_DEFAULT}}
if [[ "${FIDUCIAL}" != "true" ]]; then
  FIDUCIAL_YAML=""
fi

has_model_files() {
  local dir="$1"
  shopt -s nullglob
  local files=("${dir}"/CMS-HGG*.root)
  shopt -u nullglob
  [[ ${#files[@]} -gt 0 ]]
}

sync_models() {
  if [[ ! -d "${MODEL_SRC_SIGNAL}" ]]; then
    echo "[ERROR] Signal model source directory missing: ${MODEL_SRC_SIGNAL}" >&2
    exit 1
  fi
  if [[ ! -d "${MODEL_SRC_BACKGROUND}" ]]; then
    echo "[ERROR] Background model source directory missing: ${MODEL_SRC_BACKGROUND}" >&2
    exit 1
  fi
  if ! has_model_files "${MODEL_SRC_SIGNAL}"; then
    echo "[ERROR] No CMS-HGG*.root files found in ${MODEL_SRC_SIGNAL}" >&2
    exit 1
  fi
  if ! has_model_files "${MODEL_SRC_BACKGROUND}"; then
    echo "[ERROR] No CMS-HGG*.root files found in ${MODEL_SRC_BACKGROUND}" >&2
    exit 1
  fi
  mkdir -p "${MODEL_SIGNAL_DIR}" "${MODEL_BACKGROUND_DIR}"
  shopt -s nullglob
  for f in "${MODEL_SRC_SIGNAL}"/CMS-HGG*.root; do
    cp -v "${f}" "${MODEL_SIGNAL_DIR}/"
  done
  for f in "${MODEL_SRC_BACKGROUND}"/CMS-HGG*.root; do
    cp -v "${f}" "${MODEL_BACKGROUND_DIR}/"
  done
  shopt -u nullglob
}

ensure_models() {
  if [[ ! -d "${MODEL_SIGNAL_DIR}" ]]; then
    echo "[ERROR] Signal models directory missing: ${MODEL_SIGNAL_DIR}" >&2
    exit 1
  fi
  if [[ ! -d "${MODEL_BACKGROUND_DIR}" ]]; then
    echo "[ERROR] Background models directory missing: ${MODEL_BACKGROUND_DIR}" >&2
    exit 1
  fi

  if ! has_model_files "${MODEL_SIGNAL_DIR}"; then
    echo "[ERROR] No CMS-HGG*.root files found in ${MODEL_SIGNAL_DIR}" >&2
    echo "Run step 0 (models) or set MODEL_SRC_SIGNAL." >&2
    exit 1
  fi
  if ! has_model_files "${MODEL_BACKGROUND_DIR}"; then
    echo "[ERROR] No CMS-HGG*.root files found in ${MODEL_BACKGROUND_DIR}" >&2
    echo "Run step 0 (models) or set MODEL_SRC_BACKGROUND." >&2
    exit 1
  fi
}

if [[ ${DO_SYNC_MODELS} -eq 1 ]]; then
  sync_models
fi

if [[ ${DO_ASIMOV_SM} -eq 1 || ${DO_SM_FITS} -eq 1 || ${DO_BSM_ASIMOV} -eq 1 || ${DO_BSM_FITS} -eq 1 ]]; then
  ensure_models
fi

################################################################################
# INPUT CARDS
################################################################################
CARD_SM="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}.txt"
declare -A CARD_MAP=(
  ["SM"]="${CARD_SM}"
  ["CPodd"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_CPodd.txt"
  ["Ktm1Ktt0"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Ktm1Ktt0.txt"
  ["Kt0p7Ktt0p7"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt0p7Ktt0p7.txt"
  ["Kt0p7Kttm0p7"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt0p7Kttm0p7.txt"
  ["Kt0Kttm1"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt0Kttm1.txt"
  ["Kt0Ktt0"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt0Ktt0.txt"
  ["Kt0p500Ktt0p000"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt0p500Ktt0p000.txt"
  ["Kt0p354Ktt0p354"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt0p354Ktt0p354.txt"
  ["Kt0p000Ktt0p500"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt0p000Ktt0p500.txt"
  ["Ktm0p500Ktt0p000"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Ktm0p500Ktt0p000.txt"
  ["Kt0p000Kttm0p500"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt0p000Kttm0p500.txt"
  ["Kt0p354Kttm0p354"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt0p354Kttm0p354.txt"
  ["Kt1p500Ktt0p000"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt1p500Ktt0p000.txt"
  ["Kt1p061Ktt1p061"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt1p061Ktt1p061.txt"
  ["Kt0p000Ktt1p500"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt0p000Ktt1p500.txt"
  ["Ktm1p500Ktt0p000"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Ktm1p500Ktt0p000.txt"
  ["Kt0p000Kttm1p500"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt0p000Kttm1p500.txt"
  ["Kt1p061Kttm1p061"]="${DATACARD_BASE}/Datacard_${ANALYSIS_TAG}_Kt1p061Kttm1p061.txt"
)
BASIC_CPL_ORDER=("SM" "CPodd" "Ktm1Ktt0" "Kt0p7Ktt0p7" "Kt0p7Kttm0p7" "Kt0Kttm1" "Kt0Ktt0")
EXT_CPL_ORDER=("Kt0p500Ktt0p000" "Kt0p354Ktt0p354" "Kt0p000Ktt0p500" "Ktm0p500Ktt0p000" "Kt0p000Kttm0p500" "Kt0p354Kttm0p354" "Kt1p500Ktt0p000" "Kt1p061Ktt1p061" "Kt0p000Ktt1p500" "Ktm1p500Ktt0p000" "Kt0p000Kttm1p500" "Kt1p061Kttm1p061")
case "${COUPLINGS_SET}" in
  basic-bsm)    CPL_ORDER=("${BASIC_CPL_ORDER[@]}") ;;
  extended-bsm) CPL_ORDER=("${EXT_CPL_ORDER[@]}") ;;
  sm-only)      CPL_ORDER=("SM") ;;
  all)          CPL_ORDER=("${BASIC_CPL_ORDER[@]}" "${EXT_CPL_ORDER[@]}") ;;
  *)
    echo "[ERROR] Invalid --couplings '${COUPLINGS_SET}' (use basic-bsm|extended-bsm|sm-only|all)" >&2
    exit 1
    ;;
esac

# helper
prepare_card() {
  local card_path="$1"
  local target="$2"
  [[ -f "$card_path" ]] || { echo "[ERROR] Card not found: $card_path" >&2; exit 1; }
  mkdir -p "$(dirname "$target")"
  cp -v "$card_path" "$target"
}

link_models() {
  local card_dir="$1"
  [[ -d "${OUTPUT_BASE}/Models" ]] || { echo "[ERROR] Models directory missing under ${OUTPUT_BASE}. Run step 0 or sync models first." >&2; exit 1; }
  ln -sfn "${OUTPUT_BASE}/Models" "${card_dir}/Models"
}

build_scaled_json() {
  local scale_mode="$1"
  local center_on="$2"
  local override_base_for="$3"
  local output_json="$4"
  python3 "${SCRIPT_DIR}/build_scaled_inputs_tth_th.py" \
    --base-json "${INPUT_JSON_BASE}" \
    --output-json "${output_json}" \
    --scale-mode "${scale_mode}" \
    --center-on "${center_on}" \
    --override-base-for "${override_base_for}" \
    --fiducial-yaml "${FIDUCIAL_YAML}" \
    --points-2d "${POINTS_2D}"
}


get_range_from_json() {
  local json_path="$1"
  local mode="$2"
  local param="$3"
  python3 - "${json_path}" "${mode}" "${param}" <<'PY'
import json
import re
import sys

json_path, mode, param = sys.argv[1:4]
data = json.load(open(json_path))
opts = data[mode]["fit_opts"]
m = re.search(rf"{param}=([-0-9.]+),([-0-9.]+)", opts)
if not m:
    raise SystemExit(2)
print(f"{m.group(1)},{m.group(2)}")
PY
}

mode_exists_in_json() {
  local json_path="$1"
  local mode="$2"
  python3 - "${json_path}" "${mode}" <<'PY'
import json
import sys
json_path, mode = sys.argv[1:3]
data = json.load(open(json_path))
sys.exit(0 if mode in data else 1)
PY
}

################################################################################
# STEP 0: build SM Asimov toy
################################################################################
if [[ "${ASIMOV_LABEL}" == "SM" ]]; then
  ASIMOV_EXT="SMAsimov${ASIMOV_SUFFIX}"
  ASIMOV_TOY="higgsCombine${ASIMOV_EXT}.GenerateOnly.mH${MASS}.0.root"
else
  ASIMOV_EXT="${ASIMOV_LABEL}_Asimov${ASIMOV_SUFFIX}"
  ASIMOV_TOY="higgsCombine${ASIMOV_EXT}.GenerateOnly.mH${MASS}.0.root"
fi
ASIMOV_ROOT="Datacard_${ASIMOV_EXT}.root"
TOYS_FILE="${OUTPUT_BASE}/${ASIMOV_TOY}"
ASIMOV_POSTFIT_EXT="${ASIMOV_EXT}_postfit"
ASIMOV_REGEN_EXT="${ASIMOV_LABEL}Asimov_postfit${ASIMOV_SUFFIX}"
ASIMOV_REGEN_TOY="higgsCombine${ASIMOV_REGEN_EXT}.GenerateOnly.mH${MASS}.0.root"
TOYS_FILE_REGEN="${OUTPUT_BASE}/${ASIMOV_REGEN_TOY}"
COMBINE_COMMON_OPTS="--cminDefaultMinimizerStrategy 0 --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2"

snapshot_tag() {
  local dataset="$1"
  local template="$2"
  echo "snapshot_${dataset}_with_${template}"
}

snapshot_path() {
  local dataset="$1"
  local template="$2"
  local tag
  tag="$(snapshot_tag "${dataset}" "${template}")"
  echo "${SNAPSHOT_DIR}/higgsCombine_${tag}.MultiDimFit.mH${MASS}.root"
}

make_snapshot() {
  local ws_root="$1"
  local toys_file="$2"
  local dataset="$3"
  local template="$4"
  local tag
  tag="$(snapshot_tag "${dataset}" "${template}")"
  local out
  out="$(snapshot_path "${dataset}" "${template}")"
  if [[ -f "${out}" ]]; then
    echo "${out}"
    return 0
  fi
  [[ -f "${ws_root}" ]] || { echo "[ERROR] Workspace not found: ${ws_root}" >&2; exit 1; }
  [[ -f "${toys_file}" ]] || { echo "[ERROR] Asimov toy not found: ${toys_file}" >&2; exit 1; }
  pushd "${SNAPSHOT_DIR}" >/dev/null
  combine -M MultiDimFit "${ws_root}" -m ${MASS} -t -1 --toysFile "${toys_file}" \
          --setParameters r_tHq=1,r_ttH=1,MH=${MASS} --freezeParameters MH \
          --saveWorkspace --saveFitResult -n _${tag} \
          -P r_tHq -P r_ttH --floatOtherPOIs 1 ${COMBINE_COMMON_OPTS}
  popd >/dev/null
  [[ -f "${out}" ]] || { echo "[ERROR] Expected snapshot not found at ${out}" >&2; exit 1; }
  echo "${out}"
}

SM_SNAPSHOT_PATH="$(snapshot_path "${ASIMOV_EXT}" "SM")"
ASIMOV_SNAPSHOT_PATH="$(snapshot_path "${ASIMOV_EXT}" "${ASIMOV_LABEL}")"
if [[ -n "${ASIMOV_SNAPSHOT_OVERRIDE}" ]]; then
  SM_SNAPSHOT_PATH="${ASIMOV_SNAPSHOT_OVERRIDE}"
  ASIMOV_SNAPSHOT_PATH="${ASIMOV_SNAPSHOT_OVERRIDE}"
fi

ASIMOV_LABEL_MODE="r_2D${MODE_SUFFIX}"
ASIMOV_LABEL_CARD="${CARD_SM}"
ASIMOV_LABEL_CARD_DIR="${OUTPUT_BASE}"
if [[ "${ASIMOV_LABEL}" != "SM" ]]; then
  ASIMOV_LABEL_MODE="r_2D_${ASIMOV_LABEL}${MODE_SUFFIX}"
  ASIMOV_LABEL_CARD="${CARD_MAP[$ASIMOV_LABEL]}"
  ASIMOV_LABEL_CARD_DIR="${OUTPUT_BASE}/cards/${ASIMOV_EXT}"
fi
ASIMOV_LABEL_WS="${ASIMOV_LABEL_CARD_DIR}/Datacard_${ASIMOV_EXT}.root"

ensure_asimov_label_ws() {
  if [[ -f "${ASIMOV_LABEL_WS}" ]]; then
    return 0
  fi
  if [[ "${ASIMOV_LABEL}" == "SM" ]]; then
    pushd "${OUTPUT_BASE}" >/dev/null
    prepare_card "${ASIMOV_LABEL_CARD}" "Datacard_${ASIMOV_EXT}.txt"
    python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode "${ASIMOV_LABEL_MODE}" --batch local --ext "${ASIMOV_EXT}" --outputDir .
    popd >/dev/null
  else
    [[ -f "${ASIMOV_LABEL_CARD}" ]] || { echo "[ERROR] Card for ${ASIMOV_LABEL} not found at ${ASIMOV_LABEL_CARD}" >&2; exit 1; }
    mkdir -p "${ASIMOV_LABEL_CARD_DIR}"
    prepare_card "${ASIMOV_LABEL_CARD}" "${ASIMOV_LABEL_CARD_DIR}/Datacard_${ASIMOV_EXT}.txt"
    link_models "${ASIMOV_LABEL_CARD_DIR}"
    pushd "${ASIMOV_LABEL_CARD_DIR}" >/dev/null
    python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode "${ASIMOV_LABEL_MODE}" --batch local --ext "${ASIMOV_EXT}" --outputDir .
    popd >/dev/null
  fi
  [[ -f "${ASIMOV_LABEL_WS}" ]] || { echo "[ERROR] Expected workspace not found at ${ASIMOV_LABEL_WS}" >&2; exit 1; }
}

ensure_regenerated_asimov() {
  if [[ -f "${TOYS_FILE_REGEN}" ]]; then
    return 0
  fi
  ensure_asimov_label_ws
  [[ -f "${TOYS_FILE}" ]] || { echo "[ERROR] Asimov toy not found at ${TOYS_FILE}. Build ${ASIMOV_LABEL} Asimov first (step 0 for SM, step 3 for BSM)." >&2; exit 1; }
  SNAPSHOT_PATH="$(make_snapshot "${ASIMOV_LABEL_WS}" "${TOYS_FILE}" "${ASIMOV_EXT}" "${ASIMOV_LABEL}")"
  pushd "${OUTPUT_BASE}" >/dev/null
  combine -M GenerateOnly "${SNAPSHOT_PATH}" -m ${MASS} -t -1 \
          --snapshotName MultiDimFit \
          --saveWorkspace --saveToys -n ${ASIMOV_REGEN_EXT} -s 0 \
          --setParameters r_tHq=1,r_ttH=1,MH=${MASS} --freezeParameters MH
  popd >/dev/null
  [[ -f "${TOYS_FILE_REGEN}" ]] || { echo "[ERROR] Expected regenerated Asimov toy not found at ${TOYS_FILE_REGEN}" >&2; exit 1; }
}

ensure_bsm_ws() {
  local cpl="$1"
  local as_ext="$2"
  local card="${CARD_MAP[$cpl]}"
  local card_dir="${OUTPUT_BASE}/cards/${as_ext}"
  local ws="${card_dir}/Datacard_${as_ext}.root"
  if [[ -f "${ws}" ]]; then
    return 0
  fi
  [[ -f "${card}" ]] || { echo "[ERROR] Card for ${cpl} not found at ${card}" >&2; exit 1; }
  mkdir -p "${card_dir}"
  prepare_card "${card}" "${card_dir}/Datacard_${as_ext}.txt"
  link_models "${card_dir}"
  pushd "${card_dir}" >/dev/null
  python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode "r_2D_${cpl}${MODE_SUFFIX}" --batch local --ext "${as_ext}" --outputDir .
  popd >/dev/null
  [[ -f "${ws}" ]] || { echo "[ERROR] Expected workspace not found at ${ws}" >&2; exit 1; }
}

ensure_regenerated_bsm() {
  local cpl="$1"
  local as_ext="$2"
  local as_toy="$3"
  local regen_ext="${as_ext}_postfit"
  local regen_toy="${OUTPUT_BASE}/higgsCombine${regen_ext}.GenerateOnly.mH${MASS}.0.root"
  if [[ -f "${regen_toy}" ]]; then
    echo "${regen_toy}"
    return 0
  fi
  [[ -f "${as_toy}" ]] || { echo "[ERROR] Asimov toy not found at ${as_toy}" >&2; exit 1; }
  ensure_bsm_ws "${cpl}" "${as_ext}"
  local ws="${OUTPUT_BASE}/cards/${as_ext}/Datacard_${as_ext}.root"
  local snapshot_path
  snapshot_path="$(make_snapshot "${ws}" "${as_toy}" "${as_ext}" "${cpl}")"
  pushd "${OUTPUT_BASE}" >/dev/null
  combine -M GenerateOnly "${snapshot_path}" -m ${MASS} -t -1 \
          --snapshotName MultiDimFit \
          --saveWorkspace --saveToys -n ${regen_ext} -s 0 \
          --setParameters r_tHq=1,r_ttH=1,MH=${MASS} --freezeParameters MH
  popd >/dev/null
  [[ -f "${regen_toy}" ]] || { echo "[ERROR] Expected regenerated Asimov toy not found at ${regen_toy}" >&2; exit 1; }
  echo "${regen_toy}"
}

if [[ ${DO_ASIMOV_SM} -eq 1 ]]; then
  if [[ "${ASIMOV_LABEL}" != "SM" ]]; then
    echo "[ERROR] Step 1 builds only the SM Asimov dataset. Use --asimovLabel SM or run step 3 for ${ASIMOV_LABEL} Asimov." >&2
    exit 1
  fi
  pushd "${OUTPUT_BASE}" >/dev/null
  # SM Asimov
  prepare_card "$CARD_SM" "Datacard_${ASIMOV_EXT}.txt"
  python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode r_2D${MODE_SUFFIX} --batch local --ext ${ASIMOV_EXT} --outputDir .
  combine -M GenerateOnly ${ASIMOV_ROOT} -m ${MASS} -t -1 \
          --saveWorkspace --saveToys -n ${ASIMOV_EXT} -s 0 \
          --setParameters r_tHq=1,r_ttH=1,MH=${MASS} --freezeParameters MH
  popd >/dev/null
fi

################################################################################
# STEP 1b: fit Asimov once and save snapshot (for postfit Asimov regeneration)
################################################################################
if [[ ${DO_ASIMOV_POSTFIT} -eq 1 ]]; then
  if [[ -n "${ASIMOV_SNAPSHOT_OVERRIDE}" ]]; then
    [[ -f "${SM_SNAPSHOT_PATH}" ]] || { echo "[ERROR] Asimov snapshot not found at ${SM_SNAPSHOT_PATH}" >&2; exit 1; }
  else
    [[ -f "${TOYS_FILE}" ]] || { echo "[ERROR] Asimov toy not found at ${TOYS_FILE}. Run step 1 first (SM) or step 3 (BSM)." >&2; exit 1; }
    ensure_asimov_label_ws
    make_snapshot "${ASIMOV_LABEL_WS}" "${TOYS_FILE}" "${ASIMOV_EXT}" "${ASIMOV_LABEL}" >/dev/null
  fi
fi

################################################################################
# STEP 1c: regenerate Asimov dataset from postfit snapshot (r=1)
################################################################################
if [[ ${DO_ASIMOV_REGEN} -eq 1 ]]; then
  ensure_regenerated_asimov
fi

################################################################################
# (A) Fit SM Asimov with each BSM template
################################################################################
if [[ ${DO_SM_FITS} -eq 1 ]]; then
  ensure_regenerated_asimov
  TOYS_FILE_USE="${TOYS_FILE_REGEN}"
  INPUT_JSON_SM="${SCALED_JSON_DIR}/inputs_statonly_tth_th_scaled${MODE_SUFFIX}.json"
  # SM Asimov (SM rates) fitted with BSM templates: center at 1/XS_ratio, width scaled by 1/XS_ratio.
  build_scaled_json "inverse" "inverse" "" "${INPUT_JSON_SM}"
  for CPL in "${CPL_ORDER[@]}"; do
    CARD="${CARD_MAP[$CPL]}"
    if [[ ! -f "${CARD}" ]]; then
      echo "[WARN] Card for ${CPL} not found at ${CARD}; skipping." >&2
      continue
    fi
    MODE="r_2D${MODE_SUFFIX}"
    EXT="${SM_ASIMOV_TAG}"
    EXT_RUN="${EXT}${RUN_EXT_SUFFIX}"
    # For BSM labels use the coupling-specific mode; SM uses the base r_2D model.
    if [[ "${CPL}" != "SM" ]]; then
      MODE="r_2D_${CPL}${MODE_SUFFIX}"
    fi
    if ! mode_exists_in_json "${INPUT_JSON_SM}" "${MODE}"; then
      echo "[WARN] Mode '${MODE}' missing in ${INPUT_JSON_SM}; skipping ${CPL}." >&2
      continue
    fi
    echo ">>> [Type A scan | Asimov=${ASIMOV_LABEL}] Processing coupling ${CPL} (mode ${MODE}, ext ${EXT})"
    CARD_DIR="${OUTPUT_BASE}/cards/${EXT_RUN}/${CPL}"
    prepare_card "${CARD}" "${CARD_DIR}/Datacard_${EXT_RUN}.txt"
    link_models "${CARD_DIR}"
    pushd "${CARD_DIR}" >/dev/null
    python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode ${MODE} --batch local --ext ${EXT_RUN} --outputDir .
    popd >/dev/null
    RUNFITS_TOY_OPTS="--toysFile ${TOYS_FILE_USE}"
    RUNFITS_SNAPSHOT_OPTS=""
    # For the template matching the Asimov label, use the postfit snapshot
    # workspace to keep the discrete background model (pdfindex) aligned with
    # the regenerated Asimov dataset (no freezing; just consistent initialization).
    if [[ "${CPL}" == "${ASIMOV_LABEL}" ]]; then
      if [[ -f "${ASIMOV_SNAPSHOT_PATH}" ]]; then
        RUNFITS_SNAPSHOT_OPTS="--snapshotWSFile ${ASIMOV_SNAPSHOT_PATH}"
      else
        echo "[WARN] Asimov snapshot not found at ${ASIMOV_SNAPSHOT_PATH}; proceeding without snapshotWSFile." >&2
      fi
    fi
    pushd "${OUTPUT_BASE}" >/dev/null
    python3 "${SCRIPT_DIR}/RunFits.py" --inputJson "${INPUT_JSON_SM}" --mode ${MODE} --ext ${EXT_RUN} --mass ${MASS} \
      ${RUNFITS_TOY_OPTS} ${RUNFITS_SNAPSHOT_OPTS} ${RUNFITS_FREEZE_OPT} --datacardDir "${CARD_DIR}" ${RUNFITS_SUBOPTS:+--subOpts "${RUNFITS_SUBOPTS}"}
    popd >/dev/null
  done
fi

################################################################################
# (B) Build BSM Asimovs and/or fit them with the SM template
################################################################################
if [[ ${DO_BSM_ASIMOV} -eq 1 ]]; then
  for CPL in "${CPL_ORDER[@]}"; do
    [[ "${CPL}" == "SM" ]] && continue
    CARD="${CARD_MAP[$CPL]}"
    if [[ ! -f "${CARD}" ]]; then
      echo "[WARN] Card for ${CPL} not found at ${CARD}; skipping." >&2
      continue
    fi
    AS_EXT="${CPL}_Asimov${ASIMOV_SUFFIX}"
    CARD_DIR="${OUTPUT_BASE}/cards/${AS_EXT}"
    AS_ROOT="${CARD_DIR}/Datacard_${AS_EXT}.root"
    if ! mode_exists_in_json "${INPUT_JSON_BASE}" "r_2D_${CPL}${MODE_SUFFIX}"; then
      echo "[WARN] Mode 'r_2D_${CPL}${MODE_SUFFIX}' missing in ${INPUT_JSON_BASE}; skipping ${CPL} Asimov build." >&2
      continue
    fi
    echo ">>> [BSM Asimov] Building ${CPL} Asimov"
    prepare_card "${CARD}" "${CARD_DIR}/Datacard_${AS_EXT}.txt"
    link_models "${CARD_DIR}"
    pushd "${CARD_DIR}" >/dev/null
    python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode r_2D_${CPL}${MODE_SUFFIX} --batch local --ext ${AS_EXT} --outputDir .
    popd >/dev/null
    pushd "${OUTPUT_BASE}" >/dev/null
    combine -M GenerateOnly "${AS_ROOT}" -m ${MASS} -t -1 \
            --saveWorkspace --saveToys -n ${AS_EXT} -s 0 \
            --setParameters r_tHq=1,r_ttH=1,MH=${MASS} --freezeParameters MH
    popd >/dev/null
  done
fi

################################################################################
# STEP 3b: fit each BSM Asimov with its own signal model (save snapshot)
################################################################################
if [[ ${DO_BSM_POSTFIT} -eq 1 ]]; then
  for CPL in "${CPL_ORDER[@]}"; do
    [[ "${CPL}" == "SM" ]] && continue
    AS_EXT="${CPL}_Asimov${ASIMOV_SUFFIX}"
    AS_TOY="${OUTPUT_BASE}/higgsCombine${AS_EXT}.GenerateOnly.mH${MASS}.0.root"
    [[ -f "${AS_TOY}" ]] || { echo "[ERROR] Asimov toy missing for ${CPL}: ${AS_TOY}. Run step 3 first." >&2; exit 1; }
    ensure_bsm_ws "${CPL}" "${AS_EXT}"
    ws="${OUTPUT_BASE}/cards/${AS_EXT}/Datacard_${AS_EXT}.root"
    make_snapshot "${ws}" "${AS_TOY}" "${AS_EXT}" "${CPL}" >/dev/null
  done
fi

################################################################################
# STEP 3c: regenerate each BSM Asimov dataset from snapshot (r=1)
################################################################################
if [[ ${DO_BSM_REGEN} -eq 1 ]]; then
  for CPL in "${CPL_ORDER[@]}"; do
    [[ "${CPL}" == "SM" ]] && continue
    AS_EXT="${CPL}_Asimov${ASIMOV_SUFFIX}"
    AS_TOY="${OUTPUT_BASE}/higgsCombine${AS_EXT}.GenerateOnly.mH${MASS}.0.root"
    [[ -f "${AS_TOY}" ]] || { echo "[ERROR] Asimov toy missing for ${CPL}: ${AS_TOY}. Run step 3 first." >&2; exit 1; }
    snapshot_file="$(snapshot_path "${AS_EXT}" "${CPL}")"
    [[ -f "${snapshot_file}" ]] || { echo "[ERROR] Snapshot missing for ${CPL}: ${snapshot_file}. Run step 3b first." >&2; exit 1; }
    regen_ext="${AS_EXT}_postfit"
    regen_toy="${OUTPUT_BASE}/higgsCombine${regen_ext}.GenerateOnly.mH${MASS}.0.root"
    if [[ -f "${regen_toy}" ]]; then
      continue
    fi
    pushd "${OUTPUT_BASE}" >/dev/null
    combine -M GenerateOnly "${snapshot_file}" -m ${MASS} -t -1 \
            --snapshotName MultiDimFit \
            --saveWorkspace --saveToys -n ${regen_ext} -s 0 \
            --setParameters r_tHq=1,r_ttH=1,MH=${MASS} --freezeParameters MH
    popd >/dev/null
    [[ -f "${regen_toy}" ]] || { echo "[ERROR] Expected regenerated Asimov toy not found at ${regen_toy}" >&2; exit 1; }
  done
fi

if [[ ${DO_BSM_FITS} -eq 1 ]]; then
  INPUT_JSON_BSM="${SCALED_JSON_DIR}/inputs_statonly_tth_th_scaled_bsmfit${MODE_SUFFIX}.json"
  # Build one JSON with per-coupling entries (r_2D_<CPL>) scaled for BSM Asimov fits.
  build_scaled_json "inverse_sqrt" "ratio" "" "${INPUT_JSON_BSM}"
  for CPL in "${CPL_ORDER[@]}"; do
    [[ "${CPL}" == "SM" ]] && continue
    CARD="${CARD_MAP[$CPL]}"
    if [[ ! -f "${CARD}" ]]; then
      echo "[WARN] Card for ${CPL} not found at ${CARD}; skipping." >&2
      continue
    fi
    AS_EXT="${CPL}_Asimov${ASIMOV_SUFFIX}"
    AS_TOY="${OUTPUT_BASE}/higgsCombine${AS_EXT}.GenerateOnly.mH${MASS}.0.root"
    if [[ -f "${AS_TOY}" ]]; then
      echo ">>> [BSM Asimov] Fitting ${CPL} Asimov with SM template"
      SM_EXT="${BSM_ASIMOV_TAG}"
      SM_EXT_RUN="${SM_EXT}${RUN_EXT_SUFFIX}"
      MODE="r_2D_${CPL}${MODE_SUFFIX}"
      if ! mode_exists_in_json "${INPUT_JSON_BSM}" "${MODE}"; then
        echo "[WARN] Mode '${MODE}' missing in ${INPUT_JSON_BSM}; skipping ${CPL}." >&2
        continue
      fi
      CARD_DIR="${OUTPUT_BASE}/cards/${SM_EXT_RUN}/${CPL}"
      prepare_card "${CARD_SM}" "${CARD_DIR}/Datacard_${SM_EXT_RUN}.txt"
      link_models "${CARD_DIR}"
      pushd "${CARD_DIR}" >/dev/null
      python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode r_2D${MODE_SUFFIX} --batch local --ext ${SM_EXT_RUN} --outputDir .
      popd >/dev/null
      REGEN_TOY="$(ensure_regenerated_bsm "${CPL}" "${AS_EXT}" "${AS_TOY}")"
      pushd "${OUTPUT_BASE}" >/dev/null
      python3 "${SCRIPT_DIR}/RunFits.py" --inputJson "${INPUT_JSON_BSM}" --mode ${MODE} --ext ${SM_EXT_RUN} --mass ${MASS} --toysFile "${REGEN_TOY}" ${RUNFITS_FREEZE_OPT} --datacardDir "${CARD_DIR}" ${RUNFITS_SUBOPTS:+--subOpts "${RUNFITS_SUBOPTS}"}
      popd >/dev/null
    else
      echo "[WARN] Asimov toy missing for ${CPL}: ${AS_TOY}. Run step 3 first." >&2
    fi
  done
fi

################################################################################
# (Optional) collect & plot: run after fits are done (set PLOT_2D=true)
################################################################################
if [[ ${DO_PLOT} -eq 1 ]]; then
  echo ">>> Collecting and plotting 2D scans (requires finished fits)"
  pushd "${OUTPUT_BASE}" >/dev/null
  BASE_DIR="$(pwd)"
  PLOT_BASE_SM="${OUTPUT_BASE}/plots_${ASIMOV_LABEL}_asimov"
  PLOT_BASE_BSM="${OUTPUT_BASE}/plots_bsm_asimov"
  INPUT_JSON_SM="${SCALED_JSON_DIR}/inputs_statonly_tth_th_scaled${MODE_SUFFIX}.json"
  # Match the SM-Asimov fit ranges: center at 1/XS_ratio, width ~1/XS_ratio.
  build_scaled_json "inverse" "inverse" "" "${INPUT_JSON_SM}"

  # Helper: try to merge points if no profile file exists yet
  merge_points_if_needed() {
    local dir="$1"
    local outfile="$2"
    local pattern="$3"
    if ls ${pattern} >/dev/null 2>&1; then
      echo "  -> Merging points in ${dir}"
      hadd -f "${outfile}" ${pattern}
    fi
  }

  run_plot() {
    local tree_file="$1"
    local xrange="$2"
    local yrange="$3"
    local ext="$4"
    local outdir="$5"
    mkdir -p "${outdir}"
    pushd "${outdir}" >/dev/null
    python3 "${SCRIPT_DIR}/../Plots/make2DPlot.py" \
      --inputTreeFile "${tree_file}" \
      --xparam   "r_tHq:${xrange}" \
      --yparam   "r_ttH:${yrange}" \
      --nPoints  1000 \
      --nBins    200 \
      --interpolation linear \
      --doBestFit \
      --doSM \
      --ext      "${ext}"
    popd >/dev/null
  }

  # (A) Asimov (label=${ASIMOV_LABEL}) fitted with each template
  for CPL in "${CPL_ORDER[@]}"; do
    MODE="r_2D${MODE_SUFFIX}"
    EXT="${SM_ASIMOV_TAG}"
    EXT_RUN="${EXT}${RUN_EXT_SUFFIX}"
    [[ "${CPL}" != "SM" ]] && MODE="r_2D_${CPL}${MODE_SUFFIX}"
    DIR_PRIMARY="runFits${EXT_RUN}_${MODE}"

    if [[ -d "${DIR_PRIMARY}" ]]; then
      python3 "${SCRIPT_DIR}/CollectFits.py" --inputJson "${INPUT_JSON_SM}" --mode ${MODE} --ext ${EXT_RUN}
    else
      echo "[WARN] Fit output not found for ${CPL} (${DIR_PRIMARY}); skipping collect/plot."
      continue
    fi

    TREE="${DIR_PRIMARY}/profile2D_statonly_fixedMH_r_tHq_vs_r_ttH.root"
    merge_points_if_needed "${DIR_PRIMARY}" "${TREE}" "${DIR_PRIMARY}/higgsCombine_profile2D_statonly_fixedMH_r_tHq_vs_r_ttH*.POINTS.*.root"
    if [[ -f "${TREE}" ]]; then
      XRANGE="$(get_range_from_json "${INPUT_JSON_SM}" "${MODE}" "r_tHq")"
      YRANGE="$(get_range_from_json "${INPUT_JSON_SM}" "${MODE}" "r_ttH")"
      PLOT_SUBDIR="${PLOT_BASE_SM}/${CPL}"
      run_plot "${BASE_DIR}/${TREE}" "${XRANGE}" "${YRANGE}" "_${EXT_RUN}_${CPL}_rscan" "${PLOT_SUBDIR}"
    else
      echo "[WARN] Plot input missing for ${CPL}: ${TREE}"
    fi
  done

  # (B) BSM Asimovs fitted with the SM template
  INPUT_JSON_BSM="${SCALED_JSON_DIR}/inputs_statonly_tth_th_scaled_bsmfit${MODE_SUFFIX}.json"
  build_scaled_json "inverse_sqrt" "ratio" "" "${INPUT_JSON_BSM}"
  for CPL in "${CPL_ORDER[@]}"; do
    [[ "${CPL}" == "SM" ]] && continue
    SM_EXT="${BSM_ASIMOV_TAG}"
    SM_EXT_RUN="${SM_EXT}${RUN_EXT_SUFFIX}"
    MODE="r_2D_${CPL}${MODE_SUFFIX}"
    DIR_PRIMARY="runFits${SM_EXT_RUN}_${MODE}"

    if [[ -d "${DIR_PRIMARY}" ]]; then
      python3 "${SCRIPT_DIR}/CollectFits.py" --inputJson "${INPUT_JSON_BSM}" --mode ${MODE} --ext ${SM_EXT_RUN}
    else
      echo "[WARN] Fit output not found for ${SM_EXT} (${DIR_PRIMARY}); skipping collect/plot."
      continue
    fi

    TREE="${DIR_PRIMARY}/profile2D_statonly_fixedMH_r_tHq_vs_r_ttH.root"
    merge_points_if_needed "${DIR_PRIMARY}" "${TREE}" "${DIR_PRIMARY}/higgsCombine_profile2D_statonly_fixedMH_r_tHq_vs_r_ttH*.POINTS.*.root"
    if [[ -f "${TREE}" ]]; then
      XRANGE="$(get_range_from_json "${INPUT_JSON_BSM}" "${MODE}" "r_tHq")"
      YRANGE="$(get_range_from_json "${INPUT_JSON_BSM}" "${MODE}" "r_ttH")"
      PLOT_SUBDIR="${PLOT_BASE_BSM}/${CPL}"
      run_plot "${BASE_DIR}/${TREE}" "${XRANGE}" "${YRANGE}" "_${SM_EXT_RUN}_${CPL}_rscan" "${PLOT_SUBDIR}"
    else
      echo "[WARN] Plot input missing for ${SM_EXT}: ${TREE}"
    fi
  done
  popd >/dev/null
fi
