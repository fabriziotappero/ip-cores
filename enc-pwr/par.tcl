#=========================================================================
# Command file for place/route using cadence encounter
#-------------------------------------------------------------------------
# $Id: par.tcl,v 1.1 2008-06-26 18:01:02 jamey.hicks Exp $
#
# This file specifies commands which encounter will execute when 
# performing place and route for your design.

#------------------------------------------------------------
# Setup
#------------------------------------------------------------

source make_generated_vars.tcl

# Read in the config file which also reads in the synthesized design
source par.conf
commitConfig

# Load the floorplan if it exists
if {${FLOORPLAN} != ""} {
  loadFPlan ${FLOORPLAN}
}

generateTracks

# Connect all the power and ground pins
# Note that these aren't specified in the verilog
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *

checkDesign -io -physicalLibrary -timingLibrary

clearClockDomains
setClockDomains -all

#------------------------------------------------------------
# Placement
#------------------------------------------------------------

# This does the actual placement
amoebaPlace -timingdriven

# Optimize the placement
setOptMode -reclaimArea
setOptMode -highEffort
optDesign -preCTS

#------------------------------------------------------------
# Clock tree synthesis
#------------------------------------------------------------

setCTSMode \
    -topPreferredLayer 6 \
    -bottomPreferredLayer 5 \
    -noUseLibMaxFanout \
    -addClockRootProp \
    -useCTSRouteGuide

createClockTreeSpec \
    -bufferList inv0d0 inv0d1 inv0d2 inv0d4 inv0d7 inv0da \
                buffd1 buffd2 buffd3 buffd4 buffd7 buffda \
                bufbd1 bufbd2 bufbd3 bufbd4 bufbd7 bufbda bufbdf bufbdk \
                invbd2 invbd4 invbd7 invbda invbdf invbdk \
    -output par.ctstch \
    -routeClkNet

specifyClockTree -clkfile par.ctstch
ckSynthesis -rguide par_clk.rguide

# The clock router sometimes (incorrectly) routes M2 over pins, 
# causing violations this allows those routes to be moved later
changeUseClockNetStatus -noFixedNetWires

# Save design for debugging
saveDesign postclksynth -netlist -tcon -rc

#------------------------------------------------------------
# preroute reports
#------------------------------------------------------------

trialRoute -guide par_clk.rguide

setAnalysisMode -setup -async -skew -clockTree
buildTimingGraph
reportSlacks -setup -outfile preroute_setup_slacks.rpt
reportViolation -outfile preroute_setup_timing.rpt -num 200 -plusNonViolating
reportMostCritPath -outfile preroute_critpath.rpt

setAnalysisMode -hold -async -skew -clockTree
buildTimingGraph
reportSlacks -hold -outfile preroute_hold_slacks.rpt
reportViolation -outfile preroute_hold_timing.rpt -num 200 -plusNonViolating

reportGateCount -level 5 -limit 100 -stdCellOnly -outfile preroute_area.rpt
reportWire preroute_wire.rpt

saveDesign preroute -netlist -tcon -rc

#------------------------------------------------------------
# Routing
#------------------------------------------------------------

# Add filler/feedthrough cells
addFiller -cell feedth feedth3 feedth9 -prefix feedth

# Wire up cells to power network
sroute -noStripes -noPadRings -jogControl { preferWithChanges differentLayer }

# Do signal routing
setNanoRouteMode -drouteFixAntenna true
setNanoRouteMode -routeInsertAntennaDiode false
setNanoRouteMode -timingEngine CTE
setNanoRouteMode -routeWithTimingDriven true
setNanoRouteMode -routeWithEco false
setNanoRouteMode -routeWithSiDriven true
setNanoRouteMode -routeTdrEffort 0
setNanoRouteMode -routeSiEffort low
setNanoRouteMode -siNoiseCTotalThreshold 0.050000
setNanoRouteMode -siNoiseCouplingCapThreshold 0.005000
setNanoRouteMode -routeWithSiPostRouteFix false
setNanoRouteMode -drouteAutoStop true
setNanoRouteMode -routeSelectedNetOnly false
setNanoRouteMode -envNumberProcessor 1
setNanoRouteMode -drouteOptimizeUseMultiCutVia true
globalDetailRoute

delayCal -sdf postroute.sdf

#------------------------------------------------------------
# postroute reports
#------------------------------------------------------------

extractRC -outfile par.cap

setAnalysisMode -setup -async -skew -clockTree
buildTimingGraph
reportSlacks -setup -outfile postroute_setup_slacks.rpt
reportViolation -outfile postroute_setup_timing.rpt -num 200 -plusNonViolating
reportMostCritPath -outfile postroute_critpath.rpt

setAnalysisMode -hold -async -skew -clockTree
buildTimingGraph
reportSlacks -hold -outfile postroute_hold_slacks.rpt
reportViolation -outfile postroute_hold_timing.rpt -num 200 -plusNonViolating

reportGateCount -level 5 -limit 100 -stdCellOnly -outfile postroute_area.rpt
reportWire postroute_wire.rpt

saveDesign postroute -netlist -tcon -rc
saveNetlist par.v

exit
