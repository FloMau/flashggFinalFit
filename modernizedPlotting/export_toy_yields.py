#!/usr/bin/env python3
"""
Export per-bin toy yields (for uncertainty bands) from toy ROOT files produced by FinalFit.

This mirrors the logic in flashggFinalFit's ROOT-based plotting, but only extracts the
numbers needed for ±1σ/±2σ bands. It requires PyROOT because toys are RooFit datasets.

Output: a pickled pandas DataFrame with columns:
  - <cat>_<ibin> for each category and bin (1..nBins)
  - sum_<ibin> for the sum over processed categories

Usage example:
  python3 export_toy_yields.py \
    --inputWSFile ../../CMSSW_14_1_0_pre4/src/flashggFinalFit/Combine/Datacard_r_2D.root \
    --cats all \
    --toysDir ../../CMSSW_14_1_0_pre4/src/flashggFinalFit/Plots/SplusBModelstth_th_analysis/toys \
    --nBins 80 \
    --blindingRegion 116,134 \
    --doToyVeto \
    --output SplusBModelstth_th_analysis/toyYields_CMS_hgg_mass.pkl
"""

import argparse
import glob
import os
import sys
import pickle
import ROOT
import pandas as pd

ROOT.gROOT.SetBatch(True)


def parse_args():
    ap = argparse.ArgumentParser(description="Export per-bin toy yields for bands")
    ap.add_argument("--inputWSFile", required=True, help="ROOT file with RooWorkspace 'w' (for xvar and categories)")
    ap.add_argument("--cats", default="all", help="Comma-separated categories or 'all'")
    ap.add_argument("--toysDir", required=True, help="Directory containing toy_*.root")
    ap.add_argument("--nBins", type=int, default=80)
    ap.add_argument("--blindingRegion", default="116,134")
    ap.add_argument("--xvar", default="CMS_hgg_mass")
    ap.add_argument("--doToyVeto", action="store_true")
    ap.add_argument("--output", required=True, help="Output pickle path for DataFrame")
    return ap.parse_args()


def main():
    opt = parse_args()

    # Load workspace for categories and variable definition
    fws = ROOT.TFile.Open(opt.inputWSFile)
    if not fws or fws.IsZombie():
        sys.exit(f"Cannot open {opt.inputWSFile}")
    w = fws.Get("w")
    if not w:
        sys.exit("Workspace 'w' not found")

    xvar = w.var(opt.xvar)
    if not xvar:
        sys.exit(f"Variable {opt.xvar} not found in workspace")
    xname = xvar.GetName()
    xvar_arglist = ROOT.RooArgList(xvar)

    chan = w.cat("CMS_channel")
    if not chan:
        sys.exit("Category 'CMS_channel' not found in workspace")

    # Categories
    all_cats = []
    for i in range(chan.numTypes()):
        chan.setIndex(i)
        all_cats.append(chan.getLabel())
    if opt.cats == "all":
        cats = all_cats
    else:
        req = [c.strip() for c in opt.cats.split(",") if c.strip()]
        cats = [c for c in req if c in all_cats]
        missing = set(req) - set(cats)
        if missing:
            print(f"[warn] requested categories not in workspace: {sorted(missing)}")

    # Columns
    columns = []
    for c in cats:
        for ib in range(1, opt.nBins + 1):
            columns.append(f"{c}_{ib}")
    for ib in range(1, opt.nBins + 1):
        columns.append(f"sum_{ib}")
    df = pd.DataFrame(columns=columns)

    toys = sorted(glob.glob(os.path.join(opt.toysDir, "toy_*.root")))
    if not toys:
        sys.exit(f"No toy_*.root found in {opt.toysDir}")

    # Blinding region (used only for selection, but toys are background-only model datasets; keep parity)
    br_low, br_high = [float(x) for x in opt.blindingRegion.split(",")]

    for tidx, toy_path in enumerate(toys, 1):
        ftoy = ROOT.TFile.Open(toy_path)
        if not ftoy or ftoy.IsZombie():
            print(f"[warn] cannot open {toy_path}")
            continue
        toy = ftoy.Get("toys/toy_asimov")
        if not toy:
            print(f"[warn] 'toys/toy_asimov' not found in {toy_path}")
            ftoy.Close()
            continue

        vetoToy = False
        values = {k: 0.0 for k in columns}

        for i in range(chan.numTypes()):
            chan.setIndex(i)
            c = chan.getLabel()
            if c not in cats:
                continue
            dtoy = toy.reduce(f"CMS_channel=={i}")
            htoy = xvar.createHistogram("h_tmp", ROOT.RooFit.Binning(opt.nBins, xvar.getMin(), xvar.getMax()))
            dtoy.fillHistogram(htoy, xvar_arglist)
            # Store values and apply optional veto based on first bin
            for ib in range(1, htoy.GetNbinsX() + 1):
                v = htoy.GetBinContent(ib)
                values[f"{c}_{ib}"] = v
                values[f"sum_{ib}"] += v
            if opt.doToyVeto:
                if htoy.GetBinContent(1) == 0:
                    vetoToy = True
            htoy.Delete()
            dtoy.Delete()

        toy.Delete()
        ftoy.Close()

        if not (opt.doToyVeto and vetoToy):
            df.loc[len(df)] = values
        else:
            print(f"[info] veto toy (first bin zero) in {toy_path}")

    # Save pickle
    os.makedirs(os.path.dirname(opt.output), exist_ok=True)
    with open(opt.output, "wb") as fd:
        pickle.dump(df, fd)
    print(f"Saved toy yields to {opt.output} with {len(df)} rows")


if __name__ == "__main__":
    main()

