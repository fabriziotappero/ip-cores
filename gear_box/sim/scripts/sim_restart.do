
vlog +define+DEBUG "../../src/tb_top.v"

vlog ./the_test.v 

vlog ../../../src/buffered_gear_box.v
vlog ../../../src/unbuffered_gear_box.v
vlog ../../../src/unbuffered_gear_box_fsm.v
vlog ../../../src/sync_fifo.v


restart -force

#run 100us

run -all

