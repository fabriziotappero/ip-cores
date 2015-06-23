onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_ctrl_regs/clk
add wave -noupdate /tb_ctrl_regs/rst_n
add wave -noupdate /tb_ctrl_regs/test_id
add wave -noupdate -divider {from hibi receiver (=tb)}
add wave -noupdate /tb_ctrl_regs/release_lock_to_duv
add wave -noupdate /tb_ctrl_regs/new_tx_conf_to_duv
add wave -noupdate /tb_ctrl_regs/new_rx_conf_to_duv
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/ip_to_duv
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/dest_port_to_duv
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/source_port_to_duv
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/lock_addr_to_duv
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/response_addr_to_duv
add wave -noupdate -divider {to tx_ctrl}
add wave -noupdate /tb_ctrl_regs/lock_from_duv
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/lock_addr_from_duv
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/tx_ip_from_duv
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/tx_dest_port_from_duv
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/tx_source_port_from_duv
add wave -noupdate /tb_ctrl_regs/timeout_release_to_duv
add wave -noupdate -divider {from rx_ctrl}
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/rx_ip_to_duv
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/rx_dest_port_to_duv
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/rx_source_port_to_duv
add wave -noupdate /tb_ctrl_regs/rx_addr_valid_from_duv
add wave -noupdate -divider {to hibi transmitter}
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/ack_addr_from_duv
add wave -noupdate -radix hexadecimal /tb_ctrl_regs/rx_addr_from_duv
add wave -noupdate /tb_ctrl_regs/send_tx_ack_from_duv
add wave -noupdate /tb_ctrl_regs/send_tx_nack_from_duv
add wave -noupdate /tb_ctrl_regs/send_rx_ack_from_duv
add wave -noupdate /tb_ctrl_regs/send_rx_nack_from_duv
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1480 ns} 0}
configure wave -namecolwidth 266
configure wave -valuecolwidth 259
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
WaveRestoreZoom {0 ns} {3038 ns}
