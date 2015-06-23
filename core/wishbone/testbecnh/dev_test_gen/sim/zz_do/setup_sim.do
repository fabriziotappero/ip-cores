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
vcom     -quiet ../../../../../src/pcie_src/components/rtl/host_pkg.vhd
vcom     -quiet ../../../../../src/pcie_src/components/rtl/ctrl_ram16_v1.vhd
vcom     -quiet ../../../../../src/wishbone/block_test_generate/block_generate_wb_config_slave.vhd

vlog     -quiet ../../../../../src/wishbone/block_test_generate/block_generate_wb_burst_slave.v
vcom     -quiet ../../../../../src/wishbone/coregen/ctrl_fifo1024x64_st_v1.vhd

vcom     -quiet ../../../../../src/wishbone/block_test_generate/cl_test_generate.vhd

vcom     -quiet ../../../../../src/wishbone/block_test_generate/block_generate_wb_pkg.vhd
vcom     -quiet ../../../../../src/wishbone/block_test_generate/block_test_generate_wb.vhd

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
