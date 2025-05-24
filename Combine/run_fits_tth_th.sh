source ../setup.sh

rm -rv Models

mkdir -p Models
mkdir -p Models/signal
mkdir -p Models/background

cp -v ../Signal/outdir_packaged/CMS-HGG*.root ./Models/signal/
cp -v ../Background/outdir_tth_th_analysis/CMS-HGG*.root ./Models/background/
cp -v ../Datacard/Datacard.txt .


#####################################
### 2D scan in r_tHq and r_ttH
#####################################

python3 RunText2Workspace.py --mode r_2D --batch local
rm -rv runFits_r_2D
python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode r_2D

python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode r_2D

python3 ../Plots/make2DPlot.py \
  --inputTreeFile runFits_r_2D/profile2D_statonly_fixedMH_r_tHq_vs_r_ttH.root \
  --xparam   "r_tHq:-5.0,20.0" \
  --yparam   "r_ttH:-1.0,3.0" \
  --nPoints  1000 \
  --nBins    200 \
  --interpolation linear \
  --doBestFit \
  --doSM \
  --ext      "_rscan"



#####################################
### 1D scan in r_tHq
#####################################

# ttH fixed
python3 RunText2Workspace.py --mode r_tHq_1D --batch local

# rm -rv runFits_r_tHq_1D
python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode r_tHq_1D
python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode r_tHq_1D

# ttH profiled
python3 RunText2Workspace.py --mode r_tHq_1D_ttH_profiled --batch local

# rm -rv runFits_r_tHq_1D_ttH_profiled
python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode r_tHq_1D_ttH_profiled
python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode r_tHq_1D_ttH_profiled


#####################################
### 1D scan in r_ttH
#####################################

# ttH fixed
python3 RunText2Workspace.py --mode r_ttH_1D --batch local

# rm -rv runFits_r_ttH_1D
python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode r_ttH_1D
python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode r_ttH_1D

# ttH profiled
python3 RunText2Workspace.py --mode r_ttH_1D_tHq_profiled --batch local

# rm -rv runFits_r_ttH_1D_tHq_profiled
python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode r_ttH_1D_tHq_profiled
python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode r_ttH_1D_tHq_profiled


#####################################
### Significance for ttH
#####################################

python3 RunText2Workspace.py --mode Z_ttH --batch local

combine -M Significance ./Datacard_Z_ttH.root --rMin 0 --rMax 5 \
    -t -1 --setParameters r_ttH=1,MH=125.38 --freezeParameters MH

#####################################
### Significance and limit for tHq
#####################################

python3 RunText2Workspace.py --mode Z_tHq --batch local

combine -M Significance ./Datacard_Z_tHq.root --rMin 0 --rMax 25\
    -t -1 --setParameters r_tHq=1,MH=125.38 --freezeParameters MH

# combine -M AsymptoticLimits Datacard_Z_tHq.root --rMin 0 --rMax 25\
#     -t -1 --setParameters MH=125.38 --freezeParameters MH -v 5


#####################################
### Upper limit tries for tHq
#####################################

# python3 RunText2Workspace.py --mode limit_tHq --batch local

# rm -rv runFits_limit_tHq
# python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode limit_tHq
# python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode limit_tHq


# python3 RunText2Workspace.py --mode limit_tHq_HybridNew --batch local

# combine -M HybridNew Datacard_limit_tHq_HybridNew.root \
#         --rMin 0 --rMax 25 \
#         -t -1 \
#         --setParameters r_tHq=1,MH=125.38 \
#         --freezeParameters MH \
#         --testStat=ProfileLikelihood \
#         --saveHybridResult \
#         --singlePoint 1 \
#         -T 100

# python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode limit_tHq

# combine --run expected -t -1 --redefineSignalPOI r_tHq --setParameters MH=125.38 --freezeParameters MH,allConstrainedNuisances,discreteParams --cminDefaultMinimizerStrategy 0 --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2 -M AsymptoticLimits -m 125.38 -d /.automount/net_rw/net__data_cms3a-1/mausolf/CMSSW_14_1_0_pre4/src/flashggFinalFit/Combine/Datacard_limit_tHq.root --setParameterRanges r_tHq=0,25 -n _AsymptoticLimit_statonly_fixedMH_r_tHq -v 1000 --cminRunAllDiscreteCombinations
# python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode limit_tHq


# example from the docs (with your POI and MH)
# combine -M AsymptoticLimits Datacard_limit_tHq.root \
#   --run expected \
#   -t -1 \
#   --rMin 0 --rMax 25 \
#   --setParameters MH=125.38 \
#   --freezeParameters MH \
#   --noFitAsimov \
#   --cminDefaultMinimizerStrategy 0 \
#   --cminRunAllDiscreteCombinations \
#   -v 5 \
#   -n tHq_limit \
#   --optimizeSimPdf 0 \
#   > log.txt

