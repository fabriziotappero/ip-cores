onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/DUT/i_clk
add wave -noupdate /tb/DUT/i_rst
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/DUT/i_wbs_cfg_cyc
add wave -noupdate /tb/DUT/i_wbs_cfg_stb
add wave -noupdate /tb/DUT/i_wbs_cfg_we
add wave -noupdate /tb/DUT/iv_wbs_cfg_addr
add wave -noupdate /tb/DUT/iv_wbs_cfg_bte
add wave -noupdate /tb/DUT/iv_wbs_cfg_cti
add wave -noupdate /tb/DUT/iv_wbs_cfg_data
add wave -noupdate /tb/DUT/iv_wbs_cfg_sel
add wave -noupdate /tb/DUT/o_wbs_cfg_ack
add wave -noupdate /tb/DUT/o_wbs_cfg_err
add wave -noupdate /tb/DUT/o_wbs_cfg_rty
add wave -noupdate /tb/DUT/ov_wbs_cfg_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/DUT/i_wbs_burst_cyc
add wave -noupdate /tb/DUT/i_wbs_burst_stb
add wave -noupdate /tb/DUT/i_wbs_burst_we
add wave -noupdate -radix hexadecimal /tb/DUT/iv_wbs_burst_addr
add wave -noupdate /tb/DUT/iv_wbs_burst_bte
add wave -noupdate /tb/DUT/iv_wbs_burst_cti
add wave -noupdate /tb/DUT/iv_wbs_burst_sel
add wave -noupdate /tb/DUT/o_wbs_burst_ack
add wave -noupdate /tb/DUT/o_wbs_burst_err
add wave -noupdate /tb/DUT/o_wbs_burst_rty
add wave -noupdate -radix hexadecimal /tb/DUT/ov_wbs_burst_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /tb/DUT/sv_test_gen_ctrl
add wave -noupdate -expand -group TEST_GEN_FIFO /tb/DUT/TEST_GEN_FIFO/clk
add wave -noupdate -expand -group TEST_GEN_FIFO /tb/DUT/TEST_GEN_FIFO/wr_en
add wave -noupdate -expand -group TEST_GEN_FIFO -radix hexadecimal /tb/DUT/TEST_GEN_FIFO/din
add wave -noupdate -expand -group TEST_GEN_FIFO /tb/DUT/TEST_GEN_FIFO/rd_en
add wave -noupdate -expand -group TEST_GEN_FIFO -radix hexadecimal /tb/DUT/TEST_GEN_FIFO/dout
add wave -noupdate -expand -group TEST_GEN_FIFO /tb/DUT/TEST_GEN_FIFO/empty
add wave -noupdate -expand -group TEST_GEN_FIFO /tb/DUT/TEST_GEN_FIFO/full
add wave -noupdate -expand -group TEST_GEN_FIFO /tb/DUT/TEST_GEN_FIFO/prog_full
add wave -noupdate -expand -group TEST_GEN_FIFO /tb/DUT/TEST_GEN_FIFO/rst
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/DUT/WB_BURST_SLAVE/s_wb_transfer_ok_0
add wave -noupdate -radix unsigned /tb/DUT/WB_BURST_SLAVE/sv_wbs_burst_counter
add wave -noupdate -format Literal /tb/DUT/WB_BURST_SLAVE/sv_wbs_fsm
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix unsigned /tb/DUT/sv_test_gen_bl_wr
add wave -noupdate -radix hexadecimal /tb/DUT/sv_test_gen_ctrl
add wave -noupdate -radix unsigned /tb/DUT/sv_test_gen_size
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18116000 ps} 0}
configure wave -namecolwidth 281
configure wave -valuecolwidth 163
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
WaveRestoreZoom {8047752 ps} {39322248 ps}
