  echo -n " Starting Synthesis "

  set search_path [list . $search_path ../../rtl]
  set synthetic_library [list standard.sldb dw_foundation.sldb]

  set tech_lib "slow"

  set target_library ${tech_lib}.db
  set link_library [concat $target_library $synthetic_library]

  define_design_lib WORK -path work

  analyze -work WORK -format verilog ../../rtl/BM_lamda.v
  analyze -work WORK -format verilog ../../rtl/GF_mult_add_syndromes.v
  analyze -work WORK -format verilog ../../rtl/Omega_Phy.v
  analyze -work WORK -format verilog ../../rtl/RS_dec.v
  analyze -work WORK -format verilog ../../rtl/error_correction.v
  analyze -work WORK -format verilog ../../rtl/input_syndromes.v
  analyze -work WORK -format verilog ../../rtl/lamda_roots.v
  analyze -work WORK -format verilog ../../rtl/out_stage.v
  analyze -work WORK -format verilog ../../rtl/transport_in2out.v
  set module RS_dec

  elaborate -work WORK $module

  current_design ${module}

  echo -n " ================================== "
  echo -n "      Constraining the design       "
  echo -n " ================================== "

  # /*------------------------------------------------------------------------
  # Creating virtual clock
  # ------------------------------------------------------------------------*/

  create_clock "clk" -period 17.8

  set_dont_touch_network clk
  set_clock_latency 0.8 clk
  set_clock_uncertainty 0.5 clk

  set_dont_touch_network [get_ports clk]
  set_dont_touch_network [get_ports reset]

  set_drive 0 [get_ports clk]
  set_fix_hold [get_clocks clk]

  # /*------------------------------------------------------------------------
  # Setting Input/Output delays
  # ------------------------------------------------------------------------*/

  set_input_delay 5.9 -clock clk [all_inputs]

  set_output_delay 5.9 -clock clk [all_outputs]


  echo " ================================== "
  echo "               Linking              "
  echo " ================================== "
  link

  echo " ================================== "
  echo "           Uniquifying              "
  echo " ================================== "
  set uniquify_naming_style %s_%d
  uniquify


  echo -n " ================================== "
  echo -n "       Compiling the design         "
  echo -n " ================================== "

  compile -ungroup_all -map_effort high -scan

  echo -n " ================================== "
  echo -n "         Generating reports         "
  echo -n " ================================== "
  report_area      > "report/${module}.rpt"
  report_timing    >> "report/${module}.rpt"
  report_design    >> "report/${module}.rpt"
  report_cell      >> "report/${module}.rpt"
  report_power -nosplit     >> "report/${module}.rpt"
  report_constraint >> "report/${module}.rpt"
  echo "Loops\n" >> "report/${module}.rpt"
  echo "=====\n" >> "report/${module}.rpt"
  report_timing -loops >> "report/${module}.rpt"

  echo "Reporting Hierarchy\n" >> "report/${module}.rpt"
  echo "===================\n" >> "report/${module}.rpt"
  report_hier >> "report/${module}.rpt"
  get_designs -hier "*" >> "report/${module}.rpt"

  echo "Reporting Fanout\n" >> "report/${module}.rpt"
  echo "================\n" >> "report/${module}.rpt"
  report_net_fanout -high -nosplit >> "report/${module}.rpt"


  current_design ${module}

  write -format ddc -hierarchy -o gatenet/$module.ddc
  write -format verilog -o gatenet/$module.v
  write_sdc gatenet/$module.sdc

  echo -n " ================================== "
  echo -n "           Synthesis Over           "
  echo -n " ================================== "
  sh date

  echo "Done"
  quit

