#!/usr/bin/env python3
"""
Export TH1 shapes (data, bkg, sig[, sig_top, sig_thq, sig_res]) per category from a RooWorkspace.

Why: mplhep/uproot can’t evaluate RooFit PDFs from a RooWorkspace, so we export histograms once
with PyROOT and then plot purely in Python without ROOT dependencies.

The exported ROOT file will contain, for each category <cat>:
  - data_<cat>  : TH1 with data (blinded outside region if --unblind not set)
  - bkg_<cat>   : TH1 with background-only expectation (nBins binning)
  - sig_<cat>   : TH1 with signal-only expectation (nBins binning)
  - Optional (with --splitResonant): sig_top_<cat>, sig_thq_<cat>, sig_res_<cat>

Usage example:
  python3 export_workspace_shapes.py \
    --inputWSFile CMSSW_14_1_0_pre4/src/flashggFinalFit/Combine/Datacard_r_2D.root \
    --cats all \
    --blindingRegion 116,134 \
    --nBins 80 --pdfNBins 3200 \
    --splitResonant --topPOIs r_ttH --thqPOIs r_tHq \
    --output shapes_for_plot.root
"""

import argparse
import os
import sys
import ROOT

ROOT.gROOT.SetBatch(True)


def parse_args():
    ap = argparse.ArgumentParser(description="Export TH1 shapes from RooWorkspace")
    ap.add_argument("--inputWSFile", required=True, help="ROOT file with RooWorkspace 'w'")
    ap.add_argument("--loadSnapshot", default=None, help="Snapshot name to load (post-fit)")
    ap.add_argument("--mass", type=float, default=None, help="Override Higgs mass MH for export")
    ap.add_argument("--cats", default="all", help="Comma-separated categories or 'all'")
    ap.add_argument("--xvar", default="CMS_hgg_mass,m_{#gamma#gamma},GeV", help="name,title,units")
    ap.add_argument("--nBins", type=int, default=80)
    ap.add_argument("--pdfNBins", type=int, default=3200)
    ap.add_argument("--blindingRegion", default="116,134")
    ap.add_argument("--unblind", action="store_true")
    ap.add_argument("--doBkgRenormalization", action="store_true")
    ap.add_argument("--splitResonant", action="store_true")
    ap.add_argument("--topPOIs", default="r_ttH")
    ap.add_argument("--thqPOIs", default="r_tHq")
    ap.add_argument("--output", required=True, help="Output ROOT file with TH1s")
    return ap.parse_args()


def main():
    opt = parse_args()

    f_in = ROOT.TFile.Open(opt.inputWSFile)
    if not f_in or f_in.IsZombie():
        sys.exit(f"Cannot open {opt.inputWSFile}")
    w = f_in.Get("w")
    if not w:
        sys.exit("Workspace 'w' not found in input file")

    if opt.loadSnapshot:
        w.loadSnapshot(opt.loadSnapshot)

    # Optionally enforce MH value to align with toys
    if opt.mass is not None:
        mh = w.var("MH")
        if mh:
            mh.setVal(float(opt.mass))

    xname, xtitle, xunits = opt.xvar.split(",")
    xvar = w.var(xname)
    if not xvar:
        sys.exit(f"Variable {xname} not found in workspace")
    xvar.SetTitle(xtitle)
    xvar.setPlotLabel(xtitle)
    xvar.setUnit(xunits)
    xvar_arglist, xvar_argset = ROOT.RooArgList(xvar), ROOT.RooArgSet(xvar)

    weight = ROOT.RooRealVar("weight", "weight", 0)
    wxvar_arglist, wxvar_argset = ROOT.RooArgList(xvar, weight), ROOT.RooArgSet(xvar, weight)

    chan = w.cat("CMS_channel")
    if not chan:
        sys.exit("Category 'CMS_channel' not found in workspace")

    # Models
    sb_model = w.pdf("model_s")
    b_model = w.pdf("model_b")
    if not sb_model or not b_model:
        sys.exit("model_s or model_b not found in workspace")

    # Data
    d_obs = w.data("data_obs")
    if not d_obs:
        sys.exit("RooDataSet 'data_obs' not found")

    # Blinding region
    br_low, br_high = [float(x) for x in opt.blindingRegion.split(",")]

    # Categories
    all_cats = []
    for i in range(chan.numTypes()):
        chan.setIndex(i)
        all_cats.append(chan.getLabel())
    if opt.cats == "all":
        cats = all_cats
    else:
        cats = [c.strip() for c in opt.cats.split(",") if c.strip() in all_cats]
        missing = set(c.strip() for c in opt.cats.split(",") if c.strip()) - set(cats)
        if missing:
            print(f"[warn] Requested categories not found in workspace: {sorted(missing)}")

    # Output
    f_out = ROOT.TFile(opt.output, "RECREATE")

    for c in cats:
        print(f"Exporting category: {c}")
        chan.setLabel(c)
        cidx = chan.getIndex()

        # Data TH1 (nBins) with optional blinding
        h_data = xvar.createHistogram(f"data_{c}", ROOT.RooFit.Binning(opt.nBins, xvar.getMin(), xvar.getMax()))
        h_data.Sumw2()
        # Ensure a clean name without the RooFit suffix like '__CMS_hgg_mass'
        h_data.SetName(f"data_{c}")
        # Reduce dataset to this category only
        d_cat = d_obs.reduce(f"CMS_channel=={cidx}")
        if opt.unblind:
            d_cat.fillHistogram(h_data, xvar_arglist)
        else:
            sel = f"{xname}<{br_low}||{xname}>{br_high}"
            d_cat.reduce(sel).fillHistogram(h_data, xvar_arglist)

        # Background and S+B PDF histograms (nBins and pdfNBins)
        sbpdf = sb_model.getPdf(c)
        bpdf = b_model.getPdf(c)
        h_sb_n = sbpdf.createHistogram(f"h_sb_nBins_{c}", xvar, ROOT.RooFit.Binning(opt.nBins, xvar.getMin(), xvar.getMax()))
        h_b_n = bpdf.createHistogram(f"h_b_nBins_{c}", xvar, ROOT.RooFit.Binning(opt.nBins, xvar.getMin(), xvar.getMax()))
        h_sb_p = sbpdf.createHistogram(f"h_sb_pdfNBins_{c}", xvar, ROOT.RooFit.Binning(opt.pdfNBins, xvar.getMin(), xvar.getMax()))
        h_b_p = bpdf.createHistogram(f"h_b_pdfNBins_{c}", xvar, ROOT.RooFit.Binning(opt.pdfNBins, xvar.getMin(), xvar.getMax()))

        # Optional renormalization
        if opt.doBkgRenormalization:
            SB = sbpdf.expectedEvents(xvar_argset)
            B = bpdf.expectedEvents(xvar_argset)
            S = SB - B
            Bcorr = B - S
            SBcorr = B
            nf_B = Bcorr / B if B else 1.0
            nf_SB = SBcorr / SB if SB else 1.0
            for h in (h_b_n, h_b_p):
                h.Scale(nf_B)
            for h in (h_sb_n, h_sb_p):
                h.Scale(nf_SB)

        # Signal-only TH1 (nBins) from the current snapshot
        # Note: if the snapshot is B-only (POIs at 0), this corresponds to the resonant-only signal
        h_sig_n = h_sb_n.Clone(f"sig_{c}")
        h_sig_n.Add(h_b_n, -1.0)

        # Write base shapes
        f_out.cd()
        h_data.Write()
        h_b_n.SetName(f"bkg_{c}")
        h_b_n.Write()
        h_sig_n.Write()

        # Split components: resonant (ggH+VBF+VH+bbH), top (ttH+tHW), thq
        if opt.splitResonant:
            # Collect POIs
            top_pois = [p for p in opt.topPOIs.split(",") if p]
            thq_pois = [p for p in opt.thqPOIs.split(",") if p]

            def _save(pois):
                vals = {}
                for pn in pois:
                    v = w.var(pn)
                    if v:
                        vals[pn] = v.getVal()
                    else:
                        print(f"[warn] POI {pn} not found in workspace")
                return vals

            def _set_const(pois, value):
                for pn in pois:
                    v = w.var(pn)
                    if v:
                        v.setVal(float(value))

            saved_top = _save(top_pois)
            saved_thq = _save(thq_pois)

            # Build resonant with (top=0, thq=0)
            _set_const(top_pois, 0.0)
            _set_const(thq_pois, 0.0)
            h_sb_res_n = sbpdf.createHistogram(f"h_sb_res_nBins_{c}", xvar, ROOT.RooFit.Binning(opt.nBins, xvar.getMin(), xvar.getMax()))
            if opt.doBkgRenormalization and h_sb_res_n.Integral() > 0:
                h_sb_res_n.Scale(h_sb_n.Integral() / h_sb_res_n.Integral())
            h_sig_res = h_sb_res_n.Clone(f"sig_res_{c}")
            h_sig_res.Add(h_b_n, -1.0)

            # Build top with (top=1, thq=0)
            _set_const(top_pois, 1.0)
            _set_const(thq_pois, 0.0)
            h_sb_top_n = sbpdf.createHistogram(f"h_sb_top_nBins_{c}", xvar, ROOT.RooFit.Binning(opt.nBins, xvar.getMin(), xvar.getMax()))
            if opt.doBkgRenormalization and h_sb_top_n.Integral() > 0:
                h_sb_top_n.Scale(h_sb_n.Integral() / h_sb_top_n.Integral())
            h_sig_top = h_sb_top_n.Clone(f"sig_top_{c}")
            h_sig_top.Add(h_b_n, -1.0)
            h_sig_top.Add(h_sig_res, -1.0)  # remove resonant

            # Build thq with (top=0, thq=1)
            _set_const(top_pois, 0.0)
            _set_const(thq_pois, 1.0)
            h_sb_thq_n = sbpdf.createHistogram(f"h_sb_thq_nBins_{c}", xvar, ROOT.RooFit.Binning(opt.nBins, xvar.getMin(), xvar.getMax()))
            if opt.doBkgRenormalization and h_sb_thq_n.Integral() > 0:
                h_sb_thq_n.Scale(h_sb_n.Integral() / h_sb_thq_n.Integral())
            h_sig_thq = h_sb_thq_n.Clone(f"sig_thq_{c}")
            h_sig_thq.Add(h_b_n, -1.0)
            h_sig_thq.Add(h_sig_res, -1.0)

            # Restore original POI values
            for pn, val in saved_top.items():
                v = w.var(pn)
                if v:
                    v.setVal(val)
            for pn, val in saved_thq.items():
                v = w.var(pn)
                if v:
                    v.setVal(val)

            # Write split components
            h_sig_top.Write()
            h_sig_thq.Write()
            h_sig_res.Write()

    f_out.Close()
    f_in.Close()
    print(f"Exported shapes to {opt.output}")


if __name__ == "__main__":
    main()
