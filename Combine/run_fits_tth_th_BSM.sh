#!/usr/bin/env bash

# Wrapper to run BSM fits for the ttH/tH analysis.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Steps:
#   0 / models      : sync signal/background Models into output/<analysis>/Models
#   1 / asimov-sm   : build the SM Asimov dataset
#   2 / smfits      : fit SM Asimov with each BSM template
#   3 / bsmasimov   : build BSM Asimov datasets
#   4 / bsmfit      : fit each BSM Asimov with the SM template
#   5 / plot        : collect and plot 2D scans
#
# Prerequisites:
#   - Datacards produced by runDatacardSteps.sh for all coupling scenarios.
#   - SM Asimov toy built once (see STEP 0 below).
#   - Models and input JSON already include the new coupling labels.
#
# How to run:
#   bash run_fits_tth_th_BSM.sh --step 0
#   bash run_fits_tth_th_BSM.sh --step 1
#   bash run_fits_tth_th_BSM.sh --steps 2,5
#   bash run_fits_tth_th_BSM.sh --step plot



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
    1 / asimov-sm
    2 / smfits
    3 / bsmasimov
    4 / bsmfit
    5 / plot
  Example: --steps 0,1,5
  Optional:
    --fine-grid   run an additional fine 2D scan in the same output directory
    --setPdfIndices  freeze discrete pdfindex nuisances using pdfindex.json
      (override path with PDFINDEX_SOURCE=/path/to/pdfindex.json)
    --noDeco      use noDeco analysis tag and model paths
EOF
}

STEPS_RAW=""
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
    --fine-grid)
      FINE_GRID=1
      shift 1
      ;;
    --setPdfIndices)
      SET_PDFINDICES=1
      shift 1
      ;;
    --noDeco)
      USE_NODECO=1
      shift 1
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

DO_SYNC_MODELS=0
DO_ASIMOV_SM=0
DO_SM_FITS=0
DO_BSM_ASIMOV=0
DO_BSM_FITS=0
DO_PLOT=0
FINE_GRID=${FINE_GRID:-0}
SET_PDFINDICES=${SET_PDFINDICES:-0}

IFS=',' read -ra STEP_LIST <<< "${STEPS_RAW}"
for step in "${STEP_LIST[@]}"; do
  step="${step// /}"
  case "${step}" in
    0|models|sync-models|sync_models) DO_SYNC_MODELS=1 ;;
    1|asimov|asimov-sm|sm_asimov) DO_ASIMOV_SM=1 ;;
    2|smfits|fit-sm|fit-sm-asimov) DO_SM_FITS=1 ;;
    3|bsmasimov|asimov-bsm|bsm-asimov) DO_BSM_ASIMOV=1 ;;
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
PDFIDX_SUFFIX=""
RUNFITS_PDFOPTS=""
if [[ ${SET_PDFINDICES} -eq 1 ]]; then
  PDFIDX_SUFFIX="_pdfidx"
  RUNFITS_PDFOPTS="--setPdfIndices"
fi
INPUT_JSON_BASE="${SCRIPT_DIR}/inputs_statonly_tth_th.json"
OUTPUT_BASE="${SCRIPT_DIR}/output/${ANALYSIS_TAG}"
mkdir -p "${OUTPUT_BASE}"
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

PDFINDEX_SOURCE="${PDFINDEX_SOURCE:-${OUTPUT_BASE}/pdfindex_${ANALYSIS_TAG}.json}"

ensure_pdfindex_json() {
  local ext="$1"
  if [[ ${SET_PDFINDICES} -ne 1 ]]; then
    return 0
  fi
  [[ -f "${PDFINDEX_SOURCE}" ]] || { echo "[ERROR] Missing ${PDFINDEX_SOURCE} for --setPdfIndices" >&2; exit 1; }
  cp -f "${PDFINDEX_SOURCE}" "${OUTPUT_BASE}/pdfindex${ext}.json"
}

if [[ ${SET_PDFINDICES} -eq 1 ]]; then
  echo "[INFO] --setPdfIndices enabled; using PDFINDEX_SOURCE=${PDFINDEX_SOURCE}"
fi

SM_ASIMOV_TAG=${SM_ASIMOV_TAG:-SM_Asimov}
BSM_ASIMOV_TAG=${BSM_ASIMOV_TAG:-BSM_Asimov}
POINTS_2D_TOTAL=${POINTS_2D_TOTAL:-20000}
POINTS_2D_SPLIT=${POINTS_2D_SPLIT:-400}
POINTS_2D="${POINTS_2D_TOTAL}:${POINTS_2D_SPLIT}"

FINE_POINTS=${FINE_POINTS:-20200}
FINE_SPLIT=${FINE_SPLIT:-404}
FINE_FRAC=${FINE_FRAC:-0.2}
FINE_SM_R_THQ_MIN=${FINE_SM_R_THQ_MIN:-0.0}
FINE_SM_R_THQ_MAX=${FINE_SM_R_THQ_MAX:-2.0}
FINE_SM_R_TTH_MIN=${FINE_SM_R_TTH_MIN:-0.8}
FINE_SM_R_TTH_MAX=${FINE_SM_R_TTH_MAX:-1.2}
FINE_CENTER_MODE=${FINE_CENTER_MODE:-none}
FIDUCIAL_YAML_DEFAULT="/net/data_cms3a-1/mausolf/HttCPAnalysis/modelDependenceStudies/fiducial_fractions_2022postEE.yaml"
FIDUCIAL_YAML=${FIDUCIAL_YAML:-${FIDUCIAL_YAML_DEFAULT}}
if [[ "${FIDUCIAL}" != "true" ]]; then
  FIDUCIAL_YAML=""
fi
FINE_FIDUCIAL_YAML=${FINE_FIDUCIAL_YAML:-${FIDUCIAL_YAML}}

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
)
CPL_ORDER=("SM" "CPodd" "Ktm1Ktt0" "Kt0p7Ktt0p7" "Kt0p7Kttm0p7" "Kt0Kttm1" "Kt0Ktt0")

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

build_fine_json() {
  local base_json="$1"
  local output_json="$2"
  FINE_POINTS="${FINE_POINTS}" \
  FINE_SPLIT="${FINE_SPLIT}" \
  FINE_FRAC="${FINE_FRAC}" \
  FINE_SM_R_THQ_MIN="${FINE_SM_R_THQ_MIN}" \
  FINE_SM_R_THQ_MAX="${FINE_SM_R_THQ_MAX}" \
  FINE_SM_R_TTH_MIN="${FINE_SM_R_TTH_MIN}" \
  FINE_SM_R_TTH_MAX="${FINE_SM_R_TTH_MAX}" \
  FINE_CENTER_MODE="${FINE_CENTER_MODE}" \
  FINE_FIDUCIAL_YAML="${FINE_FIDUCIAL_YAML}" \
  FINE_THQ_LEP_FRAC="0.3258" \
  python3 - "${base_json}" "${output_json}" <<'PY'
import json
import os
import re
import sys

base_json, output_json = sys.argv[1:3]
points = int(os.environ.get("FINE_POINTS", "20200"))
split = int(os.environ.get("FINE_SPLIT", "101"))
frac = float(os.environ.get("FINE_FRAC", "0.2"))
sm_tHq_min = float(os.environ.get("FINE_SM_R_THQ_MIN", "0.0"))
sm_tHq_max = float(os.environ.get("FINE_SM_R_THQ_MAX", "2.0"))
sm_ttH_min = float(os.environ.get("FINE_SM_R_TTH_MIN", "0.8"))
sm_ttH_max = float(os.environ.get("FINE_SM_R_TTH_MAX", "1.2"))
center_mode = os.environ.get("FINE_CENTER_MODE", "none").strip().lower()
fid_yaml = os.environ.get("FINE_FIDUCIAL_YAML", "")
thq_lep_frac = float(os.environ.get("FINE_THQ_LEP_FRAC", "0.3258"))

def extract_ranges(opts):
    m_thq = re.search(r"r_tHq=([-0-9.]+),([-0-9.]+)", opts)
    m_tth = re.search(r"r_ttH=([-0-9.]+),([-0-9.]+)", opts)
    if not m_thq or not m_tth:
        return None
    return (float(m_thq.group(1)), float(m_thq.group(2))), (float(m_tth.group(1)), float(m_tth.group(2)))

def replace_range(opts, param, new_min, new_max):
    pattern = rf"({param}=)([-0-9.]+),([-0-9.]+)"
    repl = rf"\g<1>{new_min:.2f},{new_max:.2f}"
    return re.sub(pattern, repl, opts, count=1)

def central_window(min_val, max_val, center=None):
    if center is None:
        center = 0.5 * (min_val + max_val)
    width = (max_val - min_val) * frac
    half = 0.5 * width
    new_min = center - half
    new_max = center + half
    if new_min < min_val:
        new_min = min_val
    if new_max > max_val:
        new_max = max_val
    return new_min, new_max

def parse_coupling(label):
    special = {
        "SM": (1.0, 0.0),
        "CPodd": (0.0, 1.0),
        "Ktm1Ktt0": (-1.0, 0.0),
        "Kt0Kttm1": (0.0, -1.0),
        "Kt0Ktt0": (0.0, 0.0),
    }
    if label in special:
        return special[label]
    m = re.match(
        r"Kt(?P<kt_sign>m?)(?P<kt_int>\\d+)(?:p(?P<kt_frac>\\d+))?"
        r"Ktt(?P<ktt_sign>m?)(?P<ktt_int>\\d+)(?:p(?P<ktt_frac>\\d+))?$",
        label,
    )
    if not m:
        return None
    def to_float(sign, whole, frac):
        val = float(whole)
        if frac:
            val += float(frac) / (10 ** len(frac))
        if sign == "m":
            val = -val
        return val
    kt = to_float(m.group("kt_sign"), m.group("kt_int"), m.group("kt_frac"))
    ktt = to_float(m.group("ktt_sign"), m.group("ktt_int"), m.group("ktt_frac"))
    return kt, ktt

def load_fiducial_fractions(path):
    try:
        import yaml
    except Exception:
        return None
    if not path or not os.path.isfile(path):
        return None
    with open(path, "r") as handle:
        data = yaml.safe_load(handle)
    processes = data.get("processes", {})
    fractions = {}
    for proc, info in processes.items():
        bins = info.get("bins", [])
        if not bins:
            continue
        in_frac = bins[0].get("in_frac")
        if in_frac is None:
            continue
        fractions[proc] = float(in_frac)
    return fractions

def fiducial_ratios(label, fractions):
    if fractions is None:
        return None
    try:
        import XSBRMap as xs
    except Exception:
        return None
    kt_ktt = parse_coupling(label)
    if kt_ktt is None:
        return None
    kt, ktt = kt_ktt

    def key(proc):
        return f"{proc}{'' if label == 'SM' else label}"

    def frac(proc):
        return fractions.get(proc, None)

    ttH_frac = frac(key("tth"))
    tHW_frac = frac(key("tHW"))
    tHq_had = frac(key("tHqHad"))
    tHq_lep = frac(key("tHqLep"))

    ttH_frac_sm = frac("tth")
    tHW_frac_sm = frac("tHW")
    tHq_had_sm = frac("tHqHad")
    tHq_lep_sm = frac("tHqLep")
    if None in (ttH_frac, tHW_frac, tHq_had, tHq_lep, ttH_frac_sm, tHW_frac_sm, tHq_had_sm, tHq_lep_sm):
        return None

    tth_sm_xs = xs.tth_sm_xs
    thw_sm_xs = xs.tHW_sm_xs
    thq_sm_xs = xs.tHq_sm_xs

    ttH_in = xs.tth_xs(kt, ktt) * ttH_frac
    tHW_in = xs.tHW_xs(kt, ktt) * tHW_frac
    tHq_in = xs.tHq_xs(kt, ktt) * (
        thq_lep_frac * tHq_lep + (1.0 - thq_lep_frac) * tHq_had
    )

    ttH_sm_in = tth_sm_xs * ttH_frac_sm
    tHW_sm_in = thw_sm_xs * tHW_frac_sm
    tHq_sm_in = thq_sm_xs * (
        thq_lep_frac * tHq_lep_sm + (1.0 - thq_lep_frac) * tHq_had_sm
    )

    if ttH_sm_in + tHW_sm_in <= 0 or tHq_sm_in <= 0:
        return None
    r_ttH = (ttH_in + tHW_in) / (ttH_sm_in + tHW_sm_in)
    r_tHq = tHq_in / tHq_sm_in
    return r_tHq, r_ttH

fractions = load_fiducial_fractions(fid_yaml)
if fractions is not None:
    # Add path for XSBRMap imports if not already available.
    script_dir = os.path.dirname(os.path.abspath(__file__))
    signal_tools = os.path.abspath(os.path.join(script_dir, "..", "Signal", "tools"))
    if signal_tools not in sys.path:
        sys.path.insert(0, signal_tools)

with open(base_json, "r") as handle:
    data = json.load(handle)

for mode, payload in data.items():
    if "points" in payload:
        payload["points"] = f"{points}:{split}"
    fit_opts = payload.get("fit_opts")
    if not fit_opts:
        continue
    ranges = extract_ranges(fit_opts)
    if not ranges:
        continue
    (tHq_min, tHq_max), (ttH_min, ttH_max) = ranges
    center_tHq = None
    center_ttH = None
    if center_mode in ("fiducial", "fiducial_inverse") and mode not in ("r_2D", "r_2D_fiducial"):
        label = mode.replace("r_2D_", "").replace("_fiducial", "")
        ratios = fiducial_ratios(label, fractions)
        if ratios is not None:
            r_tHq, r_ttH = ratios
            if center_mode == "fiducial_inverse":
                center_tHq = 1.0 / r_tHq if r_tHq > 0 else None
                center_ttH = 1.0 / r_ttH if r_ttH > 0 else None
            else:
                center_tHq = r_tHq
                center_ttH = r_ttH
    if mode in ("r_2D", "r_2D_fiducial"):
        tHq_min, tHq_max = sm_tHq_min, sm_tHq_max
        ttH_min, ttH_max = sm_ttH_min, sm_ttH_max
    else:
        tHq_min, tHq_max = central_window(tHq_min, tHq_max, center=center_tHq)
        ttH_min, ttH_max = central_window(ttH_min, ttH_max, center=center_ttH)
    fit_opts = replace_range(fit_opts, "r_tHq", tHq_min, tHq_max)
    fit_opts = replace_range(fit_opts, "r_ttH", ttH_min, ttH_max)
    payload["fit_opts"] = fit_opts

with open(output_json, "w") as handle:
    json.dump(data, handle, indent=2, sort_keys=True)
PY
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

################################################################################
# STEP 0: build SM Asimov toy
################################################################################
ASIMOV_EXT="SMAsimov${ASIMOV_SUFFIX}"
ASIMOV_ROOT="Datacard_${ASIMOV_EXT}.root"
ASIMOV_TOY="higgsCombine${ASIMOV_EXT}.GenerateOnly.mH125.38.0.root"
TOYS_FILE="${OUTPUT_BASE}/${ASIMOV_TOY}"

if [[ ${DO_ASIMOV_SM} -eq 1 ]]; then
  pushd "${OUTPUT_BASE}" >/dev/null
  # SM Asimov
  prepare_card "$CARD_SM" "Datacard_${ASIMOV_EXT}.txt"
  python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode r_2D${MODE_SUFFIX} --batch local --ext ${ASIMOV_EXT} --outputDir .
  combine -M GenerateOnly ${ASIMOV_ROOT} -m 125.38 -t -1 \
          --saveWorkspace --saveToys -n ${ASIMOV_EXT} -s 0 \
          --setParameters r_tHq=1,r_ttH=1,MH=125.38 --freezeParameters MH
  popd >/dev/null
fi

################################################################################
# (A) Fit SM Asimov with each BSM template
################################################################################
if [[ ${DO_SM_FITS} -eq 1 ]]; then
  [[ -f "${TOYS_FILE}" ]] || { echo "[ERROR] SM Asimov toy not found at ${TOYS_FILE}. Run step 0 first." >&2; exit 1; }
  INPUT_JSON_SM="${SCALED_JSON_DIR}/inputs_statonly_tth_th_scaled${MODE_SUFFIX}.json"
  # SM Asimov (SM rates) fitted with BSM templates: center at 1/XS_ratio, width scaled by 1/XS_ratio.
  build_scaled_json "inverse" "inverse" "" "${INPUT_JSON_SM}"
  INPUT_JSON_SM_FINE="${SCALED_JSON_DIR}/inputs_statonly_tth_th_scaled_fine${MODE_SUFFIX}.json"
  if [[ ${FINE_GRID} -eq 1 ]]; then
    FINE_CENTER_MODE="fiducial_inverse" build_fine_json "${INPUT_JSON_SM}" "${INPUT_JSON_SM_FINE}"
  fi
  for CPL in "${CPL_ORDER[@]}"; do
    CARD="${CARD_MAP[$CPL]}"
    if [[ ! -f "${CARD}" ]]; then
      echo "[WARN] Card for ${CPL} not found at ${CARD}; skipping." >&2
      continue
    fi
    MODE="r_2D${MODE_SUFFIX}"
    EXT="${SM_ASIMOV_TAG}"
    EXT_RUN="${EXT}${PDFIDX_SUFFIX}"
    # For BSM labels use the coupling-specific mode; SM uses the base r_2D model.
    if [[ "${CPL}" != "SM" ]]; then
      MODE="r_2D_${CPL}${MODE_SUFFIX}"
    fi
    echo ">>> [SM Asimov] Processing coupling ${CPL} (mode ${MODE}, ext ${EXT})"
    CARD_DIR="${OUTPUT_BASE}/cards/${EXT_RUN}/${CPL}"
    prepare_card "${CARD}" "${CARD_DIR}/Datacard_${EXT_RUN}.txt"
    link_models "${CARD_DIR}"
    ensure_pdfindex_json "${EXT_RUN}"
    pushd "${CARD_DIR}" >/dev/null
    python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode ${MODE} --batch local --ext ${EXT_RUN} --outputDir .
    popd >/dev/null
    pushd "${OUTPUT_BASE}" >/dev/null
    python3 "${SCRIPT_DIR}/RunFits.py" --inputJson "${INPUT_JSON_SM}" --mode ${MODE} --ext ${EXT_RUN} --toysFile "${TOYS_FILE}" --datacardDir "${CARD_DIR}" ${RUNFITS_PDFOPTS}
    if [[ ${FINE_GRID} -eq 1 ]]; then
      python3 "${SCRIPT_DIR}/RunFits.py" --inputJson "${INPUT_JSON_SM_FINE}" --mode ${MODE} --ext ${EXT_RUN} --toysFile "${TOYS_FILE}" --datacardDir "${CARD_DIR}" --nameSuffix fine ${RUNFITS_PDFOPTS}
    fi
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
    echo ">>> [BSM Asimov] Building ${CPL} Asimov"
    prepare_card "${CARD}" "${CARD_DIR}/Datacard_${AS_EXT}.txt"
    link_models "${CARD_DIR}"
    pushd "${CARD_DIR}" >/dev/null
    python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode r_2D_${CPL}${MODE_SUFFIX} --batch local --ext ${AS_EXT} --outputDir .
    popd >/dev/null
    pushd "${OUTPUT_BASE}" >/dev/null
    combine -M GenerateOnly "${AS_ROOT}" -m 125.38 -t -1 \
            --saveWorkspace --saveToys -n ${AS_EXT} -s 0 \
            --setParameters r_tHq=1,r_ttH=1,MH=125.38 --freezeParameters MH
    popd >/dev/null
  done
fi

if [[ ${DO_BSM_FITS} -eq 1 ]]; then
  INPUT_JSON_BSM="${SCALED_JSON_DIR}/inputs_statonly_tth_th_scaled_bsmfit${MODE_SUFFIX}.json"
  # Build one JSON with per-coupling entries (r_2D_<CPL>) scaled for BSM Asimov fits.
  build_scaled_json "inverse_sqrt" "ratio" "" "${INPUT_JSON_BSM}"
  INPUT_JSON_BSM_FINE="${SCALED_JSON_DIR}/inputs_statonly_tth_th_scaled_bsmfit_fine${MODE_SUFFIX}.json"
  if [[ ${FINE_GRID} -eq 1 ]]; then
    FINE_CENTER_MODE="fiducial" build_fine_json "${INPUT_JSON_BSM}" "${INPUT_JSON_BSM_FINE}"
  fi
  for CPL in "${CPL_ORDER[@]}"; do
    [[ "${CPL}" == "SM" ]] && continue
    CARD="${CARD_MAP[$CPL]}"
    if [[ ! -f "${CARD}" ]]; then
      echo "[WARN] Card for ${CPL} not found at ${CARD}; skipping." >&2
      continue
    fi
    AS_EXT="${CPL}_Asimov${ASIMOV_SUFFIX}"
    AS_TOY="${OUTPUT_BASE}/higgsCombine${AS_EXT}.GenerateOnly.mH125.38.0.root"
    if [[ -f "${AS_TOY}" ]]; then
      echo ">>> [BSM Asimov] Fitting ${CPL} Asimov with SM template"
      SM_EXT="${BSM_ASIMOV_TAG}"
      SM_EXT_RUN="${SM_EXT}${PDFIDX_SUFFIX}"
      MODE="r_2D_${CPL}${MODE_SUFFIX}"
      CARD_DIR="${OUTPUT_BASE}/cards/${SM_EXT_RUN}/${CPL}"
      prepare_card "${CARD_SM}" "${CARD_DIR}/Datacard_${SM_EXT_RUN}.txt"
      link_models "${CARD_DIR}"
      ensure_pdfindex_json "${SM_EXT_RUN}"
      pushd "${CARD_DIR}" >/dev/null
      python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode r_2D${MODE_SUFFIX} --batch local --ext ${SM_EXT_RUN} --outputDir .
      popd >/dev/null
      pushd "${OUTPUT_BASE}" >/dev/null
      python3 "${SCRIPT_DIR}/RunFits.py" --inputJson "${INPUT_JSON_BSM}" --mode ${MODE} --ext ${SM_EXT_RUN} --toysFile "${AS_TOY}" --datacardDir "${CARD_DIR}" ${RUNFITS_PDFOPTS}
      if [[ ${FINE_GRID} -eq 1 ]]; then
        python3 "${SCRIPT_DIR}/RunFits.py" --inputJson "${INPUT_JSON_BSM_FINE}" --mode ${MODE} --ext ${SM_EXT_RUN} --toysFile "${AS_TOY}" --datacardDir "${CARD_DIR}" --nameSuffix fine ${RUNFITS_PDFOPTS}
      fi
      popd >/dev/null
    else
      echo "[WARN] Asimov toy missing for ${CPL}: ${AS_TOY}. Run step 2 first." >&2
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
  PLOT_BASE_SM="${OUTPUT_BASE}/plots_sm_asimov${PDFIDX_SUFFIX}"
  PLOT_BASE_BSM="${OUTPUT_BASE}/plots_bsm_asimov${PDFIDX_SUFFIX}"
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

  # (A) SM Asimov fitted with each template
  for CPL in "${CPL_ORDER[@]}"; do
    MODE="r_2D${MODE_SUFFIX}"
    EXT="${SM_ASIMOV_TAG}${PDFIDX_SUFFIX}"
    [[ "${CPL}" != "SM" ]] && MODE="r_2D_${CPL}${MODE_SUFFIX}"
    DIR_PRIMARY="runFits${EXT}_${MODE}"

    if [[ -d "${DIR_PRIMARY}" ]]; then
      python3 "${SCRIPT_DIR}/CollectFits.py" --inputJson "${INPUT_JSON_SM}" --mode ${MODE} --ext ${EXT}
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
      run_plot "${BASE_DIR}/${TREE}" "${XRANGE}" "${YRANGE}" "_${EXT}_${CPL}_rscan" "${PLOT_SUBDIR}"
    else
      echo "[WARN] Plot input missing for ${CPL}: ${TREE}"
    fi
  done

  # (B) BSM Asimovs fitted with the SM template
  INPUT_JSON_BSM="${SCALED_JSON_DIR}/inputs_statonly_tth_th_scaled_bsmfit${MODE_SUFFIX}.json"
  build_scaled_json "inverse_sqrt" "ratio" "" "${INPUT_JSON_BSM}"
  for CPL in "${CPL_ORDER[@]}"; do
    [[ "${CPL}" == "SM" ]] && continue
    SM_EXT="${BSM_ASIMOV_TAG}${PDFIDX_SUFFIX}"
    MODE="r_2D_${CPL}${MODE_SUFFIX}"
    DIR_PRIMARY="runFits${SM_EXT}_${MODE}"

    if [[ -d "${DIR_PRIMARY}" ]]; then
      python3 "${SCRIPT_DIR}/CollectFits.py" --inputJson "${INPUT_JSON_BSM}" --mode ${MODE} --ext ${SM_EXT}
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
      run_plot "${BASE_DIR}/${TREE}" "${XRANGE}" "${YRANGE}" "_${SM_EXT}_${CPL}_rscan" "${PLOT_SUBDIR}"
    else
      echo "[WARN] Plot input missing for ${SM_EXT}: ${TREE}"
    fi
  done
  popd >/dev/null
fi
