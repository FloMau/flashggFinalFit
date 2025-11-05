# Config file: options for signal fitting

backgroundScriptCfg = {
  
  # Setup
  'inputWS':'/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_04Nov2025/workspaces/Data/ws/allData.root', # location of 'allData.root' file
  'cats':'auto', # auto: automatically inferred from input ws
  'catOffset':0, # add offset to category numbers (useful for categories from different allData.root files)  
  'ext':'tth_th_analysis', # extension to add to output directory
  'year':'combined', # Use combined when merging all years in category (for plots)

  # Job submission options
  'batch':'local', # [condor,condor_lxplus,SGE,IC,local]
  'queue':'microcentury' # for condor e.g. microcentury
  
}
