onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_tx_ctrl/clk
add wave -noupdate /tb_tx_ctrl/rst_n
add wave -noupdate /tb_tx_ctrl/test_len
add wave -noupdate /tb_tx_ctrl/timeout_cnt
add wave -noupdate -divider {hibi receiver (=tb) -> duv}
add wave -noupdate /tb_tx_ctrl/clk_udp_to_duv
add wave -noupdate /tb_tx_ctrl/write_data
add wave -noupdate /tb_tx_ctrl/write_state
add wave -noupdate /tb_tx_ctrl/write_done
add wave -noupdate /tb_tx_ctrl/new_tx_to_duv
add wave -noupdate -radix hexadecimal /tb_tx_ctrl/tx_len_to_duv
add wave -noupdate -radix hexadecimal /tb_tx_ctrl/tx_data_to_duv
add wave -noupdate /tb_tx_ctrl/tx_we_to_duv
add wave -noupdate /tb_tx_ctrl/new_tx_ack_from_duv
add wave -noupdate /tb_tx_ctrl/tx_full_from_duv
add wave -noupdate -divider {ctrl regs (=tb) to duv}
add wave -noupdate -radix hexadecimal /tb_tx_ctrl/tx_ip_to_duv
add wave -noupdate -radix hexadecimal /tb_tx_ctrl/tx_dest_port_to_duv
add wave -noupdate -radix hexadecimal /tb_tx_ctrl/tx_source_port_to_duv
add wave -noupdate -radix hexadecimal /tb_tx_ctrl/timeout_to_duv
add wave -noupdate /tb_tx_ctrl/do_timeout
add wave -noupdate /tb_tx_ctrl/timeout_release_from_duv
add wave -noupdate -divider {duv -> udp (=tb)}
add wave -noupdate /tb_tx_ctrl/read_data
add wave -noupdate /tb_tx_ctrl/read_state
add wave -noupdate /tb_tx_ctrl/read_done
add wave -noupdate /tb_tx_ctrl/new_tx_from_duv
add wave -noupdate /tb_tx_ctrl/tx_data_valid_from_duv
add wave -noupdate -radix hexadecimal /tb_tx_ctrl/tx_data_from_duv
add wave -noupdate /tb_tx_ctrl/tx_re_to_duv
add wave -noupdate -radix hexadecimal /tb_tx_ctrl/tx_len_from_duv
add wave -noupdate -radix hexadecimal /tb_tx_ctrl/dest_ip_from_duv
add wave -noupdate -radix hexadecimal /tb_tx_ctrl/dest_port_from_duv
add wave -noupdate -radix hexadecimal /tb_tx_ctrl/source_port_from_duv
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {95934 ns} 0}
configure wave -namecolwidth 247
configure wave -valuecolwidth 199
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
WaveRestoreZoom {90892 ns} {96564 ns}
