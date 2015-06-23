
#=============================================================================#
#                                Configuration                                #
#=============================================================================#

# Enable/Disable DC_ULTRA option
set WITH_DC_ULTRA 1

# Enable/Disable DFT insertion
set WITH_DFT      1


#=============================================================================#
#                           Read technology library                           #
#=============================================================================#
source -echo -verbose ./library.tcl


#=============================================================================#
#                               Read design RTL                               #
#=============================================================================#
source -echo -verbose ./read.tcl


#=============================================================================#
#                           Set design constraints                            #
#=============================================================================#
source -echo -verbose ./constraints.tcl


#=============================================================================#
#              Set operating conditions & wire-load models                    #
#=============================================================================#

# Set operating conditions
set_operating_conditions -max $LIB_WC_OPCON -max_library $LIB_WC_NAME \
	                 -min $LIB_WC_OPCON -min_library $LIB_BC_NAME

# Set wire-load models
set_wire_load_mode top
set_wire_load_model -name $LIB_WIRE_LOAD -max -library $LIB_WC_NAME
set_wire_load_model -name $LIB_WIRE_LOAD -min -library $LIB_BC_NAME


#=============================================================================#
#                                Synthesize                                   #
#=============================================================================#

# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -buffer_constants

# Configuration
current_design $DESIGN_NAME
set_max_area  0.0
set_flatten false
set_structure true -timing true -boolean false

# Synthesis
if {$WITH_DC_ULTRA} {
    if {$WITH_DFT} {
	compile_ultra -scan -area_high_effort_script -no_autoungroup -no_boundary_optimization
    } else {
	compile_ultra       -area_high_effort_script -no_autoungroup -no_boundary_optimization
    }
} else {
    if {$WITH_DFT} {
	compile       -scan -map_effort high -area_effort high
    } else {
	compile             -map_effort high -area_effort high
    }
}

#=============================================================================#
#                                DFT Insertion                                #
#=============================================================================#
if {$WITH_DFT} {

    # DFT Signal Type Definitions
    set_dft_signal -view spec         -type ScanEnable  -port scan_enable -active_state 1
    set_dft_signal -view existing_dft -type ScanEnable  -port scan_enable -active_state 1
    set_dft_signal -view spec         -type Constant    -port scan_mode   -active_state 1
    set_dft_signal -view existing_dft -type Constant    -port scan_mode   -active_state 1
    set_dft_signal -view existing_dft -type ScanClock   -port dco_clk     -timing [list 45 55]
    set_dft_signal -view existing_dft -type ScanClock   -port lfxt_clk    -timing [list 45 55]
    set_dft_signal -view existing_dft -type Reset       -port reset_n     -active 0

    # DFT Configuration
    set_dft_insertion_configuration -preserve_design_name true
    set_scan_configuration -style multiplexed_flip_flop
    set_scan_configuration -clock_mixing mix_clocks
    set_scan_configuration -chain_count 3

    # DFT Test Protocol Creation
    create_test_protocol

    # DFT Design Rule Check
    redirect -tee -file ./results/report.dft_drc           {dft_drc}
    redirect      -file ./results/report.dft_drc_verbose   {dft_drc -verbose}
    redirect      -file ./results/report.dft_drc_coverage  {dft_drc -coverage_estimate}
    redirect      -file ./results/report.dft_scan_config   {report_scan_configuration}
    redirect      -file ./results/report.dft_insert_config {report_dft_insertion_configuration}

    # Preview DFT insertion
    redirect -tee -file ./results/report.dft_preview       {preview_dft}
    redirect      -file ./results/report.dft_preview_all   {preview_dft -show all -test_points all}

    # DFT insertion
    insert_dft

    # DFT Incremental Compile
    if {$WITH_DC_ULTRA} {
	compile_ultra -scan -incremental
    } else {
	compile       -scan -incremental
    }

    # DFT Coverage estimate
    redirect      -file ./results/report.dft_drc_coverage  {dft_drc -coverage_estimate}
}

#=============================================================================#
#                            Reports generation                               #
#=============================================================================#

redirect -file ./results/report.timing         {check_timing}
redirect -file ./results/report.constraints    {report_constraints -all_violators -verbose}
redirect -file ./results/report.paths.max      {report_timing -path end  -delay max -max_paths 200 -nworst 2}
redirect -file ./results/report.full_paths.max {report_timing -path full -delay max -max_paths 5   -nworst 2}
redirect -file ./results/report.paths.min      {report_timing -path end  -delay min -max_paths 200 -nworst 2}
redirect -file ./results/report.full_paths.min {report_timing -path full -delay min -max_paths 5   -nworst 2}
redirect -file ./results/report.refs           {report_reference}
redirect -file ./results/report.area           {report_area}

# Add NAND2 size equivalent report to the area report file
if {[info exists NAND2_NAME]} {
    set nand2_area [get_attribute [get_lib_cell $LIB_WC_NAME/$NAND2_NAME] area]
    redirect -variable area {report_area}
    regexp {Total cell area:\s+([^\n]+)\n} $area whole_match area
    set nand2_eq [expr $area/$nand2_area]
    set fp [open "./results/report.area" a]
    puts $fp ""
    puts $fp "NAND2 equivalent cell area: $nand2_eq"
    close $fp
    puts ""
    puts "      ======================================================="
    puts "     |                       AREA SUMMARY                    "
    puts "     |-------------------------------------------------------"
    puts "     |"
    puts "     |    $NAND2_NAME cell gate area: $nand2_area"
    puts "     |"
    puts "     |    Total Area                : $area"
    puts "     |    NAND2 equivalent cell area: $nand2_eq"
    puts "     |"
    puts "      ======================================================="
    puts ""
}

#=============================================================================#
#          Dump gate level netlist, final DDC file and Test protocol          #
#=============================================================================#
current_design $DESIGN_NAME

change_name -rules verilog -hierarchy

write -hierarchy -format verilog -output "./results/$DESIGN_NAME.gate.v"
write -hierarchy -format ddc     -output "./results/$DESIGN_NAME.ddc"

if {$WITH_DFT} {
    write_test_protocol          -output "./results/$DESIGN_NAME.spf"
}

quit
