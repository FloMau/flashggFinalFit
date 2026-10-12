# Script to make toys from inputWS: to be used for making bands in S+B model plot

import os, sys
import re
from optparse import OptionParser
import ROOT
import glob

def get_options():
  parser = OptionParser()
  parser.add_option("--inputWSFile", dest="inputWSFile", default=None, help="Input RooWorkspace file. If loading snapshot then use a post-fit workspace where the option --saveWorkspace was set")
  parser.add_option("--loadSnapshot", dest="loadSnapshot", default=None, help="Load best-fit snapshot name")
  parser.add_option("--ext", dest="ext", default='', help="Extension for saving")
  parser.add_option("--nToys", dest="nToys", default=500, type='int', help="Number of toys")
  parser.add_option("--POIs", dest="POIs", default="r", help="Parameters of interest in fit")
  parser.add_option("--batch", dest="batch", default="condor", help="Batch system [IC,condor]")
  parser.add_option("--queue", dest="queue", default="espresso", help="Change condor queue")
  parser.add_option("--mass", dest="mass", default=None, type='float', help="Override Higgs mass (MH) used by combine and freeze it during toy fit/throw")
  parser.add_option("--toysDir", dest="toysDir", default=None, help="Override toy output directory (default: ./SplusBModels<ext>/toys)")
  parser.add_option('--freezePdfIndices', dest='freezePdfIndices', default=False, action='store_true', help='Freeze discrete pdf index parameters during toy fit/throw')
  parser.add_option('--pdfIndexRegex', dest='pdfIndexRegex', default='pdfindex', help='Regex/substring to select pdf index parameters (default: pdfindex)')
  parser.add_option('--dryRun',dest='dryRun', default=False, action="store_true", help='Dry run')
  return parser.parse_args()
(opt,args) = get_options()

toys_dir = opt.toysDir or "./SplusBModels%s/toys" % opt.ext
toys_dir = os.path.abspath(toys_dir)
jobs_dir = os.path.join(toys_dir, "jobs")

# Create jobs directory
if not os.path.isdir(toys_dir):
  os.system("mkdir -p %s" % toys_dir)
if not os.path.isdir(jobs_dir):
  os.system("mkdir -p %s" % jobs_dir)

# Delete all old jobs
for job in glob.glob(os.path.join(jobs_dir, "sub*.sh")): os.system("rm %s"%job)

# Open workspace and extract best fit mass and signal strength
inputWSFile = "%s/%s"%(os.environ['PWD'],opt.inputWSFile)
f = ROOT.TFile(inputWSFile)
w = f.Get("w")
if opt.loadSnapshot is not None: w.loadSnapshot(opt.loadSnapshot)
poi_bf = {}
for poi in opt.POIs.split(","): poi_bf[poi] = w.var(poi).getVal()
setParamStr = "--setParameters "
setParam0Str = "--setParameters "
for p,v in poi_bf.items(): 
  setParamStr += "%s=%.3f,"%(p,v)
  setParam0Str += "%s=0,"%p
setParamStr = setParamStr[:-1]
setParam0Str = setParam0Str[:-1]
mh_bf = w.var("MH").getVal()
if opt.mass is not None:
  mh_bf = float(opt.mass)

# Append MH to the existing --setParameters strings (keeps single flag instance)
setParamStr += ",MH=%.3f" % mh_bf
setParam0Str += ",MH=%.3f" % mh_bf

# Collect optional pdf index names to freeze (by regex) if requested
extra_freeze = ""
if opt.freezePdfIndices:
  import re as _re
  names = []
  # Look through categories (discrete) and variables
  cats = w.allCats(); it = cats.fwdIterator(); obj = it.next()
  while obj:
    name = obj.GetName()
    if _re.search(opt.pdfIndexRegex, name, _re.IGNORECASE):
      names.append(name)
    obj = it.next()
  vars_ = w.allVars(); it2 = vars_.fwdIterator(); obj2 = it2.next()
  while obj2:
    name = obj2.GetName()
    if _re.search(opt.pdfIndexRegex, name, _re.IGNORECASE) and name not in names:
      names.append(name)
    obj2 = it2.next()
  if len(names) > 0:
    extra_freeze = "," + ",".join(names)
  else:
    print("[warn] --freezePdfIndices requested, but no indices matched '%s'" % opt.pdfIndexRegex)

if opt.batch == 'IC':
  # Create submission file
  for itoy in range(0,opt.nToys):
    fsub = open(os.path.join(jobs_dir, "sub_toy_%g.sh"%itoy),'w')
    fsub.write("#!/bin/bash\n\n")
    fsub.write("cd %s\n\n"%(toys_dir))
    fsub.write("eval `scramv1 runtime -sh`\n\n")
    # Generate command
    fsub.write("#Generate command\n")
    #gen_cmd = "combine %s -m %.3f -M GenerateOnly --saveWorkspace --toysFrequentist --bypassFrequentistFit -t 1 --setParameters %s=%.3f -s -1 -n _%g_gen_step"%(inputWSFile,mh_bf,opt.POI,poi_bf,itoy)
    gen_cmd = "combine %s -m %.3f -M GenerateOnly --saveWorkspace --toysFrequentist --bypassFrequentistFit -t 1 %s -s -1 -n _%g_gen_step"%(inputWSFile,mh_bf,setParamStr,itoy)
    if opt.loadSnapshot is not None: gen_cmd += " --snapshotName %s"%opt.loadSnapshot
    fsub.write("%s\n\n"%gen_cmd)
    # Fit cmd
    fsub.write("#Fit command\n")
    fsub.write("mv higgsCombine_%g_gen_step*.root gen_%g.root\n"%(itoy,itoy))
    #fit_cmd = "combine gen_%g.root -m %.3f -M MultiDimFit --floatOtherPOIs=1 --saveWorkspace --toysFrequentist --bypassFrequentistFit -t 1 --setParameters %s=%.3f -s -1 -n _%g_fit_step --cminDefaultMinimizerStrategy 0 --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2"%(itoy,mh_bf,opt.POI,poi_bf,itoy)
    fit_cmd = "combine gen_%g.root -m %.3f -M MultiDimFit -P %s --floatOtherPOIs=1 --saveWorkspace --toysFrequentist --bypassFrequentistFit -t 1 %s --freezeParameters MH%s -s -1 -n _%g_fit_step --cminDefaultMinimizerStrategy 0 --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2"%(itoy,mh_bf,opt.POIs.split(",")[0],setParamStr,extra_freeze,itoy)
    fsub.write("%s\n\n"%fit_cmd)
    # Throw cmd
    fsub.write("#Throw command\n")
    fsub.write("mv higgsCombine_%g_fit_step*.root fit_%g.root\n"%(itoy,itoy))
    throw_cmd = "combine fit_%g.root -m %.3f --snapshotName MultiDimFit -M GenerateOnly --saveToys --toysFrequentist --bypassFrequentistFit -t -1 -n _%g_throw_step %s --freezeParameters MH%s"%(itoy,mh_bf,itoy,setParam0Str,extra_freeze)
    fsub.write("%s\n\n"%throw_cmd)
    # Clean up
    fsub.write("mv higgsCombine_%g_throw_step*.root toy_%g.root\n"%(itoy,itoy))
    fsub.write("rm gen_%g.root fit_%g.root\n"%(itoy,itoy))
    fsub.close()

  # Change permission of all files and set running on batch
  os.system("chmod 775 %s/sub*.sh"%jobs_dir)
  if not opt.dryRun:
    subs = glob.glob("%s/sub*"%jobs_dir)
    for fsub in subs: os.system("qsub -q hep.q -l h_rt=4:0:0 -l h_vmem=24G %s"%fsub)
  else: print(" --> [DRY-RUN] jobs have not been submitted")

elif opt.batch == 'condor':

  # Create submission file
  fsub = open(os.path.join(jobs_dir, "sub_toys.sh"),'w')
  fsub.write("#!/bin/bash\n")
  fsub.write("ulimit -s unlimited\n")
  fsub.write("set -e\n")
  # fsub.write("cd %s/src/flashggFinalFit/Plots/SplusBModels%s/toys\n"%(os.environ['CMSSW_BASE'],opt.ext))
  fsub.write("cd %s/src\n"%os.environ['CMSSW_BASE'])
  fsub.write("export SCRAM_ARCH=%s\n"%os.environ['SCRAM_ARCH'])
  fsub.write("source /cvmfs/cms.cern.ch/cmsset_default.sh\n")
  fsub.write("eval `scramv1 runtime -sh`\n")
  fsub.write("cd %s\n\n"%(toys_dir))
  fsub.write("itoy=$1\n\n")
  # Generate command
  fsub.write("#Generate command\n")
  gen_cmd = "combine %s -m %.3f -M GenerateOnly --saveWorkspace --toysFrequentist --bypassFrequentistFit -t 1 %s -s -1 -n _${itoy}_gen_step"%(inputWSFile,mh_bf,setParamStr)
  if opt.loadSnapshot is not None: gen_cmd += " --snapshotName %s"%opt.loadSnapshot
  fsub.write("%s\n\n"%gen_cmd)
  # Fit cmd
  fsub.write("#Fit command\n")
  fsub.write("gen_file=$(ls -1t higgsCombine_${itoy}_gen_step*.root 2>/dev/null | head -n1)\n")
  fsub.write("if [[ -z \"${gen_file}\" ]]; then echo \"[ERROR] Missing gen_step output for itoy=${itoy}\" >&2; exit 1; fi\n")
  fsub.write("mv \"${gen_file}\" gen_${itoy}.root\n")
  fit_cmd = "combine gen_${itoy}.root -m %.3f -M MultiDimFit -P %s --floatOtherPOIs=1 --saveWorkspace --toysFrequentist --bypassFrequentistFit -t 1 %s --freezeParameters MH%s -s -1 -n _${itoy}_fit_step --cminDefaultMinimizerStrategy 0 --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2"%(mh_bf,opt.POIs.split(",")[0],setParamStr,extra_freeze)
  fsub.write("%s\n\n"%fit_cmd)
  # Throw cmd
  fsub.write("#Throw command\n")
  fsub.write("fit_file=$(ls -1t higgsCombine_${itoy}_fit_step*.root 2>/dev/null | head -n1)\n")
  fsub.write("if [[ -z \"${fit_file}\" ]]; then echo \"[ERROR] Missing fit_step output for itoy=${itoy}\" >&2; exit 1; fi\n")
  fsub.write("mv \"${fit_file}\" fit_${itoy}.root\n")
  throw_cmd = "combine fit_${itoy}.root -m %.3f --snapshotName MultiDimFit -M GenerateOnly --saveToys --toysFrequentist --bypassFrequentistFit -t -1 -n _${itoy}_throw_step %s --freezeParameters MH%s"%(mh_bf,setParam0Str,extra_freeze)
  fsub.write("%s\n\n"%throw_cmd)
  # Clean up
  fsub.write("toy_file=$(ls -1t higgsCombine_${itoy}_throw_step*.root 2>/dev/null | head -n1)\n")
  fsub.write("if [[ -z \"${toy_file}\" ]]; then echo \"[ERROR] Missing throw_step output for itoy=${itoy}\" >&2; exit 1; fi\n")
  fsub.write("mv \"${toy_file}\" toy_${itoy}.root\n")
  fsub.write("rm gen_${itoy}.root fit_${itoy}.root\n")
  fsub.close()

  # Write condor submission file
  fcondor = open(os.path.join(jobs_dir, "sub_toys.sub"),'w')
  fcondor.write("executable = sub_toys.sh\n")
  fcondor.write("arguments = $(ProcId)\n")
  fcondor.write("output                = sub_toys.$(ClusterId).$(ProcId).out\n")
  fcondor.write("error                 = sub_toys.$(ClusterId).$(ProcId).err\n")
  fcondor.write("log                   = sub_toys.$(ClusterId).log\n\n")
  fcondor.write("on_exit_hold = (ExitBySignal == True) || (ExitCode != 0)\n")
  fcondor.write("periodic_release =  (NumJobStarts < 3) && ((CurrentTime - EnteredCurrentStatus) > 600)\n\n")
  fcondor.write("+JobFlavour = \"%s\"\n"%opt.queue)
  fcondor.write("queue %s"%opt.nToys)
  fcondor.close()

  # Submission
  os.system("chmod 775 %s/sub_toys.sh"%jobs_dir)
  # if not opt.dryRun: os.system("cd ./SplusBModels%s/toys/jobs; source /cvmfs/cms.cern.ch/cmsset_default.sh; eval `scramv1 runtime -sh`; condor_submit sub_toys.sub; cd ../../.."%opt.ext)
  if not opt.dryRun: 
    if os.path.realpath(os.environ['PWD']).startswith("/eos"):
      os.system("cd %s; condor_submit -spool sub_toys.sub; cd - >/dev/null"%jobs_dir)
    else:
      os.system("cd %s; condor_submit sub_toys.sub; cd - >/dev/null"%jobs_dir)
  else: print(" --> [DRY-RUN] jobs have not been submitted")
