onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {UDP/IP internals}
add wave -noupdate -divider {To/From Eth PHY}
add wave -noupdate -divider {Flooder's tx}
add wave -noupdate /udp_flood_example_dm9000a/clk_in_CLK
add wave -noupdate /udp_flood_example_dm9000a/rst_n_RESETn
add wave -noupdate -divider {UDP/IP internals}
add wave -noupdate /udp_flood_example_dm9000a/udp_ip_dm9000a_1/DM9kA_controller_1/init_module/init_cnt_r
add wave -noupdate /udp_flood_example_dm9000a/udp_ip_dm9000a_1/DM9kA_controller_1/init_module/state_r
add wave -noupdate -radix decimal /udp_flood_example_dm9000a/udp_ip_dm9000a_1/DM9kA_controller_1/init_module/sleep_time_out
add wave -noupdate /udp_flood_example_dm9000a/udp_ip_dm9000a_1/DM9kA_controller_1/init_module/wait_link_state_r
add wave -noupdate /udp_flood_example_dm9000a/udp_ip_dm9000a_1/DM9kA_controller_1/init_module/ready_r
add wave -noupdate -radix decimal /udp_flood_example_dm9000a/udp_ip_dm9000a_1/DM9kA_controller_1/init_module/wait_link_cnt_r
add wave -noupdate -divider {To/From Eth PHY}
add wave -noupdate /udp_flood_example_dm9000a/pll_flooderCLK
add wave -noupdate /udp_flood_example_dm9000a/DM9000A_eth_interrupt_in
add wave -noupdate /udp_flood_example_dm9000a/DM9000A_eth_chip_sel_out
add wave -noupdate /udp_flood_example_dm9000a/DM9000A_eth_clk_out
add wave -noupdate /udp_flood_example_dm9000a/DM9000A_eth_cmd_out
add wave -noupdate /udp_flood_example_dm9000a/DM9000A_eth_read_out
add wave -noupdate /udp_flood_example_dm9000a/DM9000A_eth_reset_out
add wave -noupdate /udp_flood_example_dm9000a/DM9000A_eth_write_out
add wave -noupdate -radix hexadecimal /udp_flood_example_dm9000a/DM9000A_eth_data_inout
add wave -noupdate -divider {Flooder's tx}
add wave -noupdate /udp_flood_example_dm9000a/link_up_out_gpio_out
add wave -noupdate -radix hexadecimal /udp_flood_example_dm9000a/udp_flooderrxdest_port_out
add wave -noupdate /udp_flood_example_dm9000a/floodertx_udpfatal_error_out
add wave -noupdate /udp_flood_example_dm9000a/floodertx_udplink_up_out
add wave -noupdate /udp_flood_example_dm9000a/udp_flooderrxnew_rx_out
add wave -noupdate /udp_flood_example_dm9000a/floodertx_udpnew_tx_in
add wave -noupdate -radix hexadecimal /udp_flood_example_dm9000a/floodertx_udpno_arp_target_MAC_in
add wave -noupdate -radix hexadecimal /udp_flood_example_dm9000a/udp_flooderrxrx_data_out
add wave -noupdate /udp_flood_example_dm9000a/udp_flooderrxrx_data_valid_out
add wave -noupdate /udp_flood_example_dm9000a/udp_flooderrxrx_erroneous_out
add wave -noupdate /udp_flood_example_dm9000a/udp_flooderrxrx_error_out
add wave -noupdate -radix hexadecimal /udp_flood_example_dm9000a/udp_flooderrxrx_len_out
add wave -noupdate /udp_flood_example_dm9000a/udp_flooderrxrx_re_in
add wave -noupdate -radix hexadecimal /udp_flood_example_dm9000a/udp_flooderrxsource_addr_out
add wave -noupdate -radix hexadecimal /udp_flood_example_dm9000a/udp_flooderrxsource_port_out
add wave -noupdate -radix hexadecimal /udp_flood_example_dm9000a/floodertx_udpsource_port_in
add wave -noupdate -radix hexadecimal /udp_flood_example_dm9000a/floodertx_udptarget_addr_in
add wave -noupdate -radix hexadecimal /udp_flood_example_dm9000a/floodertx_udptarget_port_in
add wave -noupdate -radix hexadecimal /udp_flood_example_dm9000a/floodertx_udptx_data_in
add wave -noupdate /udp_flood_example_dm9000a/floodertx_udptx_data_valid_in
add wave -noupdate -radix hexadecimal /udp_flood_example_dm9000a/floodertx_udptx_len_in
add wave -noupdate /udp_flood_example_dm9000a/floodertx_udptx_re_out
add wave -noupdate -divider {send module}
add wave -noupdate /udp_flood_example_dm9000a/udp_ip_dm9000a_1/DM9kA_controller_1/send_module/tx_re_in
add wave -noupdate /udp_flood_example_dm9000a/udp_ip_dm9000a_1/DM9kA_controller_1/send_module/tx_re_out
add wave -noupdate -divider flooder
add wave -noupdate /udp_flood_example_dm9000a/simple_udp_flood_example_1/pkt_cnt_r
add wave -noupdate /udp_flood_example_dm9000a/simple_udp_flood_example_1/state_r
add wave -noupdate /udp_flood_example_dm9000a/simple_udp_flood_example_1/tx_re_in
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {86089900000 ps} 0}
configure wave -namecolwidth 508
configure wave -valuecolwidth 125
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
WaveRestoreZoom {19261954282 ps} {20521662933 ps}
