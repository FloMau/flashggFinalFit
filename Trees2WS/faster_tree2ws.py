import os
import subprocess
import shutil
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Dict


# Map each mode to its input subdir and filename template
# The filename may depend on the era only through the directory name.
MODE_INPUTS: Dict[str, str] = {
    # signal modes
    "tth": "ttH_{era}/output_TTHToGG_M125_13TeV_amcatnlo_pythia8.root",
    "tthCPodd": "ttH_CPodd_{era}/output_TTHToGG_CP_odd_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt0p7Ktt0p7": "ttH_Kt0p7Ktt0p7_{era}/output_TTHToGG_Kt0p7Ktt0p7_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt0p7Kttm0p7": "ttH_Kt0p7Kttm0p7_{era}/output_TTHToGG_Kt0p7Kttm0p7_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt0Kttm1": "ttH_Kt0Kttm1_{era}/output_TTHToGG_Kt0Kttm1_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt0Ktt0": "ttH_Kt0Ktt0_{era}/output_TTHToGG_Kt0Ktt0_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt0p500Ktt0p000": "ttH_Kt0p500Ktt0p000_{era}/output_TTHToGG_Kt0p500Ktt0p000_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt0p354Ktt0p354": "ttH_Kt0p354Ktt0p354_{era}/output_TTHToGG_Kt0p354Ktt0p354_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt0p000Ktt0p500": "ttH_Kt0p000Ktt0p500_{era}/output_TTHToGG_Kt0p000Ktt0p500_M125_13TeV_amcatnlo_pythia8.root",
    "tthKtm0p500Ktt0p000": "ttH_Ktm0p500Ktt0p000_{era}/output_TTHToGG_Ktm0p500Ktt0p000_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt0p000Kttm0p500": "ttH_Kt0p000Kttm0p500_{era}/output_TTHToGG_Kt0p000Kttm0p500_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt0p354Kttm0p354": "ttH_Kt0p354Kttm0p354_{era}/output_TTHToGG_Kt0p354Kttm0p354_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt1p500Ktt0p000": "ttH_Kt1p500Ktt0p000_{era}/output_TTHToGG_Kt1p500Ktt0p000_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt1p061Ktt1p061": "ttH_Kt1p061Ktt1p061_{era}/output_TTHToGG_Kt1p061Ktt1p061_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt0p000Ktt1p500": "ttH_Kt0p000Ktt1p500_{era}/output_TTHToGG_Kt0p000Ktt1p500_M125_13TeV_amcatnlo_pythia8.root",
    "tthKtm1p500Ktt0p000": "ttH_Ktm1p500Ktt0p000_{era}/output_TTHToGG_Ktm1p500Ktt0p000_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt0p000Kttm1p500": "ttH_Kt0p000Kttm1p500_{era}/output_TTHToGG_Kt0p000Kttm1p500_M125_13TeV_amcatnlo_pythia8.root",
    "tthKt1p061Kttm1p061": "ttH_Kt1p061Kttm1p061_{era}/output_TTHToGG_Kt1p061Kttm1p061_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLep": "tHqLep_{era}/output_THQtoGG_lep_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHad": "tHqHad_{era}/output_THQtoGG_had_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepCPodd": "tHqLep_CPodd_{era}/output_THQtoGG_lep_CPodd_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadCPodd": "tHqHad_CPodd_{era}/output_THQtoGG_had_CPodd_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKtm1Ktt0": "tHqLep_Ktm1Ktt0_{era}/output_THQtoGG_lep_Ktm1Ktt0_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKtm1Ktt0": "tHqHad_Ktm1Ktt0_{era}/output_THQtoGG_had_Ktm1Ktt0_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt0p7Ktt0p7": "tHqLep_Kt0p7Ktt0p7_{era}/output_THQtoGG_lep_Kt0p7Ktt0p7_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt0p7Ktt0p7": "tHqHad_Kt0p7Ktt0p7_{era}/output_THQtoGG_had_Kt0p7Ktt0p7_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt0p7Kttm0p7": "tHqLep_Kt0p7Kttm0p7_{era}/output_THQtoGG_lep_Kt0p7Kttm0p7_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt0p7Kttm0p7": "tHqHad_Kt0p7Kttm0p7_{era}/output_THQtoGG_had_Kt0p7Kttm0p7_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt0Kttm1": "tHqLep_Kt0Kttm1_{era}/output_THQtoGG_lep_Kt0Kttm1_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt0Kttm1": "tHqHad_Kt0Kttm1_{era}/output_THQtoGG_had_Kt0Kttm1_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt0Ktt0": "tHqLep_Kt0Ktt0_{era}/output_THQtoGG_lep_Kt0Ktt0_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt0Ktt0": "tHqHad_Kt0Ktt0_{era}/output_THQtoGG_had_Kt0Ktt0_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt0p500Ktt0p000": "tHqLep_Kt0p500Ktt0p000_{era}/output_THQtoGG_lep_Kt0p500Ktt0p000_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt0p500Ktt0p000": "tHqHad_Kt0p500Ktt0p000_{era}/output_THQtoGG_had_Kt0p500Ktt0p000_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt0p354Ktt0p354": "tHqLep_Kt0p354Ktt0p354_{era}/output_THQtoGG_lep_Kt0p354Ktt0p354_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt0p354Ktt0p354": "tHqHad_Kt0p354Ktt0p354_{era}/output_THQtoGG_had_Kt0p354Ktt0p354_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt0p000Ktt0p500": "tHqLep_Kt0p000Ktt0p500_{era}/output_THQtoGG_lep_Kt0p000Ktt0p500_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt0p000Ktt0p500": "tHqHad_Kt0p000Ktt0p500_{era}/output_THQtoGG_had_Kt0p000Ktt0p500_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKtm0p500Ktt0p000": "tHqLep_Ktm0p500Ktt0p000_{era}/output_THQtoGG_lep_Ktm0p500Ktt0p000_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKtm0p500Ktt0p000": "tHqHad_Ktm0p500Ktt0p000_{era}/output_THQtoGG_had_Ktm0p500Ktt0p000_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt0p000Kttm0p500": "tHqLep_Kt0p000Kttm0p500_{era}/output_THQtoGG_lep_Kt0p000Kttm0p500_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt0p000Kttm0p500": "tHqHad_Kt0p000Kttm0p500_{era}/output_THQtoGG_had_Kt0p000Kttm0p500_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt0p354Kttm0p354": "tHqLep_Kt0p354Kttm0p354_{era}/output_THQtoGG_lep_Kt0p354Kttm0p354_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt0p354Kttm0p354": "tHqHad_Kt0p354Kttm0p354_{era}/output_THQtoGG_had_Kt0p354Kttm0p354_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt1p500Ktt0p000": "tHqLep_Kt1p500Ktt0p000_{era}/output_THQtoGG_lep_Kt1p500Ktt0p000_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt1p500Ktt0p000": "tHqHad_Kt1p500Ktt0p000_{era}/output_THQtoGG_had_Kt1p500Ktt0p000_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt1p061Ktt1p061": "tHqLep_Kt1p061Ktt1p061_{era}/output_THQtoGG_lep_Kt1p061Ktt1p061_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt1p061Ktt1p061": "tHqHad_Kt1p061Ktt1p061_{era}/output_THQtoGG_had_Kt1p061Ktt1p061_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt0p000Ktt1p500": "tHqLep_Kt0p000Ktt1p500_{era}/output_THQtoGG_lep_Kt0p000Ktt1p500_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt0p000Ktt1p500": "tHqHad_Kt0p000Ktt1p500_{era}/output_THQtoGG_had_Kt0p000Ktt1p500_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKtm1p500Ktt0p000": "tHqLep_Ktm1p500Ktt0p000_{era}/output_THQtoGG_lep_Ktm1p500Ktt0p000_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKtm1p500Ktt0p000": "tHqHad_Ktm1p500Ktt0p000_{era}/output_THQtoGG_had_Ktm1p500Ktt0p000_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt0p000Kttm1p500": "tHqLep_Kt0p000Kttm1p500_{era}/output_THQtoGG_lep_Kt0p000Kttm1p500_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt0p000Kttm1p500": "tHqHad_Kt0p000Kttm1p500_{era}/output_THQtoGG_had_Kt0p000Kttm1p500_M125_13TeV_amcatnlo_pythia8.root",
    "tHqLepKt1p061Kttm1p061": "tHqLep_Kt1p061Kttm1p061_{era}/output_THQtoGG_lep_Kt1p061Kttm1p061_M125_13TeV_amcatnlo_pythia8.root",
    "tHqHadKt1p061Kttm1p061": "tHqHad_Kt1p061Kttm1p061_{era}/output_THQtoGG_had_Kt1p061Kttm1p061_M125_13TeV_amcatnlo_pythia8.root",
    "tHW": "tHW_{era}/output_THWtoGG_M125_13TeV_madgraph_pythia8.root",
    "tHWCPodd": "tHW_CPodd_{era}/output_THWtoGG_CPodd_M125_13TeV_madgraph_pythia8.root",
    "tHWKtm1Ktt0": "tHW_Ktm1Ktt0_{era}/output_THWtoGG_Ktm1Ktt0_M125_13TeV_madgraph_pythia8.root",
    "tHWKt0p7Ktt0p7": "tHW_Kt0p7Ktt0p7_{era}/output_THWtoGG_Kt0p7Ktt0p7_M125_13TeV_madgraph_pythia8.root",
    "tHWKt0p7Kttm0p7": "tHW_Kt0p7Kttm0p7_{era}/output_THWtoGG_Kt0p7Kttm0p7_M125_13TeV_madgraph_pythia8.root",
    "tHWKt0Kttm1": "tHW_Kt0Kttm1_{era}/output_THWtoGG_Kt0Kttm1_M125_13TeV_madgraph_pythia8.root",
    "tHWKt0Ktt0": "tHW_Kt0Ktt0_{era}/output_THWtoGG_Kt0Ktt0_M125_13TeV_madgraph_pythia8.root",
    "tHWKt0p500Ktt0p000": "tHW_Kt0p500Ktt0p000_{era}/output_THWtoGG_Kt0p500Ktt0p000_M125_13TeV_madgraph_pythia8.root",
    "tHWKt0p354Ktt0p354": "tHW_Kt0p354Ktt0p354_{era}/output_THWtoGG_Kt0p354Ktt0p354_M125_13TeV_madgraph_pythia8.root",
    "tHWKt0p000Ktt0p500": "tHW_Kt0p000Ktt0p500_{era}/output_THWtoGG_Kt0p000Ktt0p500_M125_13TeV_madgraph_pythia8.root",
    "tHWKtm0p500Ktt0p000": "tHW_Ktm0p500Ktt0p000_{era}/output_THWtoGG_Ktm0p500Ktt0p000_M125_13TeV_madgraph_pythia8.root",
    "tHWKt0p000Kttm0p500": "tHW_Kt0p000Kttm0p500_{era}/output_THWtoGG_Kt0p000Kttm0p500_M125_13TeV_madgraph_pythia8.root",
    "tHWKt0p354Kttm0p354": "tHW_Kt0p354Kttm0p354_{era}/output_THWtoGG_Kt0p354Kttm0p354_M125_13TeV_madgraph_pythia8.root",
    "tHWKt1p500Ktt0p000": "tHW_Kt1p500Ktt0p000_{era}/output_THWtoGG_Kt1p500Ktt0p000_M125_13TeV_madgraph_pythia8.root",
    "tHWKt1p061Ktt1p061": "tHW_Kt1p061Ktt1p061_{era}/output_THWtoGG_Kt1p061Ktt1p061_M125_13TeV_madgraph_pythia8.root",
    "tHWKt0p000Ktt1p500": "tHW_Kt0p000Ktt1p500_{era}/output_THWtoGG_Kt0p000Ktt1p500_M125_13TeV_madgraph_pythia8.root",
    "tHWKtm1p500Ktt0p000": "tHW_Ktm1p500Ktt0p000_{era}/output_THWtoGG_Ktm1p500Ktt0p000_M125_13TeV_madgraph_pythia8.root",
    "tHWKt0p000Kttm1p500": "tHW_Kt0p000Kttm1p500_{era}/output_THWtoGG_Kt0p000Kttm1p500_M125_13TeV_madgraph_pythia8.root",
    "tHWKt1p061Kttm1p061": "tHW_Kt1p061Kttm1p061_{era}/output_THWtoGG_Kt1p061Kttm1p061_M125_13TeV_madgraph_pythia8.root",
    # data
    "Data": "Data/allData.root",
    # resonant backgrounds
    "vh": "VH_{era}/output_VHToGG_M125_13TeV_amcatnlo_pythia8.root",
    "ggh": "GluGluH_{era}/output_GluGluHToGG_M125_13TeV_amcatnloFXFX_pythia8.root",
    "vbf": "VBFH_{era}/output_VBFHToGG_M125_13TeV_amcatnlo_pythia8.root",
    "bbh": "bbH_{era}/output_BBHToGG_M125_13TeV_powheg_pythia8.root",
}


def build_input_path(root_base: str, era: str, mode: str) -> str:
    if mode not in MODE_INPUTS:
        raise ValueError(f"Unknown mode '{mode}'. Supported: {sorted(MODE_INPUTS.keys())}")
    rel = MODE_INPUTS[mode].format(era=era)
    return os.path.join(root_base, rel)


def run_trees2ws(
    input_config: str,
    input_tree_file: str,
    mass: int,
    mode: str,
    era: str,
    wsdir: str,
    do_systematics: bool,
    do_in_out_splitting: bool,
):
    cmd = [
        "python3", "trees2ws.py",
        "--inputConfig", input_config,
        "--inputTreeFile", input_tree_file,
        "--inputMass", str(mass),
        "--productionMode", mode,
        "--year", era,
        "--outputWSDir", wsdir,
    ]
    if do_in_out_splitting:
        cmd.append("--doInOutSplitting")
    if do_systematics:
        cmd.append("--doSystematics")
    print("Running:", " ".join(cmd))
    subprocess.check_call(cmd)


def run_one_task(
    input_config: str,
    root_base: str,
    mass: int,
    mode: str,
    era: str,
    wsdir: str,
    do_systematics: bool,
    do_in_out_splitting: bool,
) -> str:
    input_tree_file = build_input_path(root_base, era, mode)
    if not os.path.isfile(input_tree_file):
        msg = f"[WARN] Input file missing for mode {mode}, era {era}: {input_tree_file}"
        print(msg)
        return msg
    run_trees2ws(
        input_config=input_config,
        input_tree_file=input_tree_file,
        mass=mass,
        mode=mode,
        era=era,
        wsdir=wsdir,
        do_systematics=do_systematics,
        do_in_out_splitting=do_in_out_splitting,
    )
    return f"[OK] {mode} {era}"


def main():
    parser = argparse.ArgumentParser(description="Run trees2ws.py over eras/modes like the bash script.")
    parser.add_argument("--base-ws-dir", required=True, help="Base workspace output dir (will contain per-era subdirs)")
    parser.add_argument("--root-base", default="/net/data_cms3a-1/mausolf/HttCPAnalysis/finalFitPreparation/outputForFinalFits_03Sept2025/root", help="Base directory containing per-mode ROOT files")
    parser.add_argument("--input-config", default="config_ttH_tH_2022_2023.py", help="trees2ws input config path")
    parser.add_argument("--eras", default="2022preEE,2022postEE,2023preBPix,2023postBPix", help="Comma-separated eras to process")
    parser.add_argument("--modes", default="tth", help="Comma-separated production modes to run. See MODE_INPUTS keys for options.")
    parser.add_argument("--mass", type=int, default=125, help="H mass to pass to trees2ws")
    parser.add_argument("--clean", action="store_true", help="Wipe base-ws-dir before running")
    parser.add_argument("--do-systematics", action="store_true", help="Pass --doSystematics to trees2ws.py")
    parser.add_argument("--max-procs", type=int, default=1, help="Max concurrent trees2ws jobs (>=2 enables parallel)")
    parser.add_argument(
        "--do-in-out-splitting",
        action="store_true",
        help="Forward --doInOutSplitting to trees2ws.py (use for fiducial runs).",
    )

    args = parser.parse_args()

    eras = [e.strip() for e in args.eras.split(",") if e.strip()]
    modes = [m.strip() for m in args.modes.split(",") if m.strip()]

    # Mirror the bash: wipe and recreate base dir
    if args.clean and os.path.isdir(args.base_ws_dir):
        print(f"Removing existing base dir: {args.base_ws_dir}")
        shutil.rmtree(args.base_ws_dir)
    os.makedirs(args.base_ws_dir, exist_ok=True)

    # Prepare era directories
    era_wsdirs = {}
    for era in eras:
        print(f">>>>> Making workspaces for era: {era}")
        wsdir = os.path.join(args.base_ws_dir, era)
        os.makedirs(wsdir, exist_ok=True)
        era_wsdirs[era] = wsdir

    # Build all tasks
    tasks = [(mode, era) for era in eras for mode in modes]

    if args.max_procs > 1:
        print(f"Running up to {args.max_procs} jobs in parallel...")
        with ThreadPoolExecutor(max_workers=args.max_procs) as ex:
            futures = {
                ex.submit(
                    run_one_task,
                    args.input_config,
                    args.root_base,
                    args.mass,
                    mode,
                    era,
                    era_wsdirs[era],
                    args.do_systematics,
                    args.do_in_out_splitting,
                ): (mode, era)
                for (mode, era) in tasks
            }
            for fut in as_completed(futures):
                mode, era = futures[fut]
                try:
                    res = fut.result()
                    print(res)
                except subprocess.CalledProcessError as cpe:
                    print(f"[FAIL] {mode} {era}: returncode={cpe.returncode}")
                except Exception as e:
                    print(f"[FAIL] {mode} {era}: {e}")
    else:
        # Run sequentially
        for era in eras:
            wsdir = era_wsdirs[era]
            for mode in modes:
                try:
                    msg = run_one_task(
                        input_config=args.input_config,
                        root_base=args.root_base,
                        mass=args.mass,
                        mode=mode,
                        era=era,
                        wsdir=wsdir,
                        do_systematics=args.do_systematics,
                        do_in_out_splitting=args.do_in_out_splitting,
                    )
                    print(msg)
                except subprocess.CalledProcessError as cpe:
                    print(f"[FAIL] {mode} {era}: returncode={cpe.returncode}")
                except Exception as e:
                    print(f"[FAIL] {mode} {era}: {e}")

    print(">>> All done!")


if __name__ == "__main__":
    main()
