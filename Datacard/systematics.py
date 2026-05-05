# Python file to store systematics: for STXS analysis

# Comment out all nuisances that you do not want to include

# THEORY SYSTEMATICS:

# For type:constant
#  1) specify same value for all processes
#  2) define process map json in ./theory_uncertainties (add process names where necessary!)

# For type:factory
# Tier system: adds different uncertainties to dataframe
#   1) shape: absolute yield of process kept constant, shape effects i.e. calc migrations across cats
#   2) ishape: as (1) but absolute yield for proc x cat is allowed to vary
#   3) norm: absolute yield of production mode (s0) kept constant but migrations across sub-processes e.g. STXS bins.Same value in each category.
#   4) inorm: as (3) but absolute yield of production mode (s0) can vary
#   5) inc: variations in production mode (s0), same value for each subprocess in each category
# Relations: shape = ishape/inorm
#            norm  = inorm/inc
# Specify as list in dict: e.g. 'tiers'=['inc','inorm','norm','ishape','shape']

theory_systematics = [
                # Normalisation uncertainties: enter interpretations
                # Interim 13.6 TeV xsec theory uncertainties (per process for scale; single NP for PDF/alphaS)
                # Values are in theory_uncs_ad_interim_13p6TeV.json and mapped to ggh/vbf/vh/bbh in/out processes
                {'name':'QCDscale_ggH','title':'QCDscale_ggH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/theory_uncs_ad_interim_13p6TeV.json'},
                {'name':'QCDscale_VBF','title':'QCDscale_VBF','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/theory_uncs_ad_interim_13p6TeV.json'},
                {'name':'QCDscale_VH','title':'QCDscale_VH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/theory_uncs_ad_interim_13p6TeV.json'},
                {'name':'QCDscale_bbH','title':'QCDscale_bbH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/theory_uncs_ad_interim_13p6TeV.json'},
                # PDF and alphaS treated as single correlated NPs across processes (xsec-only)
                {'name':'pdf_xsec','title':'pdf_xsec','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/theory_uncs_ad_interim_13p6TeV.json'},
                {'name':'alphaS_xsec','title':'alphaS_xsec','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/theory_uncs_ad_interim_13p6TeV.json'},
              ]

# Theory weights in the nominal RooDataSets (HiggsDNA naming)
# LHE scale weights: use the conventional 6-point subset (skip 2,4,6)
# Decorrelate between production modes (including signal processes)
lhescale_procs = [
  ("ggH", "ggh"),
  ("VBF", "vbf"),
  ("VH",  "vh"),
  ("bbH", "bbh"),
  ("ttH", "tth"),
  ("tHq", "tHq"),
  ("tHW", "tHW"),
]
for i in (0, 1, 3, 5, 7, 8):
  for tag, match in lhescale_procs:
    theory_systematics.append({
      'name': f'weight_LHEScal_{tag}_{i}',
      'title': f'CMS_hgg_scaleWeight_{i}_{tag}',
      'weight_name': f'weight_LHEScal_{i}',
      'proc_match': match,
      'type': 'factory',
      'prior': 'lnN',
      'correlateAcrossYears': 1,
      'tiers': ['shape']
    })

# LHE PDF weights (1..100). Stored as weight_LHEPd_* in RooDataSets.
for i in range(1, 101):
  theory_systematics.append({
    'name': f'weight_LHEPd_{i}',
    'title': f'CMS_hgg_pdfWeight_{i}',
    'type': 'factory',
    'prior': 'lnN',
    'correlateAcrossYears': 1,
    'tiers': ['shape']
  })

# alphaS and PS weights
theory_systematics.extend([
  {'name':'weight_AlphaS','title':'CMS_hgg_AlphaS','type':'factory','prior':'lnN','correlateAcrossYears':1,'tiers':['shape']},
  {'name':'weight_PS_ISR','title':'CMS_hgg_PS_ISR','type':'factory','prior':'lnN','correlateAcrossYears':1,'tiers':['shape']},
  {'name':'weight_PS_FSR','title':'CMS_hgg_PS_FSR','type':'factory','prior':'lnN','correlateAcrossYears':1,'tiers':['shape']},
])

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# EXPERIMENTAL SYSTEMATICS
# correlateAcrossYears = 0 : no correlation
# correlateAcrossYears = 1 : fully correlated
# correlateAcrossYears = -1 : partially correlated

experimental_systematics = [
                # Run-3 correlated luminosity scheme (reduction method)
                {'name':'lumi_1','title':'lumi_1','type':'constant','prior':'lnN','correlateAcrossYears':-1,'value':{"2022preEE": "1.0138", "2022postEE": "1.0138", "2022": "1.0138", "2023preBPix": "1.0017", "2023postBPix": "1.0017", "2023": "1.0017", "2024": "1.0020"}},
                {'name':'lumi_2','title':'lumi_2','type':'constant','prior':'lnN','correlateAcrossYears':-1,'value':{"2023preBPix": "1.0127", "2023postBPix": "1.0127", "2023": "1.0127", "2024": "1.0068"}},
              ]

# Tree-based experimental systematics (Up/Down trees in Trees2WS config)
experimental_systematics.extend([
  {'name':'ElectronScale','title':'CMS_hgg_ElectronScale','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'ElectronSmearing','title':'CMS_hgg_ElectronSmearing','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'JecSystTotal','title':'CMS_scale_j','type':'factory','prior':'lnN','correlateAcrossYears':0},
  {'name':'JerSyst','title':'CMS_res_j','type':'factory','prior':'lnN','correlateAcrossYears':0},
  {'name':'METUnclustered','title':'CMS_hgg_MET_Unclustered','type':'factory','prior':'lnN','correlateAcrossYears':0},
  {'name':'MuonResolution','title':'CMS_hgg_MuonResolution','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'MuonScale','title':'CMS_hgg_MuonScale','type':'factory','prior':'lnN','correlateAcrossYears':1},
])

# Weight-based experimental systematics (Up/Down weights in nominal RooDataSets)
experimental_systematics.extend([
  {'name':'weight_Pileup','title':'CMS_hgg_PileupWeight','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_TriggerSF','title':'CMS_hgg_TriggerWeight','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_ElectronVetoSF','title':'CMS_hgg_ElectronVetoSF','type':'factory','prior':'lnN','correlateAcrossYears':0}, # from Zmumug, main unc is statistical
  {'name':'weight_PreselSF','title':'CMS_hgg_PreselSF','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_atLeast1LeptonIdSF_ele_Reco','title':'CMS_hgg_EleRecoSF','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_atLeast1LeptonIdSF_ele_wp90iso','title':'CMS_hgg_EleWP90IsoSF','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_atLeast1LeptonIdSF_mu_NUM_MediumID_DEN_TrackerMuons','title':'CMS_hgg_MuMediumIDSF','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_atLeast1LeptonIdSF_mu_NUM_TightPFIso_DEN_MediumID','title':'CMS_hgg_MuTightPFIsoSF','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_bTagSF_sys_cferr1','title':'CMS_hgg_bTagSF_sys_cferr1','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_bTagSF_sys_cferr2','title':'CMS_hgg_bTagSF_sys_cferr2','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_bTagSF_sys_hf','title':'CMS_hgg_bTagSF_sys_hf','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_bTagSF_sys_hfstats1','title':'CMS_hgg_bTagSF_sys_hfstats1','type':'factory','prior':'lnN','correlateAcrossYears':0},
  {'name':'weight_bTagSF_sys_hfstats2','title':'CMS_hgg_bTagSF_sys_hfstats2','type':'factory','prior':'lnN','correlateAcrossYears':0},
  {'name':'weight_bTagSF_sys_jes','title':'CMS_hgg_bTagSF_sys_jes','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_bTagSF_sys_lf','title':'CMS_hgg_bTagSF_sys_lf','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_bTagSF_sys_lfstats1','title':'CMS_hgg_bTagSF_sys_lfstats1','type':'factory','prior':'lnN','correlateAcrossYears':0},
  {'name':'weight_bTagSF_sys_lfstats2','title':'CMS_hgg_bTagSF_sys_lfstats2','type':'factory','prior':'lnN','correlateAcrossYears':0},
  # ggH/VBF-specific Higgs+heavy-flavor variations (separate NPs per production mode)
  {'name':'weight_Higgs_plus_b_syst_ggH','weight_name':'weight_Higgs_plus_b_syst','proc_match':'ggh','title':'CMS_hgg_Higgs_plus_b_syst_ggH','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_Higgs_plus_c_syst_ggH','weight_name':'weight_Higgs_plus_c_syst','proc_match':'ggh','title':'CMS_hgg_Higgs_plus_c_syst_ggH','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_Higgs_plus_b_syst_vbf','weight_name':'weight_Higgs_plus_b_syst','proc_match':'vbf','title':'CMS_hgg_Higgs_plus_b_syst_vbf','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_Higgs_plus_c_syst_vbf','weight_name':'weight_Higgs_plus_c_syst','proc_match':'vbf','title':'CMS_hgg_Higgs_plus_c_syst_vbf','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_Higgs_plus_b_syst_VH','weight_name':'weight_Higgs_plus_b_syst','proc_match':'vh','title':'CMS_hgg_Higgs_plus_b_syst_vh','type':'factory','prior':'lnN','correlateAcrossYears':1},
  {'name':'weight_Higgs_plus_c_syst_VH','weight_name':'weight_Higgs_plus_c_syst','proc_match':'vh','title':'CMS_hgg_Higgs_plus_c_syst_vh','type':'factory','prior':'lnN','correlateAcrossYears':1},
])

# Shape nuisances: effect encoded in signal model
# mode = (other,scalesGlobal,scales,scalesCorr,smears,smearsCorr): match the definition in the signal models
signal_shape_systematics = [
                {'name':'ScaleEB','title':'ScaleEB','type':'signal_shape','mode':'scalesCorr','mean':'0.0','sigma':'2.0'},
                {'name':'ScaleEE','title':'ScaleEE','type':'signal_shape','mode':'scalesCorr','mean':'0.0','sigma':'2.0'},
                {'name':'Smearing','title':'Smearing','type':'signal_shape','mode':'smearsCorr','mean':'0.0','sigma':'1.0'},
                {'name':'Material','title':'Material','type':'signal_shape','mode':'scalesCorr','mean':'0.0','sigma':'1.0'},
                {'name':'FNUF','title':'FNUF','type':'signal_shape','mode':'scalesCorr','mean':'0.0','sigma':'1.0'}
]
