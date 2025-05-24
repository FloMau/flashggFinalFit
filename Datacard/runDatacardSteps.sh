source ../setup.sh

python3 RunYields.py \
    --cats auto \
    --inputWSDirMap 2022preEE=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/2022preEE/ws_signal,2022postEE=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/2022postEE/ws_signal,2023preBPix=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/2023preBPix/ws_signal,2023postBPix=/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/2023postBPix/ws_signal\
    --procs auto \
    --ext tth_th_analysis \
    --batch local \
    --mergeYears # --queue longlunch # (--doSystematics)

python3 makeDatacard.py --years 2022preEE,2022postEE,2023preBPix,2023posBPixE --ext tth_th_analysis --prune --pruneThreshold 0.0001 --skipCOWCorr # --doSystematics # --doMCStatUncertainty 