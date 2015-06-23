onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_basic_tester/clk_ip
add wave -noupdate /tb_basic_tester/clk_noc
add wave -noupdate /tb_basic_tester/rst_n
add wave -noupdate -expand /tb_basic_tester/av_ip_wra
add wave -noupdate -radix decimal -childformat {{/tb_basic_tester/data_ip_wra(2) -radix decimal} {/tb_basic_tester/data_ip_wra(1) -radix decimal} {/tb_basic_tester/data_ip_wra(0) -radix decimal}} -expand -subitemconfig {/tb_basic_tester/data_ip_wra(2) {-radix decimal} /tb_basic_tester/data_ip_wra(1) {-radix decimal} /tb_basic_tester/data_ip_wra(0) {-radix decimal}} /tb_basic_tester/data_ip_wra
add wave -noupdate -radix decimal /tb_basic_tester/comm_ip_wra
add wave -noupdate /tb_basic_tester/we_ip_wra
add wave -noupdate /tb_basic_tester/full_wra_ip
add wave -noupdate /tb_basic_tester/one_p_wra_ip
add wave -noupdate /tb_basic_tester/av_wra_ip
add wave -noupdate -radix decimal /tb_basic_tester/data_wra_ip
add wave -noupdate -radix decimal /tb_basic_tester/comm_wra_ip
add wave -noupdate /tb_basic_tester/re_ip_wra
add wave -noupdate /tb_basic_tester/empty_wra_ip
add wave -noupdate /tb_basic_tester/one_d_wra_ip
add wave -noupdate /tb_basic_tester/av_wra_bus
add wave -noupdate -radix decimal /tb_basic_tester/data_wra_bus
add wave -noupdate -radix decimal /tb_basic_tester/comm_wra_bus
add wave -noupdate -radix decimal /tb_basic_tester/trnsp_data_out
add wave -noupdate -radix decimal /tb_basic_tester/trnsp_comm_out
add wave -noupdate -radix decimal /tb_basic_tester/full_wra_bus
add wave -noupdate -radix decimal /tb_basic_tester/lock_wra_bus
add wave -noupdate /tb_basic_tester/av_bus_wra
add wave -noupdate -radix decimal /tb_basic_tester/data_bus_wra
add wave -noupdate -radix decimal /tb_basic_tester/comm_bus_wra
add wave -noupdate /tb_basic_tester/full_bus_wra
add wave -noupdate /tb_basic_tester/lock_bus_wra
add wave -noupdate -divider sender
add wave -noupdate /tb_basic_tester/sender/conf_file_g
add wave -noupdate /tb_basic_tester/sender/comm_width_g
add wave -noupdate /tb_basic_tester/sender/data_width_g
add wave -noupdate /tb_basic_tester/sender/clk
add wave -noupdate /tb_basic_tester/sender/done_out
add wave -noupdate /tb_basic_tester/sender/curr_state_r
add wave -noupdate /tb_basic_tester/sender/delay_r
add wave -noupdate /tb_basic_tester/sender/agent_av_out
add wave -noupdate -radix decimal /tb_basic_tester/sender/agent_data_out
add wave -noupdate -radix decimal /tb_basic_tester/sender/agent_comm_out
add wave -noupdate /tb_basic_tester/sender/agent_we_out
add wave -noupdate /tb_basic_tester/sender/agent_full_in
add wave -noupdate /tb_basic_tester/sender/agent_one_p_in
add wave -noupdate -divider receiver
add wave -noupdate /tb_basic_tester/receiver/conf_file_g
add wave -noupdate /tb_basic_tester/receiver/comm_width_g
add wave -noupdate /tb_basic_tester/receiver/data_width_g
add wave -noupdate /tb_basic_tester/receiver/clk
add wave -noupdate /tb_basic_tester/receiver/done_out
add wave -noupdate /tb_basic_tester/receiver/agent_av_in
add wave -noupdate -radix decimal /tb_basic_tester/receiver/agent_data_in
add wave -noupdate -radix decimal /tb_basic_tester/receiver/agent_comm_in
add wave -noupdate /tb_basic_tester/receiver/agent_empty_in
add wave -noupdate /tb_basic_tester/receiver/agent_one_d_in
add wave -noupdate /tb_basic_tester/receiver/agent_re_out
add wave -noupdate /tb_basic_tester/receiver/curr_state_r
add wave -noupdate -radix decimal /tb_basic_tester/receiver/last_addr_r
add wave -noupdate /tb_basic_tester/receiver/cycle_counter_r
add wave -noupdate -radix decimal /tb_basic_tester/receiver/delay_r
add wave -noupdate -radix decimal /tb_basic_tester/receiver/dst_addr_r
add wave -noupdate -radix unsigned /tb_basic_tester/receiver/data_val_r
add wave -noupdate -radix decimal /tb_basic_tester/receiver/comm_r
add wave -noupdate /tb_basic_tester/receiver/addr_correct_r
add wave -noupdate /tb_basic_tester/receiver/n_addr_r
add wave -noupdate /tb_basic_tester/receiver/n_data_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {600 ns} 0}
configure wave -namecolwidth 332
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ns} {1628 ns}
