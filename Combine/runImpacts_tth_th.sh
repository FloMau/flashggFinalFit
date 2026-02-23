#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------------------------
# Steps overview
#   t2w    : build workspace root file from the datacard (needed once per datacard)
#   init   : initial fit (defines the reference point for all impacts)
#   fit    : one fit per nuisance parameter to compute its effect on each POI
#   collect: gather fit outputs into impacts.json (optionally drop bkg params)
#   plot   : make per-POI impact plots (optionally translate labels)
#
# Impacts are computed *relative to the initial fit point*. For Asimov (-t -1),
# this means a small closure offset (e.g. r != 1) only shifts the reference
# point; the impacts are still valid around that point. If you require the
# reference point to be exactly r=1 (Asimov closure), you would need to
# regenerate a postfit Asimov dataset and rerun the impacts on that dataset.
# This script currently uses the standard combineTool Impacts workflow.
# ------------------------------------------------------------------------------

usage() {
  cat <<'EOF'
Usage: runImpacts_tth_th.sh --steps <list> [options]

Minimal impacts driver (local):
  1) Optional: run text2workspace in Combine/output/<analysis-tag>
  2) Initial fit
  3) Per-nuisance fits
  4) Collect + (optional) correct impacts
  5) Plot (per POI)

Options:
  --analysis-tag <tag>     Analysis tag (default: tth_th_analysis_fiducial_syst)
  --datacard-root <path>   Workspace root file (default: Combine/output/<tag>/Datacard_<tag>.root)
  --datacard-txt <path>    Datacard txt for t2w (default: Datacard output path for <tag>)
  --mass <value>           Higgs mass (default: 125.08)
  --pois <p1,p2,...>        POIs to plot (default: r_tHq,r_ttH)
  --set-params <k=v,...>   combine --setParameters (default: r_tHq=1,r_ttH=1)
  --freeze-params <list>   combine --freezeParameters (default: MH)
  --parallel <N>           combineTool --parallel for doFits (default: 24)
  --steps <list>           Required. Comma-separated: t2w,init,fit,collect,plot
  --workdir <dir>          Working dir (default: Combine/output/<analysis-tag>/impacts)
  --no-asimov              Run on observed data (omit -t -1)
  --drop-bkg-params        Run correctImpacts.py --dropBkgModelParams
  --job-mode <condor|local>  combineTool job mode for init/fit (default: condor)
  --sub-opts <string>      Extra condor submit opts (default: +JobFlavour="workday")
  --translate <json>       plotImpacts.py --translate JSON
  -h, --help               Show help

Examples:
  bash runImpacts_tth_th.sh --steps init,fit,collect,plot
  bash runImpacts_tth_th.sh --steps t2w,init,fit,collect,plot
  bash runImpacts_tth_th.sh --pois r_tHq --parallel 12
EOF
}

ANALYSIS_TAG="tth_th_analysis_fiducial_syst"
MASS="125.08"
POIS="r_tHq,r_ttH"
SET_PARAMS="r_tHq=1,r_ttH=1"
FREEZE_PARAMS="MH"
PARALLEL="24"
STEPS=""
WORKDIR=""
ASIMOV=1
DROP_BKG_PARAMS=0
JOB_MODE="condor"
SUB_OPTS='+JobFlavour = "workday"'
TRANSLATE=""

DATACARD_ROOT=""
DATACARD_TXT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --analysis-tag) ANALYSIS_TAG="$2"; shift 2 ;;
    --datacard-root) DATACARD_ROOT="$2"; shift 2 ;;
    --datacard-txt) DATACARD_TXT="$2"; shift 2 ;;
    --mass) MASS="$2"; shift 2 ;;
    --pois) POIS="$2"; shift 2 ;;
    --set-params) SET_PARAMS="$2"; shift 2 ;;
    --freeze-params) FREEZE_PARAMS="$2"; shift 2 ;;
    --parallel) PARALLEL="$2"; shift 2 ;;
    --steps) STEPS="$2"; shift 2 ;;
    --workdir) WORKDIR="$2"; shift 2 ;;
    --no-asimov) ASIMOV=0; shift 1 ;;
    --drop-bkg-params) DROP_BKG_PARAMS=1; shift 1 ;;
    --job-mode) JOB_MODE="$2"; shift 2 ;;
    --sub-opts) SUB_OPTS="$2"; shift 2 ;;
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
  WORKDIR="${SCRIPT_DIR}/output/${ANALYSIS_TAG}/impacts"
fi

if [[ -z "${DATACARD_ROOT}" ]]; then
  DATACARD_ROOT="${SCRIPT_DIR}/output/${ANALYSIS_TAG}/Datacard_${ANALYSIS_TAG}.root"
fi

if [[ -z "${DATACARD_TXT}" ]]; then
  DATACARD_TXT="${SCRIPT_DIR}/../Datacard/datacard_outputs/${ANALYSIS_TAG}/Datacard_${ANALYSIS_TAG}.txt"
fi

IFS=',' read -ra STEP_LIST <<< "${STEPS}"
declare -A DO
for s in "${STEP_LIST[@]}"; do
  s="${s// /}"
  DO["$s"]=1
done

ASIMOV_OPTS=""
if [[ ${ASIMOV} -eq 1 ]]; then
  ASIMOV_OPTS="-t -1"
fi

FREEZE_OPTS=""
if [[ -n "${FREEZE_PARAMS}" ]]; then
  FREEZE_OPTS="--freezeParameters ${FREEZE_PARAMS}"
fi

SET_OPTS=""
if [[ -n "${SET_PARAMS}" ]]; then
  SET_OPTS="--setParameters ${SET_PARAMS}"
fi

EXTRA_OPTS="--cminDefaultMinimizerStrategy 0 --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2"

if [[ -n "${DO[t2w]:-}" ]]; then
  T2W_DIR="${SCRIPT_DIR}/output/${ANALYSIS_TAG}"
  if [[ ! -d "${T2W_DIR}/Models/background" ]]; then
    echo "[ERROR] Missing Models/background in ${T2W_DIR}. Cannot run text2workspace." >&2
    exit 1
  fi
  if [[ ! -f "${DATACARD_TXT}" ]]; then
    echo "[ERROR] Datacard txt not found: ${DATACARD_TXT}" >&2
    exit 1
  fi
  cp -v "${DATACARD_TXT}" "${T2W_DIR}/Datacard_${ANALYSIS_TAG}.txt"
  (cd "${T2W_DIR}" && python3 "${SCRIPT_DIR}/RunText2Workspace.py" --mode r_2D_fiducial --batch local --ext "${ANALYSIS_TAG}" --outputDir .)
fi

if [[ ! -f "${DATACARD_ROOT}" ]]; then
  echo "[ERROR] Missing ${DATACARD_ROOT}. Run with --steps t2w first or provide --datacard-root." >&2
  exit 1
fi

mkdir -p "${WORKDIR}"
pushd "${WORKDIR}" >/dev/null

if [[ -n "${DO[init]:-}" ]]; then
  combineTool.py -M Impacts -d "${DATACARD_ROOT}" -m "${MASS}" ${FREEZE_OPTS} \
    --doInitialFit --robustFit 1 ${ASIMOV_OPTS} ${SET_OPTS} ${EXTRA_OPTS} \
    --job-mode "${JOB_MODE}" --task-name impacts_first --sub-opts="${SUB_OPTS}"
fi

if [[ -n "${DO[fit]:-}" ]]; then
  combineTool.py -M Impacts -d "${DATACARD_ROOT}" -m "${MASS}" ${FREEZE_OPTS} \
    --robustFit 1 --doFits ${ASIMOV_OPTS} ${SET_OPTS} --parallel "${PARALLEL}" ${EXTRA_OPTS} \
    --job-mode "${JOB_MODE}" --task-name impacts_second --sub-opts="${SUB_OPTS}"
fi

if [[ -n "${DO[collect]:-}" ]]; then
  BAD_PARAMS="$(IMPACTS_MASS="${MASS}" python3 - <<'PY'
import glob
import os
import re
import ROOT

mass = os.environ.get("IMPACTS_MASS", "")
pat = f"higgsCombine_paramFit_Test_*.MultiDimFit.mH{mass}.root" if mass else "higgsCombine_paramFit_Test_*.MultiDimFit.mH*.root"
bad = []
for path in glob.glob(pat):
    name = os.path.basename(path)
    m = re.match(r"higgsCombine_paramFit_Test_(.+)\\.MultiDimFit\\.", name)
    if not m:
        continue
    param = m.group(1)
    f = ROOT.TFile.Open(path)
    if not f or f.IsZombie():
        bad.append(param)
        continue
    obj = f.Get("limit")
    if not obj or not obj.InheritsFrom("TTree"):
        bad.append(param)
    f.Close()
print(",".join(sorted(set(bad))))
PY
  )"
  EXCLUDE_ARGS=""
  if [[ -n "${BAD_PARAMS}" ]]; then
    echo "[WARN] Skipping params with bad/incomplete outputs: ${BAD_PARAMS}" >&2
    EXCLUDE_ARGS="--exclude ${BAD_PARAMS}"
  fi
  combineTool.py -M Impacts -d "${DATACARD_ROOT}" -m "${MASS}" ${EXCLUDE_ARGS} -o impacts.json
  if [[ ${DROP_BKG_PARAMS} -eq 1 ]]; then
    python3 "${SCRIPT_DIR}/../Plots/correctImpacts.py" --impactsJson impacts.json --frozenParam MH --dropBkgModelParams
  fi
fi

if [[ -n "${DO[plot]:-}" ]]; then
  IMPACTS_JSON="impacts.json"
  if [[ ${DROP_BKG_PARAMS} -eq 1 && -f impacts_corrected_dropBkgModelParams.json ]]; then
    IMPACTS_JSON="impacts_corrected_dropBkgModelParams.json"
  fi
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
  IFS=',' read -ra POI_LIST <<< "${POIS}"
  for poi in "${POI_LIST[@]}"; do
    poi="${poi// /}"
    [[ -z "${poi}" ]] && continue
    if [[ -n "${TRANSLATE}" ]]; then
      plotImpacts.py -i "${IMPACTS_JSON}" -o "impacts_${poi}" --POI "${poi}" --translate "${TRANSLATE}"
    else
      plotImpacts.py -i "${IMPACTS_JSON}" -o "impacts_${poi}" --POI "${poi}"
    fi
  done
fi

popd >/dev/null
echo "Done. Outputs in ${WORKDIR}"
