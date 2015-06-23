onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_hibi_transmitter/clk
add wave -noupdate /tb_hibi_transmitter/rst_n
add wave -noupdate /tb_hibi_transmitter/current_test_case
add wave -noupdate /tb_hibi_transmitter/read_tmp
add wave -noupdate -divider {rx_ctrl (=tb) -> duv}
add wave -noupdate /tb_hibi_transmitter/send_tx_ack_to_duv
add wave -noupdate /tb_hibi_transmitter/send_tx_nack_to_duv
add wave -noupdate /tb_hibi_transmitter/send_rx_ack_to_duv
add wave -noupdate /tb_hibi_transmitter/send_rx_nack_to_duv
add wave -noupdate /tb_hibi_transmitter/send_request_to_duv
add wave -noupdate /tb_hibi_transmitter/send_en
add wave -noupdate /tb_hibi_transmitter/ready_for_tx_from_duv
add wave -noupdate -radix hexadecimal /tb_hibi_transmitter/ack_addr_to_duv
add wave -noupdate -radix hexadecimal /tb_hibi_transmitter/rx_addr_to_duv
add wave -noupdate -radix hexadecimal /tb_hibi_transmitter/rx_len_to_duv
add wave -noupdate -radix hexadecimal /tb_hibi_transmitter/rx_data_to_duv
add wave -noupdate /tb_hibi_transmitter/rx_re_from_duv
add wave -noupdate /tb_hibi_transmitter/rx_empty_to_duv
add wave -noupdate -divider {duv -> hibi}
add wave -noupdate /tb_hibi_transmitter/clk
add wave -noupdate /tb_hibi_transmitter/hibi_av_from_duv
add wave -noupdate -radix hexadecimal /tb_hibi_transmitter/hibi_data_from_duv
add wave -noupdate -radix hexadecimal /tb_hibi_transmitter/hibi_comm_from_duv
add wave -noupdate /tb_hibi_transmitter/hibi_we_from_duv
add wave -noupdate /tb_hibi_transmitter/hibi_full_to_duv
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {293 ns} 0}
configure wave -namecolwidth 270
configure wave -valuecolwidth 182
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ns} {4179 ns}
