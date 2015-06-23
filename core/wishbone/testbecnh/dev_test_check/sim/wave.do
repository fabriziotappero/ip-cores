onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/DUT/BLOCK_ID
add wave -noupdate -radix hexadecimal /tb/DUT/BLOCK_VER
add wave -noupdate /tb/DUT/i_clk
add wave -noupdate /tb/DUT/i_rst
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/DUT/i_wbs_cfg_cyc
add wave -noupdate /tb/DUT/i_wbs_cfg_stb
add wave -noupdate /tb/DUT/i_wbs_cfg_we
add wave -noupdate -radix hexadecimal /tb/DUT/iv_wbs_cfg_addr
add wave -noupdate /tb/DUT/iv_wbs_cfg_bte
add wave -noupdate /tb/DUT/iv_wbs_cfg_cti
add wave -noupdate -radix hexadecimal /tb/DUT/iv_wbs_cfg_data
add wave -noupdate -radix hexadecimal /tb/DUT/ov_wbs_cfg_data
add wave -noupdate /tb/DUT/iv_wbs_cfg_sel
add wave -noupdate /tb/DUT/o_wbs_cfg_ack
add wave -noupdate /tb/DUT/o_wbs_cfg_err
add wave -noupdate /tb/DUT/o_wbs_cfg_rty
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/DUT/i_wbs_burst_cyc
add wave -noupdate /tb/DUT/i_wbs_burst_stb
add wave -noupdate /tb/DUT/i_wbs_burst_we
add wave -noupdate -radix hexadecimal /tb/DUT/iv_wbs_burst_addr
add wave -noupdate /tb/DUT/iv_wbs_burst_bte
add wave -noupdate /tb/DUT/iv_wbs_burst_cti
add wave -noupdate -radix hexadecimal /tb/DUT/iv_wbs_burst_data
add wave -noupdate /tb/DUT/iv_wbs_burst_sel
add wave -noupdate /tb/DUT/o_wbs_burst_ack
add wave -noupdate /tb/DUT/o_wbs_burst_err
add wave -noupdate /tb/DUT/o_wbs_burst_rty
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/DUT/WB_BURST_SLAVE/o_test_check_data_ena
add wave -noupdate -radix hexadecimal /tb/DUT/WB_BURST_SLAVE/ov_test_check_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1330530 ps} 0}
configure wave -namecolwidth 304
configure wave -valuecolwidth 121
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {18506250 ps}
