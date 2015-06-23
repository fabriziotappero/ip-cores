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
vlog     -quiet ../../../../../src/pcie_src/components/rtl/core64_pb_wishbone_ctrl.v
vcom     -quiet ../../../../../src/pcie_src/components/coregen/ctrl_fifo512x64st_v0.vhd

#
#
vlog -sv -quiet tb.v

#
#
vsim -t ps -novopt -L unisims_ver work.tb

#
#
log -r /*

#
#
do wave.do

#
#
run -all
