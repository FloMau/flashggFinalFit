# Input config file for running trees2ws (with systematics)

trees2wsCfg = {
  # Name of RooDirectory storing input tree
  'inputTreeDir':'DiphotonTree',

  # Variables to be added to dataframe: use wildcard * for common strings
  'mainVars':["CMS_hgg_mass", "weight", "weight_central", "dZ", "*Up","*Down", "fiducialGeometricFlag", "GenNBJet"],
  'dataVars':["CMS_hgg_mass","weight"], # Vars to be added for data
  'stxsVar':'',
  'diffVar':'',
  'notagVars':[], # Vars to add to NOTAG RooDataset

  # Variables to add to systematic RooDataHists (keep minimal to avoid huge WS)
  'systematicsVars':["CMS_hgg_mass", "weight", "fiducialGeometricFlag", "GenNBJet"],

  # Theory weight containers (vector branches in the tree)
  'theoryWeightContainers':{
    'weight_LHEScale': 9,
    'weight_LHEPdf': 101
  },

  # List of systematics base names (Up/Down appended in trees2ws.py)
  'systematics': [
    "ElectronScale",
    "ElectronSmearing",
    "FNUF",
    "JecSystTotal",
    "JerSyst",
    "Material",
    "METUnclustered",
    "MuonResolution",
    "MuonScale",
    "ScaleEE",
    "ScaleEB",
    "Smearing",
  ],

  # Analysis categories: python list of cats or use 'auto' to extract from input tree
  'cats':'auto'
}
