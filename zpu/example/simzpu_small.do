# Xilinx WebPack modelsim script
#
# 
# cd C:/workspace/zpu/zpu/hdl/example
# do simzpu_small.do
#
# after 5ms simulated time ends and log.txt is produced
# with the hello world text output from a simulated 
# uart/debug port output

set BreakOnAssertion 1
vlib work

vcom -93 -explicit  zpu_config.vhd
vcom -93 -explicit  ../zpu4/core/zpupkg.vhd
vcom -93 -explicit  ../zpu4/src/txt_util.vhd
vcom -93 -explicit  sim_small_fpga_top_noint.vhd
vcom -93 -explicit  ../zpu4/core/zpu_core_small.vhd
vcom -93 -explicit  helloworld.vhd
vcom -93 -explicit  ../zpu4/src/timer.vhd
vcom -93 -explicit  ../zpu4/src/io.vhd
vcom -93 -explicit  ../zpu4/src/trace.vhd

# run ZPU
vsim fpga_top
view wave
add wave -recursive fpga_top/zpu/*
#add wave -recursive fpga_top/*
view structure
#view signals

# Enough to run tiny programs
run 5 ms
