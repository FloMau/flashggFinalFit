source ../setup.sh
cmsenv

rm -rv ./outdir_tth_th_analysis
python3 RunBackgroundScripts.py --inputConfig config_FM.py --mode fTestParallel