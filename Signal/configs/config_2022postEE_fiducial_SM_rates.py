# Config file: options for signal fitting
signalScriptCfg = {

  # Setup
  'inputWSDir':'/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_14Jan2026_CP_penalty_10/workspaces_fiducial/2022postEE/ws_signal', # dir storing flashgg workspaces
  'procs':'auto', # if auto: inferred automatically from filenames (requires names to be of from *pythia8_{PROC}.root)
  'cats':'auto', # if auto: inferred automatically from (0) workspace
  #'ext':'earlyAnalysis_freeze_include', # output directory extension
  'ext':'tth_th_analysis_fiducial_SM_rates_2022postEE', # output directory extension
  'analysis':'tth_th_analysis_fiducial_SM_rates', # To specify replacement dataset and XS*BR mapping (defined in ./tools/replacementMap.py and ./tools/XSBRMap.py respectively)
  'year':'2022postEE', # Use 'combined' if merging all years: not recommended
  'massPoints':'125', # You can now run with a single mass point if necessary

  #Photon shape systematics  
  'scales':'', # separate nuisance per year
  'scalesCorr':'', # correlated across years
  #'scalesGlobal':'NonLinearity,Geant4', # affect all processes equally, correlated across years
  # Removed nonLinearity for HIG-23-014 
  'scalesGlobal':'', # affect all processes equally, correlated across years
  'smears':'', # separate nuisance per year

  # Job submission options
  'batch':'condor', # ['condor_lxplus','condor','SGE','IC','local']
  'queue':'microcentury', # use hep.q for IC
  'jobOpts':'request_memory = 12000'
}
