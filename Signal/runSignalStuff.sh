source ../setup.sh

#!/usr/bin/env bash
set -euo pipefail

FIDUCIAL_YAML_DEFAULT="/net/data_cms3a-1/mausolf/HttCPAnalysis/modelDependenceStudies/fiducial_fractions_2022postEE.yaml"
FIDUCIAL_YAML=${FIDUCIAL_YAML:-$FIDUCIAL_YAML_DEFAULT}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fiducial-yaml)
      FIDUCIAL_YAML="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

export FIDUCIAL_FRACTIONS_YAML="$FIDUCIAL_YAML"

# which eras to process
eras=(2022preEE 2022postEE 2023preBPix 2023postBPix)



# base workspace directory you wrote into above
# BASE_WS=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_17Dec2025_withPenalty/workspaces/
BASE_WS=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_17Dec2025_withPenalty/workspaces_fiducial

### be careful: do you want to wipe out old outputs?
# rm -rv outdir_tth_th_analysis_2022preEE
# rm -rv outdir_tth_th_analysis_2022postEE
# rm -rv outdir_tth_th_analysis_2023preBPix
# rm -rv outdir_tth_th_analysis_2023postBPix

# NOTE: COMMENT IN ONE AFTER EACH OTHER WHEN THE CONDOR JOBS ARE FINISHED!
# for era in "${eras[@]}"; do
#   echo ">>> Running signal scripts for era: $era"

  # 1) fTest
  # python3 RunSignalScripts.py \
  #   --inputConfig config_${era}.py \
  #   --mode fTest \
  #   --modeOpts "--doPlots --skipWV"

  # python3 RunSignalScripts.py \
  #   --inputConfig config_${era}_fiducial.py \
  #   --mode fTest \
  #   --modeOpts "--doPlots --skipWV"

  ## 2) full signal fit (per-cat condor jobs)
#   python3 RunSignalScripts.py \
#     --inputConfig config_${era}.py \
#     --mode signalFit \
#     --groupSignalFitJobsByCat \
#     --modeOpts "--skipVertexScenarioSplit --skipSystematics --doPlots"

#   python3 RunSignalScripts.py \
#     --inputConfig config_${era}_fiducial.py \
#     --mode signalFit \
#     --groupSignalFitJobsByCat \
#     --modeOpts "--skipVertexScenarioSplit --skipSystematics --doPlots"

# done
# condor_q

### be careful: do you want to wipe out old outputs?
# 1) Make a new “merged” workspace folder
# rm -rv ./outdir_packaged
rm -rv ./all_eras_ws_signal
mkdir -p ./all_eras_ws_signal

for era in 2022preEE 2022postEE 2023preBPix 2023postBPix; do
  for f in ${BASE_WS}/${era}/ws_tHW*/*.root; do
    base=$(basename "$f" .root)
    cp -v "$f" ./all_eras_ws_signal/${base}_${era}.root
  done
done

# now run the packager once on the merged folder
# python3 RunPackager.py \
#   --cats auto \
#   --inputWSDir ./all_eras_ws_signal \
#   --exts tth_th_analysis_2022preEE,tth_th_analysis_2022postEE,tth_th_analysis_2023preBPix,tth_th_analysis_2023postBPix \
#   --mergeYears \
#   --massPoints 125 \
#   --batch condor \
#   --mergeYears

python3 RunPackager.py \
  --cats auto \
  --inputWSDir ./all_eras_ws_signal \
  --exts tth_th_analysis_fiducial_2022preEE,tth_th_analysis_fiducial_2022postEE,tth_th_analysis_fiducial_2023preBPix,tth_th_analysis_fiducial_2023postBPix \
  --mergeYears \
  --massPoints 125 \
  --batch condor \
  --mergeYears


# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats tH_lep_1 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats tH_lep_2 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats tH_lep_3 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats tH_lep_4 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_lep_1 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_lep_2 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_lep_3 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_lep_4 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_lep_5 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats bkg_lep --ext packaged

# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats tH_had_1 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats tH_had_2 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats tH_had_3 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats tH_had_4 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_had_1 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_had_2 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_had_3 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_had_4 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats bkg_had --ext packaged
