#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../setup.sh"

CONFIG_DIR="${SCRIPT_DIR}/configs"
SETUP="fid"
USE_NODECO=0
MODES=()
CLEAN_COPY=0

usage() {
  cat <<'USAGE'
Usage: runSignalStuff.sh [options]

Options:
  --setup <incl|fid|fidSM>     Analysis setup (default: fid)
  --noDeco                     Use noDeco configs
  --config-dir <path>          Override config dir (default: ./configs)
  --mode <name[,name...]>      Run one or more modes:
                                f-test | signal-fit | copy-ws | packaging | plotting
  --clean-copy                 Remove merged workspace dir before copy-ws
  -h, --help                   Show help

Examples:
  bash runSignalStuff.sh --setup fid --mode f-test
  bash runSignalStuff.sh --setup fid --mode signal-fit
  bash runSignalStuff.sh --setup fid --mode copy-ws,packaging
  bash runSignalStuff.sh --setup fid --mode plotting
USAGE
}

add_modes() {
  local raw="$1"
  local item
  IFS=',' read -ra parts <<< "${raw}"
  for item in "${parts[@]}"; do
    item="${item// /}"
    if [[ -n "${item}" ]]; then
      MODES+=("${item}")
    fi
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --setup)
      SETUP="$2"
      shift 2
      ;;
    --noDeco)
      USE_NODECO=1
      shift 1
      ;;
    --config-dir)
      CONFIG_DIR="$2"
      shift 2
      ;;
    --mode)
      add_modes "$2"
      shift 2
      ;;
    --clean-copy)
      CLEAN_COPY=1
      shift 1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ ${#MODES[@]} -eq 0 ]]; then
  echo "[ERROR] No --mode provided." >&2
  usage >&2
  exit 1
fi

case "$SETUP" in
  incl|fid|fidSM) ;;
  *)
    echo "Invalid --setup '$SETUP' (use incl|fid|fidSM)" >&2
    exit 1
    ;;
esac

# which eras to process
eras=(2022preEE 2022postEE 2023preBPix 2023postBPix)

# base workspace directory
global_ws_root=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation
BASE_WS_INCL="${global_ws_root}/outputForFinalFits_17Dec2025_withPenalty/workspaces"
BASE_WS_FID="${global_ws_root}/outputForFinalFits_14Jan2026_CP_penalty_10/workspaces_fiducial"
BASE_WS_INCL_NODECO="${global_ws_root}/outputForFinalFits_16Jan2026_noDeco/workspaces"
BASE_WS_FID_NODECO="${global_ws_root}/outputForFinalFits_16Jan2026_noDeco/workspaces_fiducial"
BASE_WS="$BASE_WS_FID"
if [[ "$SETUP" == "incl" ]]; then
  BASE_WS="$BASE_WS_INCL"
  if [[ $USE_NODECO -eq 1 ]]; then
    BASE_WS="$BASE_WS_INCL_NODECO"
  fi
else
  if [[ $USE_NODECO -eq 1 ]]; then
    BASE_WS="$BASE_WS_FID_NODECO"
  fi
fi

# Analysis tag used across Signal/Datacard/Combine.
ANALYSIS_TAG="tth_th_analysis"
case "$SETUP" in
  incl) ANALYSIS_TAG="tth_th_analysis" ;;
  fid) ANALYSIS_TAG="tth_th_analysis_fiducial" ;;
  fidSM) ANALYSIS_TAG="tth_th_analysis_fiducial_SM_rates" ;;
esac
if [[ $USE_NODECO -eq 1 ]]; then
  ANALYSIS_TAG="${ANALYSIS_TAG}_noDeco"
fi

# Packager outputs (used by RunPackager.py and RunPlotter.py).
PACKAGED_OUTDIR="${SCRIPT_DIR}/outdir_packaged_${ANALYSIS_TAG}"
PACKAGED_OUTPUT_EXT="packaged"
PLOT_EXT="packaged"
MERGED_WS_DIR="${SCRIPT_DIR}/all_eras_ws_signal_${ANALYSIS_TAG}"

EXTS="${ANALYSIS_TAG}_2022preEE,${ANALYSIS_TAG}_2022postEE,${ANALYSIS_TAG}_2023preBPix,${ANALYSIS_TAG}_2023postBPix"

config_suffix() {
  local suffix=""
  case "$SETUP" in
    incl) suffix="" ;;
    fid) suffix="_fiducial" ;;
    fidSM) suffix="_fiducial_SM_rates" ;;
  esac
  if [[ $USE_NODECO -eq 1 ]]; then
    suffix="${suffix}_noDeco"
  fi
  echo "$suffix"
}

config_path_for_era() {
  local era="$1"
  local suffix
  suffix="$(config_suffix)"
  echo "${CONFIG_DIR}/config_${era}${suffix}.py"
}

run_f_test() {
  for era in "${eras[@]}"; do
    local cfg
    cfg="$(config_path_for_era "$era")"
    if [[ ! -f "$cfg" ]]; then
      echo "[ERROR] Config not found: $cfg" >&2
      exit 1
    fi
    echo ">>> Running fTest for era: $era"
    python3 RunSignalScripts.py \
      --inputConfig "$cfg" \
      --mode fTest \
      --modeOpts "--doPlots --skipWV"
  done
}

# could be worth a try running without --groupSignalFitJobsByCat, then there is a single job for each proc and cat, should be much faster
run_signal_fit() {
  for era in "${eras[@]}"; do
    local cfg
    cfg="$(config_path_for_era "$era")"
    if [[ ! -f "$cfg" ]]; then
      echo "[ERROR] Config not found: $cfg" >&2
      exit 1
    fi
    echo ">>> Running signalFit for era: $era"
    python3 RunSignalScripts.py \
      --inputConfig "$cfg" \
      --mode signalFit \
      --groupSignalFitJobsByCat \
      --modeOpts "--skipVertexScenarioSplit --skipSystematics --doPlots"
  done
}

copy_ws() {
  if [[ $CLEAN_COPY -eq 1 ]]; then
    echo ">>> Cleaning merged workspace dir: ${MERGED_WS_DIR}"
    rm -rf "${MERGED_WS_DIR}"
  fi
  mkdir -p "${MERGED_WS_DIR}"
  for era in "${eras[@]}"; do
    local src_dir="${BASE_WS}/${era}/ws_signal"
    if [[ ! -d "${src_dir}" ]]; then
      echo "[ERROR] Missing ws_signal dir: ${src_dir}" >&2
      exit 1
    fi
    echo ">>> Copying ws_signal for era: $era"
    shopt -s nullglob
    local files=("${src_dir}"/*.root)
    shopt -u nullglob
    if [[ ${#files[@]} -eq 0 ]]; then
      echo "[ERROR] No ROOT files found in ${src_dir}" >&2
      exit 1
    fi
    for f in "${files[@]}"; do
      local base
      base=$(basename "$f" .root)
      cp -v "$f" "${MERGED_WS_DIR}/${base}_${era}.root"
    done
  done
}

run_packaging() {
  if [[ ! -d "${MERGED_WS_DIR}" ]]; then
    echo "[ERROR] Merged workspace dir missing: ${MERGED_WS_DIR}" >&2
    echo "Run with --mode copy-ws first." >&2
    exit 1
  fi
  shopt -s nullglob
  local files=("${MERGED_WS_DIR}"/*.root)
  shopt -u nullglob
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "[ERROR] No ROOT files found in ${MERGED_WS_DIR}" >&2
    exit 1
  fi

  echo ">>> Running packager: ${PACKAGED_OUTDIR}"
  python3 RunPackager.py \
    --cats auto \
    --inputWSDir "${MERGED_WS_DIR}" \
    --exts "${EXTS}" \
    --mergeYears \
    --massPoints 125 \
    --batch condor \
    --outputExt "${PACKAGED_OUTPUT_EXT}" \
    --outputDir "${PACKAGED_OUTDIR}"
}

run_plotting() {
  if [[ ! -d "${PACKAGED_OUTDIR}" ]]; then
    echo "[ERROR] Packaged output dir missing: ${PACKAGED_OUTDIR}" >&2
    echo "Run with --mode packaging first." >&2
    exit 1
  fi
  local plot_cats=(
    tH_lep_1 tH_lep_2 tH_lep_3
    ttH_lep_1 ttH_lep_2 ttH_lep_3
    bkg_lep
    tH_had_1 tH_had_2 tH_had_3 tH_had_4 tH_had_5
    ttH_had_1 ttH_had_2 ttH_had_3
    bkg_had
  )
  for cat in "${plot_cats[@]}"; do
    python3 RunPlotter.py \
      --procs all \
      --years 2022preEE,2022postEE,2023preBPix,2023postBPix \
      --cats "${cat}" \
      --ext "${PLOT_EXT}" \
      --inputDir "${PACKAGED_OUTDIR}" \
      --outputDir "${PACKAGED_OUTDIR}"
  done
}

for mode in "${MODES[@]}"; do
  case "$mode" in
    f-test)
      run_f_test
      ;;
    signal-fit)
      run_signal_fit
      ;;
    copy-ws)
      copy_ws
      ;;
    packaging)
      run_packaging
      ;;
    plotting)
      run_plotting
      ;;
    *)
      echo "[ERROR] Unknown mode: ${mode}" >&2
      usage >&2
      exit 1
      ;;
  esac
done
