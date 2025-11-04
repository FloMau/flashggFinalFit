#!/usr/bin/env bash
set -euo pipefail

# Environment
source ../setup.sh

# Paths
BASE_WS_DIR=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_03Sept2025/workspaces
ROOT_BASE=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_03Sept2025/root

# Run the faster orchestrator for all eras and all modes in parallel
# python3 faster_tree2ws.py \
#   --base-ws-dir "${BASE_WS_DIR}" \
#   --root-base "${ROOT_BASE}" \
#   --input-config config_ttH_tH_2022_2023.py \
#   --eras "2022preEE,2022postEE,2023preBPix,2023postBPix" \
#   --modes "tth,tHqLep,tHqHad,tHW,vh,ggh,vbf,bbh" \
#   --mass 125 \
#   --max-procs 32 \
#   --clean

# copy everything into your signal directory layout
# for era in 2022preEE 2022postEE 2023preBPix 2023postBPix; do
#   wsdir="${BASE_WS_DIR}/${era}"
#   bash cp_ws_to_signal_dir.sh "${wsdir}"
# done

# data workspaces
mkdir -p "${BASE_WS_DIR}/Data"
python3 trees2ws_data.py \
  --inputConfig config_ttH_tH_2022_2023.py \
  --inputTreeFile "${ROOT_BASE}/Data/allData.root" \
  --outputWSDir "${BASE_WS_DIR}/Data"

echo ">>> All done!"

