source ../setup.sh

python3 RunSignalScripts.py --inputConfig config_2022postEE.py --mode fTest --modeOpts "--doPlots"

# this one did not work for me:
# python3 RunSignalScripts.py --inputConfig config_2022postEE.py --mode getDiagProc

python3 RunSignalScripts.py --inputConfig config_2022postEE.py --mode signalFit --groupSignalFitJobsByCat --modeOpts "--skipVertexScenarioSplit --skipSystematics --doPlots"

python3 RunPackager.py --cats auto --inputWSDir /net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits/workspaces/2022postEE/ws_signal/ --year 2022postEE --batch local --massPoints 125 --exts tth_th_analysis_2022postEE --mergeYears

# python3 RunPlotter.py --procs all --years 2022postEE --cats tH_lep_1,tH_lep_2,ttH_lep_1,ttH_lep_2 --ext packaged

python3 RunPlotter.py --procs all --years 2022postEE --cats tH_lep_1 --ext packaged
python3 RunPlotter.py --procs all --years 2022postEE --cats tH_lep_2 --ext packaged
python3 RunPlotter.py --procs all --years 2022postEE --cats ttH_lep_1 --ext packaged
python3 RunPlotter.py --procs all --years 2022postEE --cats ttH_lep_2 --ext packaged