#!/usr/bin/env python3
"""
mplhep + uproot remake of the S+B model plotter.

Notes:
- This script plots from simple TH1 shapes read with uproot (no PyROOT).
- Provide a ROOT file with TH1 histograms for data, background, and signal
  (optionally split into components). Example naming conventions supported:
    - data_<cat>, bkg_<cat>, sig_<cat>
    - OR h_data_<cat>, h_bkg_<cat>, h_sig_<cat>
    - If --splitResonant is used:
        sig_top_<cat>, sig_thq_<cat>, [sig_res_<cat>]

Limitations vs. the original ROOT script:
- Reading directly from a RooWorkspace (e.g. 'w' in a Combine workspace) is not
  supported with uproot. You need a shapes ROOT file with TH1s. I can provide
  a small ROOT-based exporter on request.
- --saveToyYields/--doToyVeto and toy extraction are not implemented here. If you
  have a pickled toy yields DataFrame (from the original tool), pass it with
  --loadToyYields to draw bands.
"""

import argparse
import os
import math
import numpy as np
import pandas as pd
import uproot
import sys

import matplotlib.pyplot as plt
import mplhep as hep
hep.style.use("CMS")


def plot_splusb_model(
    bin_edges,
    data_vals,
    bkg_vals,
    sig_vals=None,
    sig_split=None,
    ratio_sig_split=None,
    data_err=None,
    bands=None,
    blinded_region=None,
    unblind=False,
    output_filename="./SplusBModels/plot.pdf",
    split_labels=("ttH+tHW", "tHq", "Resonant"),
    cms_label="Work in Progress",
    lumi=62.4,
    title_right=None,
    title_left=None,
    xlim=(100, 180),
):
    """
    Make an S+B style model plot with a lower panel showing background-subtracted data
    versus the signal model, using mplhep.

    Parameters:
      bin_edges: 1D array-like of bin edges (length N+1)
      data_vals: 1D array-like of data counts per bin (length N)
      bkg_vals : 1D array-like of background expectation per bin (length N)
      sig_vals : 1D array-like of signal expectation per bin (length N). Ignored if sig_split is provided.
      sig_split: Optional tuple/list of arrays (top, thq, resonant), each length N. "resonant" may be None.
      data_err : Optional 1D array-like of data errors per bin (length N). If None, uses sqrt(N).
      bands    : Optional dict with keys ["median","up1","down1","up2","down2"], each length N, for total model (S+B)
      blinded_region: Optional tuple (xmin, xmax). If provided and unblind=False, only show signal between these bounds on the top panel.
      unblind  : If True show S+B and B lines; otherwise show B line and filled signal in blinded region only.
      output_filename: Path to save the figure (pdf/png)
      split_labels: Legend labels to use when sig_split is provided: (top, thq, resonant)
      cms_label: Text for CMS label (e.g. "Preliminary" or "Private Work")
      lumi     : Luminosity text (fb^-1)
      title_right: Optional right-hand title text (e.g. category label)
    """

    # Common label fontsize used across panels and CMS label
    label_fontsize = 26

    # Prepare arrays
    data_vals = np.asarray(data_vals, dtype=float)
    bkg_vals = np.asarray(bkg_vals, dtype=float)
    if sig_split is not None:
        sig_top, sig_thq, sig_res = sig_split
        sig_top = None if sig_top is None else np.asarray(sig_top, dtype=float)
        sig_thq = None if sig_thq is None else np.asarray(sig_thq, dtype=float)
        sig_res = None if sig_res is None else np.asarray(sig_res, dtype=float)
    else:
        sig_vals = np.zeros_like(data_vals) if sig_vals is None else np.asarray(sig_vals, dtype=float)

    if data_err is None:
        data_err = np.sqrt(np.clip(data_vals, 0, None))
    else:
        data_err = np.asarray(data_err, dtype=float)

    # Build figure: main + ratio-like panel (background-subtracted)
    fig, (ax, ax_ratio) = plt.subplots(
        nrows=2,
        ncols=1,
        figsize=(10, 9),
        gridspec_kw={"height_ratios": (3, 1), "hspace": 0.05},
    )

    # 1) Optional toy bands (total model S+B)
    if bands is not None:
        # Expect arrays of length N
        for k in ["median", "up1", "down1", "up2", "down2"]:
            if k not in bands:
                raise ValueError(f"bands dict missing key '{k}'")
        med = np.asarray(bands["median"])  # these should be total model expectations per bin
        up1 = np.asarray(bands["up1"])
        dn1 = np.asarray(bands["down1"])
        up2 = np.asarray(bands["up2"])
        dn2 = np.asarray(bands["down2"])

        # Colors: 1σ = green (#607641), 2σ = yellow (#F5BB54)
        col_1sigma = "#607641"
        col_2sigma = "#F5BB54"

        # Draw as filled bands using step='post'
        ax.fill_between(
            bin_edges,
            np.r_[dn2, dn2[-1]],
            np.r_[up2, up2[-1]],
            step="post",
            color=col_2sigma,
            alpha=0.8,
            linewidth=0,
            label=r"Bkg. $\pm 2\,\sigma$",
        )
        ax.fill_between(
            bin_edges,
            np.r_[dn1, dn1[-1]],
            np.r_[up1, up1[-1]],
            step="post",
            color=col_1sigma,
            alpha=0.8,
            linewidth=0,
            label=r"Bkg. $\pm 1\,\sigma$",
        )

    # 2) Draw background and signal on main axis
    # Background line
    hep.histplot(
        bkg_vals,
        bins=bin_edges,
        ax=ax,
        linewidth=3,
        color="tab:red",
        label="Bkg. (continuum)",
    )

    # Signal drawing
    if unblind:
        # draw S+B and B as lines
        tot = bkg_vals.copy()
        if sig_split is not None:
            if sig_top is not None:
                tot = tot + sig_top
            if sig_thq is not None:
                tot = tot + sig_thq
            if sig_res is not None:
                tot = tot + sig_res
        else:
            tot = tot + sig_vals
        hep.histplot(
            tot,
            bins=bin_edges,
            ax=ax,
            linewidth=3,
            color="tab:red",
            linestyle="-",
            label="S+B fit",
        )
        hep.histplot(
            bkg_vals,
            bins=bin_edges,
            ax=ax,
            linewidth=3,
            color="tab:red",
            linestyle="--",
        )
    else:
        # draw filled signal only in blinded region (if provided). Use stacking order: resonant (gray), top (blue), thq (green)
        def mask_region(vals):
            if blinded_region is None:
                return vals
            xcent = 0.5 * (bin_edges[:-1] + bin_edges[1:])
            mask = (xcent >= blinded_region[0]) & (xcent <= blinded_region[1])
            v = np.array(vals, dtype=float)
            v[~mask] = np.nan
            return v

        if sig_split is not None:
            arrays = []
            labels = []
            colors = []
            # Stack only ttH+tHW and tHq
            if sig_top is not None:
                arrays.append(mask_region(sig_top))
                labels.append(split_labels[0] if len(split_labels) > 0 else "ttH+tHW")
                colors.append("C0")
            # tHq on top
            if sig_thq is not None:
                arrays.append(mask_region(sig_thq))
                labels.append(split_labels[1] if len(split_labels) > 1 else "tHq")
                colors.append("C3")

            if arrays:
                hep.histplot(
                    arrays,
                    bins=bin_edges,
                    ax=ax,
                    histtype="fill",
                    stack=True,
                    linewidth=0,
                    color=colors,
                    label=labels,
                    alpha=0.8,
                )
            # Resonant drawn as step (dotted) on top of B fit, only between 120-130 GeV
            if sig_res is not None:
                xcent_all = 0.5 * (bin_edges[:-1] + bin_edges[1:])
                mask_window = (xcent_all >= 120) & (xcent_all <= 130)
                res_offset = sig_res + bkg_vals
                # res_offset = np.where(mask_window, res_offset, np.nan)
                hep.histplot(
                    res_offset,
                    bins=bin_edges,
                    ax=ax,
                    histtype="step",
                    linewidth=3,
                    color="tab:red",
                    linestyle=":",
                    label=r"Bkg. ($H\rightarrow\gamma\gamma$)",
                )
        else:
            hep.histplot(
                [mask_region(sig_vals)],
                bins=bin_edges,
                ax=ax,
                linewidth=0,
                histtype="fill",
                color="tab:blue",
                label="S model",
            )

    # Data points with errors (mask blinded region if needed)
    def _mask_blind(arr):
        if unblind or blinded_region is None:
            return arr
        xcent = 0.5 * (bin_edges[:-1] + bin_edges[1:])
        mask = (xcent < blinded_region[0]) | (xcent > blinded_region[1])
        out = np.array(arr, dtype=float)
        out[~mask] = np.nan
        return out

    data_main = _mask_blind(data_vals)
    err_main = _mask_blind(data_err)
    hep.histplot(
        data_main,
        bins=bin_edges,
        ax=ax,
        histtype="errorbar",
        yerr=err_main,
        color="black",
        label="Data",
        markersize=12,
        elinewidth=3,
    )

    # Style main
    ax.margins(y=0.15)
    ax.set_ylim(0, 1.25 * ax.get_ylim()[1])
    ax.set_ylabel("Events / GeV", fontsize=label_fontsize)
    ax.set_xlabel("")
    ax.set_xticklabels([])
    # Reorder legend: continuum, resonant bkg, uncertainties, Data, then signals
    handles, labels_display = ax.get_legend_handles_labels()

    # Priority map (lower = earlier in legend)
    def _priority(lbl: str):
        if lbl.startswith("Bkg. (continuum)"):
            return (0, lbl)
        if lbl.startswith("Bkg. ($H") or "H\\rightarrow" in lbl:
            return (1, lbl)
        if lbl == "Data":
            return (2, lbl)
        if "$\\pm 1" in lbl:
            return (3, lbl)
        if "$\\pm 2" in lbl:
            return (4, lbl)
        return (5, lbl)

    order = sorted(range(len(labels_display)), key=lambda i: _priority(labels_display[i]))
    handles_ordered = [handles[i] for i in order]
    labels_ordered = [labels_display[i] for i in order]

    ncols = 2 if len(labels_ordered) < 6 else 3
    ax.legend(handles_ordered, labels_ordered, loc="upper right", fontsize=17, ncols=ncols, labelspacing=0.3, columnspacing=1)

    hep.cms.label(data=True, ax=ax, loc=0, label=cms_label, com=13.6, lumi=_fmt_lumi(lumi), fontsize=label_fontsize)
    if title_right:
        ax.text(0.94, 0.76, title_right, ha="right", va="center", transform=ax.transAxes, fontsize=20)
    if title_left:
        ax.text(0.14, 0.86, title_left, ha="left", va="center", transform=ax.transAxes, fontsize=20)

    # 3) Ratio-like panel: (Data - B) vs Signal
    data_minus_b = data_vals - bkg_vals
    # Build "band" for ratio panel if provided
    if bands is not None:
        med = np.asarray(bands["median"]) - bkg_vals
        up1 = np.asarray(bands["up1"]) - bkg_vals
        dn1 = np.asarray(bands["down1"]) - bkg_vals
        up2 = np.asarray(bands["up2"]) - bkg_vals
        dn2 = np.asarray(bands["down2"]) - bkg_vals
        # Also subtract resonant from the band to avoid a bump
        res_unscaled = None
        if ratio_sig_split is not None and len(ratio_sig_split) == 3:
            res_unscaled = ratio_sig_split[2]
        elif sig_split is not None and len(sig_split) == 3:
            res_unscaled = sig_split[2]
        if res_unscaled is not None:
            med = med - res_unscaled
            up1 = up1 - res_unscaled
            dn1 = dn1 - res_unscaled
            up2 = up2 - res_unscaled
            dn2 = dn2 - res_unscaled
        col_1sigma = "#607641"
        col_2sigma = "#F5BB54"
        ax_ratio.fill_between(
            bin_edges,
            np.r_[dn2, dn2[-1]],
            np.r_[up2, up2[-1]],
            step="post",
            color=col_2sigma,
            alpha=0.8,
            linewidth=0,
        )
        ax_ratio.fill_between(
            bin_edges,
            np.r_[dn1, dn1[-1]],
            np.r_[up1, up1[-1]],
            step="post",
            color=col_1sigma,
            alpha=0.8,
            linewidth=0,
        )

    # Draw signal expectation on ratio panel (prefer unscaled if provided); do not draw resonant
    if ratio_sig_split is not None:
        top_u, thq_u, res_u = ratio_sig_split
        arrays = []
        colors = []
        if top_u is not None:
            arrays.append(top_u)
            colors.append("C0")
        if thq_u is not None:
            arrays.append(thq_u)
            colors.append("C3")
        if arrays:
            hep.histplot(arrays, bins=bin_edges, ax=ax_ratio, histtype="fill", stack=True, linewidth=0, color=colors)
    elif sig_split is not None:
        arrays = []
        colors = []
        if sig_top is not None:
            arrays.append(sig_top)
            colors.append("C0")
        if sig_thq is not None:
            arrays.append(sig_thq)
            colors.append("C3")
        if arrays:
            hep.histplot(arrays, bins=bin_edges, ax=ax_ratio, histtype="fill", stack=True, linewidth=0, color=colors)
    else:
        hep.histplot(sig_vals, bins=bin_edges, ax=ax_ratio, linewidth=3, color="tab:blue")

    # Data minus background with errors
    data_ratio = _mask_blind(data_minus_b)
    err_ratio = _mask_blind(data_err)
    hep.histplot(
        data_ratio,
        bins=bin_edges,
        ax=ax_ratio,
        histtype="errorbar",
        yerr=err_ratio,
        color="black",
        markersize=12,
        elinewidth=3,
    )
    ax_ratio.set_ylabel("Data - Bkg.", fontsize=label_fontsize)
    ax_ratio.set_xlabel(r"Diphoton mass [GeV]", fontsize=label_fontsize)
    if xlim is not None:
        ax.set_xlim(*xlim)
        ax_ratio.set_xlim(*xlim)
    # Autoscale y from data only (mask blinded region), for stable limits
    valid = ~np.isnan(data_ratio)
    if np.any(valid):
        ymin = np.nanmin(data_ratio[valid])
        ymax = np.nanmax(data_ratio[valid])
    else:
        ymin, ymax = 0.0, 1.0
    span = ymax - ymin
    ax_ratio.set_ylim(ymin - 0.15 * span, ymax + 0.25 * span)

    # Finalize
    os.makedirs(os.path.dirname(output_filename), exist_ok=True)
    fig.tight_layout()
    fig.subplots_adjust(hspace=0.07)
    fig.savefig(output_filename)
    plt.close(fig)




def parse_args():
    ap = argparse.ArgumentParser(description="S+B model plotter (mplhep + uproot)")
    ap.add_argument("--inputWSFile", required=True, help="Path to workspace or shapes ROOT file")
    ap.add_argument("--shapesFile", default=None, help="Explicit shapes ROOT file with TH1s (overrides inputWSFile)")
    ap.add_argument("--cats", default="all", help="Comma-separated category names or 'all'")
    ap.add_argument("--unblind", action="store_true", help="Unblind signal region")
    ap.add_argument("--blindingRegion", default="116,134", help="Comma-separated blinded region: low,high")
    ap.add_argument("--doZeroes", action="store_true", help="Give zero bins unit error to show markers")
    ap.add_argument("--ext", default="", help="Extension tag for outputs (subdirectory and filename prefix)")
    ap.add_argument("--xvar", default="CMS_hgg_mass,m_{#gamma#gamma},GeV", help="name,title,units; only name is used in filenames")
    ap.add_argument("--nBins", type=int, default=80, help="Number of bins (used to validate shapes and bands)")
    ap.add_argument("--translateCats", default=None, help="JSON mapping for category labels")
    ap.add_argument("--doBands", action="store_true", help="Draw ±1σ/±2σ bands from toy yields")
    ap.add_argument("--loadToyYields", default="", help="Pickle file with toy yields DataFrame (from original tool)")
    ap.add_argument("--splitResonant", action="store_true", help="Split signal into (top,thq,resonant)")
    ap.add_argument("--topPOIs", default="r_ttH", help="Unused here (kept for CLI parity)")
    ap.add_argument("--thqPOIs", default="r_tHq", help="Unused here (kept for CLI parity)")
    ap.add_argument("--topScale", type=float, default=2.0, help="Visual scale factor for ttH+tHW component")
    ap.add_argument("--thqScale", type=float, default=10.0, help="Visual scale factor for tHq component")
    ap.add_argument(
        "--splitLabels",
        default="$t\\bar{t}H + tHW \\times 2$,$tHq \\times 10$,Resonant bkg.",
        help="Legend labels for split components",
    )
    return ap.parse_args()


def load_translations(path):
    if not path:
        return {}
    import json
    with open(path) as f:
        return json.load(f)


def discover_categories_and_components(file):
    """Scan TH1 keys and infer available categories and components.

    Supports names like data_<cat>, bkg_<cat>, sig_<cat>, sig_top_<cat>, sig_thq_<cat>, sig_res_<cat>.
    Returns (categories, components) where components is a set of component tags found.
    """
    keys = [k.decode() if isinstance(k, bytes) else k for k in file.keys()]
    # uproot v5 returns keys like 'hname;1' — strip ';N'
    def hname(k):
        return k.split(";")[0]

    names = [hname(k) for k in keys]
    def base_cat(s):
        # Strip RooFit suffix like '__CMS_hgg_mass' from category fragments
        return s.split("__")[0]
    cats = set()
    comps = set()
    for n in names:
        for pref in ("data_", "h_data_"):
            if n.startswith(pref):
                cats.add(base_cat(n[len(pref):]))
        for pref in ("bkg_", "h_bkg_", "b_", "h_b_"):
            if n.startswith(pref):
                cats.add(base_cat(n[len(pref):]))
        for pref in ("sig_", "h_sig_"):
            if n.startswith(pref):
                rest = n[len(pref):]
                # Could be 'top_<cat>' or '<cat>'
                if rest.startswith("top_"):
                    comps.add("top")
                    cats.add(base_cat(rest[len("top_"):]))
                elif rest.startswith("thq_"):
                    comps.add("thq")
                    cats.add(base_cat(rest[len("thq_"):]))
                elif rest.startswith("res_") or rest.startswith("resonant_"):
                    comps.add("res")
                    cat = rest.split("_", 1)[1]
                    cats.add(base_cat(cat))
                else:
                    cats.add(base_cat(rest))
    return sorted(cats), comps


def get_th1(file, name):
    """Fetch TH1 by base name, allowing RooFit-style suffixes like '__CMS_hgg_mass'."""
    for k in file.keys():
        base = k.split(";")[0]
        if base == name or base.startswith(name + "__"):
            return file[base]
    return None


def read_shapes_for_category(f, cat, split=False):
    """Return (bin_edges, data, bkg, sig or (top,thq,res)).

    Accept several naming patterns. Raises if required shapes are missing.
    """
    # Accept multiple prefixes; normalize category (strip suffixes)
    cat_base = cat.split("__")[0]
    # Accept multiple prefixes
    data = None
    for nm in (f"data_{cat}", f"h_data_{cat}", f"data_{cat_base}", f"h_data_{cat_base}"):
        h = get_th1(f, nm)
        if h is not None:
            data = h
            break
    if data is None:
        raise FileNotFoundError(f"No data TH1 found for category '{cat}'")

    bkg = None
    for nm in (
        f"bkg_{cat}", f"h_bkg_{cat}", f"b_{cat}", f"h_b_{cat}",
        f"bkg_{cat_base}", f"h_bkg_{cat_base}", f"b_{cat_base}", f"h_b_{cat_base}"
    ):
        h = get_th1(f, nm)
        if h is not None:
            bkg = h
            break
    if bkg is None:
        raise FileNotFoundError(f"No background TH1 found for category '{cat}'")

    # Edges from one of the histograms (uproot v5 TH1 interface)
    if hasattr(data, "axis"):
        edges = data.axis().edges()  # some uproot models
    else:
        edges = data.axes[0].edges()
    data_vals = data.values(flow=False)
    bkg_vals = bkg.values(flow=False)

    if split:
        # Top / thq optional resonant
        top = None
        thq = None
        res = None
        for nm in (f"sig_top_{cat}", f"h_sig_top_{cat}", f"sig_top_{cat_base}", f"h_sig_top_{cat_base}"):
            h = get_th1(f, nm)
            if h is not None:
                top = h.values(flow=False)
                break
        for nm in (f"sig_thq_{cat}", f"h_sig_thq_{cat}", f"sig_thq_{cat_base}", f"h_sig_thq_{cat_base}"):
            h = get_th1(f, nm)
            if h is not None:
                thq = h.values(flow=False)
                break
        for nm in (
            f"sig_res_{cat}", f"h_sig_res_{cat}", f"sig_resonant_{cat}",
            f"sig_res_{cat_base}", f"h_sig_res_{cat_base}", f"sig_resonant_{cat_base}"
        ):
            h = get_th1(f, nm)
            if h is not None:
                res = h.values(flow=False)
                break
        if top is None and thq is None and res is None:
            raise FileNotFoundError(
                f"--splitResonant set but no split signal components found for '{cat}'"
            )
        return edges, data_vals, bkg_vals, (top, thq, res)
    else:
        sig = None
        for nm in (f"sig_{cat}", f"h_sig_{cat}", f"sig_{cat_base}", f"h_sig_{cat_base}"):
            h = get_th1(f, nm)
            if h is not None:
                sig = h.values(flow=False)
                break
        if sig is None:
            raise FileNotFoundError(f"No signal TH1 found for category '{cat}'")
        return edges, data_vals, bkg_vals, sig


def compute_bands_from_toys(df, category, n_bins):
    """Reproduce the percentiles as in plottingTools.extractBandProperties.
    Expects columns named '{category}_{ibin}' where ibin = 1..n_bins.
    Returns dict with keys: median, up1, down1, up2, down2.
    """
    from math import erf, sqrt
    p_up1 = 50 * (1 + erf(1.0 / sqrt(2)))
    p_dn1 = 50 * (1 + erf(-1.0 / sqrt(2)))
    p_up2 = 50 * (1 + erf(2.0 / sqrt(2)))
    p_dn2 = 50 * (1 + erf(-2.0 / sqrt(2)))
    med = []
    up1 = []
    dn1 = []
    up2 = []
    dn2 = []
    for ib in range(1, n_bins + 1):
        col = f"{category}_{ib}"
        if col not in df.columns:
            raise KeyError(f"Toy yields missing column '{col}'")
        vals = df[col].values
        med.append(np.median(vals))
        up1.append(np.percentile(vals, p_up1))
        dn1.append(np.percentile(vals, p_dn1))
        up2.append(np.percentile(vals, p_up2))
        dn2.append(np.percentile(vals, p_dn2))
    return {"median": np.array(med), "up1": np.array(up1), "down1": np.array(dn1), "up2": np.array(up2), "down2": np.array(dn2)}


def main():
    opt = parse_args()

    # Where to read shapes
    shapes_path = opt.shapesFile or opt.inputWSFile
    if not os.path.isfile(shapes_path):
        raise FileNotFoundError(f"Shapes file not found: {shapes_path}")

    # Try to open with uproot
    f = uproot.open(shapes_path)

    # If a RooWorkspace is present and no TH1s, we can't proceed without an exporter
    # We try to discover categories from TH1 keys
    cats_discovered, comps = discover_categories_and_components(f)
    if len(cats_discovered) == 0:
        raise RuntimeError(
            "No TH1 histograms found in shapes file. If you passed a RooWorkspace, "
            "please provide a shapes ROOT file with TH1s (data/bkg/sig per category)."
        )

    # Categories to process
    if opt.cats == "all":
        cats = cats_discovered
    else:
        cats = [c.strip() for c in opt.cats.split(",") if c.strip()]

    translate_cats = load_translations(opt.translateCats) if opt.translateCats else {}

    def human_readable_category(cat):
        # Prefer translation JSON if provided
        if cat in translate_cats:
            return translate_cats[cat]
        c = cat
        label = c
        try:
            parts = c.split("_")
            head = parts[0]
            rest = parts[1:]
            if head == "tH":
                head_lbl = "$tHq$"
            elif head == "ttH":
                head_lbl = "ttH"
            else:
                head_lbl = head
            # replace had/lep
            rest_lbl = []
            for p in rest:
                if p == "had":
                    rest_lbl.append("had.")
                elif p == "lep":
                    rest_lbl.append("lep.")
                else:
                    rest_lbl.append(p)
            label = f"{head_lbl} {' '.join(rest_lbl)}"
        except Exception:
            pass
        return label
    blinded = tuple(float(x) for x in opt.blindingRegion.split(","))
    xvar_name = opt.xvar.split(",")[0]
    split_labels = [s.strip() for s in opt.splitLabels.split(",")]

    # Optional toy yields for bands
    toy_df = None
    if opt.doBands:
        if opt.loadToyYields:
            toy_df = pd.read_pickle(opt.loadToyYields)
        else:
            print("[warn] --doBands set but no --loadToyYields provided; skipping bands.")

    outdir = f"./SplusBModels{opt.ext}"
    os.makedirs(outdir, exist_ok=True)

    # Process categories and optionally build a sum
    have_split = bool(opt.splitResonant)
    summed = None  # to store running sums for 'all'
    summed_split = None
    bin_edges_ref = None

    for cat in cats:
        if have_split:
            edges, data, bkg, split = read_shapes_for_category(f, cat, split=True)
            top, thq, res = split
            # Keep unscaled copies for ratio panel
            top_unscaled = None if top is None else top.copy()
            thq_unscaled = None if thq is None else thq.copy()
            res_unscaled = None if res is None else res.copy()
            # Apply visual scales
            if top is not None:
                top = opt.topScale * top
            if thq is not None:
                thq = opt.thqScale * thq
            sig_for_sum = np.zeros_like(bkg)
            if top is not None:
                sig_for_sum += top
            if thq is not None:
                sig_for_sum += thq
            if res is not None:
                sig_for_sum += res
        else:
            edges, data, bkg, sig = read_shapes_for_category(f, cat, split=False)
            split = None
            sig_for_sum = sig

        # Data errors
        data_err = np.sqrt(np.clip(data, 0, None))
        if opt.doZeroes:
            data_err = np.where(data == 0.0, 1.0, data_err)

        # Bands for this category (optional)
        bands = None
        if toy_df is not None:
            bands = compute_bands_from_toys(toy_df, cat, opt.nBins)

        # Title/label for category (display on right under legend)
        title_right = human_readable_category(cat)

        # Output path
        outname = os.path.join(outdir, f"{opt.ext}_{cat}_{xvar_name}.pdf")

        # Plot
        if have_split:
            plot_splusb_model(
                bin_edges=edges,
                data_vals=data,
                bkg_vals=bkg,
                sig_vals=None,
                sig_split=(top, thq, res),
                ratio_sig_split=(top_unscaled, thq_unscaled, res_unscaled),
                data_err=data_err,
                bands=bands,
                blinded_region=blinded,
                unblind=opt.unblind,
                output_filename=outname,
                split_labels=split_labels,
                cms_label="Private Work",
                lumi=62.4,
                title_right=title_right,
                title_left=None,
                xlim=(100, 180),
            )
        else:
            plot_splusb_model(
                bin_edges=edges,
                data_vals=data,
                bkg_vals=bkg,
                sig_vals=sig_for_sum,
                sig_split=None,
                data_err=data_err,
                bands=bands,
                blinded_region=blinded,
                unblind=opt.unblind,
                output_filename=outname,
                split_labels=split_labels,
                cms_label="Private Work",
                lumi=62.4,
                title_right=title_right,
                title_left=None,
                xlim=(100, 180),
            )

        # Accumulate for sum plot
        if summed is None:
            bin_edges_ref = edges
            summed = {
                "data": data.copy(),
                "bkg": bkg.copy(),
                "sig": sig_for_sum.copy(),
            }
            if have_split:
                summed_split = {
                    "top": np.zeros_like(bkg) if top is not None else None,
                    "thq": np.zeros_like(bkg) if thq is not None else None,
                    "res": np.zeros_like(bkg) if res is not None else None,
                }
                if top is not None:
                    summed_split["top"] += top
                if thq is not None:
                    summed_split["thq"] += thq
                if res is not None:
                    summed_split["res"] += res
        else:
            # Ensure same binning
            if not np.allclose(bin_edges_ref, edges):
                raise ValueError("All categories must share identical binning for the sum plot.")
            summed["data"] += data
            summed["bkg"] += bkg
            summed["sig"] += sig_for_sum
            if have_split and summed_split is not None:
                if top is not None and summed_split["top"] is not None:
                    summed_split["top"] += top
                if thq is not None and summed_split["thq"] is not None:
                    summed_split["thq"] += thq
                if res is not None and summed_split["res"] is not None:
                    summed_split["res"] += res

    # Sum plot (for 'all')
    if len(cats) > 1 or (len(cats) == 1 and cats[0].lower() == "all"):
        if summed is not None:
            data = summed["data"]
            bkg = summed["bkg"]
            sig = summed["sig"]
            data_err = np.sqrt(np.clip(data, 0, None))
            if opt.doZeroes:
                data_err = np.where(data == 0.0, 1.0, data_err)
            bands = None
            if toy_df is not None:
                # In toy pickle from original tool, the sum columns were named 'sum_<ibin>' or 'wsum_<ibin>'.
                # Try 'sum' first.
                try:
                    bands = compute_bands_from_toys(toy_df, "sum", opt.nBins)
                except Exception:
                    pass
            outname = os.path.join(outdir, f"{opt.ext}_all_{xvar_name}.pdf")
            if have_split and summed_split is not None:
                plot_splusb_model(
                    bin_edges=bin_edges_ref,
                    data_vals=data,
                    bkg_vals=bkg,
                    sig_vals=None,
                    sig_split=(
                        summed_split.get("top"),
                        summed_split.get("thq"),
                        summed_split.get("res"),
                    ),
                    ratio_sig_split=(
                        summed_split.get("top"),
                        summed_split.get("thq"),
                        summed_split.get("res"),
                    ),
                    data_err=data_err,
                    bands=bands,
                    blinded_region=tuple(float(x) for x in opt.blindingRegion.split(",")),
                    unblind=opt.unblind,
                    output_filename=outname,
                    split_labels=split_labels,
                    cms_label="Private Work",
                    lumi=62.4,
                    title_right=human_readable_category("all"),
                    title_left=None,
                    xlim=(100, 180),
                )
            else:
                plot_splusb_model(
                    bin_edges=bin_edges_ref,
                    data_vals=data,
                    bkg_vals=bkg,
                    sig_vals=sig,
                    sig_split=None,
                    data_err=data_err,
                    bands=bands,
                    blinded_region=tuple(float(x) for x in opt.blindingRegion.split(",")),
                    unblind=opt.unblind,
                    output_filename=outname,
                    split_labels=split_labels,
                    cms_label="Private Work",
                    lumi=62.4,
                    title_right=human_readable_category("all"),
                    title_left=None,
                    xlim=(100, 180),
                )


if __name__ == "__main__":
    main()
