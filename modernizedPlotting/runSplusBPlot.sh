#!/usr/bin/env bash
set -euo pipefail

# New variant of the S+B plotting pipeline that performs a real B-only fit
# to obtain a postfit snapshot (with discrete PDF indices chosen) before
# exporting shapes and plotting. Keeps the original script for comparison.

# Run from current directory (HttCPAnalysis/finalFitsPlotting)
# FinalFit repo is located at: ../../CMSSW_14_1_0_pre4/src/flashggFinalFit
FLASHGG_BASE="../../CMSSW_14_1_0_pre4/src/flashggFinalFit"

# Inputs and outputs
# Prefit datacard workspace (input to the fit)
WS_PREFIT="${FLASHGG_BASE}/Combine/Datacard_r_2D.root"
# Postfit workspace produced by MultiDimFit (saved locally in CWD)
POSTFIT_WS="postfit_workspace_for_export.root"
SHAPES_FILE="${FLASHGG_BASE}/Combine/shapes_for_plot.root"
CATS_JSON="${FLASHGG_BASE}/Plots/cats_tth_th.json"
EXT="tth_th_analysis"
TOYS_DIR="${FLASHGG_BASE}/Plots/SplusBModels${EXT}/toys"
TOY_PKL="SplusBModels${EXT}/toyYields_CMS_hgg_mass.pkl"
# Mass choice used for fit/toys/export
MASS_FOR_EXPORT=125.38

# Optionally clean out old toys (uncomment next line to enable)
# rm -rv "${TOYS_DIR}"
mkdir -p "${TOYS_DIR}"

# Toy production settings
# Number of toys to submit if none are found (override via env)
N_TOYS=${N_TOYS:-500}
# HTCondor queue to use (override via env)
CONDOR_QUEUE=${CONDOR_QUEUE:-espresso}
# Regenerate toys even if some exist (0/1)
REGENERATE_TOYS=${REGENERATE_TOYS:-0}
# Freeze MultiPdf indices during toy fits/throws (0/1)
FREEZE_PDFINDEX=${FREEZE_PDFINDEX:-0}

############################################
# 0) Perform a real B-only fit and save snapshot (MultiDimFit)
#    - This fits nuisances and chooses discrete PDF indices on data with POIs frozen to 0
############################################

# (
#   set -e
#   pushd ../../CMSSW_14_1_0_pre4/src >/dev/null
#   cmsenv
#   # Run MultiDimFit with POIs frozen to zero; save workspace snapshot 'MultiDimFit'
#   # Include commonly used X-rtd flags for robust minimization and discrete profiling
#   combine "${WS_PREFIT}" -M MultiDimFit -m ${MASS_FOR_EXPORT} \
#     --saveWorkspace \
#     --setParameters MH=${MASS_FOR_EXPORT},r_ttH=0,r_tHq=0 \
#     --freezeParameters MH,r_ttH,r_tHq \
#     --cminDefaultMinimizerStrategy 0 \
#     --X-rtd MINIMIZER_freezeDisassociatedParams \
#     --X-rtd MINIMIZER_multiMin_hideConstants \
#     --X-rtd MINIMIZER_multiMin_maskConstraints \
#     --X-rtd MINIMIZER_multiMin_maskChannels=2 \
#     -n _bonly_fit
#   # Move the output workspace next to this script (CWD)
#   OUTFILE="higgsCombine_bonly_fit.MultiDimFit.mH${MASS_FOR_EXPORT}.root"
#   popd >/dev/null
#   cp ../../CMSSW_14_1_0_pre4/src/${OUTFILE} "${POSTFIT_WS}"
# )

###########################################
# 1) Export TH1s and toy yields (PyROOT)
#    Export uses the postfit snapshot 'MultiDimFit' from the fitted workspace
###########################################

# (
#   set -e
#   pushd ../../CMSSW_14_1_0_pre4/src >/dev/null
#   cmsenv
#   popd >/dev/null
#   # Export shapes from the postfit snapshot (ensures background line matches fitted discrete indices)
#   python3 ./export_workspace_shapes.py \
#     --inputWSFile "${POSTFIT_WS}" \
#     --loadSnapshot MultiDimFit \
#     --mass ${MASS_FOR_EXPORT} \
#     --cats all \
#     --blindingRegion 120,130 \
#     --nBins 80 \
#     --pdfNBins 3200 \
#     --splitResonant \
#     --topPOIs r_ttH \
#     --thqPOIs r_tHq \
#     --output "${SHAPES_FILE}"

#   # 1b) Generate toys aligned to the same postfit snapshot if missing or forced
#   if [[ ${REGENERATE_TOYS} -eq 1 ]] || ! compgen -G "${TOYS_DIR}/toy_*.root" > /dev/null; then
#     echo "[info] Submitting ${N_TOYS} toys (queue=${CONDOR_QUEUE}) aligned to snapshot 'MultiDimFit'."
#     # Note: run from this directory so makeToys records an absolute path to POSTFIT_WS via $PWD
#     python3 "${FLASHGG_BASE}/Plots/makeToys.py" \
#       --inputWSFile "${POSTFIT_WS}" \
#       --loadSnapshot MultiDimFit \
#       --ext "${EXT}" \
#       --nToys "${N_TOYS}" \
#       --POIs r_ttH,r_tHq \
#       --batch condor \
#       --mass "${MASS_FOR_EXPORT}" \
#       --queue "${CONDOR_QUEUE}" \
#       $( [[ ${FREEZE_PDFINDEX} -eq 1 ]] && echo "--freezePdfIndices" )
#     # Toys run on condor asynchronously; export will proceed if any are already present
#   else
#     echo "[info] Found existing toys in ${TOYS_DIR}; skipping submission. Set REGENERATE_TOYS=1 to resubmit."
#   fi

#   # 1c) Export per-bin toy yields (if any toy ROOTs present)
#   if compgen -G "${TOYS_DIR}/toy_*.root" > /dev/null; then
#     python3 ./export_toy_yields.py \
#       --inputWSFile "${POSTFIT_WS}" \
#       --cats all \
#       --toysDir "${TOYS_DIR}" \
#       --nBins 80 \
#       --blindingRegion 120,130 \
#       --doToyVeto \
#       --output "${TOY_PKL}"
#   else
#     echo "[warn] No toy ROOT files found under ${TOYS_DIR}; will plot without bands."
#   fi
# )

############################################
# 2) Plot with mplhep + uproot from the exported shapes
#    Activate your analysis env: micromamba activate cpanalysisenv
############################################
(
  set -e
  if command -v micromamba >/dev/null 2>&1; then
    eval "$(micromamba shell hook -s bash)"
    micromamba activate cpanalysisenv
  else
    echo "[warn] micromamba not found; using current Python env" >&2
  fi
  python3 ./makeSplusBModelPlot.py \
    --inputWSFile "${SHAPES_FILE}" \
    --cats all \
    --doZeroes \
    --ext ${EXT} \
    --blindingRegion 120,130 \
    --translateCats "${CATS_JSON}" \
    --doBands \
    --loadToyYields "${TOY_PKL}" \
    --splitResonant \
    --topPOIs r_ttH \
    --thqPOIs r_tHq \
    --topScale 2 \
    --thqScale 10 \
    --splitLabels '$(t\bar{t}H\!+\!tHW) \times 2$,$tHq \times 10$,Resonant bkg.'
)
