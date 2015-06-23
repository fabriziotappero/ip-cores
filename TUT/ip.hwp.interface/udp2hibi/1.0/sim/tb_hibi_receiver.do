onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {hibi (=tb) -> duv}
add wave -noupdate /tb_hibi_receiver/clk
add wave -noupdate /tb_hibi_receiver/rst_n
add wave -noupdate /tb_hibi_receiver/current_tx
add wave -noupdate /tb_hibi_receiver/hibi_av_to_duv
add wave -noupdate -radix hexadecimal /tb_hibi_receiver/hibi_data_to_duv
add wave -noupdate -radix hexadecimal /tb_hibi_receiver/hibi_comm_to_duv
add wave -noupdate /tb_hibi_receiver/hibi_empty_to_duv
add wave -noupdate /tb_hibi_receiver/hibi_re_from_duv
add wave -noupdate -divider {which operation duv performs}
add wave -noupdate /tb_hibi_receiver/new_tx_conf_from_duv
add wave -noupdate /tb_hibi_receiver/new_tx_from_duv
add wave -noupdate /tb_hibi_receiver/release_lock_from_duv
add wave -noupdate /tb_hibi_receiver/new_rx_conf_from_duv
add wave -noupdate -divider {params from DUV to ctrl-regs}
add wave -noupdate /tb_hibi_receiver/new_tx_conf_from_duv
add wave -noupdate -radix hexadecimal /tb_hibi_receiver/timeout_from_duv
add wave -noupdate -radix hexadecimal /tb_hibi_receiver/ip_from_duv
add wave -noupdate -radix hexadecimal /tb_hibi_receiver/dest_port_from_duv
add wave -noupdate -radix hexadecimal /tb_hibi_receiver/source_port_from_duv
add wave -noupdate -radix hexadecimal /tb_hibi_receiver/lock_addr_from_duv
add wave -noupdate -radix hexadecimal /tb_hibi_receiver/response_addr_from_duv
add wave -noupdate -divider {Lock infor from ctrl-regs}
add wave -noupdate /tb_hibi_receiver/lock_to_duv
add wave -noupdate -radix hexadecimal /tb_hibi_receiver/lock_addr_to_duv
add wave -noupdate -divider {data from DUV}
add wave -noupdate -radix hexadecimal /tb_hibi_receiver/tx_length_from_duv
add wave -noupdate -radix hexadecimal /tb_hibi_receiver/tx_data_from_duv
add wave -noupdate /tb_hibi_receiver/tx_we_from_duv
add wave -noupdate /tb_hibi_receiver/new_tx_ack_to_duv
add wave -noupdate /tb_hibi_receiver/tx_full_to_duv
add wave -noupdate /tb_hibi_receiver/fifo_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8803 ns} 0}
configure wave -namecolwidth 304
configure wave -valuecolwidth 95
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
WaveRestoreZoom {0 ns} {16002 ns}
