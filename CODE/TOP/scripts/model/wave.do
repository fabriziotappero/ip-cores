onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /hdlc_tb/txclk
add wave -noupdate -format Logic /hdlc_tb/rxclk
add wave -noupdate -format Logic /hdlc_tb/tx
add wave -noupdate -format Logic /hdlc_tb/rx
add wave -noupdate -format Logic /hdlc_tb/dut/rxchannel/flag_detect/flagdetect
add wave -noupdate -format Logic /hdlc_tb/rst_i
add wave -noupdate -format Logic /hdlc_tb/clk_i
add wave -noupdate -format Literal /hdlc_tb/adr_i
add wave -noupdate -format Literal /hdlc_tb/dat_o
add wave -noupdate -format Literal /hdlc_tb/dat_i
add wave -noupdate -format Logic /hdlc_tb/we_i
add wave -noupdate -format Logic /hdlc_tb/stb_i
add wave -noupdate -format Logic /hdlc_tb/ack_o
add wave -noupdate -format Logic /hdlc_tb/dut/wb_host/ack_0
add wave -noupdate -format Logic /hdlc_tb/dut/wb_host/ack_1
add wave -noupdate -format Logic /hdlc_tb/dut/wb_host/ack_2
add wave -noupdate -format Logic /hdlc_tb/dut/wb_host/ack_3
add wave -noupdate -format Logic /hdlc_tb/dut/wb_host/ack_4
add wave -noupdate -format Logic /hdlc_tb/dut/wb_host/en_0
add wave -noupdate -format Logic /hdlc_tb/dut/wb_host/en_1
add wave -noupdate -format Logic /hdlc_tb/dut/wb_host/en_2
add wave -noupdate -format Logic /hdlc_tb/dut/wb_host/en_3
add wave -noupdate -format Logic /hdlc_tb/dut/wb_host/en_4
add wave -noupdate -format Literal /hdlc_tb/dut/wb_host/counter
add wave -noupdate -format Logic /hdlc_tb/dut/wb_host/rst_count
add wave -noupdate -format Logic /hdlc_tb/dut/rxbuff/rd
add wave -noupdate -format Logic /hdlc_tb/cyc_i
add wave -noupdate -format Logic /hdlc_tb/rty_o
add wave -noupdate -format Logic /hdlc_tb/tag0_o
add wave -noupdate -format Logic /hdlc_tb/tag1_o
add wave -noupdate -format Literal /hdlc_tb/dut/rxbuff/p_state
add wave -noupdate -format Literal /hdlc_tb/dut/rxbuff/address
add wave -noupdate -format Literal /hdlc_tb/dut/rxbuff/rxdatabuffout
add wave -noupdate -format Literal /hdlc_tb/dut/rxbuff/databuff
add wave -noupdate -format Logic /hdlc_tb/dut/rxbuff/wrbuff
add wave -noupdate -format Literal /hdlc_tb/dut/txbuff/p_state
add wave -noupdate -format Logic /hdlc_tb/dut/txbuff/rdbuff
add wave -noupdate -format Logic /hdlc_tb/dut/txbuff/wr
add wave -noupdate -format Literal /hdlc_tb/dut/txbuff/address
add wave -noupdate -format Literal /hdlc_tb/dut/txbuff/txdataoutbuff
add wave -noupdate -format Literal /hdlc_tb/dut/txbuff/txdatainbuff
add wave -noupdate -format Logic /hdlc_tb/dut/wb_host/txenable
add wave -noupdate -format Literal /hdlc_tb/dut/txbuff/spmem_core/data
add wave -noupdate -format Logic /hdlc_tb/dut/txbuff/txdataavail
add wave -noupdate -format Logic /hdlc_tb/dut/txfcs/validframe
add wave -noupdate -format Literal /hdlc_tb/dut/txfcs/fsm_proc/state
add wave -noupdate -format Logic /hdlc_tb/dut/txfcs/rdy
add wave -noupdate -format Literal /hdlc_tb/dut/txfcs/txdata
add wave -noupdate -format Literal /hdlc_tb/dut/rxbuff/data_out_i
add wave -noupdate -format Literal /hdlc_tb/dut/rxbuff/address
add wave -noupdate -format Literal /hdlc_tb/dut/rxbuff/framesize_i
add wave -noupdate -format Logic /hdlc_tb/dut/rxfcs/validframe
add wave -noupdate -format Literal /hdlc_tb/dut/rxbuff/databuff
add wave -noupdate -format Literal /hdlc_tb/dut/rxfcs/rxd
add wave -noupdate -format Logic /hdlc_tb/dut/rxfcs/rdy
add wave -noupdate -format Logic /hdlc_tb/dut/rxfcs/readbyte
add wave -noupdate -format Logic /hdlc_tb/dut/rxchannel/zero_backend/readbyte
add wave -noupdate -format Logic /hdlc_tb/dut/rxchannel/zero_backend/rdy
add wave -noupdate -format Logic /hdlc_tb/dut/rxchannel/zero_backend/rxd
add wave -noupdate -format Literal /hdlc_tb/dut/rxchannel/zero_backend/rxdata
add wave -noupdate -format Literal /hdlc_tb/dut/rxchannel/zero_backend/dataregister
add wave -noupdate -format Logic /hdlc_tb/dut/rxchannel/zero_backend/flag
add wave -noupdate -format Literal /hdlc_tb/dut/rxchannel/zero_backend/detect_proc/tempregister
add wave -noupdate -format Literal /hdlc_tb/dut/rxchannel/zero_backend/detect_proc/counter
add wave -noupdate -format Logic /hdlc_tb/dut/rxchannel/zero_backend/detect_proc/zerodetected
add wave -noupdate -format Literal /hdlc_tb/dut/rxchannel/zero_backend/detect_proc/checkreg
add wave -noupdate -format Logic /hdlc_tb/dut/rxchannel/zero_backend/startofframe
add wave -noupdate -format Logic /hdlc_tb/dut/rxchannel/zero_backend/aval
add wave -noupdate -format Logic /hdlc_tb/dut/rxchannel/zero_backend/enable
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {146050 ns}
WaveRestoreZoom {146015 ns} {146179 ns}
configure wave -namecolwidth 224
configure wave -valuecolwidth 112
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
