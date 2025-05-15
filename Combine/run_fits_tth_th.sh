source ../setup.sh

mkdir -p Models
mkdir -p Models/signal
mkdir -p Models/background

cp -v ../Signal/outdir_packaged/CMS-HGG*.root ./Models/signal/
cp -v ../Background/outdir_tth_th_analysis/CMS-HGG*.root ./Models/background/
cp -v ../Datacard/Datacard.txt .

python3 RunText2Workspace.py --mode mu --batch local

# rm -rv runFits_mu
python3 RunFits.py --inputJson inputs_statonly_tth_th.json --mode mu

python3 CollectFits.py --inputJson inputs_statonly_tth_th.json --mode mu


python3 ../Plots/make2DPlot.py \
  --inputTreeFile runFits_mu/profile2D_statonly_fixedMH_r_tHq_vs_r_ttH.root \
  --xparam   "r_tHq:-30.0,30.0" \
  --yparam   "r_ttH:-2.0,4.0" \
  --nPoints  200 \
  --nBins    200 \
  --interpolation linear \
  --doBestFit \
  --doSM \
  --ext      "_rscan"
