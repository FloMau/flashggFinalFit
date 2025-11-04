# Input config file for running trees2ws

trees2wsCfg = {
  # Name of RooDirectory storing input tree
  'inputTreeDir':'DiphotonTree',

  # Variables to be added to dataframe: use wildcard * for common strings
  'mainVars':["CMS_hgg_mass", "weight", "weight_central", "dZ", "*Up","*Down", "fiducialGeometricFlag", "GenNBJet"],
  'dataVars':["CMS_hgg_mass","weight"], # Vars to be added for data
  'stxsVar':'',
  'diffVar':'',
  'notagVars':[], # Vars to add to NOTAG RooDataset
  'systematicsVars':[], # Variables to add to sytematic RooDataHists
  'theoryWeightContainers':{},
  #'theoryWeightContainers':{'weight_LHEScale': 9},

  # List of systematics: use string YEAR for year-dependent systematics
  # 'systematics':["ScaleEB", "ScaleEE", "Smearing", "Material", "FNUF", "energyErrShift"],
  'systematics': [''],

  # Analysis categories: python list of cats or use 'auto' to extract from input tree
  'cats':'auto'
}