source ../setup.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Usage examples:
#   Run yields + datacards (default): bash runDatacardSteps_fiducial.sh
#   Run yields only:                 bash runDatacardSteps_fiducial.sh --yields
#   Run datacards only:              bash runDatacardSteps_fiducial.sh --datacards
# Notes:
#   - Yields are submitted to condor in this script.
#   - Run --yields-only first, wait for jobs to finish, then run --datacards-only.

ANALYSIS=${ANALYSIS:-tth_th_analysis_fiducial}
ANALYSIS_SET=0
YIELDS_BASE="${SCRIPT_DIR}/yields/${ANALYSIS}"
DATACARD_OUT_BASE="${SCRIPT_DIR}/datacard_outputs/${ANALYSIS}"
RUN_YIELDS=1
RUN_DATACARDS=1
USE_NODECO=0

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
    --yields)
      RUN_YIELDS=1
      RUN_DATACARDS=0
      shift 1
      ;;
    --datacards)
      RUN_YIELDS=0
      RUN_DATACARDS=1
      shift 1
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

export FIDUCIAL_FRACTIONS_YAML="$FIDUCIAL_YAML"

if [[ ${USE_NODECO} -eq 1 && ${ANALYSIS_SET} -eq 0 ]]; then
  if [[ "${ANALYSIS}" != *noDeco* ]]; then
    ANALYSIS="${ANALYSIS}_noDeco"
  fi
fi

YIELDS_BASE="${SCRIPT_DIR}/yields/${ANALYSIS}"
DATACARD_OUT_BASE="${SCRIPT_DIR}/datacard_outputs/${ANALYSIS}"

global_ws_root=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation
BASE_WS_FID="${global_ws_root}/outputForFinalFits_14Jan2026_CP_penalty_10/workspaces_fiducial"
BASE_WS_FID_NODECO="${global_ws_root}/outputForFinalFits_16Jan2026_noDeco/workspaces_fiducial"
BASE_WS="${BASE_WS_FID}"
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

# Select which modes to run; override by setting RUN_MODES in the env (e.g. RUN_MODES="CPODD KT0P7KTT0P7").
# RUN_MODES=${RUN_MODES:-"SM CPODD KTM1KTT0 KT0P7KTT0P7 KT0P7KTTM0P7 KT0KTTM1 KT0KTT0"}
RUN_MODES=${RUN_MODES:-"SM CPODD KTM1KTT0 KT0P7KTT0P7 KT0P7KTTM0P7 KT0KTTM1 KT0KTT0"}
# RUN_MODES="CPODD"
# RUN_MODES="KTM1KTT0"
# RUN_MODES="KT0P7KTT0P7"
# RUN_MODES="KT0P7KTTM0P7"
# RUN_MODES="KT0KTTM1"
# RUN_MODES="KT0KTT0"


for LABEL in ${RUN_MODES}; do
    case "$LABEL" in
        SM)           PROCS="$PROCS_SM"           EXT_BASE="tth_th_analysis_fiducial"          CP_LABEL="SM" ;;
        CPODD)        PROCS="$PROCS_CPODD"        EXT_BASE="tth_th_analysis_fiducial"          CP_LABEL="CPodd" ;;
        KTM1KTT0)     PROCS="$PROCS_KTM1KTT0"     EXT_BASE="tth_th_analysis_fiducial"          CP_LABEL="Ktm1Ktt0" ;;
        KT0P7KTT0P7)  PROCS="$PROCS_KT0P7KTT0P7"  EXT_BASE="tth_th_analysis_fiducial"          CP_LABEL="Kt0p7Ktt0p7" ;;
        KT0P7KTTM0P7) PROCS="$PROCS_KT0P7KTTM0P7" EXT_BASE="tth_th_analysis_fiducial"          CP_LABEL="Kt0p7Kttm0p7" ;;
        KT0KTTM1)     PROCS="$PROCS_KT0KTTM1"     EXT_BASE="tth_th_analysis_fiducial"          CP_LABEL="Kt0Kttm1" ;;
        KT0KTT0)      PROCS="$PROCS_KT0KTT0"      EXT_BASE="tth_th_analysis_fiducial"          CP_LABEL="Kt0Ktt0" ;;
    esac
    if [[ ${USE_NODECO} -eq 1 ]]; then
        EXT_BASE="${EXT_BASE}_noDeco"
    fi
    case "$LABEL" in
        SM) EXT="${EXT_BASE}" ;;
        CPODD) EXT="${EXT_BASE}_CPodd" ;;
        KTM1KTT0) EXT="${EXT_BASE}_Ktm1Ktt0" ;;
        KT0P7KTT0P7) EXT="${EXT_BASE}_Kt0p7Ktt0p7" ;;
        KT0P7KTTM0P7) EXT="${EXT_BASE}_Kt0p7Kttm0p7" ;;
        KT0KTTM1) EXT="${EXT_BASE}_Kt0Kttm1" ;;
        KT0KTT0) EXT="${EXT_BASE}_Kt0Ktt0" ;;
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
