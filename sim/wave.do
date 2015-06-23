onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TX controller}
add wave -noupdate /testcase_1/testbench/wb_addr_i
add wave -noupdate -radix hexadecimal /testcase_1/testbench/wb_dat_i
add wave -noupdate /testcase_1/testbench/wb_cyc_i
add wave -noupdate /testcase_1/testbench/wb_stb_i
add wave -noupdate /testcase_1/testbench/wb_we_i
add wave -noupdate /testcase_1/testbench/wb_rst_i
add wave -noupdate /testcase_1/testbench/wb_clk_i
add wave -noupdate /testcase_1/testbench/one_o
add wave -noupdate /testcase_1/testbench/zero_o
add wave -noupdate -radix hexadecimal /testcase_1/testbench/wb_dat_o
add wave -noupdate /testcase_1/testbench/wb_ack_o
add wave -noupdate /testcase_1/testbench/wb_err_o
add wave -noupdate /testcase_1/testbench/wb_rty_o
add wave -noupdate -divider {RX controller}
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/one_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/zero_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_clk_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_rst_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_dat_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_dat_o
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_cyc_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_stb_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_we_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_sel_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_cti_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_adr_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_ack_o
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_err_o
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_rty_o
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/rst
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/data
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/dat_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/dat_o
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/data_o
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/pulsewidth
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/sampleCnt
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/p2p
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/msgLength
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/word_in
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/fifo_out
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/zero_edge
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/one_edge
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/zero_det
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/one_det
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/clk
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/lock_cfg
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/filter1
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/filter0
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/filterCnt
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/sampleTime
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/filterEn
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/bitCount
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/tpiCnt
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/tpi
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/errorClr
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/msgDone
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/msgError
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/zero
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/one
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/notzero
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/notone
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/filtered1
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/filtered0
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_data_i
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/rst_FIFO
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wr_en
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/rd_en
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/full
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/empty
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/start_tx
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/full_dly
add wave -noupdate /testcase_1/testbench/wiegand_rx_top/wb_wr_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9383386 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 365
configure wave -valuecolwidth 81
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
configure wave -timelineunits ns
update
WaveRestoreZoom {9147233 ps} {9980065 ps}
