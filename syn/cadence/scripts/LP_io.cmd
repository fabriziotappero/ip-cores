# script written by Samuel N. Pagliarini
# Cadence Encounter(R) RTL Compiler

#set_attr information_level 9
#dont use level nine unless you are evaluating the synthesis

set SVNPATH /home/nscad/samuel/Desktop/svn_atari/trunk/
set FILE_LIST {t6507lp_io.v t6507lp.v t6507lp_alu.v t6507lp_fsm.v}

set_attr lp_insert_clock_gating true /
set_attr lp_insert_operand_isolation true /
set_attr lp_power_analysis_effort high /
# controls the switching activity propagation
set_attr dft_scan_style muxed_scan /
#set_attr dft_scan_map_mode tdrc_pass /
# this will force the mapping of all registers that passed dft rules into scannable registers
set_attr hdl_search_path $SVNPATH/rtl/verilog/
set_attr lib_search_path "$SVNPATH/syn/cadence/libs/ /home"

read_hdl $FILE_LIST -v2001
set_attr library {D_CELLSL_3_3V.lib IO_CELLS_33.lib}

set_attribute avoid false [find / -libcell LGC*]
set_attribute avoid false [find / -libcell LSG*]
set_attribute avoid false [find / -libcell LSOGC*]
set_attribute avoid true [find / -libcell EN2LX1]
# the EN2LX1 cell always reports violations. i have also declared the dont use attribute of the cell in the .lib file

set_attribute lef_library {xc06_m3_FE.lef D_CELLSL.lef IO_CELLS.lef}
set_attr cap_table_file xc06m3_typ.CapTbl
set_attr interconnect_mode ple /

elaborate

define_clock -period 1000000 -name 1MHz [find [ find / -design t6507lp_io] -port clk]
set_attribute slew {0 0 100 100} [find / -clock 1MHz]
external_delay -clock [find / -clock 1MHz] -output 100 [all_outputs]
external_delay -clock [find / -clock 1MHz] -input 100 [all_inputs]

define_dft shift_enable -active high [find / -port scan_enable] -name SE
set_attribute lp_clock_gating_test_signal SE /des*/*
set_attribute lp_clock_gating_extract_common_enable true /des*/*
set_attribute max_dynamic_power 3000000 /des*/*
# this command sets the max power at 3mV. The tool will optimize a bit but it wont necessarily reach that goal.

#read_vcd simvision.vcd -module t6507lp -static
#argh

report timing -lint

check_dft_rules
synthesize -to_generic -effort high
synthesize -to_mapped -effort high -no_incremental
clock_gating share -hier

define_dft scan_chain -name chain1 -sdi [find / -pin data_in[0]] -sdo [find / -pin data_out[0]] -shared_out -shared_select SE -shift_enable SE
connect_scan_chains
check_dft_rules

synthesize -incremental -effort high

check_design -all

report timing > ../reports/RC_timing.txt
report area > ../reports/RC_area.txt
report power > ../reports/RC_power.txt

write_encounter design -basename /home/nscad/samuel/Desktop/svn_atari/trunk/syn/cadence/results/t6507lp_io t6507lp_io
