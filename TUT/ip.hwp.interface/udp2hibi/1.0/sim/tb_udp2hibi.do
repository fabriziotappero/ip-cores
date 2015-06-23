onerror {resume}
quietly virtual signal -install /tb_udp2hibi { /tb_udp2hibi/hibi_data_from_duv(27 downto 17)} amount
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_udp2hibi/clk
add wave -noupdate /tb_udp2hibi/clk_udp
add wave -noupdate /tb_udp2hibi/rst_n
add wave -noupdate /tb_udp2hibi/test_tx_id
add wave -noupdate /tb_udp2hibi/test_rx_id
add wave -noupdate -divider {Hibi (=tb) -> duv}
add wave -noupdate /tb_udp2hibi/test_tx_id
add wave -noupdate /tb_udp2hibi/clk
add wave -noupdate /tb_udp2hibi/hibi_av_to_duv
add wave -noupdate -radix hexadecimal /tb_udp2hibi/hibi_data_to_duv
add wave -noupdate /tb_udp2hibi/hibi_comm_to_duv
add wave -noupdate /tb_udp2hibi/hibi_empty_to_duv
add wave -noupdate /tb_udp2hibi/hibi_re_from_duv
add wave -noupdate -divider {inside duv}
add wave -noupdate /tb_udp2hibi/duv/ctrl_regs_block/send_tx_ack_out
add wave -noupdate /tb_udp2hibi/duv/ctrl_regs_block/send_rx_ack_out
add wave -noupdate /tb_udp2hibi/duv/tx_ctrl_block/new_tx_out
add wave -noupdate /tb_udp2hibi/duv/rx_ctrl_block/new_rx_in
add wave -noupdate -radix hexadecimal /tb_udp2hibi/duv/ctrl_regs_block/lock_addr_r
add wave -noupdate -radix hexadecimal -childformat {{/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0) -radix hexadecimal -childformat {{/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0).source_ip -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0).source_port -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0).dest_port -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0).hibi_addr -radix hexadecimal}}} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1) -radix hexadecimal -childformat {{/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1).source_ip -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1).source_port -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1).dest_port -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1).hibi_addr -radix hexadecimal}}} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(2) -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(3) -radix hexadecimal}} -subitemconfig {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0) {-height 15 -radix hexadecimal -childformat {{/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0).source_ip -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0).source_port -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0).dest_port -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0).hibi_addr -radix hexadecimal}}} /tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0).source_ip {-height 15 -radix hexadecimal} /tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0).source_port {-height 15 -radix hexadecimal} /tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0).dest_port {-height 15 -radix hexadecimal} /tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(0).hibi_addr {-height 15 -radix hexadecimal} /tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1) {-height 15 -radix hexadecimal -childformat {{/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1).source_ip -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1).source_port -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1).dest_port -radix hexadecimal} {/tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1).hibi_addr -radix hexadecimal}} -expand} /tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1).source_ip {-height 15 -radix hexadecimal} /tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1).source_port {-height 15 -radix hexadecimal} /tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1).dest_port {-height 15 -radix hexadecimal} /tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(1).hibi_addr {-height 15 -radix hexadecimal} /tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(2) {-height 15 -radix hexadecimal} /tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r(3) {-height 15 -radix hexadecimal}} /tb_udp2hibi/duv/ctrl_regs_block/receiver_table_r
add wave -noupdate /tb_udp2hibi/duv/rx_ctrl_block/dump_rx_r
add wave -noupdate /tb_udp2hibi/duv/rx_ctrl_block/fifo_glue_state_r
add wave -noupdate -divider {duv -> hibi, ack + data}
add wave -noupdate /tb_udp2hibi/hibi_av_from_duv
add wave -noupdate -radix hexadecimal /tb_udp2hibi/hibi_data_from_duv
add wave -noupdate -radix hexadecimal /tb_udp2hibi/hibi_comm_from_duv
add wave -noupdate /tb_udp2hibi/hibi_we_from_duv
add wave -noupdate /tb_udp2hibi/hibi_full_to_duv
add wave -noupdate -divider {duv -> udpip tx}
add wave -noupdate -radix hexadecimal /tb_udp2hibi/tx_len_from_duv
add wave -noupdate -radix hexadecimal /tb_udp2hibi/dest_ip_from_duv
add wave -noupdate -radix hexadecimal /tb_udp2hibi/dest_port_from_duv
add wave -noupdate -radix hexadecimal /tb_udp2hibi/source_port_from_duv
add wave -noupdate /tb_udp2hibi/new_tx_from_duv
add wave -noupdate -radix hexadecimal /tb_udp2hibi/tx_data_from_duv
add wave -noupdate /tb_udp2hibi/tx_data_valid_from_duv
add wave -noupdate /tb_udp2hibi/tx_re_to_duv
add wave -noupdate -divider {udpip rx -> duv}
add wave -noupdate /tb_udp2hibi/test_rx_id
add wave -noupdate /tb_udp2hibi/udp_traffic_ready
add wave -noupdate -radix hexadecimal /tb_udp2hibi/source_ip_to_duv
add wave -noupdate -radix hexadecimal /tb_udp2hibi/source_port_to_duv
add wave -noupdate -radix hexadecimal /tb_udp2hibi/dest_port_to_duv
add wave -noupdate -radix hexadecimal /tb_udp2hibi/rx_len_to_duv
add wave -noupdate /tb_udp2hibi/rx_erroneous_to_duv
add wave -noupdate /tb_udp2hibi/new_rx_to_duv
add wave -noupdate -radix hexadecimal /tb_udp2hibi/rx_data_to_duv
add wave -noupdate /tb_udp2hibi/rx_data_valid_to_duv
add wave -noupdate /tb_udp2hibi/rx_re_from_duv
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12143 ns} 0}
configure wave -namecolwidth 277
configure wave -valuecolwidth 236
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
WaveRestoreZoom {0 ns} {19719 ns}
