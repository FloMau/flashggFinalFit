source ../setup.sh

python3 RunYields.py --cats auto --inputWSDirMap 2022postEE=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/2022postEE/ws_signal/ --procs auto --ext tth_th_analysis --batch local --mergeYears # --queue longlunch # (--doSystematics)

python3 makeDatacard.py --years 2022postEE --ext tth_th_analysis --prune --pruneThreshold 0.001 --skipCOWCorr # --doSystematics # --doMCStatUncertainty 