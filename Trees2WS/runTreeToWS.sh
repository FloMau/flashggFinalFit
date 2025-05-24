source ../setup.sh

# where to write your per-era workspaces
BASE_WS_DIR=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces

# wipe out old outputs and recreate base dir
# rm -rf "${BASE_WS_DIR}"
mkdir -p "${BASE_WS_DIR}"

# # list of eras to process
eras=(2022preEE 2022postEE 2023preBPix 2023postBPix)

# loop
for era in "${eras[@]}"; do
  echo ">>>>> Making workspaces for era: ${era}"
  wsdir="${BASE_WS_DIR}/${era}"
  mkdir -p "${wsdir}"

  # 1) signal modes
  python3 trees2ws.py \
    --inputConfig config_ttH_tH_2022_2023.py \
    --inputTreeFile /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/root/ttH_${era}/output_TTHToGG_M125_13TeV_amcatnlo_pythia8.root \
    --inputMass 125 \
    --productionMode tth \
    --year "${era}" \
    --outputWSDir "${wsdir}"

  python3 trees2ws.py \
    --inputConfig config_ttH_tH_2022_2023.py \
    --inputTreeFile /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/root/tHqLep_${era}/output_THQtoGG_lep_M125_13TeV_amcatnlo_pythia8.root \
    --inputMass 125 \
    --productionMode tHqLep \
    --year "${era}" \
    --outputWSDir "${wsdir}"

  python3 trees2ws.py \
    --inputConfig config_ttH_tH_2022_2023.py \
    --inputTreeFile /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/root/tHqHad_${era}/output_THQtoGG_had_M125_13TeV_amcatnlo_pythia8.root \
    --inputMass 125 \
    --productionMode tHqHad \
    --year "${era}" \
    --outputWSDir "${wsdir}"

  # 2) resonant backgrounds
  python3 trees2ws.py \
    --inputConfig config_ttH_tH_2022_2023.py \
    --inputTreeFile /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/root/VH_${era}/output_VHToGG_M125_13TeV_amcatnlo_pythia8.root \
    --inputMass 125 \
    --productionMode vh \
    --year "${era}" \
    --outputWSDir "${wsdir}"

  python3 trees2ws.py \
    --inputConfig config_ttH_tH_2022_2023.py \
    --inputTreeFile /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/root/GluGluH_${era}/output_GluGluHToGG_M125_13TeV_amcatnloFXFX_pythia8.root \
    --inputMass 125 \
    --productionMode ggh \
    --year "${era}" \
    --outputWSDir "${wsdir}"

  python3 trees2ws.py \
    --inputConfig config_ttH_tH_2022_2023.py \
    --inputTreeFile /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/root/VBFH_${era}/output_VBFHToGG_M125_13TeV_amcatnlo_pythia8.root \
    --inputMass 125 \
    --productionMode vbf \
    --year "${era}" \
    --outputWSDir "${wsdir}"


  # 4) copy everything into your signal directory layout
  bash cp_ws_to_signal_dir.sh "${wsdir}"

done

mkdir -p /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/Data
# 3) data (same file each time, but we generate a per‐era workspace)
python3 trees2ws_data.py \
--inputConfig config_ttH_tH_2022_2023.py \
--inputTreeFile /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/root/Data/allData.root \
--outputWSDir /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/Data

echo ">>> All done!"
