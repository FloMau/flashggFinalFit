source ../setup.sh

# Usage examples:
#   Run yields + datacards (default): bash runDatacardSteps.sh
#   Run yields only:                 bash runDatacardSteps.sh --yields
#   Run datacards only:              bash runDatacardSteps.sh --datacards
# Notes:
#   - If running yields on batch, run --yields-only first, wait for jobs to finish,
#     then run --datacards-only.

# FIDUCIAL_YAML_DEFAULT="/net/data_cms3a-1/mausolf/HttCPAnalysis/modelDependenceStudies/fiducial_fractions_2022postEE.yaml"
# FIDUCIAL_YAML=${FIDUCIAL_YAML:-$FIDUCIAL_YAML_DEFAULT}
ANALYSIS=${ANALYSIS:-tth_th_analysis}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YIELDS_BASE="${SCRIPT_DIR}/yields/${ANALYSIS}"
DATACARD_OUT_BASE="${SCRIPT_DIR}/datacard_outputs/${ANALYSIS}"
RUN_YIELDS=1
RUN_DATACARDS=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fiducial-yaml)
      FIDUCIAL_YAML="$2"
      shift 2
      ;;
    --analysis)
      ANALYSIS="$2"
      shift 2
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

# export FIDUCIAL_FRACTIONS_YAML="$FIDUCIAL_YAML"

INPUT_MAP="2022preEE=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_17Dec2025_withPenalty/workspaces/2022preEE/ws_signal,2022postEE=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_17Dec2025_withPenalty/workspaces/2022postEE/ws_signal,2023preBPix=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_17Dec2025_withPenalty/workspaces/2023preBPix/ws_signal,2023postBPix=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_17Dec2025_withPenalty/workspaces/2023postBPix/ws_signal"

# Explicit process lists
PROCS_SM="ggh_incl,vbf_incl,vh_incl,bbh_incl,tth_incl,tHqLep_incl,tHqHad_incl,tHW_incl"
PROCS_CPODD="ggh_incl,vbf_incl,vh_incl,bbh_incl,tthCPodd_incl,tHqLepCPodd_incl,tHqHadCPodd_incl,tHWCPodd_incl"
PROCS_KTM1KTT0="ggh_incl,vbf_incl,vh_incl,bbh_incl,tth_incl,tHqLepKtm1Ktt0_incl,tHqHadKtm1Ktt0_incl,tHWKtm1Ktt0_incl"
PROCS_KT0P7KTT0P7="ggh_incl,vbf_incl,vh_incl,bbh_incl,tthKt0p7Ktt0p7_incl,tHqLepKt0p7Ktt0p7_incl,tHqHadKt0p7Ktt0p7_incl,tHWKt0p7Ktt0p7_incl"
PROCS_KT0P7KTTM0P7="ggh_incl,vbf_incl,vh_incl,bbh_incl,tthKt0p7Kttm0p7_incl,tHqLepKt0p7Kttm0p7_incl,tHqHadKt0p7Kttm0p7_incl,tHWKt0p7Kttm0p7_incl"
PROCS_KT0KTTM1="ggh_incl,vbf_incl,vh_incl,bbh_incl,tthKt0Kttm1_incl,tHqLepKt0Kttm1_incl,tHqHadKt0Kttm1_incl,tHWKt0Kttm1_incl"
PROCS_KT0KTT0="ggh_incl,vbf_incl,vh_incl,bbh_incl,tthKt0Ktt0_incl,tHqLepKt0Ktt0_incl,tHqHadKt0Ktt0_incl,tHWKt0Ktt0_incl"

# Select which modes to run; override by setting RUN_MODES in the env (e.g. RUN_MODES="CPODD KT0P7KTT0P7").
RUN_MODES=${RUN_MODES:-"SM CPODD KTM1KTT0 KT0P7KTT0P7 KT0P7KTTM0P7 KT0KTTM1 KT0KTT0"}
# RUN_MODES="CPODD"
# RUN_MODES="KTM1KTT0"
# RUN_MODES="KT0P7KTT0P7"
# RUN_MODES="KT0P7KTTM0P7"
# RUN_MODES="KT0KTTM1"
# RUN_MODES="KT0KTT0"


for LABEL in ${RUN_MODES}; do
    case "$LABEL" in
        SM)           PROCS="$PROCS_SM"           EXT="tth_th_analysis"               CP_LABEL="SM" ;;
        CPODD)        PROCS="$PROCS_CPODD"        EXT="tth_th_analysis_CPodd"          CP_LABEL="CPodd" ;;
        KTM1KTT0)     PROCS="$PROCS_KTM1KTT0"     EXT="tth_th_analysis_Ktm1Ktt0"       CP_LABEL="Ktm1Ktt0" ;;
        KT0P7KTT0P7)  PROCS="$PROCS_KT0P7KTT0P7"  EXT="tth_th_analysis_Kt0p7Ktt0p7"    CP_LABEL="Kt0p7Ktt0p7" ;;
        KT0P7KTTM0P7) PROCS="$PROCS_KT0P7KTTM0P7" EXT="tth_th_analysis_Kt0p7Kttm0p7"   CP_LABEL="Kt0p7Kttm0p7" ;;
        KT0KTTM1)     PROCS="$PROCS_KT0KTTM1"     EXT="tth_th_analysis_Kt0Kttm1"       CP_LABEL="Kt0Kttm1" ;;
        KT0KTT0)      PROCS="$PROCS_KT0KTT0"      EXT="tth_th_analysis_Kt0Ktt0"        CP_LABEL="Kt0Ktt0" ;;
    esac

    YIELDS_DIR="${YIELDS_BASE}/${CP_LABEL}"
    YIELDS_DEST="${YIELDS_DIR}/yields_${EXT}"
    mkdir -p "${YIELDS_DIR}"

    if [[ ${RUN_YIELDS} -eq 1 ]]; then
        # echo ">> Running RunYields for $LABEL ..."
        python3 RunYields.py \
            --cats auto \
            --inputWSDirMap ${INPUT_MAP} \
            --procs ${PROCS} \
            --ext ${EXT} \
            --outputYieldsDir "${YIELDS_DIR}" \
            --batch condor \
            --mergeYears \
            --doSystematics
    fi

    if [[ ${RUN_DATACARDS} -eq 1 ]]; then
        if [[ ! -d "${YIELDS_DEST}" ]]; then
            echo "Expected yields directory missing: ${YIELDS_DEST}" >&2
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
