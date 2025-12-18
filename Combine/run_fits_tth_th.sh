source ../setup.sh

#####################################
### comment in what you want to run
#####################################

# rm -rv Models

# mkdir -p Models
# mkdir -p Models/signal
# mkdir -p Models/background

# cp -v ../Signal/outdir_packaged/CMS-HGG*.root ./Models/signal/
# cp -v ../Background/outdir_tth_th_analysis/CMS-HGG*.root ./Models/background/
cp -v ../Datacard/Datacard_tth_th_analysis.txt ./Datacard.txt


#####################################
### 2D scan in r_tHq and r_ttH
#####################################

# python3 RunText2Workspace.py --mode r_2D --batch local
# rm -rv runFits_r_2D
# python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode r_2D

# python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode r_2D

# python3 ../Plots/make2DPlot.py \
#   --inputTreeFile runFits_r_2D/profile2D_statonly_fixedMH_r_tHq_vs_r_ttH.root \
#   --xparam   "r_tHq:-5.0,20.0" \
#   --yparam   "r_ttH:-1.0,3.0" \
#   --nPoints  1000 \
#   --nBins    200 \
#   --interpolation linear \
#   --doBestFit \
#   --doSM \
#   --ext      "_rscan"



#####################################
### 1D scan in r_tHq
#####################################

# ttH fixed
# python3 RunText2Workspace.py --mode r_tHq_1D --batch local

# # rm -rv runFits_r_tHq_1D
# python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode r_tHq_1D
# python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode r_tHq_1D

# # ttH profiled
# python3 RunText2Workspace.py --mode r_tHq_1D_ttH_profiled --batch local

# # rm -rv runFits_r_tHq_1D_ttH_profiled
# python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode r_tHq_1D_ttH_profiled
# python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode r_tHq_1D_ttH_profiled


#####################################
### 1D scan in r_ttH
#####################################

# tHq fixed
# python3 RunText2Workspace.py --mode r_ttH_1D --batch local

# # rm -rv runFits_r_ttH_1D
# python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode r_ttH_1D
# python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode r_ttH_1D

# tHq profiled
# python3 RunText2Workspace.py --mode r_ttH_1D_tHq_profiled --batch local

# # rm -rv runFits_r_ttH_1D_tHq_profiled
# python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode r_ttH_1D_tHq_profiled
# python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode r_ttH_1D_tHq_profiled


#####################################
### Significance for ttH
#####################################

# python3 RunText2Workspace.py --mode Z_ttH --batch local

# combine -M Significance ./Datacard_Z_ttH.root --rMin 0 --rMax 5 -t -1 --setParameters r_ttH=1,MH=125.38 --freezeParameters MH

####################################
### Significance and limit for tHq
####################################

# python3 RunText2Workspace.py --mode Z_tHq --batch local

# combine -M Significance ./Datacard_Z_tHq.root --rMin 0 --rMax 25 -t -1 --setParameters r_tHq=1,MH=125.38 --freezeParameters MH

# combine -M AsymptoticLimits Datacard_Z_tHq.root --run expected --rMin 0 --rMax 25 -t -1 --setParameters MH=125.38 --freezeParameters MH # -v 3

##########################################################
### for comparison with analyses where tHW is part of tH
##########################################################

# ttH fixed
# python3 RunText2Workspace.py --mode r_tHq_plus_tHW_1D --batch local

# # rm -rv runFits_r_tHq_1D
# python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode r_tHq_plus_tHW_1D 
# python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode r_tHq_plus_tHW_1D 

# # ttH profiled
# python3 RunText2Workspace.py --mode r_tHq_plus_tHW_1D_ttH_profiled --batch local

# # rm -rv runFits_r_tHq_1D_ttH_profiled
# python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode r_tHq_plus_tHW_1D_ttH_profiled
# python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode r_tHq_plus_tHW_1D_ttH_profiled


# python3 RunText2Workspace.py --mode Z_tHq_plus_tHW --batch local

# combine -M Significance ./Datacard_Z_tHq_plus_tHW.root --rMin 0 --rMax 25 -t -1 --setParameters r_tH=1,MH=125.38 --freezeParameters MH

# combine -M AsymptoticLimits Datacard_Z_tHq_plus_tHW.root --run expected --rMin 0 --rMax 25 -t -1 --setParameters MH=125.38 --freezeParameters MH # -v 3
