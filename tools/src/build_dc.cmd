
# The Tcl script under $S1_ROOT/tools/src/build_dc.cmd is attached at the end of the filelist for DC;
# if you modify this file *REMEMBER* to run 'update_filelist' or you'll run the old version!!!

# Variables setting

set sub_modules {sparc_ifu lsu sparc_exu sparc_ffu sparc_mul_top spu tlu s1_top}
set sub_clocks  {rclk clk sys_clock_i}
set sub_resets  {grst_l arst_l sys_reset_i}

foreach active_design $sub_modules {

  # Technology-independent elaboration and linking
  elaborate      $active_design
  current_design $active_design
  link
  uniquify -dont_skip_empty_designs

  # Set constraints and mapping on target library
  create_clock -period 5.0 -waveform [list 0 2.5] [get_ports $sub_clocks]
  set_input_delay  1.8 -clock [get_clocks $sub_clocks] -max [all_inputs]
  set_output_delay 1.2 -clock [get_clocks $sub_clocks] -max [all_outputs]
  set_dont_touch_network [concat $sub_clocks $sub_resets]
  set_drive    0         [concat $sub_clocks $sub_resets]
  set_max_area 0
  set_wire_load_mode enclosed
  set_fix_multiple_port_nets -buffer_constants -all
  compile

  # Export the mapped design
  remove_unconnected_ports [find -hierarchy cell {"*"}]
  set_dont_touch current_design
  write -format ddc -hierarchy -output $active_design.ddc
  write -format verilog -hierarchy -output $active_design.sv

  # Report area and timing
  report_area -hierarchy > report_${active_design}_area.rpt
  report_timing > report_${active_design}_timing.rpt
  report_constraint -all_violators > report_${active_design}_constraint.rpt

}

quit

