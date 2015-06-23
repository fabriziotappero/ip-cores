# $Id: viv_tools_build.tcl 649 2015-02-21 21:10:16Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2015-02-21   649   1.1    add 2014.4 specific setups
# 2015-02-14   646   1.0    Initial version
#

#
# --------------------------------------------------------------------
#
proc rvtb_trace_cmd {cmd} {
  puts "# $cmd"
  eval $cmd
  return ""
}

#
# --------------------------------------------------------------------
#
proc rvtb_locate_setup_file {stem} {
  set name "${stem}_setup.tcl"
  if {[file readable $name]} {return $name}
  set name "$../{stem}_setup.tcl"
  if {[file readable $name]} {return $name}
  return ""
}

#
# --------------------------------------------------------------------
#
proc rvtb_mv_file {src dst} {
  if {[file readable $src]} {
    exec mv $src $dst
  } else {
    puts "rvtb_mv_file-W: file '$src' not existing"
  }
  return ""
}

#
# --------------------------------------------------------------------
#
proc rvtb_cp_file {src dst} {
  if {[file readable $src]} {
    exec cp -p $src $dst
  } else {
    puts "rvtb_cp_file-W: file '$src' not existing"
  }
  return ""
}

#
# --------------------------------------------------------------------
#
proc rvtb_build_check {step} {
  get_msg_config -rules
  return ""
}

#
# --------------------------------------------------------------------
#
proc rvtb_default_build {stem step} {
  
  # general setups
  switch [version -short] {
    "2014.4" {
      # suppress nonsense "cannot add Board Part xilinx.com:kc705..." messages
      # set here to avoid messages during create_project
      set_msg_config -suppress -id {Board 49-26} 
    }
  }

  # read setup
  set setup_file [rvtb_locate_setup_file $stem]
  if {$setup_file ne ""} {source  -notrace $setup_file}

  # Create project
  rvtb_trace_cmd "create_project project_mflow ./project_mflow"
  
  # Setup project properties
  set obj [get_projects project_mflow]
  set_property "default_lib"         "xil_defaultlib"    $obj
  set_property "part"                $::rvtb_part        $obj
  set_property "simulator_language"  "Mixed"             $obj
  set_property "target_language"     "VHDL"              $obj
  
  # version dependent setups
  switch [version -short] {
    "2014.4" {
      # suppress nonsense "cannot add Board Part xilinx.com:kc705..." messages
      # repeated here because create_project apparently clears msg_config
      set_msg_config -suppress -id {Board 49-26} 
    }
  }

  # Setup filesets
  set vbom_prj [exec vbomconv -vsyn_prj "${stem}.vbom"]
  eval $vbom_prj
  update_compile_order -fileset sources_1

  # some handy variables
  set path_runs "project_mflow/project_mflow.runs"
  set path_syn1 "${path_runs}/synth_1"
  set path_imp1 "${path_runs}/impl_1"

  # build: synthesize
  rvtb_trace_cmd "launch_runs synth_1"
  rvtb_trace_cmd "wait_on_run synth_1"

  rvtb_mv_file "$path_syn1/runme.log"  "${stem}_syn.log"
  
  rvtb_cp_file "$path_syn1/${stem}_utilization_synth.rpt" "${stem}_syn_util.rpt"
  rvtb_cp_file "$path_syn1/${stem}.dcp" "${stem}_syn.dcp"

  if {$step eq "syn"} {return [rvtb_build_check $step]}

  # build: implement
  rvtb_trace_cmd "launch_runs impl_1"
  rvtb_trace_cmd "wait_on_run impl_1"

  rvtb_cp_file "$path_imp1/runme.log"  "${stem}_imp.log"

  rvtb_cp_file "$path_imp1/${stem}_route_status.rpt"  "${stem}_rou_sta.rpt"
  rvtb_cp_file "$path_imp1/${stem}_drc_routed.rpt"    "${stem}_rou_drc.rpt"
  rvtb_cp_file "$path_imp1/${stem}_io_placed.rpt"     "${stem}_pla_io.rpt"
  rvtb_cp_file "$path_imp1/${stem}_clock_utilization_placed.rpt" \
                                                      "${stem}_pla_clk.rpt"
  rvtb_cp_file "$path_imp1/${stem}_timing_summary_routed.rpt" \
                                                      "${stem}_rou_tim.rpt"
  rvtb_cp_file "$path_imp1/${stem}_utilization_placed.rpt" \
                                                      "${stem}_pla_util.rpt"
  rvtb_cp_file "$path_imp1/${stem}_drc_opted.rpt"     "${stem}_opt_drc.rpt"
  rvtb_cp_file "$path_imp1/${stem}_control_sets_placed.rpt" \
                                                      "${stem}_pla_cset.rpt"
  rvtb_cp_file "$path_imp1/${stem}_power_routed.rpt"  "${stem}_rou_pwr.rpt"

  rvtb_cp_file "$path_imp1/${stem}_opt.dcp"     "${stem}_opt.dcp"
  rvtb_cp_file "$path_imp1/${stem}_placed.dcp"  "${stem}_pla.dcp"
  rvtb_cp_file "$path_imp1/${stem}_routed.dcp"  "${stem}_rou.dcp"

  # additional reports
  rvtb_trace_cmd "open_run impl_1"
  report_utilization -file "${stem}_rou_util.rpt"
  report_utilization -hierarchical -file "${stem}_rou_util_h.rpt"
  report_datasheet -file "${stem}_rou_ds.rpt"

  if {$step eq "imp"} {return [rvtb_build_check $step]}

  # build: bitstream
  rvtb_trace_cmd "launch_runs impl_1 -to_step write_bitstream"
  rvtb_trace_cmd "wait_on_run impl_1"

  rvtb_mv_file "$path_imp1/${stem}.bit" "."
  rvtb_mv_file "$path_imp1/runme.log"  "${stem}_bit.log"

  return [rvtb_build_check $step]
}

