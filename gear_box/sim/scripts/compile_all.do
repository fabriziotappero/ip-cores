
if {[file exists work/_info]} {
   echo "INFO: Simulation library work already exists"
} else {
   vlib work
}


vlog ../../../../libs/hdl/clock/tb_clk.v
vlog ../../../../libs/hdl/system/tb_reset.v

vlog ../../src/tb_top.v

vlog ./the_test.v 

vlog ../../../src/buffered_gear_box.v
vlog ../../../src/unbuffered_gear_box.v
vlog ../../../src/unbuffered_gear_box_fsm.v
vlog ../../../src/sync_fifo.v

