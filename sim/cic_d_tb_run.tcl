onerror {resume}
set tb_name cic_d_tb
quit -sim
vlog -sv -work work cic_core/trunk/src/cic_package.sv
vlog -sv -work work cic_core/trunk/src/*.sv
vlog -sv -work work cic_core/trunk/sim/$tb_name.sv
vsim -t 1ns -novopt work.$tb_name
add wave /$tb_name/*
add wave {/cic_d_tb/dut1/int_stage[0]/*}
add wave {/cic_d_tb/dut1/int_stage[1]/*}
add wave {/cic_d_tb/dut1/int_stage[2]/*}
add wave {/cic_d_tb/dut1/int_stage[3]/*}
add wave /$tb_name/dut1/u1/*
add wave {/cic_d_tb/dut1/comb_stage[0]/*}
add wave {/cic_d_tb/dut1/comb_stage[1]/*}
add wave {/cic_d_tb/dut1/comb_stage[2]/*}
add wave {/cic_d_tb/dut1/comb_stage[3]/*}
run 100 us
