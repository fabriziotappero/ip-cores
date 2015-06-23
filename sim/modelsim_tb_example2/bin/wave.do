onerror {resume}
quietly virtual signal -install /tb_example2 {/tb_example2/pltbs.test_num  } Test_number
quietly virtual signal -install /tb_example2 {/tb_example2/pltbs.test_name  } Test_name
quietly virtual signal -install /tb_example2 {/tb_example2/pltbs.info  } Info
quietly virtual signal -install /tb_example2 {/tb_example2/pltbs.chk_cnt  } Checks
quietly virtual signal -install /tb_example2 {/tb_example2/pltbs.err_cnt  } Errors
quietly virtual signal -install /tb_example2 {/tb_example2/pltbs.stop_sim  } StopSim
quietly virtual signal -install /tb_example2 {/tb_example2/pltbs.test_num  } TestNumber
quietly virtual signal -install /tb_example2 {/tb_example2/pltbs.test_name  } TestName
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Simulation info}
add wave -noupdate /tb_example2/TestNumber
add wave -noupdate /tb_example2/TestName
add wave -noupdate /tb_example2/Info
add wave -noupdate /tb_example2/Checks
add wave -noupdate /tb_example2/Errors
add wave -noupdate /tb_example2/StopSim
add wave -noupdate -divider Tb
add wave -noupdate /tb_example2/clk
add wave -noupdate /tb_example2/rst
add wave -noupdate /tb_example2/carry_in
add wave -noupdate /tb_example2/x
add wave -noupdate /tb_example2/y
add wave -noupdate /tb_example2/sum
add wave -noupdate /tb_example2/carry_out
add wave -noupdate -divider DUT
add wave -noupdate /tb_example2/dut0/clk_i
add wave -noupdate /tb_example2/dut0/rst_i
add wave -noupdate /tb_example2/dut0/carry_i
add wave -noupdate /tb_example2/dut0/x_i
add wave -noupdate /tb_example2/dut0/y_i
add wave -noupdate /tb_example2/dut0/sum_o
add wave -noupdate /tb_example2/dut0/carry_o
add wave -noupdate /tb_example2/dut0/x
add wave -noupdate /tb_example2/dut0/y
add wave -noupdate /tb_example2/dut0/c
add wave -noupdate /tb_example2/dut0/sum
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
