# Add tools dir to PYTHONPATH
eval `scramv1 runtime -sh`

if [[ -n "${PYTHONPATH:-}" ]]; then
  export PYTHONPATH="${PYTHONPATH}:${CMSSW_BASE}/src/flashggFinalFit/commonTools"
else
  export PYTHONPATH="${CMSSW_BASE}/src/flashggFinalFit/commonTools"
fi
