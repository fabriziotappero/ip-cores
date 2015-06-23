# script written by Samuel N. Pagliarini
# Cadence Encounter(R) RTL Compiler

set SVNPATH /home/nscad/samuel/Desktop/svn_atari/trunk/
set FILE_LIST {t6507lp.v t6507lp_alu.v t6507lp_fsm.v}

set_attr lp_insert_clock_gating true /
set_attribute lp_insert_operand_isolation true /

set_attribute hdl_search_path $SVNPATH/rtl/verilog/
set_attr lib_search_path $SVNPATH/syn/cadence/libs/

read_hdl $FILE_LIST -v2001
set_attr library { D_CELLS_3_3V.lib D_CELLSL_3_3V.lib}

#set_attribute avoid false [find / -libcell LGC*]
#set_attribute avoid false [find / -libcell LSG*]
#set_attribute avoid false [find / -libcell LSOGC*]

set_attribute lef_library {xc06_m3_FE.lef D_CELLS.lef D_CELLSL.lef}
set_attr cap_table_file xc06m3_typ.CapTbl
set_attr interconnect_mode ple /

elaborate
define_clock -period 1000000 -name 1MHz [find [ find / -design t6507lp] -port clk]
set_attribute slew {0 0 1 1} [find / -clock 1MHz]

read_vcd simvision.vcd

#check_design

synthesize -to_generic -effort high
synthesize -to_mapped -effort high -no_incremental
clock_gating share
synthesize -incremental -effort high

write_encounter design -basename /home/nscad/samuel/Desktop/svn_atari/trunk/syn/cadence/results/t6507lp t6507lp
