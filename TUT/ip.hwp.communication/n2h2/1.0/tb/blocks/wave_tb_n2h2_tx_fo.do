onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_n2h2_tx/test_ctrl_r
add wave -noupdate /tb_n2h2_tx/test_case_ctrl_r
add wave -noupdate -divider {TB configures DMA tx}
add wave -noupdate /tb_n2h2_tx/clk
add wave -noupdate /tb_n2h2_tx/rst_n
add wave -noupdate /tb_n2h2_tx/tx_status_duv_tb
add wave -noupdate /tb_n2h2_tx/tx_irq_tb_duv
add wave -noupdate /tb_n2h2_tx/amount_tb_duv
add wave -noupdate /tb_n2h2_tx/dpram_addr_tb_duv
add wave -noupdate -radix unsigned /tb_n2h2_tx/hibi_addr_tb_duv
add wave -noupdate -radix unsigned /tb_n2h2_tx/comm_tb_duv
add wave -noupdate -divider {Mem <-> DMA tx}
add wave -noupdate /tb_n2h2_tx/clk
add wave -noupdate /tb_n2h2_tx/avalon_read_duv_tb
add wave -noupdate -radix unsigned /tb_n2h2_tx/avalon_addr_duv_tb
add wave -noupdate -radix unsigned /tb_n2h2_tx/avalon_vec_readdata_tb_duv
add wave -noupdate /tb_n2h2_tx/avalon_waitrequest_tb_duv
add wave -noupdate /tb_n2h2_tx/avalon_readdatavalid_tb_duv
add wave -noupdate /tb_n2h2_tx/clk2
add wave -noupdate -divider {DMA tx -> Hibi}
add wave -noupdate /tb_n2h2_tx/clk
add wave -noupdate /tb_n2h2_tx/hibi_av_duv_tb
add wave -noupdate /tb_n2h2_tx/hibi_data_duv_tb
add wave -noupdate -radix unsigned /tb_n2h2_tx/hibi_comm_duv_tb
add wave -noupdate /tb_n2h2_tx/hibi_we_duv_tb
add wave -noupdate /tb_n2h2_tx/hibi_full_tb_duv
add wave -noupdate -divider {TB signals}
add wave -noupdate /tb_n2h2_tx/counter_r
add wave -noupdate /tb_n2h2_tx/new_hibi_addr_r
add wave -noupdate /tb_n2h2_tx/new_amount_r
add wave -noupdate /tb_n2h2_tx/new_dpram_addr_r
add wave -noupdate /tb_n2h2_tx/global_hibi_addr_r
add wave -noupdate /tb_n2h2_tx/global_amount_r
add wave -noupdate /tb_n2h2_tx/global_comm_r
add wave -noupdate /tb_n2h2_tx/global_dpram_addr
add wave -noupdate /tb_n2h2_tx/avalon_data_counter_r
add wave -noupdate /tb_n2h2_tx/avalon_addr_counter_r
add wave -noupdate /tb_n2h2_tx/avalon_amount
add wave -noupdate /tb_n2h2_tx/avalon_addr_sent
add wave -noupdate /tb_n2h2_tx/avalon_last_addr
add wave -noupdate /tb_n2h2_tx/hibi_addr_came
add wave -noupdate /tb_n2h2_tx/hibi_data_counter_r
add wave -noupdate /tb_n2h2_tx/hibi_amount
add wave -noupdate -divider DUT
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/clk
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/tx_hibi_addr_in
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/tx_ram_addr_in
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/tx_amount_in
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/tx_comm_in
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/avalon_addr_out
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/avalon_readdata_in
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/hibi_av_out
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/hibi_data_out
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/hibi_comm_out
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/hibi_we_out
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/tx_status_done_out
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/clk
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/control_r
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/addr_cnt_en_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/addr_cnt_value_r
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/addr_cnt_load_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/addr_r
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/amount_cnt_en_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/amount_cnt_value_r
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/amount_cnt_load_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/amount_r
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/addr_amount_eq
add wave -noupdate -radix unsigned /tb_n2h2_tx/n2h2_tx_1/addr_to_stop_r
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/avalon_re_r
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/start_re_r
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/hibi_write_addr_r
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/data_src_sel
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/hibi_we_r
add wave -noupdate /tb_n2h2_tx/n2h2_tx_1/hibi_stop_we_r
add wave -noupdate -divider {Dut ends}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1103 ns} 0}
configure wave -namecolwidth 211
configure wave -valuecolwidth 100
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ns} {2036 ns}
