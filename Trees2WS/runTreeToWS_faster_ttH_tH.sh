#!/usr/bin/env bash
set -euo pipefail

# Environment
source ../setup.sh

# Paths
# append _fiducial to BASE_WS_DIR if producing the in-out splitted datasets
# BASE_WS_DIR=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_14Jan2026_CP_penalty_10/workspaces_fiducial
# ROOT_BASE=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_14Jan2026_CP_penalty_10/root

# BASE_WS_DIR=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_24Jan2026_CP_penalty_30/workspaces_fiducial
# ROOT_BASE=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_24Jan2026_CP_penalty_30/root

BASE_WS_DIR=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_12Feb2026/workspaces_fiducial
ROOT_BASE=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_12Feb2026/root

# Run the faster orchestrator for all eras and all modes in parallel.
# Add --do-in-out-splitting when producing fiducial workspaces; leave it off for the total xsec run.

BSM_scheme_minimal="tth,tthCPodd,tthKt0p7Ktt0p7,tthKt0p7Kttm0p7,tthKt0Kttm1,tthKt0Ktt0,\
tHqLep,tHqLepCPodd,tHqLepKtm1Ktt0,tHqLepKt0p7Ktt0p7,tHqLepKt0p7Kttm0p7,tHqLepKt0Kttm1,tHqLepKt0Ktt0,\
tHqHad,tHqHadCPodd,tHqHadKtm1Ktt0,tHqHadKt0p7Ktt0p7,tHqHadKt0p7Kttm0p7,tHqHadKt0Kttm1,tHqHadKt0Ktt0,\
tHW,tHWCPodd,tHWKtm1Ktt0,tHWKt0p7Ktt0p7,tHWKt0p7Kttm0p7,tHWKt0Kttm1,tHWKt0Ktt0,\
vh,ggh,vbf,bbh"

BSM_scheme_full="${BSM_scheme_minimal},\
tthKt0p500Ktt0p000,tthKt0p354Ktt0p354,tthKt0p000Ktt0p500,tthKtm0p500Ktt0p000,tthKt0p000Kttm0p500,tthKt0p354Kttm0p354,\
tthKt1p500Ktt0p000,tthKt1p061Ktt1p061,tthKt0p000Ktt1p500,tthKtm1p500Ktt0p000,tthKt0p000Kttm1p500,tthKt1p061Kttm1p061,\
tHqLepKt0p500Ktt0p000,tHqLepKt0p354Ktt0p354,tHqLepKt0p000Ktt0p500,tHqLepKtm0p500Ktt0p000,tHqLepKt0p000Kttm0p500,tHqLepKt0p354Kttm0p354,\
tHqLepKt1p500Ktt0p000,tHqLepKt1p061Ktt1p061,tHqLepKt0p000Ktt1p500,tHqLepKtm1p500Ktt0p000,tHqLepKt0p000Kttm1p500,tHqLepKt1p061Kttm1p061,\
tHqHadKt0p500Ktt0p000,tHqHadKt0p354Ktt0p354,tHqHadKt0p000Ktt0p500,tHqHadKtm0p500Ktt0p000,tHqHadKt0p000Kttm0p500,tHqHadKt0p354Kttm0p354,\
tHqHadKt1p500Ktt0p000,tHqHadKt1p061Ktt1p061,tHqHadKt0p000Ktt1p500,tHqHadKtm1p500Ktt0p000,tHqHadKt0p000Kttm1p500,tHqHadKt1p061Kttm1p061,\
tHWKt0p500Ktt0p000,tHWKt0p354Ktt0p354,tHWKt0p000Ktt0p500,tHWKtm0p500Ktt0p000,tHWKt0p000Kttm0p500,tHWKt0p354Kttm0p354,\
tHWKt1p500Ktt0p000,tHWKt1p061Ktt1p061,tHWKt0p000Ktt1p500,tHWKtm1p500Ktt0p000,tHWKt0p000Kttm1p500,tHWKt1p061Kttm1p061"


BSM_scheme_extra="tthKt0p500Ktt0p000,tthKt0p354Ktt0p354,tthKt0p000Ktt0p500,tthKtm0p500Ktt0p000,tthKt0p000Kttm0p500,tthKt0p354Kttm0p354,\
tthKt1p500Ktt0p000,tthKt1p061Ktt1p061,tthKt0p000Ktt1p500,tthKtm1p500Ktt0p000,tthKt0p000Kttm1p500,tthKt1p061Kttm1p061,\
tHqLepKt0p500Ktt0p000,tHqLepKt0p354Ktt0p354,tHqLepKt0p000Ktt0p500,tHqLepKtm0p500Ktt0p000,tHqLepKt0p000Kttm0p500,tHqLepKt0p354Kttm0p354,\
tHqLepKt1p500Ktt0p000,tHqLepKt1p061Ktt1p061,tHqLepKt0p000Ktt1p500,tHqLepKtm1p500Ktt0p000,tHqLepKt0p000Kttm1p500,tHqLepKt1p061Kttm1p061,\
tHqHadKt0p500Ktt0p000,tHqHadKt0p354Ktt0p354,tHqHadKt0p000Ktt0p500,tHqHadKtm0p500Ktt0p000,tHqHadKt0p000Kttm0p500,tHqHadKt0p354Kttm0p354,\
tHqHadKt1p500Ktt0p000,tHqHadKt1p061Ktt1p061,tHqHadKt0p000Ktt1p500,tHqHadKtm1p500Ktt0p000,tHqHadKt0p000Kttm1p500,tHqHadKt1p061Kttm1p061,\
tHWKt0p500Ktt0p000,tHWKt0p354Ktt0p354,tHWKt0p000Ktt0p500,tHWKtm0p500Ktt0p000,tHWKt0p000Kttm0p500,tHWKt0p354Kttm0p354,\
tHWKt1p500Ktt0p000,tHWKt1p061Ktt1p061,tHWKt0p000Ktt1p500,tHWKtm1p500Ktt0p000,tHWKt0p000Kttm1p500,tHWKt1p061Kttm1p061"


#### run either without BSM samples:

# python3 faster_tree2ws.py \
#   --base-ws-dir "${BASE_WS_DIR}" \
#   --root-base "${ROOT_BASE}" \
#   --input-config config_ttH_tH_2022_2023.py \
#   --eras "2022preEE,2022postEE,2023preBPix,2023postBPix" \
#   --modes "tth,tHqLep,tHqHad,tHW,vh,ggh,vbf,bbh" \
#   --mass 125 \
#   --max-procs 32 \
#   # --clean \
#   # --do-in-out-splitting


#### or with BSM samples

# python3 faster_tree2ws.py \
#   --base-ws-dir "${BASE_WS_DIR}" \
#   --root-base "${ROOT_BASE}" \
#   --input-config config_ttH_tH_2022_2023_with_systs.py \
#   --eras "2022preEE,2022postEE,2023preBPix,2023postBPix" \
#   --modes "vh" \
#   --mass 125 \
#   --max-procs 16 \
#   --do-in-out-splitting \
#   --do-systematics
#  --modes "${BSM_scheme_minimal}" \

# copy everything into your signal directory layout
# for era in 2022preEE 2022postEE 2023preBPix 2023postBPix; do
#   wsdir="${BASE_WS_DIR}/${era}"
#   bash cp_ws_to_signal_dir.sh "${wsdir}"
# done

# # # # data workspaces
# mkdir -p "${BASE_WS_DIR}/Data"
# python3 trees2ws_data.py \
#   --inputConfig config_ttH_tH_2022_2023.py \
#   --inputTreeFile "${ROOT_BASE}/Data/allData.root" \
#   --outputWSDir "${BASE_WS_DIR}/Data"

# echo ">>> All done!"
