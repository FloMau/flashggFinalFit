source ../setup.sh

FIDUCIAL_YAML_DEFAULT="/net/data_cms3a-1/mausolf/HttCPAnalysis/modelDependenceStudies/fiducial_fractions_2022postEE.yaml"
FIDUCIAL_YAML=${FIDUCIAL_YAML:-$FIDUCIAL_YAML_DEFAULT}
ANALYSIS=${ANALYSIS:-tth_th_analysis}

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
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

export FIDUCIAL_FRACTIONS_YAML="$FIDUCIAL_YAML"

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
        SM)           PROCS="$PROCS_SM"           EXT="tth_th_analysis" ;;
        CPODD)        PROCS="$PROCS_CPODD"        EXT="tth_th_analysis_CPodd" ;;
        KTM1KTT0)     PROCS="$PROCS_KTM1KTT0"     EXT="tth_th_analysis_Ktm1Ktt0" ;;
        KT0P7KTT0P7)  PROCS="$PROCS_KT0P7KTT0P7"  EXT="tth_th_analysis_Kt0p7Ktt0p7" ;;
        KT0P7KTTM0P7) PROCS="$PROCS_KT0P7KTTM0P7" EXT="tth_th_analysis_Kt0p7Kttm0p7" ;;
        KT0KTTM1)     PROCS="$PROCS_KT0KTTM1"     EXT="tth_th_analysis_Kt0Kttm1" ;;
        KT0KTT0)      PROCS="$PROCS_KT0KTT0"      EXT="tth_th_analysis_Kt0Ktt0" ;;
    esac

    # echo ">> Running RunYields for $LABEL ..."
    python3 RunYields.py \
        --cats auto \
        --inputWSDirMap ${INPUT_MAP} \
        --procs ${PROCS} \
        --ext ${EXT} \
        --batch local \
        --mergeYears \
        --doSystematics

    echo ">> Making datacards for $LABEL ..."
    python3 makeDatacard.py --years 2022preEE,2022postEE,2023preBPix,2023postBPix --ext ${EXT} --prune --pruneThreshold 0.001 --doTrueYield --analysis ${ANALYSIS} --skipCOWCorr --doSystematics # --doMCStatUncertainty

    # Preserve the produced card with a mode-specific name
    if [[ -f Datacard.txt ]]; then
        mv -v Datacard.txt "Datacard_${EXT}.txt"
    fi
done
