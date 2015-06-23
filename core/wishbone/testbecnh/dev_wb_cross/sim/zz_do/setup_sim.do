#
#
quit -sim
#
#
echo Cre WORK lib
if {[file exists "work"]} { vdel -all}
vlib work

#
#
echo Compile SRC:

vlog -quiet ../../../../../src/wishbone/cross/wb_conmax_top.v 
vlog -quiet ../../../../../src/wishbone/cross/wb_conmax_slave_if.v 
vlog -quiet ../../../../../src/wishbone/cross/wb_conmax_master_if.v 
vlog -quiet ../../../../../src/wishbone/cross/wb_conmax_msel.v 
vlog -quiet ../../../../../src/wishbone/cross/wb_conmax_arb.v 
vlog -quiet ../../../../../src/wishbone/cross/wb_conmax_pri_enc.v 
vlog -quiet ../../../../../src/wishbone/cross/wb_conmax_pri_dec.v 
vlog -quiet ../../../../../src/wishbone/cross/wb_conmax_rf.v 

#
#
vlog -sv -quiet tb.v

#
#
vsim -t ps -novopt work.tb

#
#
log -r /*

#
#
do wave.do

#
#
run -all
