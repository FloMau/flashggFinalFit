import ROOT
import os
import sys
import json
import re
import numpy as np
import pandas
import pickle
from collections import OrderedDict as od

# Ensure commonTools is importable when running standalone.
_this_dir = os.path.dirname(os.path.abspath(__file__))
_flashgg_dir = os.path.abspath(os.path.join(_this_dir, "..", ".."))
_common_tools_dir = os.path.join(_flashgg_dir, "commonTools")
if _common_tools_dir not in sys.path:
  sys.path.insert(0, _common_tools_dir)

from commonObjects import *
from commonTools import *

XSBRMap = od()

# ttH/tH analysis maps are maintained in Signal/tools/XSBRMap.py only.
# Datacard uses that map below via _load_signal_xsbr_map().

# Use Signal/tools/XSBRMap.py as the single source of truth for XS*BR maps.
def _load_signal_xsbr_map():
  this_dir = os.path.dirname(os.path.abspath(__file__))
  flashgg_dir = os.path.abspath(os.path.join(this_dir, "..", ".."))
  signal_tools_dir = os.path.join(flashgg_dir, "Signal", "tools")
  common_tools_dir = os.path.join(flashgg_dir, "commonTools")
  for p in (signal_tools_dir, common_tools_dir):
    if p not in sys.path:
      sys.path.insert(0, p)
  try:
    from XSBRMap import globalXSBRMap as signal_xsbr_map
  except Exception as exc:
    raise RuntimeError(
      "Failed to import Signal/tools/XSBRMap.py. "
      "Please check PYTHONPATH/CMSSW env. Original error: %s" % exc
    )
  return signal_xsbr_map

XSBRMap = _load_signal_xsbr_map()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Functions for loading XS*BR below
# Importing modules from combine
from HiggsAnalysis.CombinedLimit.DatacardParser import *
from HiggsAnalysis.CombinedLimit.ModelTools import *
from HiggsAnalysis.CombinedLimit.PhysicsModel import *
from HiggsAnalysis.CombinedLimit.SMHiggsBuilder import *
import HiggsAnalysis.CombinedLimit.PhysicsModel as models
class dummy_options:
  def __init__(self):
    self.physModel = "HiggsAnalysis.CombinedLimit.PhysicsModel:floatingHiggsMass"
    self.physOpt = ["higgsMassRange=90,250"]
    self.bin = True
    self.fileName = "dummy.root"
    self.cexpr = False
    self.out = "wsdefault"
    self.verbose = 0
    self.mass = 125
    self.funcXSext = "dummy"

# Functions to get XS/BR
def getXS(_SM,_MHVar,_mh,_pm):
  _MHVar.setVal(_mh)
  return _SM.modelBuilder.out.function("SM_XS_%s_%s"%(_pm,sqrts__)).getVal()
def getBR(_SM,_MHVar,_mh,_dm):
  _MHVar.setVal(_mh)
  return _SM.modelBuilder.out.function("SM_BR_%s"%_dm).getVal()

# Function to initialise XS values from combine
def initialiseXSBR(mass='125'):
  options=dummy_options()
  DC = Datacard()
  MB = ModelBuilder(DC, options)
  physics = models.floatingHiggsMass
  physics.setPhysicsOptions(options.physOpt)
  MB.setPhysics(physics)
  MB.physics.doParametersOfInterest()
  SM = SMHiggsBuilder(MB)
  MHVar = SM.modelBuilder.out.var("MH")

  # Make XS and BR
  SM.makeBR(decayMode)
  for pm in productionModes: SM.makeXS(pm,sqrts__)

  # Store values for each production mode in ordered dict
  xsbr = od()
  for pm in productionModes: xsbr[pm] = getXS(SM,MHVar,float(mass),pm)
  xsbr['constant'] = 1.
  xsbr[decayMode] = getBR(SM,MHVar,float(mass),decayMode)
  # If ggZH and ZH in production modes then make qqZH numpy array
  if('ggZH' in productionModes)&('ZH' in productionModes): xsbr['qqZH'] = xsbr['ZH']-xsbr['ggZH']
  return xsbr

def extractXSBR(d,mass='125',analysis='STXS'):
  # Import cross sections and branching ratios from combine
  xsbr = initialiseXSBR(mass)
  # Allow syst-tagged analyses to reuse the base XSBR map
  if analysis not in XSBRMap and analysis.endswith("_syst"):
    base_analysis = analysis[:-5]
    if base_analysis in XSBRMap:
      analysis = base_analysis
  # Define map of procs to XS,BR
  XSBR_for_analysis = od()

  def _infer_missing_cfg(_proc, _analysis):
    """
    Fallback for new coupling labels not explicitly listed in XSBRMap.
    For fiducial analyses we intentionally use SM rates for ttH/tH variants.
    """
    if "fiducial" not in _analysis:
      return None
    sm_map = XSBRMap['tth_th_analysis']
    p = _proc.lower()
    if p.startswith("tth"):
      return {'mode': 'constant', 'factor': sm_map['TTH']['factor']}
    if p.startswith("thw"):
      return {'mode': 'constant', 'factor': sm_map['tHW']['factor']}
    if p.startswith("thqlep"):
      return {'mode': 'constant', 'factor': sm_map['tHqLep']['factor']}
    if p.startswith("thqhad"):
      return {'mode': 'constant', 'factor': sm_map['tHqHad']['factor']}
    if p.startswith("ggh"):
      return {'mode': 'constant', 'factor': sm_map['GG2H']['factor']}
    if p.startswith("vbf"):
      return {'mode': 'constant', 'factor': sm_map['VBF']['factor']}
    if p.startswith("vh"):
      return {'mode': 'constant', 'factor': sm_map['VH']['factor']}
    if p.startswith("bbh"):
      return {'mode': 'constant', 'factor': sm_map['bbh']['factor']}
    return None

  # XS
  for proc in d[d['type']=='sig']['procOriginal'].unique():
    proc_cfg = XSBRMap[analysis].get(proc)
    if proc_cfg is None:
      proc_cfg = _infer_missing_cfg(proc, analysis)
      if proc_cfg is None:
        raise KeyError(
          "Process '%s' missing in XSBRMap[%s]. "
          "Add it to datacardTools/XSBR.py or provide an inference rule." % (proc, analysis)
        )
      print("[WARN] XSBR fallback for %s in %s -> mode=%s, factor=%s" % (proc, analysis, proc_cfg['mode'], proc_cfg.get('factor', 1.)))
    fp = proc_cfg['factor'] if 'factor' in proc_cfg else 1.
    mode = proc_cfg['mode']
    xs = fp*xsbr[mode]
    XSBR_for_analysis['XS_%s'%proc] = xs
  # BR
  fd = XSBRMap[analysis]['decay']['factor'] if 'factor' in XSBRMap[analysis]['decay'] else 1.
  mode = XSBRMap[analysis]['decay']['mode']
  br = fd*xsbr[mode]
  XSBR_for_analysis['BR'] = br
  return XSBR_for_analysis
