source ../setup.sh

#!/usr/bin/env bash
set -euo pipefail

# which eras to process
eras=(2022preEE 2022postEE 2023preBPix 2023postBPix)



# base workspace directory you wrote into above
BASE_WS=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_26Aug2025/workspaces/

### be careful: do you want to wipe out old outputs?
# rm -rv outdir_tth_th_analysis_2022preEE
# rm -rv outdir_tth_th_analysis_2022postEE
# rm -rv outdir_tth_th_analysis_2023preBPix
# rm -rv outdir_tth_th_analysis_2023postBPix

# NOTE: COMMENT IN ONE AFTER EACH OTHER WHEN THE CONDOR JOBS ARE FINISHED!
# for era in "${eras[@]}"; do
  # echo ">>> Running signal scripts for era: $era"

  # 1) fTest
  # python3 RunSignalScripts.py \
  #   --inputConfig config_${era}.py \
  #   --mode fTest \
  #   --modeOpts "--doPlots --skipWV"

  # 2) full signal fit (per-cat condor jobs)
  # python3 RunSignalScripts.py \
  #   --inputConfig config_${era}.py \
  #   --mode signalFit \
  #   --groupSignalFitJobsByCat \
  #   --modeOpts "--skipVertexScenarioSplit --skipSystematics --doPlots"

# done


# 1) Make a new “merged” workspace folder
# rm -rv ./outdir_packaged
# rm -rv ./all_eras_ws_signal
# mkdir -p ./all_eras_ws_signal

# for era in 2022preEE 2022postEE 2023preBPix 2023postBPix; do
#   for f in /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_26Aug2025/workspaces/${era}/ws_signal/*.root; do
#     base=$(basename "$f" .root)
#     cp -v "$f" ./all_eras_ws_signal/${base}_${era}.root
#   done
# done

# now run the packager once on the merged folder
# python3 RunPackager.py \
#   --cats auto \
#   --inputWSDir ./all_eras_ws_signal \
#   --exts tth_th_analysis_2022preEE,tth_th_analysis_2022postEE,tth_th_analysis_2023preBPix,tth_th_analysis_2023postBPix \
#   --mergeYears \
#   --massPoints 125 \
#   --batch local \
#   --mergeYears


# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats tH_lep_1 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats tH_lep_2 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_lep_1 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_lep_2 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats tH_had_1 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats tH_had_2 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_had_1 --ext packaged
# python3 RunPlotter.py --procs all --years 2022preEE,2022postEE,2023preBPix,2023postBPix --cats ttH_had_2 --ext packaged