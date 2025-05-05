source ../setup.sh d

# rm -rv /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/2022postEE

mkdir -p /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/2022postEE

python3 trees2ws.py --inputConfig config_2022_FM_test.py --inputTreeFile /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/root/VH_2022postEE/output_VHToGG_M125_13TeV_amcatnlo_pythia8.root --inputMass 125 --productionMode vh --year 2022postEE --outputWSDir /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/2022postEE
python3 trees2ws.py --inputConfig config_2022_FM_test.py --inputTreeFile /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/root/ttH_2022postEE/output_TTHToGG_M125_13TeV_amcatnlo_pythia8.root --inputMass 125 --productionMode tth --year 2022postEE --outputWSDir /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/2022postEE

python3 trees2ws_data.py --inputConfig config_2022_FM_test.py --inputTreeFile /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/root/Data/allData.root --outputWSDir /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/2022postEE

bash cp_ws_to_signal_dir.sh /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/2022postEE/
