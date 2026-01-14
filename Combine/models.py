models = {
"r_2D":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLep_incl.*:r_tHq[1,-25,25]" \
    --PO "map=.*/tHqHad_incl.*:r_tHq[1,-25,25]" \
    --PO "map=.*/tth_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/tHW_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
""",
"r_2D_fiducial":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLep_in.*:r_tHq[1,-25,25]" \
    --PO "map=.*/tHqHad_in.*:r_tHq[1,-25,25]" \
    --PO "map=.*/tth_in.*:r_ttH[1,-1,3]" \
    --PO "map=.*/tHW_in.*:r_ttH[1,-1,3]" \
    --PO "map=.*/ggh_in.*:1" \
    --PO "map=.*/ggh_out.*:1" \
    --PO "map=.*/bbh_in.*:1" \
    --PO "map=.*/bbh_out.*:1" \
    --PO "map=.*/vbf_in.*:1" \
    --PO "map=.*/vbf_out.*:1" \
    --PO "map=.*/vh_in.*:1" \
    --PO "map=.*/vh_out.*:1" \
    --PO "map=.*/tHqLep_out.*:1" \
    --PO "map=.*/tHqHad_out.*:1" \
    --PO "map=.*/tth_out.*:1" \
    --PO "map=.*/tHW_out.*:1"
""",
"r_tHq_1D":
  """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
     --PO "map=.*/tHqLep_incl.*:r_tHq[1,-25,25]" \
     --PO "map=.*/tHqHad_incl.*:r_tHq[1,-25,25]" \
     --PO "map=.*/tth_incl.*:1" \
     --PO "map=.*/tHW_incl.*:1" \
     --PO "map=.*/ggh_incl.*:1" \
     --PO "map=.*/bbH_incl.*:1" \
     --PO "map=.*/vbf_incl.*:1" \
     --PO "map=.*/vh_incl.*:1"
     """,

"r_tHq_1D_ttH_profiled":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLep_incl.*:r_tHq[1,-25,25]" \
    --PO "map=.*/tHqHad_incl.*:r_tHq[1,-25,25]" \
    --PO "map=.*/tth_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/tHW_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
    """,

# the following two are for comparison with previous measurements, where tHW was part of tH
"r_tHq_plus_tHW_1D":
  """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
     --PO "map=.*/tHqLep_incl.*:r_tH[1,-25,25]" \
     --PO "map=.*/tHqHad_incl.*:r_tH[1,-25,25]" \
     --PO "map=.*/tth_incl.*:1" \
     --PO "map=.*/tHW_incl.*:r_tH[1,-25,25]" \
     --PO "map=.*/ggh_incl.*:1" \
     --PO "map=.*/bbH_incl.*:1" \
     --PO "map=.*/vbf_incl.*:1" \
     --PO "map=.*/vh_incl.*:1"
     """,

"r_tHq_plus_tHW_1D_ttH_profiled":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLep_incl.*:r_tH[1,-25,25]" \
    --PO "map=.*/tHqHad_incl.*:r_tH[1,-25,25]" \
    --PO "map=.*/tth_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/tHW_incl.*:r_tH[1,-1,3]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
    """,

"r_ttH_1D":
  """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
     --PO "map=.*/tHqLep_incl.*:1" \
     --PO "map=.*/tHqHad_incl.*:1" \
     --PO "map=.*/tth_incl.*:r_ttH[1,-1,3]" \
     --PO "map=.*/tHW_incl.*:r_ttH[1,-1,3]" \
     --PO "map=.*/ggh_incl.*:1" \
     --PO "map=.*/bbH_incl.*:1" \
     --PO "map=.*/vbf_incl.*:1" \
     --PO "map=.*/vh_incl.*:1"
     """,

"r_ttH_1D_tHq_profiled":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLep_incl.*:r_tHq[1,-25,25]" \
    --PO "map=.*/tHqHad_incl.*:r_tHq[1,-25,25]" \
    --PO "map=.*/tth_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/tHW_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
    """,

# only one POI for significance? warning: ModelConfig 'ModelConfig' defines more than one parameter of interest. This is not supported in some statistical methods.
  "Z_ttH": 
  """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
      --PO "map=.*/tHqLep_incl.*:1" \
      --PO "map=.*/tHqHad_incl.*:1" \
      --PO \"map=.*/vbf_incl.*:1" \
      --PO \"map=.*/vh_incl.*:1" \
      --PO \"map=.*/ggh_incl.*:1" \
      --PO "map=.*/bbH_incl.*:1" \
      --PO "map=.*/tth_incl.*:r_ttH[1,0,5]"
      --PO "map=.*/tHW_incl.*:r_ttH[1,0,5]" \
      """,

  "Z_tHq":
    """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
       --PO "map=.*/tHqLep_incl.*:r_tHq[1,0,25]" \
       --PO "map=.*/tHqHad_incl.*:r_tHq[1,0,25]" \
       --PO "map=.*/tth_incl.*:1" \
       --PO "map=.*/ggh_incl.*:1" \
       --PO "map=.*/bbH_incl.*:1" \
       --PO "map=.*/tHW_incl.*:1" \
       --PO "map=.*/vbf_incl.*:1" \
       --PO "map=.*/vh_incl.*:1"
       """,

  "Z_tHq_plus_tHW":
    """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
       --PO "map=.*/tHqLep_incl.*:r_tH[1,0,25]" \
       --PO "map=.*/tHqHad_incl.*:r_tH[1,0,25]" \
       --PO "map=.*/tth_incl.*:1" \
       --PO "map=.*/ggh_incl.*:1" \
       --PO "map=.*/bbH_incl.*:1" \
       --PO "map=.*/tHW_incl.*:r_tH[1,0,25]" \
       --PO "map=.*/vbf_incl.*:1" \
       --PO "map=.*/vh_incl.*:1"
       """,


  "limit_tHq":
    """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
       --PO "map=.*/tHqLep_incl.*:r_tHq[1,0,25]" \
       --PO "map=.*/tHqHad_incl.*:r_tHq[1,0,25]" \
       --PO "map=.*/tth_incl.*:1" \
       --PO "map=.*/tHW_incl.*:1" \
       --PO "map=.*/ggh_incl.*:1" \
       --PO "map=.*/bbH_incl.*:1" \
       --PO "map=.*/vbf_incl.*:1" \
       --PO "map=.*/vh_incl.*:1"
       """,

  "limit_tHq_plus_tHW":
    """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
       --PO "map=.*/tHqLep_incl.*:r_tH[1,0,25]" \
       --PO "map=.*/tHqHad_incl.*:r_tH[1,0,25]" \
       --PO "map=.*/tth_incl.*:1" \
       --PO "map=.*/tHW_incl.*:r_tH[1,0,25]" \
       --PO "map=.*/ggh_incl.*:1" \
       --PO "map=.*/bbH_incl.*:1" \
       --PO "map=.*/vbf_incl.*:1" \
       --PO "map=.*/vh_incl.*:1"
       """,


# used this just for tests
  "limit_tHq_HybridNew":
    """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
       --PO "map=.*/tHqLep_incl.*:r_tHq[1,0,25]" \
       --PO "map=.*/tHqHad_incl.*:r_tHq[1,0,25]" \
       --PO "map=.*/tth_incl.*:1" \
       --PO "map=.*/ggh_incl.*:1" \
       --PO "map=.*/bbH_incl.*:1" \
       --PO "map=.*/vbf_incl.*:1" \
       --PO "map=.*/vh_incl.*:1"
       """,

# --------------------------------------------------------------------------
# BSM template variants (CP-odd, ktm1) with flattened process names. Will be tested against SM Asimov datasets to study model dependence.
# --------------------------------------------------------------------------

"r_2D_SM":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLep_incl.*:r_tHq[1,-25,25]" \
    --PO "map=.*/tHqHad_incl.*:r_tHq[1,-25,25]" \
    --PO "map=.*/tth_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/tHW_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
""",



"r_2D_CPodd":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepCPodd_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tHqHadCPodd_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tthCPodd_incl.*:r_ttH[1,0,5]" \
    --PO "map=.*/tHWCPodd_incl.*:r_ttH[1,0,5]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
""",
"r_2D_CPodd_fiducial":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepCPodd_in.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tHqHadCPodd_in.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tthCPodd_in.*:r_ttH[1,0,5]" \
    --PO "map=.*/tHWCPodd_in.*:r_ttH[1,0,5]" \
    --PO "map=.*/ggh_in.*:1" \
    --PO "map=.*/ggh_out.*:1" \
    --PO "map=.*/bbh_in.*:1" \
    --PO "map=.*/bbh_out.*:1" \
    --PO "map=.*/vbf_in.*:1" \
    --PO "map=.*/vbf_out.*:1" \
    --PO "map=.*/vh_in.*:1" \
    --PO "map=.*/vh_out.*:1" \
    --PO "map=.*/tHqLepCPodd_out.*:1" \
    --PO "map=.*/tHqHadCPodd_out.*:1" \
    --PO "map=.*/tthCPodd_out.*:1" \
    --PO "map=.*/tHWCPodd_out.*:1"
""",

"r_2D_Ktm1":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKtm1Ktt0_incl.*:r_tHq[1,-1,3]" \
    --PO "map=.*/tHqHadKtm1Ktt0_incl.*:r_tHq[1,-1,3]" \
    --PO "map=.*/tth_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/tHWKtm1Ktt0_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
""",
"r_2D_Ktm1Ktt0":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKtm1Ktt0_incl.*:r_tHq[1,-1,3]" \
    --PO "map=.*/tHqHadKtm1Ktt0_incl.*:r_tHq[1,-1,3]" \
    --PO "map=.*/tth_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/tHWKtm1Ktt0_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
""",
"r_2D_Ktm1Ktt0_fiducial":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKtm1Ktt0_in.*:r_tHq[1,-1,3]" \
    --PO "map=.*/tHqHadKtm1Ktt0_in.*:r_tHq[1,-1,3]" \
    --PO "map=.*/tth_in.*:r_ttH[1,-1,3]" \
    --PO "map=.*/tHWKtm1Ktt0_in.*:r_ttH[1,-1,3]" \
    --PO "map=.*/ggh_in.*:1" \
    --PO "map=.*/ggh_out.*:1" \
    --PO "map=.*/bbh_in.*:1" \
    --PO "map=.*/bbh_out.*:1" \
    --PO "map=.*/vbf_in.*:1" \
    --PO "map=.*/vbf_out.*:1" \
    --PO "map=.*/vh_in.*:1" \
    --PO "map=.*/vh_out.*:1" \
    --PO "map=.*/tHqLepKtm1Ktt0_out.*:1" \
    --PO "map=.*/tHqHadKtm1Ktt0_out.*:1" \
    --PO "map=.*/tth_out.*:1" \
    --PO "map=.*/tHWKtm1Ktt0_out.*:1"
""",

"r_2D_Kt0p7Ktt0p7":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKt0p7Ktt0p7_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tHqHadKt0p7Ktt0p7_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tthKt0p7Ktt0p7_incl.*:r_ttH[1,-1,5]" \
    --PO "map=.*/tHWKt0p7Ktt0p7_incl.*:r_ttH[1,-1,5]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
""",
"r_2D_Kt0p7Ktt0p7_fiducial":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKt0p7Ktt0p7_in.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tHqHadKt0p7Ktt0p7_in.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tthKt0p7Ktt0p7_in.*:r_ttH[1,-1,5]" \
    --PO "map=.*/tHWKt0p7Ktt0p7_in.*:r_ttH[1,-1,5]" \
    --PO "map=.*/ggh_in.*:1" \
    --PO "map=.*/ggh_out.*:1" \
    --PO "map=.*/bbh_in.*:1" \
    --PO "map=.*/bbh_out.*:1" \
    --PO "map=.*/vbf_in.*:1" \
    --PO "map=.*/vbf_out.*:1" \
    --PO "map=.*/vh_in.*:1" \
    --PO "map=.*/vh_out.*:1" \
    --PO "map=.*/tHqLepKt0p7Ktt0p7_out.*:1" \
    --PO "map=.*/tHqHadKt0p7Ktt0p7_out.*:1" \
    --PO "map=.*/tthKt0p7Ktt0p7_out.*:1" \
    --PO "map=.*/tHWKt0p7Ktt0p7_out.*:1"
""",

"r_2D_Kt0p7Kttm0p7":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKt0p7Kttm0p7_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tHqHadKt0p7Kttm0p7_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tthKt0p7Kttm0p7_incl.*:r_ttH[1,-1,5]" \
    --PO "map=.*/tHWKt0p7Kttm0p7_incl.*:r_ttH[1,-1,5]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
""",
"r_2D_Kt0p7Kttm0p7_fiducial":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKt0p7Kttm0p7_in.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tHqHadKt0p7Kttm0p7_in.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tthKt0p7Kttm0p7_in.*:r_ttH[1,-1,5]" \
    --PO "map=.*/tHWKt0p7Kttm0p7_in.*:r_ttH[1,-1,5]" \
    --PO "map=.*/ggh_in.*:1" \
    --PO "map=.*/ggh_out.*:1" \
    --PO "map=.*/bbh_in.*:1" \
    --PO "map=.*/bbh_out.*:1" \
    --PO "map=.*/vbf_in.*:1" \
    --PO "map=.*/vbf_out.*:1" \
    --PO "map=.*/vh_in.*:1" \
    --PO "map=.*/vh_out.*:1" \
    --PO "map=.*/tHqLepKt0p7Kttm0p7_out.*:1" \
    --PO "map=.*/tHqHadKt0p7Kttm0p7_out.*:1" \
    --PO "map=.*/tthKt0p7Kttm0p7_out.*:1" \
    --PO "map=.*/tHWKt0p7Kttm0p7_out.*:1"
""",

"r_2D_Kt0Kttm1":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKt0Kttm1_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tHqHadKt0Kttm1_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tthKt0Kttm1_incl.*:r_ttH[1,-1,5]" \
    --PO "map=.*/tHWKt0Kttm1_incl.*:r_ttH[1,-1,5]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
""",
"r_2D_Kt0Kttm1_fiducial":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKt0Kttm1_in.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tHqHadKt0Kttm1_in.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tthKt0Kttm1_in.*:r_ttH[1,-1,5]" \
    --PO "map=.*/tHWKt0Kttm1_in.*:r_ttH[1,-1,5]" \
    --PO "map=.*/ggh_in.*:1" \
    --PO "map=.*/ggh_out.*:1" \
    --PO "map=.*/bbh_in.*:1" \
    --PO "map=.*/bbh_out.*:1" \
    --PO "map=.*/vbf_in.*:1" \
    --PO "map=.*/vbf_out.*:1" \
    --PO "map=.*/vh_in.*:1" \
    --PO "map=.*/vh_out.*:1" \
    --PO "map=.*/tHqLepKt0Kttm1_out.*:1" \
    --PO "map=.*/tHqHadKt0Kttm1_out.*:1" \
    --PO "map=.*/tthKt0Kttm1_out.*:1" \
    --PO "map=.*/tHWKt0Kttm1_out.*:1"
""",

"r_2D_Kt0Ktt0":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKt0Ktt0_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tHqHadKt0Ktt0_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tthKt0Ktt0_incl.*:r_ttH[1,-1,5]" \
    --PO "map=.*/tHWKt0Ktt0_incl.*:r_ttH[1,-1,5]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
""",
"r_2D_Kt0Ktt0_fiducial":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKt0Ktt0_in.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tHqHadKt0Ktt0_in.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tthKt0Ktt0_in.*:r_ttH[1,-1,5]" \
    --PO "map=.*/tHWKt0Ktt0_in.*:r_ttH[1,-1,5]" \
    --PO "map=.*/ggh_in.*:1" \
    --PO "map=.*/ggh_out.*:1" \
    --PO "map=.*/bbh_in.*:1" \
    --PO "map=.*/bbh_out.*:1" \
    --PO "map=.*/vbf_in.*:1" \
    --PO "map=.*/vbf_out.*:1" \
    --PO "map=.*/vh_in.*:1" \
    --PO "map=.*/vh_out.*:1" \
    --PO "map=.*/tHqLepKt0Ktt0_out.*:1" \
    --PO "map=.*/tHqHadKt0Ktt0_out.*:1" \
    --PO "map=.*/tthKt0Ktt0_out.*:1" \
    --PO "map=.*/tHWKt0Ktt0_out.*:1"
""",

"r_tHq_1D_CPodd":
  """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
     --PO "map=.*/tHqLepCPodd_incl.*:r_tHq[1,-1,5]" \
     --PO "map=.*/tHqHadCPodd_incl.*:r_tHq[1,-1,5]" \
     --PO "map=.*/tthCPodd_incl.*:1" \
     --PO "map=.*/tHWCPodd_incl.*:1" \
     --PO "map=.*/ggh_incl.*:1" \
     --PO "map=.*/bbH_incl.*:1" \
     --PO "map=.*/vbf_incl.*:1" \
     --PO "map=.*/vh_incl.*:1"
     """,

"r_tHq_1D_Ktm1":
  """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
     --PO "map=.*/tHqLepKtm1_incl.*:r_tHq[1,-1,3]" \
     --PO "map=.*/tHqHadKtm1_incl.*:r_tHq[1,-1,3]" \
     --PO "map=.*/tth_incl.*:1" \
     --PO "map=.*/tHWKtm1_incl.*:1" \
     --PO "map=.*/ggh_incl.*:1" \
     --PO "map=.*/bbH_incl.*:1" \
     --PO "map=.*/vbf_incl.*:1" \
     --PO "map=.*/vh_incl.*:1"
     """,

"r_tHq_1D_ttH_profiled_CPodd":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepCPodd_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tHqHadCPodd_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tthCPodd_incl.*:r_ttH[1,0,5]" \
    --PO "map=.*/tHWCPodd_incl.*:r_ttH[1,0,5]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
    """,

"r_tHq_1D_ttH_profiled_Ktm1":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKtm1_incl.*:r_tHq[1,-1,3]" \
    --PO "map=.*/tHqHadKtm1_incl.*:r_tHq[1,-1,3]" \
    --PO "map=.*/tth_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/tHWKtm1_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
    """,

"r_ttH_1D_CPodd":
  """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
     --PO "map=.*/tHqLepCPodd_incl.*:1" \
     --PO "map=.*/tHqHadCPodd_incl.*:1" \
     --PO "map=.*/tthCPodd_incl.*:r_ttH[1,-1,3]" \
     --PO "map=.*/tHWCPodd_incl.*:r_ttH[1,-1,3]" \
     --PO "map=.*/ggh_incl.*:1" \
     --PO "map=.*/bbH_incl.*:1" \
     --PO "map=.*/vbf_incl.*:1" \
     --PO "map=.*/vh_incl.*:1"
     """,

"r_ttH_1D_Ktm1":
  """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
     --PO "map=.*/tHqLepKtm1_incl.*:1" \
     --PO "map=.*/tHqHadKtm1_incl.*:1" \
     --PO "map=.*/tth_incl.*:r_ttH[1,-1,3]" \
     --PO "map=.*/tHWKtm1_incl.*:r_ttH[1,-1,3]" \
     --PO "map=.*/ggh_incl.*:1" \
     --PO "map=.*/bbH_incl.*:1" \
     --PO "map=.*/vbf_incl.*:1" \
     --PO "map=.*/vh_incl.*:1"
     """,

"r_ttH_1D_tHq_profiled_CPodd":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepCPodd_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tHqHadCPodd_incl.*:r_tHq[1,-1,5]" \
    --PO "map=.*/tthCPodd_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/tHWCPodd_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
    """,

"r_ttH_1D_tHq_profiled_Ktm1":
"""-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
    --PO "map=.*/tHqLepKtm1_incl.*:r_tHq[1,-1,3]" \
    --PO "map=.*/tHqHadKtm1_incl.*:r_tHq[1,-1,3]" \
    --PO "map=.*/tth_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/tHWKtm1_incl.*:r_ttH[1,-1,3]" \
    --PO "map=.*/ggh_incl.*:1" \
    --PO "map=.*/bbH_incl.*:1" \
    --PO "map=.*/vbf_incl.*:1" \
    --PO "map=.*/vh_incl.*:1"
    """,

"Z_tHq_CPodd":
    """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
       --PO "map=.*/tHqLepCPodd_incl.*:r_tHq[1,0,5]" \
       --PO "map=.*/tHqHadCPodd_incl.*:r_tHq[1,0,5]" \
       --PO "map=.*/tthCPodd_incl.*:1" \
       --PO "map=.*/ggh_incl.*:1" \
       --PO "map=.*/bbH_incl.*:1" \
       --PO "map=.*/tHWCPodd_incl.*:1" \
       --PO "map=.*/vbf_incl.*:1" \
       --PO "map=.*/vh_incl.*:1"
       """,

"Z_tHq_Ktm1":
    """-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
       --PO "map=.*/tHqLepKtm1_incl.*:r_tHq[1,0,2.5]" \
       --PO "map=.*/tHqHadKtm1_incl.*:r_tHq[1,0,2.5]" \
       --PO "map=.*/tth_incl.*:1" \
       --PO "map=.*/ggh_incl.*:1" \
       --PO "map=.*/bbH_incl.*:1" \
       --PO "map=.*/tHWKtm1_incl.*:1" \
       --PO "map=.*/vbf_incl.*:1" \
       --PO "map=.*/vh_incl.*:1"
       """,









  "mu_inclusive_wsyst":"",

  "mu_fiducial":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_in.*:r[1,0,2]\" \
--PO \"map=.*/vbf_in.*:r[1,0,2]\" \
--PO \"map=.*/vh_in.*:r[1,0,2]\" \
--PO \"map=.*/tth_in.*:r[1,0,2]\"",

  "mu_fiducial_observed":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
  --PO \"map=.*/ggh_in.*:r[1,0,2]\" \
  --PO \"map=.*/vbf_in.*:r[1,0,2]\" \
  --PO \"map=.*/vh_in.*:r[1,0,2]\" \
  --PO \"map=.*/tth_in.*:r[1,0,2]\"",

#   "mu":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
# --PO \"map=.*/ggH.*:r_ggH[1,0,2]\" \
# --PO \"map=.*/bbH.*:r_ggH[1,0,2]\" \
# --PO \"map=.*/qqH.*:r_VBF[1,0,3]\" \
# --PO \"map=.*/WH_had.*:r_VH[1,0,3]\" \
# --PO \"map=.*/ZH_had.*:r_VH[1,0,3]\" \
# --PO \"map=.*/ggZH_had.*:r_VH[1,0,3]\" \
# --PO \"map=.*/WH_lep.*:r_VH[1,0,3]\" \
# --PO \"map=.*/ZH_lep.*:r_VH[1,0,3]\" \
# --PO \"map=.*/ggZH_ll.*:r_VH[1,0,3]\" \
# --PO \"map=.*/ggZH_nunu.*:r_VH[1,0,3]\" \
# --PO \"map=.*/ttH.*:r_top[1,0,3]\" \
# --PO \"map=.*/tHq.*:r_top[1,0,3]\" \
# --PO \"map=.*/tHW.*:r_top[1,0,3]\"",

  "stage0":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggH.*:r_ggH[1,0,2]\" \
--PO \"map=.*/bbH.*:r_ggH[1,0,2]\" \
--PO \"map=.*/qqH.*:r_qqH[1,0,3]\" \
--PO \"map=.*/WH_had.*:r_qqH[1,0,3]\" \
--PO \"map=.*/ZH_had.*:r_qqH[1,0,3]\" \
--PO \"map=.*/ggZH_had.*:r_ggH[1,0,2]\" \
--PO \"map=.*/WH_lep.*:r_WH_lep[1,0,5]\" \
--PO \"map=.*/ZH_lep.*:r_ZH_lep[1,0,5]\" \
--PO \"map=.*/ggZH_ll.*:r_ZH_lep[1,0,5]\" \
--PO \"map=.*/ggZH_nunu.*:r_ZH_lep[1,0,5]\" \
--PO \"map=.*/ttH.*:r_ttH[1,0,3]\" \
--PO \"map=.*/tHq.*:r_tH[1,0,15]\" \
--PO \"map=.*/tHW.*:r_tH[1,0,15]\"",

  "stage1p2_maximal":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggH_0J_PTH_0_10.*:r_ggH_0J_low[1,0,4]\" \
--PO \"map=.*/ggZH_had_0J_PTH_0_10.*:r_ggH_0J_low[1,0,4]\" \
--PO \"map=RECO_0J_PTH_0_10_Tag.*/bbH.*:r_ggH_0J_low[1,0,4]\" \
--PO \"map=.*/ggH_0J_PTH_GT10.*:r_ggH_0J_high[1,0,2]\" \
--PO \"map=.*/ggZH_had_0J_PTH_GT10.*:r_ggH_0J_high[1,0,2]\" \
--PO \"map=RECO_0J_PTH_GT10_Tag.*/bbH.*:r_ggH_0J_high[1,0,2]\" \
--PO \"map=.*/ggH_1J_PTH_0_60.*:r_ggH_1J_low[1,0,4]\" \
--PO \"map=.*/ggZH_had_1J_PTH_0_60.*:r_ggH_1J_low[1,0,4]\" \
--PO \"map=RECO_1J_PTH_0_60_Tag.*/bbH.*:r_ggH_1J_low[1,0,4]\" \
--PO \"map=.*/ggH_1J_PTH_60_120.*:r_ggH_1J_med[1,0,4]\" \
--PO \"map=.*/ggZH_had_1J_PTH_60_120.*:r_ggH_1J_med[1,0,4]\" \
--PO \"map=RECO_1J_PTH_60_120_Tag.*/bbH.*:r_ggH_1J_med[1,0,4]\" \
--PO \"map=.*/ggH_1J_PTH_120_200.*:r_ggH_1J_high[1,0,4]\" \
--PO \"map=.*/ggZH_had_1J_PTH_120_200.*:r_ggH_1J_high[1,0,4]\" \
--PO \"map=RECO_1J_PTH_120_200_Tag.*/bbH.*:r_ggH_1J_high[1,0,4]\" \
--PO \"map=.*/ggH_GE2J_MJJ_0_350_PTH_0_60.*:r_ggH_2J_low[1,0,4]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_0_350_PTH_0_60.*:r_ggH_2J_low[1,0,4]\" \
--PO \"map=RECO_GE2J_PTH_0_60_Tag.*/bbH.*:r_ggH_2J_low[1,0,4]\" \
--PO \"map=.*/ggH_GE2J_MJJ_0_350_PTH_60_120.*:r_ggH_2J_med[1,0,4]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_0_350_PTH_60_120.*:r_ggH_2J_med[1,0,4]\" \
--PO \"map=RECO_GE2J_PTH_60_120_Tag.*/bbH.*:r_ggH_2J_med[1,0,4]\" \
--PO \"map=.*/ggH_GE2J_MJJ_0_350_PTH_120_200.*:r_ggH_2J_high[1,0,4]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_0_350_PTH_120_200.*:r_ggH_2J_high[1,0,4]\" \
--PO \"map=RECO_GE2J_PTH_120_200_Tag.*/bbH.*:r_ggH_2J_high[1,0,4]\" \
--PO \"map=.*/ggH_PTH_.*:r_ggH_BSM[1,0,4]\" \
--PO \"map=.*/ggZH_had_PTH_.*:r_ggH_BSM[1,0,4]\" \
--PO \"map=RECO_PTH.*/bbH.*:r_ggH_BSM[1,0,4]\" \
--PO \"map=.*/ggH_GE2J_MJJ_350_700_.*.*:r_ggH_VBFlike[1,0,6]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_350_700_.*.*:r_ggH_VBFlike[1,0,6]\" \
--PO \"map=.*/ggH_GE2J_MJJ_GT700_.*.*:r_ggH_VBFlike[1,0,6]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_GT700_.*.*:r_ggH_VBFlike[1,0,6]\" \
--PO \"map=.*/qqH_GE2J_MJJ_350_700_PTH_0_200_.*:r_qqH_VBFlike[1,0,3]\" \
--PO \"map=.*/qqH_GE2J_MJJ_GT700_PTH_0_200_.*:r_qqH_VBFlike[1,0,3]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_350_700_PTH_0_200_.*:r_qqH_VBFlike[1,0,3]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_GT700_PTH_0_200_.*:r_qqH_VBFlike[1,0,3]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_350_700_PTH_0_200_.*:r_qqH_VBFlike[1,0,3]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_GT700_PTH_0_200_.*:r_qqH_VBFlike[1,0,3]\" \
--PO \"map=.*/qqH_GE2J_.*_PTH_GT200.*:r_qqH_BSM[1,0,4]\" \
--PO \"map=.*/WH_had_GE2J_.*_PTH_GT200.*:r_qqH_BSM[1,0,4]\" \
--PO \"map=.*/ZH_had_GE2J_.*_PTH_GT200.*:r_qqH_BSM[1,0,4]\" \
--PO \"map=.*/qqH_GE2J_MJJ_60_120.*:r_qqH_VHhad[1,0,6]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_60_120.*:r_qqH_VHhad[1,0,6]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_60_120.*:r_qqH_VHhad[1,0,6]\" \
--PO \"map=.*/WH_lep.*hgg:r_WH_lep[1,0,6]\" \
--PO \"map=.*/ZH_lep.*hgg:r_ZH_lep[1,0,6]\" \
--PO \"map=.*/ggZH_ll.*hgg:r_ZH_lep[1,0,6]\" \
--PO \"map=.*/ggZH_nunu.*hgg:r_ZH_lep[1,0,6]\" \
--PO \"map=.*/ttH.*hgg:r_ttH[1,0,3]\" \
--PO \"map=.*/tHq.*hgg:r_tH[1,0,15]\" \
--PO \"map=.*/tHW.*hgg:r_tH[1,0,15]\"",

  "stage1p2_minimal":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggH_0J_PTH_0_10.*:r_ggH_0J_low[1,0,4]\" \
--PO \"map=.*/ggZH_had_0J_PTH_0_10.*:r_ggH_0J_low[1,0,4]\" \
--PO \"map=RECO_0J_PTH_0_10_Tag.*/bbH.*:r_ggH_0J_low[1,0,4]\" \
--PO \"map=.*/ggH_0J_PTH_GT10.*:r_ggH_0J_high[1,0,2]\" \
--PO \"map=.*/ggZH_had_0J_PTH_GT10.*:r_ggH_0J_high[1,0,2]\" \
--PO \"map=RECO_0J_PTH_GT10_Tag.*/bbH.*:r_ggH_0J_high[1,0,2]\" \
--PO \"map=.*/ggH_1J_PTH_0_60.*:r_ggH_1J_low[1,0,4]\" \
--PO \"map=.*/ggZH_had_1J_PTH_0_60.*:r_ggH_1J_low[1,0,4]\" \
--PO \"map=RECO_1J_PTH_0_60_Tag.*/bbH.*:r_ggH_1J_low[1,0,4]\" \
--PO \"map=.*/ggH_1J_PTH_60_120.*:r_ggH_1J_med[1,0,4]\" \
--PO \"map=.*/ggZH_had_1J_PTH_60_120.*:r_ggH_1J_med[1,0,4]\" \
--PO \"map=RECO_1J_PTH_60_120_Tag.*/bbH.*:r_ggH_1J_med[1,0,4]\" \
--PO \"map=.*/ggH_1J_PTH_120_200.*:r_ggH_1J_high[1,0,4]\" \
--PO \"map=.*/ggZH_had_1J_PTH_120_200.*:r_ggH_1J_high[1,0,4]\" \
--PO \"map=RECO_1J_PTH_120_200_Tag.*/bbH.*:r_ggH_1J_high[1,0,4]\" \
--PO \"map=.*/ggH_GE2J_MJJ_0_350_PTH_0_60.*:r_ggH_2J_low[1,0,4]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_0_350_PTH_0_60.*:r_ggH_2J_low[1,0,4]\" \
--PO \"map=RECO_GE2J_PTH_0_60_Tag.*/bbH.*:r_ggH_2J_low[1,0,4]\" \
--PO \"map=.*/ggH_GE2J_MJJ_0_350_PTH_60_120.*:r_ggH_2J_med[1,0,4]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_0_350_PTH_60_120.*:r_ggH_2J_med[1,0,4]\" \
--PO \"map=RECO_GE2J_PTH_60_120_Tag.*/bbH.*:r_ggH_2J_med[1,0,4]\" \
--PO \"map=.*/ggH_GE2J_MJJ_0_350_PTH_120_200.*:r_ggH_2J_high[1,0,4]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_0_350_PTH_120_200.*:r_ggH_2J_high[1,0,4]\" \
--PO \"map=RECO_GE2J_PTH_120_200_Tag.*/bbH.*:r_ggH_2J_high[1,0,4]\" \
--PO \"map=.*/ggH_PTH_200_300.*:r_ggH_BSM_low[1,0,4]\" \
--PO \"map=.*/ggZH_had_PTH_200_300.*:r_ggH_BSM_low[1,0,4]\" \
--PO \"map=RECO_PTH_200_300_Tag.*/bbH.*:r_ggH_BSM_low[1,0,4]\" \
--PO \"map=.*/ggH_PTH_300_450.*:r_ggH_BSM_high[1,0,4]\" \
--PO \"map=.*/ggZH_had_PTH_300_450.*:r_ggH_BSM_high[1,0,4]\" \
--PO \"map=RECO_PTH_300_450_Tag.*/bbH.*:r_ggH_BSM_high[1,0,4]\" \
--PO \"map=.*/ggH_PTH_450_650.*:r_ggH_BSM_high[1,0,4]\" \
--PO \"map=.*/ggZH_had_PTH_450_650.*:r_ggH_BSM_high[1,0,4]\" \
--PO \"map=RECO_PTH_450_650_Tag.*/bbH.*:r_ggH_BSM_high[1,0,4]\" \
--PO \"map=.*/ggH_PTH_GT650.*:r_ggH_BSM_high[1,0,4]\" \
--PO \"map=.*/ggZH_had_PTH_GT650.*:r_ggH_BSM_high[1,0,4]\" \
--PO \"map=RECO_PTH_GT650_Tag.*/bbH.*:r_ggH_BSM_high[1,0,4]\" \
--PO \"map=.*/ggH_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_0_25.*:r_qqH_low_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_0_25.*:r_qqH_low_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/ggH_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_GT25.*:r_qqH_low_mjj_high_pthjj[1,0,7]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_GT25.*:r_qqH_low_mjj_high_pthjj[1,0,7]\" \
--PO \"map=.*/ggH_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_0_25.*:r_qqH_high_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_0_25.*:r_qqH_high_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/ggH_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_GT25.*:r_qqH_high_mjj_high_pthjj[1,0,5]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_GT25.*:r_qqH_high_mjj_high_pthjj[1,0,5]\" \
--PO \"map=.*/qqH_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_0_25.*:r_qqH_low_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/qqH_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_GT25.*:r_qqH_low_mjj_high_pthjj[1,0,7]\" \
--PO \"map=.*/qqH_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_0_25.*:r_qqH_high_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/qqH_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_GT25.*:r_qqH_high_mjj_high_pthjj[1,0,5]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_0_25.*:r_qqH_low_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_GT25.*:r_qqH_low_mjj_high_pthjj[1,0,7]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_0_25.*:r_qqH_high_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_GT25.*:r_qqH_high_mjj_high_pthjj[1,0,5]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_0_25.*:r_qqH_low_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_GT25.*:r_qqH_low_mjj_high_pthjj[1,0,7]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_0_25.*:r_qqH_high_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_GT25.*:r_qqH_high_mjj_high_pthjj[1,0,5]\" \
--PO \"map=.*/qqH_GE2J_.*_PTH_GT200.*:r_qqH_BSM[1,0,4]\" \
--PO \"map=.*/WH_had_GE2J_.*_PTH_GT200.*:r_qqH_BSM[1,0,4]\" \
--PO \"map=.*/ZH_had_GE2J_.*_PTH_GT200.*:r_qqH_BSM[1,0,4]\" \
--PO \"map=.*/qqH_GE2J_MJJ_60_120.*:r_qqH_VHhad[1,0,6]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_60_120.*:r_qqH_VHhad[1,0,6]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_60_120.*:r_qqH_VHhad[1,0,6]\" \
--PO \"map=.*/WH_lep_PTV_0_75.*hgg:r_WH_lep_low[1,0,6]\" \
--PO \"map=.*/WH_lep_PTV_75_150.*hgg:r_WH_lep_high[1,0,6]\" \
--PO \"map=.*/WH_lep_PTV_150_250.*hgg:r_WH_lep_high[1,0,6]\" \
--PO \"map=.*/WH_lep_PTV_GT250.*hgg:r_WH_lep_high[1,0,6]\" \
--PO \"map=.*/ZH_lep.*hgg:r_ZH_lep[1,0,6]\" \
--PO \"map=.*/ggZH_ll.*hgg:r_ZH_lep[1,0,6]\" \
--PO \"map=.*/ggZH_nunu.*hgg:r_ZH_lep[1,0,6]\" \
--PO \"map=.*/ttH_PTH_0_60.*hgg:r_ttH_low[1,0,5]\" \
--PO \"map=.*/ttH_PTH_60_120.*hgg:r_ttH_medlow[1,0,3]\" \
--PO \"map=.*/ttH_PTH_120_200.*hgg:r_ttH_medhigh[1,0,4]\" \
--PO \"map=.*/ttH_PTH_200_300.*hgg:r_ttH_high[1,0,5]\" \
--PO \"map=.*/ttH_PTH_GT300.*hgg:r_ttH_high[1,0,5]\" \
--PO \"map=.*/tHq.*hgg:r_tH[1,0,15]\" \
--PO \"map=.*/tHW.*hgg:r_tH[1,0,15]\"",

  "stage1p2_extended":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggH_0J_PTH_0_10.*:r_ggH_0J_low[1,0,4]\" \
--PO \"map=.*/ggZH_had_0J_PTH_0_10.*:r_ggH_0J_low[1,0,4]\" \
--PO \"map=RECO_0J_PTH_0_10_Tag.*/bbH.*:r_ggH_0J_low[1,0,4]\" \
--PO \"map=.*/ggH_0J_PTH_GT10.*:r_ggH_0J_high[1,0,2]\" \
--PO \"map=.*/ggZH_had_0J_PTH_GT10.*:r_ggH_0J_high[1,0,2]\" \
--PO \"map=RECO_0J_PTH_GT10_Tag.*/bbH.*:r_ggH_0J_high[1,0,2]\" \
--PO \"map=.*/ggH_1J_PTH_0_60.*:r_ggH_1J_low[1,0,4]\" \
--PO \"map=.*/ggZH_had_1J_PTH_0_60.*:r_ggH_1J_low[1,0,4]\" \
--PO \"map=RECO_1J_PTH_0_60_Tag.*/bbH.*:r_ggH_1J_low[1,0,4]\" \
--PO \"map=.*/ggH_1J_PTH_60_120.*:r_ggH_1J_med[1,0,4]\" \
--PO \"map=.*/ggZH_had_1J_PTH_60_120.*:r_ggH_1J_med[1,0,4]\" \
--PO \"map=RECO_1J_PTH_60_120_Tag.*/bbH.*:r_ggH_1J_med[1,0,4]\" \
--PO \"map=.*/ggH_1J_PTH_120_200.*:r_ggH_1J_high[1,0,4]\" \
--PO \"map=.*/ggZH_had_1J_PTH_120_200.*:r_ggH_1J_high[1,0,4]\" \
--PO \"map=RECO_1J_PTH_120_200_Tag.*/bbH.*:r_ggH_1J_high[1,0,4]\" \
--PO \"map=.*/ggH_GE2J_MJJ_0_350_PTH_0_60.*:r_ggH_2J_low[1,0,4]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_0_350_PTH_0_60.*:r_ggH_2J_low[1,0,4]\" \
--PO \"map=RECO_GE2J_PTH_0_60_Tag.*/bbH.*:r_ggH_2J_low[1,0,4]\" \
--PO \"map=.*/ggH_GE2J_MJJ_0_350_PTH_60_120.*:r_ggH_2J_med[1,0,4]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_0_350_PTH_60_120.*:r_ggH_2J_med[1,0,4]\" \
--PO \"map=RECO_GE2J_PTH_60_120_Tag.*/bbH.*:r_ggH_2J_med[1,0,4]\" \
--PO \"map=.*/ggH_GE2J_MJJ_0_350_PTH_120_200.*:r_ggH_2J_high[1,0,4]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_0_350_PTH_120_200.*:r_ggH_2J_high[1,0,4]\" \
--PO \"map=RECO_GE2J_PTH_120_200_Tag.*/bbH.*:r_ggH_2J_high[1,0,4]\" \
--PO \"map=.*/ggH_PTH_200_300.*:r_ggH_BSM_low[1,0,4]\" \
--PO \"map=.*/ggZH_had_PTH_200_300.*:r_ggH_BSM_low[1,0,4]\" \
--PO \"map=RECO_PTH_200_300_Tag.*/bbH.*:r_ggH_BSM_low[1,0,4]\" \
--PO \"map=.*/ggH_PTH_300_450.*:r_ggH_BSM_med[1,0,4]\" \
--PO \"map=.*/ggZH_had_PTH_300_450.*:r_ggH_BSM_med[1,0,4]\" \
--PO \"map=RECO_PTH_300_450_Tag.*/bbH.*:r_ggH_BSM_med[1,0,4]\" \
--PO \"map=.*/ggH_PTH_450_650.*:r_ggH_BSM_high[1,0,6]\" \
--PO \"map=.*/ggZH_had_PTH_450_650.*:r_ggH_BSM_high[1,0,6]\" \
--PO \"map=RECO_PTH_450_650_Tag.*/bbH.*:r_ggH_BSM_high[1,0,6]\" \
--PO \"map=.*/ggH_PTH_GT650.*:r_ggH_BSM_high[1,0,6]\" \
--PO \"map=.*/ggZH_had_PTH_GT650.*:r_ggH_BSM_high[1,0,6]\" \
--PO \"map=RECO_PTH_GT650_Tag.*/bbH.*:r_ggH_BSM_high[1,0,6]\" \
--PO \"map=.*/ggH_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_0_25.*:r_qqH_low_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_0_25.*:r_qqH_low_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/ggH_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_GT25.*:r_qqH_low_mjj_high_pthjj[1,0,7]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_GT25.*:r_qqH_low_mjj_high_pthjj[1,0,7]\" \
--PO \"map=.*/ggH_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_0_25.*:r_qqH_high_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_0_25.*:r_qqH_high_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/ggH_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_GT25.*:r_qqH_high_mjj_high_pthjj[1,0,5]\" \
--PO \"map=.*/ggZH_had_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_GT25.*:r_qqH_high_mjj_high_pthjj[1,0,5]\" \
--PO \"map=.*/qqH_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_0_25.*:r_qqH_low_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/qqH_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_GT25.*:r_qqH_low_mjj_high_pthjj[1,0,7]\" \
--PO \"map=.*/qqH_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_0_25.*:r_qqH_high_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/qqH_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_GT25.*:r_qqH_high_mjj_high_pthjj[1,0,5]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_0_25.*:r_qqH_low_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_GT25.*:r_qqH_low_mjj_high_pthjj[1,0,7]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_0_25.*:r_qqH_high_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_GT25.*:r_qqH_high_mjj_high_pthjj[1,0,5]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_0_25.*:r_qqH_low_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_350_700_PTH_0_200_PTHJJ_GT25.*:r_qqH_low_mjj_high_pthjj[1,0,7]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_0_25.*:r_qqH_high_mjj_low_pthjj[1,0,6]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_GT700_PTH_0_200_PTHJJ_GT25.*:r_qqH_high_mjj_high_pthjj[1,0,5]\" \
--PO \"map=.*/qqH_GE2J_.*_PTH_GT200.*:r_qqH_BSM[1,0,4]\" \
--PO \"map=.*/WH_had_GE2J_.*_PTH_GT200.*:r_qqH_BSM[1,0,4]\" \
--PO \"map=.*/ZH_had_GE2J_.*_PTH_GT200.*:r_qqH_BSM[1,0,4]\" \
--PO \"map=.*/qqH_GE2J_MJJ_60_120.*:r_qqH_VHhad[1,0,6]\" \
--PO \"map=.*/WH_had_GE2J_MJJ_60_120.*:r_qqH_VHhad[1,0,6]\" \
--PO \"map=.*/ZH_had_GE2J_MJJ_60_120.*:r_qqH_VHhad[1,0,6]\" \
--PO \"map=.*/WH_lep_PTV_0_75.*hgg:r_WH_lep_low[1,0,6]\" \
--PO \"map=.*/WH_lep_PTV_75_150.*hgg:r_WH_lep_high[1,0,6]\" \
--PO \"map=.*/WH_lep_PTV_150_250.*hgg:r_WH_lep_high[1,0,6]\" \
--PO \"map=.*/WH_lep_PTV_GT250.*hgg:r_WH_lep_high[1,0,6]\" \
--PO \"map=.*/ZH_lep.*hgg:r_ZH_lep[1,0,6]\" \
--PO \"map=.*/ggZH_ll.*hgg:r_ZH_lep[1,0,6]\" \
--PO \"map=.*/ggZH_nunu.*hgg:r_ZH_lep[1,0,6]\" \
--PO \"map=.*/ttH_PTH_0_60.*hgg:r_ttH_low[1,0,5]\" \
--PO \"map=.*/ttH_PTH_60_120.*hgg:r_ttH_medlow[1,0,3]\" \
--PO \"map=.*/ttH_PTH_120_200.*hgg:r_ttH_medhigh[1,0,4]\" \
--PO \"map=.*/ttH_PTH_200_300.*hgg:r_ttH_high[1,0,5]\" \
--PO \"map=.*/ttH_PTH_GT300.*hgg:r_ttH_high[1,0,5]\" \
--PO \"map=.*/tHq.*hgg:r_tH[1,0,15]\" \
--PO \"map=.*/tHW.*hgg:r_tH[1,0,15]\"",


  "PTH":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_PTH_0p0_15p0.*:r_PTH_0p0_15p0[1,-3,3]\" \
--PO \"map=.*/tth_PTH_0p0_15p0.*:r_PTH_0p0_15p0[1,-3,3]\" \
--PO \"map=.*/vh_PTH_0p0_15p0.*:r_PTH_0p0_15p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTH_0p0_15p0.*:r_PTH_0p0_15p0[1,-3,3]\" \
--PO \"map=.*/ggh_PTH_15p0_30p0.*:r_PTH_15p0_30p0[1,-3,3]\" \
--PO \"map=.*/tth_PTH_15p0_30p0.*:r_PTH_15p0_30p0[1,-3,3]\" \
--PO \"map=.*/vh_PTH_15p0_30p0.*:r_PTH_15p0_30p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTH_15p0_30p0.*:r_PTH_15p0_30p0[1,-3,3]\" \
--PO \"map=.*/ggh_PTH_30p0_45p0.*:r_PTH_30p0_45p0[1,-3,3]\" \
--PO \"map=.*/tth_PTH_30p0_45p0.*:r_PTH_30p0_45p0[1,-3,3]\" \
--PO \"map=.*/vh_PTH_30p0_45p0.*:r_PTH_30p0_45p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTH_30p0_45p0.*:r_PTH_30p0_45p0[1,-3,3]\" \
--PO \"map=.*/ggh_PTH_45p0_80p0.*:r_PTH_45p0_80p0[1,-3,3]\" \
--PO \"map=.*/tth_PTH_45p0_80p0.*:r_PTH_45p0_80p0[1,-3,3]\" \
--PO \"map=.*/vh_PTH_45p0_80p0.*:r_PTH_45p0_80p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTH_45p0_80p0.*:r_PTH_45p0_80p0[1,-3,3]\" \
--PO \"map=.*/ggh_PTH_80p0_120p0.*:r_PTH_80p0_120p0[1,-3,3]\" \
--PO \"map=.*/tth_PTH_80p0_120p0.*:r_PTH_80p0_120p0[1,-3,3]\" \
--PO \"map=.*/vh_PTH_80p0_120p0.*:r_PTH_80p0_120p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTH_80p0_120p0.*:r_PTH_80p0_120p0[1,-3,3]\" \
--PO \"map=.*/ggh_PTH_120p0_200p0.*:r_PTH_120p0_200p0[1,-3,3]\" \
--PO \"map=.*/tth_PTH_120p0_200p0.*:r_PTH_120p0_200p0[1,-3,3]\" \
--PO \"map=.*/vh_PTH_120p0_200p0.*:r_PTH_120p0_200p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTH_120p0_200p0.*:r_PTH_120p0_200p0[1,-3,3]\" \
--PO \"map=.*/ggh_PTH_200p0_350p0.*:r_PTH_200p0_350p0[1,-3,3]\" \
--PO \"map=.*/tth_PTH_200p0_350p0.*:r_PTH_200p0_350p0[1,-3,3]\" \
--PO \"map=.*/vh_PTH_200p0_350p0.*:r_PTH_200p0_350p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTH_200p0_350p0.*:r_PTH_200p0_350p0[1,-3,3]\" \
--PO \"map=.*/ggh_PTH_350p0_10000p0.*:r_PTH_350p0_10000p0[1,-3,3]\" \
--PO \"map=.*/tth_PTH_350p0_10000p0.*:r_PTH_350p0_10000p0[1,-3,3]\" \
--PO \"map=.*/vh_PTH_350p0_10000p0.*:r_PTH_350p0_10000p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTH_350p0_10000p0.*:r_PTH_350p0_10000p0[1,-3,3]\"",

  "rapidity":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_YH_0p0_0p15.*:r_YH_0p0_0p15[1,-3,3]\" \
--PO \"map=.*/tth_YH_0p0_0p15.*:r_YH_0p0_0p15[1,-3,3]\" \
--PO \"map=.*/vh_YH_0p0_0p15.*:r_YH_0p0_0p15[1,-3,3]\" \
--PO \"map=.*/vbf_YH_0p0_0p15.*:r_YH_0p0_0p15[1,-3,3]\" \
--PO \"map=.*/ggh_YH_0p15_0p3.*:r_YH_0p15_0p3[1,-3,3]\" \
--PO \"map=.*/tth_YH_0p15_0p3.*:r_YH_0p15_0p3[1,-3,3]\" \
--PO \"map=.*/vh_YH_0p15_0p3.*:r_YH_0p15_0p3[1,-3,3]\" \
--PO \"map=.*/vbf_YH_0p15_0p3.*:r_YH_0p15_0p3[1,-3,3]\" \
--PO \"map=.*/ggh_YH_0p3_0p6.*:r_YH_0p3_0p6[1,-3,3]\" \
--PO \"map=.*/tth_YH_0p3_0p6.*:r_YH_0p3_0p6[1,-3,3]\" \
--PO \"map=.*/vh_YH_0p3_0p6.*:r_YH_0p3_0p6[1,-3,3]\" \
--PO \"map=.*/vbf_YH_0p3_0p6.*:r_YH_0p3_0p6[1,-3,3]\" \
--PO \"map=.*/ggh_YH_0p6_0p9.*:r_YH_0p6_0p9[1,-3,3]\" \
--PO \"map=.*/tth_YH_0p6_0p9.*:r_YH_0p6_0p9[1,-3,3]\" \
--PO \"map=.*/vh_YH_0p6_0p9.*:r_YH_0p6_0p9[1,-3,3]\" \
--PO \"map=.*/vbf_YH_0p6_0p9.*:r_YH_0p6_0p9[1,-3,3]\" \
--PO \"map=.*/ggh_YH_0p9_2p5.*:r_YH_0p9_2p5[1,-3,3]\" \
--PO \"map=.*/tth_YH_0p9_2p5.*:r_YH_0p9_2p5[1,-3,3]\" \
--PO \"map=.*/vh_YH_0p9_2p5.*:r_YH_0p9_2p5[1,-3,3]\" \
--PO \"map=.*/vbf_YH_0p9_2p5.*:r_YH_0p9_2p5[1,-3,3]\"",

  "Njets2p5_5bin":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_NJ_0p0_1p0.*:r_NJ_0p0_1p0[1,0,3]\" \
--PO \"map=.*/tth_NJ_0p0_1p0.*:r_NJ_0p0_1p0[1,0,3]\" \
--PO \"map=.*/vh_NJ_0p0_1p0.*:r_NJ_0p0_1p0[1,0,3]\" \
--PO \"map=.*/vbf_NJ_0p0_1p0.*:r_NJ_0p0_1p0[1,0,3]\" \
--PO \"map=.*/ggh_NJ_1p0_2p0.*:r_NJ_1p0_2p0[1,0,3]\" \
--PO \"map=.*/tth_NJ_1p0_2p0.*:r_NJ_1p0_2p0[1,0,3]\" \
--PO \"map=.*/vh_NJ_1p0_2p0.*:r_NJ_1p0_2p0[1,0,3]\" \
--PO \"map=.*/vbf_NJ_1p0_2p0.*:r_NJ_1p0_2p0[1,0,3]\" \
--PO \"map=.*/ggh_NJ_2p0_3p0.*:r_NJ_2p0_3p0[1,0,3]\" \
--PO \"map=.*/tth_NJ_2p0_3p0.*:r_NJ_2p0_3p0[1,0,3]\" \
--PO \"map=.*/vh_NJ_2p0_3p0.*:r_NJ_2p0_3p0[1,0,3]\" \
--PO \"map=.*/vbf_NJ_2p0_3p0.*:r_NJ_2p0_3p0[1,0,3]\" \
--PO \"map=.*/ggh_NJ_3p0_4p0.*:r_NJ_3p0_4p0[1,0,3]\" \
--PO \"map=.*/tth_NJ_3p0_4p0.*:r_NJ_3p0_4p0[1,0,3]\" \
--PO \"map=.*/vh_NJ_3p0_4p0.*:r_NJ_3p0_4p0[1,0,3]\" \
--PO \"map=.*/vbf_NJ_3p0_4p0.*:r_NJ_3p0_4p0[1,0,3]\" \
--PO \"map=.*/ggh_NJ_4p0_100p0.*:r_NJ_4p0_100p0[1,0,3]\" \
--PO \"map=.*/tth_NJ_4p0_100p0.*:r_NJ_4p0_100p0[1,0,3]\" \
--PO \"map=.*/vh_NJ_4p0_100p0.*:r_NJ_4p0_100p0[1,0,3]\" \
--PO \"map=.*/vbf_NJ_4p0_100p0.*:r_NJ_4p0_100p0[1,0,3]\"",

  "Njets2p5":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_NJ_0p0_1p0.*:r_NJ_0p0_1p0[1,-3,3]\" \
--PO \"map=.*/tth_NJ_0p0_1p0.*:r_NJ_0p0_1p0[1,-3,3]\" \
--PO \"map=.*/vh_NJ_0p0_1p0.*:r_NJ_0p0_1p0[1,-3,3]\" \
--PO \"map=.*/vbf_NJ_0p0_1p0.*:r_NJ_0p0_1p0[1,-3,3]\" \
--PO \"map=.*/ggh_NJ_1p0_2p0.*:r_NJ_1p0_2p0[1,-3,3]\" \
--PO \"map=.*/tth_NJ_1p0_2p0.*:r_NJ_1p0_2p0[1,-3,3]\" \
--PO \"map=.*/vh_NJ_1p0_2p0.*:r_NJ_1p0_2p0[1,-3,3]\" \
--PO \"map=.*/vbf_NJ_1p0_2p0.*:r_NJ_1p0_2p0[1,-3,3]\" \
--PO \"map=.*/ggh_NJ_2p0_3p0.*:r_NJ_2p0_3p0[1,-3,3]\" \
--PO \"map=.*/tth_NJ_2p0_3p0.*:r_NJ_2p0_3p0[1,-3,3]\" \
--PO \"map=.*/vh_NJ_2p0_3p0.*:r_NJ_2p0_3p0[1,-3,3]\" \
--PO \"map=.*/vbf_NJ_2p0_3p0.*:r_NJ_2p0_3p0[1,-3,3]\" \
--PO \"map=.*/ggh_NJ_3p0_100p0.*:r_NJ_3p0_100p0[1,-3,3]\" \
--PO \"map=.*/tth_NJ_3p0_100p0.*:r_NJ_3p0_100p0[1,-3,3]\" \
--PO \"map=.*/vh_NJ_3p0_100p0.*:r_NJ_3p0_100p0[1,-3,3]\" \
--PO \"map=.*/vbf_NJ_3p0_100p0.*:r_NJ_3p0_100p0[1,-3,3]\"",

  "Njets2p5_0_3_fine":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_NJ_0p0_1p0.*:r_NJ_0p0_1p0[1,0,3]\" \
--PO \"map=.*/tth_NJ_0p0_1p0.*:r_NJ_0p0_1p0[1,0,3]\" \
--PO \"map=.*/vh_NJ_0p0_1p0.*:r_NJ_0p0_1p0[1,0,3]\" \
--PO \"map=.*/vbf_NJ_0p0_1p0.*:r_NJ_0p0_1p0[1,0,3]\" \
--PO \"map=.*/ggh_NJ_1p0_2p0.*:r_NJ_1p0_2p0[1,0,3]\" \
--PO \"map=.*/tth_NJ_1p0_2p0.*:r_NJ_1p0_2p0[1,0,3]\" \
--PO \"map=.*/vh_NJ_1p0_2p0.*:r_NJ_1p0_2p0[1,0,3]\" \
--PO \"map=.*/vbf_NJ_1p0_2p0.*:r_NJ_1p0_2p0[1,0,3]\" \
--PO \"map=.*/ggh_NJ_2p0_3p0.*:r_NJ_2p0_3p0[1,0,3]\" \
--PO \"map=.*/tth_NJ_2p0_3p0.*:r_NJ_2p0_3p0[1,0,3]\" \
--PO \"map=.*/vh_NJ_2p0_3p0.*:r_NJ_2p0_3p0[1,0,3]\" \
--PO \"map=.*/vbf_NJ_2p0_3p0.*:r_NJ_2p0_3p0[1,0,3]\" \
--PO \"map=.*/ggh_NJ_3p0_100p0.*:r_NJ_3p0_100p0[1,0,3]\" \
--PO \"map=.*/tth_NJ_3p0_100p0.*:r_NJ_3p0_100p0[1,0,3]\" \
--PO \"map=.*/vh_NJ_3p0_100p0.*:r_NJ_3p0_100p0[1,0,3]\" \
--PO \"map=.*/vbf_NJ_3p0_100p0.*:r_NJ_3p0_100p0[1,0,3]\"",

  "ptJ0":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,-3,3]\" \
--PO \"map=.*/tth_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,-3,3]\" \
--PO \"map=.*/vh_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,-3,3]\" \
--PO \"map=.*/ggh_PTJ0_30p0_75p0.*:r_PTJ0_30p0_75p0[1,-3,3]\" \
--PO \"map=.*/tth_PTJ0_30p0_75p0.*:r_PTJ0_30p0_75p0[1,-3,3]\" \
--PO \"map=.*/vh_PTJ0_30p0_75p0.*:r_PTJ0_30p0_75p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTJ0_30p0_75p0.*:r_PTJ0_30p0_75p0[1,-3,3]\" \
--PO \"map=.*/ggh_PTJ0_75p0_120p0.*:r_PTJ0_75p0_120p0[1,-3,3]\" \
--PO \"map=.*/tth_PTJ0_75p0_120p0.*:r_PTJ0_75p0_120p0[1,-3,3]\" \
--PO \"map=.*/vh_PTJ0_75p0_120p0.*:r_PTJ0_75p0_120p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTJ0_75p0_120p0.*:r_PTJ0_75p0_120p0[1,-3,3]\" \
--PO \"map=.*/ggh_PTJ0_120p0_200p0.*:r_PTJ0_120p0_200p0[1,-3,3]\" \
--PO \"map=.*/tth_PTJ0_120p0_200p0.*:r_PTJ0_120p0_200p0[1,-3,3]\" \
--PO \"map=.*/vh_PTJ0_120p0_200p0.*:r_PTJ0_120p0_200p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTJ0_120p0_200p0.*:r_PTJ0_120p0_200p0[1,-3,3]\" \
--PO \"map=.*/ggh_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,-3,3]\" \
--PO \"map=.*/tth_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,-3,3]\" \
--PO \"map=.*/vh_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,-3,3]\" \
--PO \"map=.*/vbf_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,-3,3]\"",

  "ptJ0_0_3_fine":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_30p0_75p0.*:r_PTJ0_30p0_75p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_30p0_75p0.*:r_PTJ0_30p0_75p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_30p0_75p0.*:r_PTJ0_30p0_75p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_30p0_75p0.*:r_PTJ0_30p0_75p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_75p0_120p0.*:r_PTJ0_75p0_120p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_75p0_120p0.*:r_PTJ0_75p0_120p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_75p0_120p0.*:r_PTJ0_75p0_120p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_75p0_120p0.*:r_PTJ0_75p0_120p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_120p0_200p0.*:r_PTJ0_120p0_200p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_120p0_200p0.*:r_PTJ0_120p0_200p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_120p0_200p0.*:r_PTJ0_120p0_200p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_120p0_200p0.*:r_PTJ0_120p0_200p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,0,3]\"",

  "ptJ0_0_30_GeV_0_3_fine":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_30p0_10000p0.*:r_PTJ0_30p0_10000p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_30p0_10000p0.*:r_PTJ0_30p0_10000p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_30p0_10000p0.*:r_PTJ0_30p0_10000p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_30p0_10000p0.*:r_PTJ0_30p0_10000p0[1,0,3]\"",

  "ptJ0_HIG_17_025":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_30p0_45p0.*:r_PTJ0_30p0_45p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_30p0_45p0.*:r_PTJ0_30p0_45p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_30p0_45p0.*:r_PTJ0_30p0_45p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_30p0_45p0.*:r_PTJ0_30p0_45p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_45p0_70p0.*:r_PTJ0_45p0_70p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_45p0_70p0.*:r_PTJ0_45p0_70p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_45p0_70p0.*:r_PTJ0_45p0_70p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_45p0_70p0.*:r_PTJ0_45p0_70p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_70p0_110p0.*:r_PTJ0_70p0_110p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_70p0_110p0.*:r_PTJ0_70p0_110p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_70p0_110p0.*:r_PTJ0_70p0_110p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_70p0_110p0.*:r_PTJ0_70p0_110p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_110p0_200p0.*:r_PTJ0_110p0_200p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_110p0_200p0.*:r_PTJ0_110p0_200p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_110p0_200p0.*:r_PTJ0_110p0_200p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_110p0_200p0.*:r_PTJ0_110p0_200p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,0,3]\"",

  "ptJ0_30GeV":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_0p0_30p0.*:r_PTJ0_0p0_30p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_30p0_60p0.*:r_PTJ0_30p0_60p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_30p0_60p0.*:r_PTJ0_30p0_60p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_30p0_60p0.*:r_PTJ0_30p0_60p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_30p0_60p0.*:r_PTJ0_30p0_60p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_60p0_90p0.*:r_PTJ0_60p0_90p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_60p0_90p0.*:r_PTJ0_60p0_90p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_60p0_90p0.*:r_PTJ0_60p0_90p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_60p0_90p0.*:r_PTJ0_60p0_90p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_90p0_120p0.*:r_PTJ0_90p0_120p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_90p0_120p0.*:r_PTJ0_90p0_120p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_90p0_120p0.*:r_PTJ0_90p0_120p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_90p0_120p0.*:r_PTJ0_90p0_120p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_120p0_200p0.*:r_PTJ0_120p0_200p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_120p0_200p0.*:r_PTJ0_120p0_200p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_120p0_200p0.*:r_PTJ0_120p0_200p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_120p0_200p0.*:r_PTJ0_120p0_200p0[1,0,3]\" \
--PO \"map=.*/ggh_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,0,3]\" \
--PO \"map=.*/tth_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,0,3]\" \
--PO \"map=.*/vh_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,0,3]\" \
--PO \"map=.*/vbf_PTJ0_200p0_10000p0.*:r_PTJ0_200p0_10000p0[1,0,3]\"",

  "yJ0":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_YJ0_0p0_0p5.*:r_YJ0_0p0_0p5[1,0,3]\" \
--PO \"map=.*/tth_YJ0_0p0_0p5.*:r_YJ0_0p0_0p5[1,0,3]\" \
--PO \"map=.*/vh_YJ0_0p0_0p5.*:r_YJ0_0p0_0p5[1,0,3]\" \
--PO \"map=.*/vbf_YJ0_0p0_0p5.*:r_YJ0_0p0_0p5[1,0,3]\" \
--PO \"map=.*/ggh_YJ0_0p5_1p2.*:r_YJ0_0p5_1p2[1,0,3]\" \
--PO \"map=.*/tth_YJ0_0p5_1p2.*:r_YJ0_0p5_1p2[1,0,3]\" \
--PO \"map=.*/vh_YJ0_0p5_1p2.*:r_YJ0_0p5_1p2[1,0,3]\" \
--PO \"map=.*/vbf_YJ0_0p5_1p2.*:r_YJ0_0p5_1p2[1,0,3]\" \
--PO \"map=.*/ggh_YJ0_1p2_2p0.*:r_YJ0_1p2_2p0[1,0,3]\" \
--PO \"map=.*/tth_YJ0_1p2_2p0.*:r_YJ0_1p2_2p0[1,0,3]\" \
--PO \"map=.*/vh_YJ0_1p2_2p0.*:r_YJ0_1p2_2p0[1,0,3]\" \
--PO \"map=.*/vbf_YJ0_1p2_2p0.*:r_YJ0_1p2_2p0[1,0,3]\" \
--PO \"map=.*/ggh_YJ0_2p0_2p5.*:r_YJ0_2p0_2p5[1,0,3]\" \
--PO \"map=.*/tth_YJ0_2p0_2p5.*:r_YJ0_2p0_2p5[1,0,3]\" \
--PO \"map=.*/vh_YJ0_2p0_2p5.*:r_YJ0_2p0_2p5[1,0,3]\" \
--PO \"map=.*/vbf_YJ0_2p0_2p5.*:r_YJ0_2p0_2p5[1,0,3]\" \
--PO \"map=.*/ggh_YJ0_NJ0.*:r_YJ0_NJ0[1,0,3]\" \
--PO \"map=.*/tth_YJ0_NJ0.*:r_YJ0_NJ0[1,0,3]\" \
--PO \"map=.*/vh_YJ0_NJ0.*:r_YJ0_NJ0[1,0,3]\" \
--PO \"map=.*/vbf_YJ0_NJ0.*:r_YJ0_NJ0[1,0,3]\"",

  "AbsPhiHJ0":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_AbsPhiHJ0_0p0_2p6.*:r_AbsPhiHJ0_0p0_2p6[1,0,3]\" \
--PO \"map=.*/tth_AbsPhiHJ0_0p0_2p6.*:r_AbsPhiHJ0_0p0_2p6[1,0,3]\" \
--PO \"map=.*/vh_AbsPhiHJ0_0p0_2p6.*:r_AbsPhiHJ0_0p0_2p6[1,0,3]\" \
--PO \"map=.*/vbf_AbsPhiHJ0_0p0_2p6.*:r_AbsPhiHJ0_0p0_2p6[1,0,3]\" \
--PO \"map=.*/ggh_AbsPhiHJ0_2p6_2p9.*:r_AbsPhiHJ0_2p6_2p9[1,0,3]\" \
--PO \"map=.*/tth_AbsPhiHJ0_2p6_2p9.*:r_AbsPhiHJ0_2p6_2p9[1,0,3]\" \
--PO \"map=.*/vh_AbsPhiHJ0_2p6_2p9.*:r_AbsPhiHJ0_2p6_2p9[1,0,3]\" \
--PO \"map=.*/vbf_AbsPhiHJ0_2p6_2p9.*:r_AbsPhiHJ0_2p6_2p9[1,0,3]\" \
--PO \"map=.*/ggh_AbsPhiHJ0_2p9_3p03.*:r_AbsPhiHJ0_2p9_3p03[1,0,3]\" \
--PO \"map=.*/tth_AbsPhiHJ0_2p9_3p03.*:r_AbsPhiHJ0_2p9_3p03[1,0,3]\" \
--PO \"map=.*/vh_AbsPhiHJ0_2p9_3p03.*:r_AbsPhiHJ0_2p9_3p03[1,0,3]\" \
--PO \"map=.*/vbf_AbsPhiHJ0_2p9_3p03.*:r_AbsPhiHJ0_2p9_3p03[1,0,3]\" \
--PO \"map=.*/ggh_AbsPhiHJ0_3p03_Pi.*:r_AbsPhiHJ0_3p03_Pi[1,0,3]\" \
--PO \"map=.*/tth_AbsPhiHJ0_3p03_Pi.*:r_AbsPhiHJ0_3p03_Pi[1,0,3]\" \
--PO \"map=.*/vh_AbsPhiHJ0_3p03_Pi.*:r_AbsPhiHJ0_3p03_Pi[1,0,3]\" \
--PO \"map=.*/vbf_AbsPhiHJ0_3p03_Pi.*:r_AbsPhiHJ0_3p03_Pi[1,0,3]\" \
--PO \"map=.*/ggh_AbsPhiHJ0_NJ0.*:r_AbsPhiHJ0_NJ0[1,0,3]\" \
--PO \"map=.*/tth_AbsPhiHJ0_NJ0.*:r_AbsPhiHJ0_NJ0[1,0,3]\" \
--PO \"map=.*/vh_AbsPhiHJ0_NJ0.*:r_AbsPhiHJ0_NJ0[1,0,3]\" \
--PO \"map=.*/vbf_AbsPhiHJ0_NJ0.*:r_AbsPhiHJ0_NJ0[1,0,3]\"",

  "AbsPhiHJ0_otherName":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_AbsPhiHJ0_0p0_2p6.*:r_AbsPhiHJ0_0p0_2p6[1,0,3]\" \
--PO \"map=.*/tth_AbsPhiHJ0_0p0_2p6.*:r_AbsPhiHJ0_0p0_2p6[1,0,3]\" \
--PO \"map=.*/vh_AbsPhiHJ0_0p0_2p6.*:r_AbsPhiHJ0_0p0_2p6[1,0,3]\" \
--PO \"map=.*/vbf_AbsPhiHJ0_0p0_2p6.*:r_AbsPhiHJ0_0p0_2p6[1,0,3]\" \
--PO \"map=.*/ggh_AbsPhiHJ0_2p6_2p9.*:r_AbsPhiHJ0_2p6_2p9[1,0,3]\" \
--PO \"map=.*/tth_AbsPhiHJ0_2p6_2p9.*:r_AbsPhiHJ0_2p6_2p9[1,0,3]\" \
--PO \"map=.*/vh_AbsPhiHJ0_2p6_2p9.*:r_AbsPhiHJ0_2p6_2p9[1,0,3]\" \
--PO \"map=.*/vbf_AbsPhiHJ0_2p6_2p9.*:r_AbsPhiHJ0_2p6_2p9[1,0,3]\" \
--PO \"map=.*/ggh_AbsPhiHJ0_2p9_3p03.*:r_AbsPhiHJ0_2p9_3p03[1,0,3]\" \
--PO \"map=.*/tth_AbsPhiHJ0_2p9_3p03.*:r_AbsPhiHJ0_2p9_3p03[1,0,3]\" \
--PO \"map=.*/vh_AbsPhiHJ0_2p9_3p03.*:r_AbsPhiHJ0_2p9_3p03[1,0,3]\" \
--PO \"map=.*/vbf_AbsPhiHJ0_2p9_3p03.*:r_AbsPhiHJ0_2p9_3p03[1,0,3]\" \
--PO \"map=.*/ggh_AbsPhiHJ0_3p03_3p1415926.*:r_AbsPhiHJ0_3p03_3p1415926[1,0,3]\" \
--PO \"map=.*/tth_AbsPhiHJ0_3p03_3p1415926.*:r_AbsPhiHJ0_3p03_3p1415926[1,0,3]\" \
--PO \"map=.*/vh_AbsPhiHJ0_3p03_3p1415926.*:r_AbsPhiHJ0_3p03_3p1415926[1,0,3]\" \
--PO \"map=.*/vbf_AbsPhiHJ0_3p03_3p1415926.*:r_AbsPhiHJ0_3p03_3p1415926[1,0,3]\" \
--PO \"map=.*/ggh_AbsPhiHJ0_NJ.*:r_AbsPhiHJ0_NJ[1,0,3]\" \
--PO \"map=.*/tth_AbsPhiHJ0_NJ.*:r_AbsPhiHJ0_NJ[1,0,3]\" \
--PO \"map=.*/vh_AbsPhiHJ0_NJ.*:r_AbsPhiHJ0_NJ[1,0,3]\" \
--PO \"map=.*/vbf_AbsPhiHJ0_NJ.*:r_AbsPhiHJ0_NJ[1,0,3]\"",

  "AbsYHJ0":"-P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel \
--PO \"map=.*/ggh_AbsYHJ0_0p0_0p6.*:r_AbsYHJ0_0p0_0p6[1,0,3]\" \
--PO \"map=.*/tth_AbsYHJ0_0p0_0p6.*:r_AbsYHJ0_0p0_0p6[1,0,3]\" \
--PO \"map=.*/vh_AbsYHJ0_0p0_0p6.*:r_AbsYHJ0_0p0_0p6[1,0,3]\" \
--PO \"map=.*/vbf_AbsYHJ0_0p0_0p6.*:r_AbsYHJ0_0p0_0p6[1,0,3]\" \
--PO \"map=.*/ggh_AbsYHJ0_0p6_1p2.*:r_AbsYHJ0_0p6_1p2[1,0,3]\" \
--PO \"map=.*/tth_AbsYHJ0_0p6_1p2.*:r_AbsYHJ0_0p6_1p2[1,0,3]\" \
--PO \"map=.*/vh_AbsYHJ0_0p6_1p2.*:r_AbsYHJ0_0p6_1p2[1,0,3]\" \
--PO \"map=.*/vbf_AbsYHJ0_0p6_1p2.*:r_AbsYHJ0_0p6_1p2[1,0,3]\" \
--PO \"map=.*/ggh_AbsYHJ0_1p2_1p9.*:r_AbsYHJ0_1p2_1p9[1,0,3]\" \
--PO \"map=.*/tth_AbsYHJ0_1p2_1p9.*:r_AbsYHJ0_1p2_1p9[1,0,3]\" \
--PO \"map=.*/vh_AbsYHJ0_1p2_1p9.*:r_AbsYHJ0_1p2_1p9[1,0,3]\" \
--PO \"map=.*/vbf_AbsYHJ0_1p2_1p9.*:r_AbsYHJ0_1p2_1p9[1,0,3]\" \
--PO \"map=.*/ggh_AbsYHJ0_1p9_100p0.*:r_AbsYHJ0_1p9_100p0[1,0,3]\" \
--PO \"map=.*/tth_AbsYHJ0_1p9_100p0.*:r_AbsYHJ0_1p9_100p0[1,0,3]\" \
--PO \"map=.*/vh_AbsYHJ0_1p9_100p0.*:r_AbsYHJ0_1p9_100p0[1,0,3]\" \
--PO \"map=.*/vbf_AbsYHJ0_1p9_100p0.*:r_AbsYHJ0_1p9_100p0[1,0,3]\" \
--PO \"map=.*/ggh_AbsYHJ0_NJ0.*:r_AbsYHJ0_NJ0[1,0,3]\" \
--PO \"map=.*/tth_AbsYHJ0_NJ0.*:r_AbsYHJ0_NJ0[1,0,3]\" \
--PO \"map=.*/vh_AbsYHJ0_NJ0.*:r_AbsYHJ0_NJ0[1,0,3]\" \
--PO \"map=.*/vbf_AbsYHJ0_NJ0.*:r_AbsYHJ0_NJ0[1,0,3]\"",



  "kappas_resolved":"-P HiggsAnalysis.CombinedLimit.LHCHCGModels:K1 --PO BRU=0",

  "kappas":"-P HiggsAnalysis.CombinedLimit.LHCHCGModels:K2 --PO BRU=0",

  "kVkF":"-P HiggsAnalysis.CombinedLimit.LHCHCGModels:K3 --PO BRU=0"
}
