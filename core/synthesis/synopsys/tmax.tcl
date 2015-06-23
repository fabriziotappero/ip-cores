
#=============================================================================#
#                              Configuration                                  #
#=============================================================================#

set DESIGN_NAME      "openMSP430"

set SPF_FILE         "./results/$DESIGN_NAME.spf"
set NETLIST_FILES    [list "./results/$DESIGN_NAME.gate.v"]

set LIBRARY_FILES    [list "<YOUR LIBRARY VERILOG FILE>"]



#=============================================================================#
#                           Read Design & Technology files                    #
#=============================================================================#

# Rules to be ignored
set_rules B7  ignore    ;# undriven module output pin
set_rules B8  ignore    ;# unconnected module input pin
set_rules B9  ignore    ;# undriven module internal net
set_rules B10 ignore    ;# unconnected module internal net
set_rules N20 ignore    ;# underspecified UDP
set_rules N21 ignore    ;# unsupported UDP entry
set_rules N23 ignore    ;# inconsistent UDP


# Reset TMAX
build -force
read_netlist -delete

# Read gate level netlist
foreach design_file $NETLIST_FILES {
    read_netlist $design_file
}

# Read library files
foreach lib_file $LIBRARY_FILES {
    read_netlist $lib_file
}

# Remove unused net connections
remove_net_connection -all

# Build the model
run_build_model $DESIGN_NAME


#=============================================================================#
#                                    Run DRC                                  #
#=============================================================================#

# Allow ATPG to use nonscan cell values loaded by the last shift.
set_drc -load_nonscan_cells

# Report settings
report_settings drc

# Run DRC
run_drc $SPF_FILE


#=============================================================================#
#                                      ATPG                                   #
#=============================================================================#

set_atpg -capture_cycles 4

set_faults -model stuck

set_atpg -abort_limit 10
report_settings atpg
report_settings simulation

run_atpg -auto


# Create report
redirect -file "./results/report.tmax_summary" {report_summaries}

quit
