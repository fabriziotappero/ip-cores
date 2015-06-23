onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_rx_ctrl/clk
add wave -noupdate /tb_rx_ctrl/clk_udp
add wave -noupdate /tb_rx_ctrl/rst_n
add wave -noupdate -divider stimulus
add wave -noupdate /tb_rx_ctrl/test_id
add wave -noupdate /tb_rx_ctrl/send_state
add wave -noupdate /tb_rx_ctrl/send_data
add wave -noupdate /tb_rx_ctrl/send_done
add wave -noupdate /tb_rx_ctrl/rx_data_valid_r
add wave -noupdate /tb_rx_ctrl/current
add wave -noupdate -radix hexadecimal /tb_rx_ctrl/rx_data_to_duv
add wave -noupdate /tb_rx_ctrl/rx_data_valid_to_duv
add wave -noupdate /tb_rx_ctrl/rx_re_from_duv
add wave -noupdate /tb_rx_ctrl/new_rx_to_duv
add wave -noupdate /tb_rx_ctrl/rx_len_to_duv
add wave -noupdate -radix hexadecimal /tb_rx_ctrl/source_ip_to_duv
add wave -noupdate -radix hexadecimal /tb_rx_ctrl/dest_port_to_duv
add wave -noupdate -radix hexadecimal /tb_rx_ctrl/source_port_to_duv
add wave -noupdate /tb_rx_ctrl/rx_erroneous_to_duv
add wave -noupdate -divider response
add wave -noupdate -radix hexadecimal /tb_rx_ctrl/ip_from_duv
add wave -noupdate -radix hexadecimal /tb_rx_ctrl/dest_port_from_duv
add wave -noupdate -radix hexadecimal /tb_rx_ctrl/source_port_from_duv
add wave -noupdate /tb_rx_ctrl/rx_addr_valid_to_duv
add wave -noupdate /tb_rx_ctrl/send_request_from_duv
add wave -noupdate /tb_rx_ctrl/ready_for_tx_to_duv
add wave -noupdate /tb_rx_ctrl/rx_empty_from_duv
add wave -noupdate -radix hexadecimal /tb_rx_ctrl/rx_data_from_duv
add wave -noupdate /tb_rx_ctrl/rx_re_to_duv
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2540 ns} 0}
configure wave -namecolwidth 250
configure wave -valuecolwidth 261
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
WaveRestoreZoom {0 ns} {9945 ns}
