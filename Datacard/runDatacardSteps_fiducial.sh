source ../setup.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Usage examples (required: choose exactly one of --yields or --datacards):
#   Run yields only:                 bash runDatacardSteps_fiducial.sh --yields
#   Run datacards only:              bash runDatacardSteps_fiducial.sh --datacards
#   Run only legacy BSM points:      bash runDatacardSteps_fiducial.sh --yields --couplings basic-bsm
#   Run only extended BSM points:    bash runDatacardSteps_fiducial.sh --yields --couplings extended-bsm
#   Run only SM point:               bash runDatacardSteps_fiducial.sh --yields --couplings sm-only
#   Run all points:                  bash runDatacardSteps_fiducial.sh --yields --couplings all
# Notes:
#   - Yields are submitted to condor in this script.
#   - Run --yields first, wait for jobs to finish, then run --datacards-only.
#   - Use --syst to write outputs under *_syst analysis tag (keeps stat-only outputs untouched).

ANALYSIS=${ANALYSIS:-tth_th_analysis_fiducial}
ANALYSIS_SET=0
RUN_YIELDS=0
RUN_DATACARDS=0
RUN_STEP_SET=0
USE_NODECO=0
USE_SYST=0
COUPLINGS_SET=${COUPLINGS_SET:-basic-bsm}

global_ws_root=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation
BASE_WS_FID="${global_ws_root}/outputForFinalFits_12Feb2026/workspaces_fiducial"
BASE_WS_FID_NODECO="${global_ws_root}/outputForFinalFits_06Feb2026_noDeco/workspaces_fiducial"
BASE_WS="${BASE_WS_FID}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --analysis)
      ANALYSIS="$2"
      ANALYSIS_SET=1
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
    --yields)
      if [[ ${RUN_STEP_SET} -eq 1 ]]; then
        echo "Choose exactly one of --yields or --datacards." >&2
        exit 1
      fi
      RUN_YIELDS=1
      RUN_DATACARDS=0
      RUN_STEP_SET=1
      shift 1
      ;;
    --datacards)
      if [[ ${RUN_STEP_SET} -eq 1 ]]; then
        echo "Choose exactly one of --yields or --datacards." >&2
        exit 1
      fi
      RUN_YIELDS=0
      RUN_DATACARDS=1
      RUN_STEP_SET=1
      shift 1
      ;;
    --couplings)
      COUPLINGS_SET="$2"
      shift 2
      ;;
    --run-mode-set)
      # Backward-compatible alias
      COUPLINGS_SET="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ ${RUN_STEP_SET} -eq 0 ]]; then
  echo "Missing required step selection. Choose exactly one: --yields or --datacards" >&2
  exit 1
fi

export FIDUCIAL_FRACTIONS_YAML="$FIDUCIAL_YAML"

if [[ ${USE_NODECO} -eq 1 && ${ANALYSIS_SET} -eq 0 ]]; then
  if [[ "${ANALYSIS}" != *noDeco* ]]; then
    ANALYSIS="${ANALYSIS}_noDeco"
  fi
fi
if [[ ${USE_SYST} -eq 1 ]]; then
  if [[ "${ANALYSIS}" != *_syst* ]]; then
    ANALYSIS="${ANALYSIS}_syst"
  fi
fi

# Now that ANALYSIS is finalized, set output bases.
YIELDS_BASE="${SCRIPT_DIR}/yields/${ANALYSIS}"
DATACARD_OUT_BASE="${SCRIPT_DIR}/datacard_outputs/${ANALYSIS}"

if [[ ${USE_NODECO} -eq 1 ]]; then
  BASE_WS="${BASE_WS_FID_NODECO}"
fi

INPUT_MAP="2022preEE=${BASE_WS}/2022preEE/ws_signal,2022postEE=${BASE_WS}/2022postEE/ws_signal,2023preBPix=${BASE_WS}/2023preBPix/ws_signal,2023postBPix=${BASE_WS}/2023postBPix/ws_signal"

# Explicit process lists
PROCS_SM="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tth_in,tth_out,tHqLep_in,tHqLep_out,tHqHad_in,tHqHad_out,tHW_in,tHW_out"
PROCS_CPODD="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthCPodd_in,tthCPodd_out,tHqLepCPodd_in,tHqLepCPodd_out,tHqHadCPodd_in,tHqHadCPodd_out,tHWCPodd_in,tHWCPodd_out"
PROCS_KTM1KTT0="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tth_in,tth_out,tHqLepKtm1Ktt0_in,tHqLepKtm1Ktt0_out,tHqHadKtm1Ktt0_in,tHqHadKtm1Ktt0_out,tHWKtm1Ktt0_in,tHWKtm1Ktt0_out"
PROCS_KT0P7KTT0P7="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt0p7Ktt0p7_in,tthKt0p7Ktt0p7_out,tHqLepKt0p7Ktt0p7_in,tHqLepKt0p7Ktt0p7_out,tHqHadKt0p7Ktt0p7_in,tHqHadKt0p7Ktt0p7_out,tHWKt0p7Ktt0p7_in,tHWKt0p7Ktt0p7_out"
PROCS_KT0P7KTTM0P7="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt0p7Kttm0p7_in,tthKt0p7Kttm0p7_out,tHqLepKt0p7Kttm0p7_in,tHqLepKt0p7Kttm0p7_out,tHqHadKt0p7Kttm0p7_in,tHqHadKt0p7Kttm0p7_out,tHWKt0p7Kttm0p7_in,tHWKt0p7Kttm0p7_out"
PROCS_KT0KTTM1="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt0Kttm1_in,tthKt0Kttm1_out,tHqLepKt0Kttm1_in,tHqLepKt0Kttm1_out,tHqHadKt0Kttm1_in,tHqHadKt0Kttm1_out,tHWKt0Kttm1_in,tHWKt0Kttm1_out"
PROCS_KT0KTT0="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt0Ktt0_in,tthKt0Ktt0_out,tHqLepKt0Ktt0_in,tHqLepKt0Ktt0_out,tHqHadKt0Ktt0_in,tHqHadKt0Ktt0_out,tHWKt0Ktt0_in,tHWKt0Ktt0_out"
# Inner circle (r=0.5) and outer circle (r=1.5) points
PROCS_KT0P500KTT0P000="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt0p500Ktt0p000_in,tthKt0p500Ktt0p000_out,tHqLepKt0p500Ktt0p000_in,tHqLepKt0p500Ktt0p000_out,tHqHadKt0p500Ktt0p000_in,tHqHadKt0p500Ktt0p000_out,tHWKt0p500Ktt0p000_in,tHWKt0p500Ktt0p000_out"
PROCS_KT0P354KTT0P354="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt0p354Ktt0p354_in,tthKt0p354Ktt0p354_out,tHqLepKt0p354Ktt0p354_in,tHqLepKt0p354Ktt0p354_out,tHqHadKt0p354Ktt0p354_in,tHqHadKt0p354Ktt0p354_out,tHWKt0p354Ktt0p354_in,tHWKt0p354Ktt0p354_out"
PROCS_KT0P000KTT0P500="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt0p000Ktt0p500_in,tthKt0p000Ktt0p500_out,tHqLepKt0p000Ktt0p500_in,tHqLepKt0p000Ktt0p500_out,tHqHadKt0p000Ktt0p500_in,tHqHadKt0p000Ktt0p500_out,tHWKt0p000Ktt0p500_in,tHWKt0p000Ktt0p500_out"
PROCS_KTM0P500KTT0P000="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKtm0p500Ktt0p000_in,tthKtm0p500Ktt0p000_out,tHqLepKtm0p500Ktt0p000_in,tHqLepKtm0p500Ktt0p000_out,tHqHadKtm0p500Ktt0p000_in,tHqHadKtm0p500Ktt0p000_out,tHWKtm0p500Ktt0p000_in,tHWKtm0p500Ktt0p000_out"
PROCS_KT0P000KTTM0P500="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt0p000Kttm0p500_in,tthKt0p000Kttm0p500_out,tHqLepKt0p000Kttm0p500_in,tHqLepKt0p000Kttm0p500_out,tHqHadKt0p000Kttm0p500_in,tHqHadKt0p000Kttm0p500_out,tHWKt0p000Kttm0p500_in,tHWKt0p000Kttm0p500_out"
PROCS_KT0P354KTTM0P354="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt0p354Kttm0p354_in,tthKt0p354Kttm0p354_out,tHqLepKt0p354Kttm0p354_in,tHqLepKt0p354Kttm0p354_out,tHqHadKt0p354Kttm0p354_in,tHqHadKt0p354Kttm0p354_out,tHWKt0p354Kttm0p354_in,tHWKt0p354Kttm0p354_out"
PROCS_KT1P500KTT0P000="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt1p500Ktt0p000_in,tthKt1p500Ktt0p000_out,tHqLepKt1p500Ktt0p000_in,tHqLepKt1p500Ktt0p000_out,tHqHadKt1p500Ktt0p000_in,tHqHadKt1p500Ktt0p000_out,tHWKt1p500Ktt0p000_in,tHWKt1p500Ktt0p000_out"
PROCS_KT1P061KTT1P061="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt1p061Ktt1p061_in,tthKt1p061Ktt1p061_out,tHqLepKt1p061Ktt1p061_in,tHqLepKt1p061Ktt1p061_out,tHqHadKt1p061Ktt1p061_in,tHqHadKt1p061Ktt1p061_out,tHWKt1p061Ktt1p061_in,tHWKt1p061Ktt1p061_out"
PROCS_KT0P000KTT1P500="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt0p000Ktt1p500_in,tthKt0p000Ktt1p500_out,tHqLepKt0p000Ktt1p500_in,tHqLepKt0p000Ktt1p500_out,tHqHadKt0p000Ktt1p500_in,tHqHadKt0p000Ktt1p500_out,tHWKt0p000Ktt1p500_in,tHWKt0p000Ktt1p500_out"
PROCS_KTM1P500KTT0P000="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKtm1p500Ktt0p000_in,tthKtm1p500Ktt0p000_out,tHqLepKtm1p500Ktt0p000_in,tHqLepKtm1p500Ktt0p000_out,tHqHadKtm1p500Ktt0p000_in,tHqHadKtm1p500Ktt0p000_out,tHWKtm1p500Ktt0p000_in,tHWKtm1p500Ktt0p000_out"
PROCS_KT0P000KTTM1P500="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt0p000Kttm1p500_in,tthKt0p000Kttm1p500_out,tHqLepKt0p000Kttm1p500_in,tHqLepKt0p000Kttm1p500_out,tHqHadKt0p000Kttm1p500_in,tHqHadKt0p000Kttm1p500_out,tHWKt0p000Kttm1p500_in,tHWKt0p000Kttm1p500_out"
PROCS_KT1P061KTTM1P061="ggh_in,ggh_out,vbf_in,vbf_out,vh_in,vh_out,bbh_in,bbh_out,tthKt1p061Kttm1p061_in,tthKt1p061Kttm1p061_out,tHqLepKt1p061Kttm1p061_in,tHqLepKt1p061Kttm1p061_out,tHqHadKt1p061Kttm1p061_in,tHqHadKt1p061Kttm1p061_out,tHWKt1p061Kttm1p061_in,tHWKt1p061Kttm1p061_out"

# Select which modes to run; override by setting RUN_MODES in env.
# Convenience sets:
#   basic-bsm    = legacy 7 points
#   extended-bsm = inner/outer circle points
#   sm-only      = SM point only
#   all          = basic-bsm + extended-bsm
BASIC_MODES="SM CPODD KTM1KTT0 KT0P7KTT0P7 KT0P7KTTM0P7 KT0KTTM1 KT0KTT0"
EXT_MODES="KT0P500KTT0P000 KT0P354KTT0P354 KT0P000KTT0P500 KTM0P500KTT0P000 KT0P000KTTM0P500 KT0P354KTTM0P354 KT1P500KTT0P000 KT1P061KTT1P061 KT0P000KTT1P500 KTM1P500KTT0P000 KT0P000KTTM1P500 KT1P061KTTM1P061"
case "${COUPLINGS_SET}" in
  basic-bsm) RUN_MODES=${RUN_MODES:-"${BASIC_MODES}"} ;;
  extended-bsm) RUN_MODES=${RUN_MODES:-"${EXT_MODES}"} ;;
  sm-only) RUN_MODES=${RUN_MODES:-"SM"} ;;
  all) RUN_MODES=${RUN_MODES:-"${BASIC_MODES} ${EXT_MODES}"} ;;
  *) echo "Invalid --couplings '${COUPLINGS_SET}' (use basic-bsm|extended-bsm|sm-only|all)" >&2; exit 1 ;;
esac
# RUN_MODES="CPODD"
# RUN_MODES="KTM1KTT0"
# RUN_MODES="KT0P7KTT0P7"
# RUN_MODES="KT0P7KTTM0P7"
# RUN_MODES="KT0KTTM1"
# RUN_MODES="KT0KTT0"


# Base ext label (per coupling gets appended below)
EXT_BASE_CORE="tth_th_analysis_fiducial"

for LABEL in ${RUN_MODES}; do
    case "$LABEL" in
        SM)           PROCS="$PROCS_SM"           EXT_BASE="${EXT_BASE_CORE}"          CP_LABEL="SM" ;;
        CPODD)        PROCS="$PROCS_CPODD"        EXT_BASE="${EXT_BASE_CORE}"          CP_LABEL="CPodd" ;;
        KTM1KTT0)     PROCS="$PROCS_KTM1KTT0"     EXT_BASE="${EXT_BASE_CORE}"          CP_LABEL="Ktm1Ktt0" ;;
        KT0P7KTT0P7)  PROCS="$PROCS_KT0P7KTT0P7"  EXT_BASE="${EXT_BASE_CORE}"          CP_LABEL="Kt0p7Ktt0p7" ;;
        KT0P7KTTM0P7) PROCS="$PROCS_KT0P7KTTM0P7" EXT_BASE="${EXT_BASE_CORE}"          CP_LABEL="Kt0p7Kttm0p7" ;;
        KT0KTTM1)     PROCS="$PROCS_KT0KTTM1"     EXT_BASE="${EXT_BASE_CORE}"          CP_LABEL="Kt0Kttm1" ;;
        KT0KTT0)      PROCS="$PROCS_KT0KTT0"      EXT_BASE="${EXT_BASE_CORE}"          CP_LABEL="Kt0Ktt0" ;;
        KT0P500KTT0P000) PROCS="$PROCS_KT0P500KTT0P000" EXT_BASE="${EXT_BASE_CORE}"    CP_LABEL="Kt0p500Ktt0p000" ;;
        KT0P354KTT0P354) PROCS="$PROCS_KT0P354KTT0P354" EXT_BASE="${EXT_BASE_CORE}"    CP_LABEL="Kt0p354Ktt0p354" ;;
        KT0P000KTT0P500) PROCS="$PROCS_KT0P000KTT0P500" EXT_BASE="${EXT_BASE_CORE}"    CP_LABEL="Kt0p000Ktt0p500" ;;
        KTM0P500KTT0P000) PROCS="$PROCS_KTM0P500KTT0P000" EXT_BASE="${EXT_BASE_CORE}"  CP_LABEL="Ktm0p500Ktt0p000" ;;
        KT0P000KTTM0P500) PROCS="$PROCS_KT0P000KTTM0P500" EXT_BASE="${EXT_BASE_CORE}"  CP_LABEL="Kt0p000Kttm0p500" ;;
        KT0P354KTTM0P354) PROCS="$PROCS_KT0P354KTTM0P354" EXT_BASE="${EXT_BASE_CORE}"  CP_LABEL="Kt0p354Kttm0p354" ;;
        KT1P500KTT0P000) PROCS="$PROCS_KT1P500KTT0P000" EXT_BASE="${EXT_BASE_CORE}"    CP_LABEL="Kt1p500Ktt0p000" ;;
        KT1P061KTT1P061) PROCS="$PROCS_KT1P061KTT1P061" EXT_BASE="${EXT_BASE_CORE}"    CP_LABEL="Kt1p061Ktt1p061" ;;
        KT0P000KTT1P500) PROCS="$PROCS_KT0P000KTT1P500" EXT_BASE="${EXT_BASE_CORE}"    CP_LABEL="Kt0p000Ktt1p500" ;;
        KTM1P500KTT0P000) PROCS="$PROCS_KTM1P500KTT0P000" EXT_BASE="${EXT_BASE_CORE}"  CP_LABEL="Ktm1p500Ktt0p000" ;;
        KT0P000KTTM1P500) PROCS="$PROCS_KT0P000KTTM1P500" EXT_BASE="${EXT_BASE_CORE}"  CP_LABEL="Kt0p000Kttm1p500" ;;
        KT1P061KTTM1P061) PROCS="$PROCS_KT1P061KTTM1P061" EXT_BASE="${EXT_BASE_CORE}"  CP_LABEL="Kt1p061Kttm1p061" ;;
        *) echo "Unknown RUN_MODE label '${LABEL}'" >&2; exit 1 ;;
    esac
    if [[ ${USE_NODECO} -eq 1 ]]; then
        EXT_BASE="${EXT_BASE}_noDeco"
    fi
    if [[ ${USE_SYST} -eq 1 ]]; then
        EXT_BASE="${EXT_BASE}_syst"
    fi
    case "$LABEL" in
        SM) EXT="${EXT_BASE}" ;;
        CPODD) EXT="${EXT_BASE}_CPodd" ;;
        KTM1KTT0) EXT="${EXT_BASE}_Ktm1Ktt0" ;;
        KT0P7KTT0P7) EXT="${EXT_BASE}_Kt0p7Ktt0p7" ;;
        KT0P7KTTM0P7) EXT="${EXT_BASE}_Kt0p7Kttm0p7" ;;
        KT0KTTM1) EXT="${EXT_BASE}_Kt0Kttm1" ;;
        KT0KTT0) EXT="${EXT_BASE}_Kt0Ktt0" ;;
        KT0P500KTT0P000) EXT="${EXT_BASE}_Kt0p500Ktt0p000" ;;
        KT0P354KTT0P354) EXT="${EXT_BASE}_Kt0p354Ktt0p354" ;;
        KT0P000KTT0P500) EXT="${EXT_BASE}_Kt0p000Ktt0p500" ;;
        KTM0P500KTT0P000) EXT="${EXT_BASE}_Ktm0p500Ktt0p000" ;;
        KT0P000KTTM0P500) EXT="${EXT_BASE}_Kt0p000Kttm0p500" ;;
        KT0P354KTTM0P354) EXT="${EXT_BASE}_Kt0p354Kttm0p354" ;;
        KT1P500KTT0P000) EXT="${EXT_BASE}_Kt1p500Ktt0p000" ;;
        KT1P061KTT1P061) EXT="${EXT_BASE}_Kt1p061Ktt1p061" ;;
        KT0P000KTT1P500) EXT="${EXT_BASE}_Kt0p000Ktt1p500" ;;
        KTM1P500KTT0P000) EXT="${EXT_BASE}_Ktm1p500Ktt0p000" ;;
        KT0P000KTTM1P500) EXT="${EXT_BASE}_Kt0p000Kttm1p500" ;;
        KT1P061KTTM1P061) EXT="${EXT_BASE}_Kt1p061Kttm1p061" ;;
    esac

    YIELDS_DIR="${YIELDS_BASE}/${CP_LABEL}"
    YIELDS_DEST="${YIELDS_DIR}/yields_${EXT}"
    mkdir -p "${YIELDS_DIR}"

    if [[ ${RUN_YIELDS} -eq 1 ]]; then
        echo ">> Running RunYields for $LABEL ..."
        python3 RunYields.py \
            --cats auto \
            --inputWSDirMap ${INPUT_MAP} \
            --procs ${PROCS} \
            --ext ${EXT} \
            --outputYieldsDir "${YIELDS_DIR}" \
            --batch condor \
            --mergeYears \
            --jobOpts "request_memory = 6000:request_cpus = 1" \
            --doSystematics
    fi

    if [[ ${RUN_DATACARDS} -eq 1 ]]; then
        if [[ ! -d "${YIELDS_DEST}" ]]; then
            echo "Expected yields directory missing: ${YIELDS_DEST}" >&2
            echo "Run RunYields.py or check condor output before making datacards." >&2
            exit 1
        fi

        echo ">> Making datacards for $LABEL ..."
        mkdir -p "${DATACARD_OUT_BASE}"
        python3 makeDatacard.py \
            --years 2022preEE,2022postEE,2023preBPix,2023postBPix \
            --ext ${EXT} \
            --inputFiles "${YIELDS_DIR}" \
            --outputDir "${DATACARD_OUT_BASE}" \
            --output "Datacard_${EXT}" \
            --prune --pruneThreshold 0.001 \
            --doTrueYield --analysis ${ANALYSIS} \
            --skipCOWCorr --doSystematics # --doMCStatUncertainty
    fi
done
