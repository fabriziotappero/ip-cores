onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB top}
add wave -noupdate /tb_n2h2_tx/Clk
add wave -noupdate /tb_n2h2_tx/Clk2
add wave -noupdate /tb_n2h2_tx/Rst_n
add wave -noupdate /tb_n2h2_tx/main_ctrl_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/amount_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/mem_addr_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/avalon_addr_from_tx
add wave -noupdate -radix unsigned /tb_n2h2_tx/avalon_readdata_to_tx
add wave -noupdate /tb_n2h2_tx/avalon_re_from_tx
add wave -noupdate /tb_n2h2_tx/avalon_waitrequest_to_tx
add wave -noupdate /tb_n2h2_tx/avalon_waitrequest_to_tx2
add wave -noupdate /tb_n2h2_tx/avalon_readdatavalid_to_tx
add wave -noupdate /tb_n2h2_tx/hibi_av_from_tx
add wave -noupdate -radix unsigned /tb_n2h2_tx/hibi_data_from_tx
add wave -noupdate -radix unsigned /tb_n2h2_tx/hibi_comm_from_tx
add wave -noupdate /tb_n2h2_tx/hibi_we_from_tx
add wave -noupdate /tb_n2h2_tx/hibi_full_to_tx
add wave -noupdate /tb_n2h2_tx/tx_start_to_tx
add wave -noupdate /tb_n2h2_tx/tx_status_done_from_tx
add wave -noupdate -radix unsigned /tb_n2h2_tx/tx_hibi_addr_to_tx
add wave -noupdate -radix unsigned /tb_n2h2_tx/tx_ram_addr_to_tx
add wave -noupdate -radix unsigned /tb_n2h2_tx/tx_amount_to_tx
add wave -noupdate -radix unsigned /tb_n2h2_tx/tx_comm_to_tx
add wave -noupdate /tb_n2h2_tx/cs1_n_to_ram
add wave -noupdate /tb_n2h2_tx/cs2_to_ram
add wave -noupdate -radix unsigned /tb_n2h2_tx/addr_to_ram
add wave -noupdate -radix unsigned /tb_n2h2_tx/data_inout_ram
add wave -noupdate /tb_n2h2_tx/we_n_to_ram
add wave -noupdate /tb_n2h2_tx/oe_n_to_ram
add wave -noupdate -radix unsigned /tb_n2h2_tx/delayed_data_from_ram_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/hibi_addr_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/hibi_amount_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/hibi_data_r
add wave -noupdate /tb_n2h2_tx/wait_cnt_r
add wave -noupdate /tb_n2h2_tx/avalon_waitr_cnt_r
add wave -noupdate /tb_n2h2_tx/hibi_we_was_up_r
add wave -noupdate /tb_n2h2_tx/hibi_full_cnt_r
add wave -noupdate /tb_n2h2_tx/hibi_full_up_cc
add wave -noupdate -divider {DUT tx}
add wave -noupdate /tb_n2h2_tx/DUT/clk
add wave -noupdate /tb_n2h2_tx/DUT/rst_n
add wave -noupdate /tb_n2h2_tx/DUT/avalon_re_out
add wave -noupdate -radix unsigned /tb_n2h2_tx/DUT/avalon_addr_out
add wave -noupdate -radix unsigned /tb_n2h2_tx/DUT/avalon_readdata_in
add wave -noupdate /tb_n2h2_tx/DUT/avalon_waitrequest_in
add wave -noupdate /tb_n2h2_tx/DUT/avalon_readdatavalid_in
add wave -noupdate /tb_n2h2_tx/DUT/hibi_av_out
add wave -noupdate -radix unsigned /tb_n2h2_tx/DUT/hibi_data_out
add wave -noupdate /tb_n2h2_tx/DUT/hibi_comm_out
add wave -noupdate /tb_n2h2_tx/DUT/hibi_we_out
add wave -noupdate /tb_n2h2_tx/DUT/hibi_full_in
add wave -noupdate /tb_n2h2_tx/DUT/tx_start_in
add wave -noupdate /tb_n2h2_tx/DUT/tx_status_done_out
add wave -noupdate -radix unsigned /tb_n2h2_tx/DUT/tx_comm_in
add wave -noupdate -radix unsigned /tb_n2h2_tx/DUT/tx_hibi_addr_in
add wave -noupdate -radix unsigned /tb_n2h2_tx/DUT/tx_ram_addr_in
add wave -noupdate -radix unsigned /tb_n2h2_tx/DUT/tx_amount_in
add wave -noupdate /tb_n2h2_tx/DUT/control_r
add wave -noupdate /tb_n2h2_tx/DUT/addr_cnt_en_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/DUT/addr_cnt_value_r
add wave -noupdate /tb_n2h2_tx/DUT/addr_cnt_load_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/DUT/addr_r
add wave -noupdate /tb_n2h2_tx/DUT/amount_cnt_en_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/DUT/amount_cnt_value_r
add wave -noupdate /tb_n2h2_tx/DUT/amount_cnt_load_r
add wave -noupdate -radix unsigned /tb_n2h2_tx/DUT/amount_r
add wave -noupdate /tb_n2h2_tx/DUT/addr_amount_eq
add wave -noupdate -radix unsigned /tb_n2h2_tx/DUT/addr_to_stop_r
add wave -noupdate /tb_n2h2_tx/DUT/avalon_re_r
add wave -noupdate /tb_n2h2_tx/DUT/start_re_r
add wave -noupdate /tb_n2h2_tx/DUT/hibi_write_addr_r
add wave -noupdate /tb_n2h2_tx/DUT/data_src_sel
add wave -noupdate /tb_n2h2_tx/DUT/hibi_we_r
add wave -noupdate /tb_n2h2_tx/DUT/hibi_stop_we_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {175 ns} 0}
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
WaveRestoreZoom {0 ns} {676 ns}
