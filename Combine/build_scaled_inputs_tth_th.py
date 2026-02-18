#!/usr/bin/env python3
import argparse
import json
import os
import re
import sys
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(
        description=(
            "Build a scaled inputs_statonly_tth_th.json based on SM ranges and "
            "tHq/ttH cross-section ratios."
        )
    )
    parser.add_argument("--base-json", required=True, help="Path to base inputs_statonly_tth_th.json")
    parser.add_argument("--output-json", required=True, help="Path to write the scaled JSON")
    parser.add_argument(
        "--scale-mode",
        choices=("proportional", "inverse", "inverse_sqrt"),
        default="proportional",
        help=(
            "Scale ranges proportional to XS (proportional), 1/XS (inverse), "
            "or 1/sqrt(XS) (inverse_sqrt)"
        ),
    )
    parser.add_argument(
        "--center-on",
        choices=("one", "ratio", "inverse"),
        default="one",
        help="Center ranges on 1 (one), XS ratio (ratio), or 1/XS ratio (inverse)",
    )
    parser.add_argument(
        "--override-base-for",
        default="",
        help="Coupling label to override r_2D / r_2D_fiducial ranges (used for SM-template fits)",
    )
    parser.add_argument(
        "--fiducial-yaml",
        default="",
        help="Optional YAML with fiducial fractions to scale ranges with fiducial XS ratios.",
    )
    parser.add_argument(
        "--points-2d",
        default="",
        help="Override r_2D* points in output as TOTAL:SPLIT (e.g. 20000:400).",
    )
    return parser.parse_args()


def add_sys_path():
    script_dir = Path(__file__).resolve().parent
    if "CMSSW_BASE" not in os.environ:
        try:
            os.environ["CMSSW_BASE"] = str(script_dir.parents[3])
        except (IndexError, ValueError):
            pass
    signal_tools = script_dir / ".." / "Signal" / "tools"
    common_tools = script_dir / ".." / "commonTools"
    sys.path.insert(0, str(signal_tools.resolve()))
    sys.path.insert(0, str(common_tools.resolve()))


def parse_coupling(label):
    special = {
        "SM": (1.0, 0.0),
        "CPodd": (0.0, 1.0),
        "Ktm1Ktt0": (-1.0, 0.0),
        "Kt0Kttm1": (0.0, -1.0),
        "Kt0Ktt0": (0.0, 0.0),
    }
    if label in special:
        return special[label]
    m = re.match(
        r"Kt(?P<kt_sign>m?)(?P<kt_int>\d+)(?:p(?P<kt_frac>\d+))?"
        r"Ktt(?P<ktt_sign>m?)(?P<ktt_int>\d+)(?:p(?P<ktt_frac>\d+))?$",
        label,
    )
    if not m:
        raise ValueError(f"Unrecognized coupling label: {label}")

    def to_float(sign, whole, frac):
        val = float(whole)
        if frac:
            val += float(frac) / (10 ** len(frac))
        if sign == "m":
            val = -val
        return val

    kt = to_float(m.group("kt_sign"), m.group("kt_int"), m.group("kt_frac"))
    ktt = to_float(m.group("ktt_sign"), m.group("ktt_int"), m.group("ktt_frac"))
    return kt, ktt


def extract_ranges(fit_opts):
    m_thq = re.search(r"r_tHq=([-0-9.]+),([-0-9.]+)", fit_opts)
    m_tth = re.search(r"r_ttH=([-0-9.]+),([-0-9.]+)", fit_opts)
    if not m_thq or not m_tth:
        raise ValueError(f"Could not parse ranges from fit_opts: {fit_opts}")
    return (
        (float(m_thq.group(1)), float(m_thq.group(2))),
        (float(m_tth.group(1)), float(m_tth.group(2))),
    )


def replace_range(fit_opts, param, new_min, new_max):
    pattern = rf"({param}=)([-0-9.]+),([-0-9.]+)"
    # Use explicit group reference so numbers like "1.23" don't get parsed as \10.
    repl = rf"\g<1>{new_min:.2f},{new_max:.2f}"
    return re.sub(pattern, repl, fit_opts, count=1)


def upsert_set_parameters(fit_opts, updates):
    m = re.search(r"--setParameters\s+([^\s]+)", fit_opts)
    if m:
        existing = m.group(1)
        params = {}
        for item in existing.split(","):
            if not item:
                continue
            key, value = item.split("=", 1)
            params[key] = value
        params.update(updates)
        merged = ",".join(f"{key}={value}" for key, value in params.items())
        return re.sub(r"--setParameters\s+[^\s]+", f"--setParameters {merged}", fit_opts, count=1)
    merged = ",".join(f"{key}={value}" for key, value in updates.items())
    return f"{fit_opts.strip()} --setParameters {merged}"


def set_center_parameters(fit_opts):
    (thq_range, tth_range) = extract_ranges(fit_opts)
    center_thq = (thq_range[0] + thq_range[1]) / 2.0
    center_tth = (tth_range[0] + tth_range[1]) / 2.0
    return upsert_set_parameters(
        fit_opts,
        {
            "r_tHq": f"{center_thq:.4f}",
            "r_ttH": f"{center_tth:.4f}",
        },
    )


def scaled_range(base_min, base_max, scale, center):
    base_center = 1.0
    low = base_center - base_min
    high = base_max - base_center
    return center - low * scale, center + high * scale


def load_fiducial_fractions(path):
    if not path:
        return None
    try:
        import yaml  # noqa: WPS433
    except Exception:
        return None
    yaml_path = Path(path)
    if not yaml_path.is_file():
        return None
    data = yaml.safe_load(yaml_path.read_text())
    processes = data.get("processes", {})
    fractions = {}
    for proc, info in processes.items():
        bins = info.get("bins", [])
        if not bins:
            continue
        in_frac = bins[0].get("in_frac")
        if in_frac is None:
            continue
        fractions[proc] = float(in_frac)
    return fractions


def fiducial_ratios(label, fractions, xs):
    if fractions is None:
        return None

    def key(proc):
        return proc if label == "SM" else f"{proc}{label}"

    ttH_frac = fractions.get(key("tth"))
    tHW_frac = fractions.get(key("tHW"))
    tHq_had = fractions.get(key("tHqHad"))
    tHq_lep = fractions.get(key("tHqLep"))

    ttH_frac_sm = fractions.get("tth")
    tHW_frac_sm = fractions.get("tHW")
    tHq_had_sm = fractions.get("tHqHad")
    tHq_lep_sm = fractions.get("tHqLep")
    if None in (
        ttH_frac,
        tHW_frac,
        tHq_had,
        tHq_lep,
        ttH_frac_sm,
        tHW_frac_sm,
        tHq_had_sm,
        tHq_lep_sm,
    ):
        return None

    kt, ktt = parse_coupling(label)
    tHq_lep_frac = xs.tHq_lep_frac

    ttH_in = xs.tth_xs(kt, ktt) * ttH_frac
    tHW_in = xs.tHW_xs(kt, ktt) * tHW_frac
    tHq_in = xs.tHq_xs(kt, ktt) * (
        tHq_lep_frac * tHq_lep + (1.0 - tHq_lep_frac) * tHq_had
    )

    ttH_sm_in = xs.tth_sm_xs * ttH_frac_sm
    tHW_sm_in = xs.tHW_sm_xs * tHW_frac_sm
    tHq_sm_in = xs.tHq_sm_xs * (
        tHq_lep_frac * tHq_lep_sm + (1.0 - tHq_lep_frac) * tHq_had_sm
    )
    if ttH_sm_in + tHW_sm_in <= 0 or tHq_sm_in <= 0:
        return None

    r_tHq = tHq_in / tHq_sm_in
    r_ttH = (ttH_in + tHW_in) / (ttH_sm_in + tHW_sm_in)
    return r_ttH, r_tHq


def build_scaled_json(base_json, scale_mode, center_on, override_base_for, fiducial_yaml, points_2d):
    data = json.loads(Path(base_json).read_text())

    # Determine base ranges from SM modes.
    base_ranges = {}
    for key in ("r_2D", "r_2D_fiducial"):
        if key in data:
            base_ranges[key] = extract_ranges(data[key]["fit_opts"])

    # Import XS helpers.
    add_sys_path()
    import XSBRMap as xs  # noqa: E402
    fiducial_fracs = load_fiducial_fractions(fiducial_yaml)

    def ratios_for_label(label):
        fiducial = fiducial_ratios(label, fiducial_fracs, xs)
        if fiducial is not None:
            return fiducial
        kt, ktt = parse_coupling(label)
        tth_sm = xs.tth_sm_xs
        thw_sm = xs.tHW_sm_xs
        thq_sm = xs.tHq_sm_xs
        tth_total = xs.tth_xs(kt, ktt) + xs.tHW_xs(kt, ktt)
        tth_sm_total = tth_sm + thw_sm
        tth_ratio = tth_total / tth_sm_total if tth_sm_total else 1.0
        thq_ratio = xs.tHq_xs(kt, ktt) / thq_sm if thq_sm else 1.0
        return tth_ratio, thq_ratio

    def scaled_ranges(label, base_key):
        (base_thq, base_tth) = base_ranges[base_key]
        raw_tth_ratio, raw_thq_ratio = ratios_for_label(label)
        if scale_mode == "inverse":
            tth_scale = 1.0 / raw_tth_ratio if raw_tth_ratio > 0 else 1.0
            thq_scale = 1.0 / raw_thq_ratio if raw_thq_ratio > 0 else 1.0
        elif scale_mode == "inverse_sqrt":
            tth_scale = (1.0 / raw_tth_ratio) ** 0.5 if raw_tth_ratio > 0 else 1.0
            thq_scale = (1.0 / raw_thq_ratio) ** 0.5 if raw_thq_ratio > 0 else 1.0
        else:
            tth_scale = raw_tth_ratio
            thq_scale = raw_thq_ratio
        if tth_scale <= 0 or not (tth_scale == tth_scale):
            tth_scale = 1.0
        if thq_scale <= 0 or not (thq_scale == thq_scale):
            thq_scale = 1.0

        def pick_center(ratio):
            if center_on == "ratio":
                return ratio
            if center_on == "inverse":
                return 1.0 / ratio if ratio > 0 else 1.0
            return 1.0

        thq_center = pick_center(raw_thq_ratio)
        tth_center = pick_center(raw_tth_ratio)

        new_thq = scaled_range(base_thq[0], base_thq[1], thq_scale, thq_center)
        new_tth = scaled_range(base_tth[0], base_tth[1], tth_scale, tth_center)
        return new_thq, new_tth

    # Update coupling-specific modes.
    for mode, payload in data.items():
        if not mode.startswith("r_2D_"):
            continue
        cpl = mode[len("r_2D_"):]
        base_key = "r_2D_fiducial" if cpl.endswith("_fiducial") else "r_2D"
        if cpl.endswith("_fiducial"):
            cpl = cpl[: -len("_fiducial")]
        if base_key not in base_ranges:
            continue
        try:
            (new_thq, new_tth) = scaled_ranges(cpl, base_key)
        except ValueError:
            continue
        fit_opts = payload["fit_opts"]
        fit_opts = replace_range(fit_opts, "r_tHq", new_thq[0], new_thq[1])
        fit_opts = replace_range(fit_opts, "r_ttH", new_tth[0], new_tth[1])
        fit_opts = set_center_parameters(fit_opts)
        payload["fit_opts"] = fit_opts

    # Optionally override the base r_2D ranges for a specific coupling.
    if override_base_for:
        for base_key in ("r_2D", "r_2D_fiducial"):
            if base_key not in base_ranges or base_key not in data:
                continue
            (new_thq, new_tth) = scaled_ranges(override_base_for, base_key)
            fit_opts = data[base_key]["fit_opts"]
            fit_opts = replace_range(fit_opts, "r_tHq", new_thq[0], new_thq[1])
            fit_opts = replace_range(fit_opts, "r_ttH", new_tth[0], new_tth[1])
            fit_opts = set_center_parameters(fit_opts)
            data[base_key]["fit_opts"] = fit_opts

    if points_2d:
        for mode, payload in data.items():
            if mode.startswith("r_2D") and "points" in payload:
                payload["points"] = points_2d

    return data


def main():
    opts = parse_args()
    scaled = build_scaled_json(
        opts.base_json,
        opts.scale_mode,
        opts.center_on,
        opts.override_base_for,
        opts.fiducial_yaml,
        opts.points_2d,
    )
    Path(opts.output_json).write_text(json.dumps(scaled, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
