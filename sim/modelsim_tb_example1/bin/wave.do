onerror {resume}
quietly virtual signal -install /tb_example1 {/tb_example1/pltbs.test_num  } Test_number
quietly virtual signal -install /tb_example1 {/tb_example1/pltbs.test_name  } Test_name
quietly virtual signal -install /tb_example1 {/tb_example1/pltbs.info  } Info
quietly virtual signal -install /tb_example1 {/tb_example1/pltbs.chk_cnt  } Checks
quietly virtual signal -install /tb_example1 {/tb_example1/pltbs.err_cnt  } Errors
quietly virtual signal -install /tb_example1 {/tb_example1/pltbs.stop_sim  } StopSim
quietly virtual signal -install /tb_example1 {/tb_example1/pltbs.test_num  } TestNumber
quietly virtual signal -install /tb_example1 {/tb_example1/pltbs.test_name  } TestName
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Simulation info}
add wave -noupdate /tb_example1/TestNumber
add wave -noupdate /tb_example1/TestName
add wave -noupdate /tb_example1/Info
add wave -noupdate /tb_example1/Checks
add wave -noupdate /tb_example1/Errors
add wave -noupdate /tb_example1/StopSim
add wave -noupdate -divider Tb
add wave -noupdate /tb_example1/clk
add wave -noupdate /tb_example1/rst
add wave -noupdate /tb_example1/carry_in
add wave -noupdate /tb_example1/x
add wave -noupdate /tb_example1/y
add wave -noupdate /tb_example1/sum
add wave -noupdate /tb_example1/carry_out
add wave -noupdate -divider DUT
add wave -noupdate /tb_example1/dut0/clk_i
add wave -noupdate /tb_example1/dut0/rst_i
add wave -noupdate /tb_example1/dut0/carry_i
add wave -noupdate /tb_example1/dut0/x_i
add wave -noupdate /tb_example1/dut0/y_i
add wave -noupdate /tb_example1/dut0/sum_o
add wave -noupdate /tb_example1/dut0/carry_o
add wave -noupdate /tb_example1/dut0/x
add wave -noupdate /tb_example1/dut0/y
add wave -noupdate /tb_example1/dut0/c
add wave -noupdate /tb_example1/dut0/sum
add wave -noupdate -divider End
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 133
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {131072 ps}
