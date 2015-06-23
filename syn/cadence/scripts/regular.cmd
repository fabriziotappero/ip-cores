# script written by Samuel N. Pagliarini
# Cadence Encounter(R) RTL Compiler

set SVNPATH /home/nscad/samuel/Desktop/svn_atari/trunk/
set FILE_LIST {t6507lp.v t6507lp_alu.v t6507lp_fsm.v}

set_attribute hdl_search_path $SVNPATH/rtl/verilog/
set_attr lib_search_path $SVNPATH/syn/cadence/libs/
read_hdl $FILE_LIST -v2001
set_attr library D_CELLS_3_3V.lib
# use other libs later
elaborate
check_design -unresolved
define_clock -period 1000000 -name 1MHz [find [ find / -design t6507lp] -port clk]
synthesize -to_generic
synthesize -to_mapped

write_hdl t6507lp > ../results/t6507.vg

#reports
#report area

