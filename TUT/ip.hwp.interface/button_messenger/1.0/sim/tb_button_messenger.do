onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_button_messenger/clk_ip
add wave -noupdate /tb_button_messenger/clk_noc
add wave -noupdate /tb_button_messenger/rst_n
add wave -noupdate /tb_button_messenger/av_ip_wra
add wave -noupdate /tb_button_messenger/data_ip_wra
add wave -noupdate /tb_button_messenger/comm_ip_wra
add wave -noupdate /tb_button_messenger/we_ip_wra
add wave -noupdate /tb_button_messenger/full_wra_ip
add wave -noupdate /tb_button_messenger/one_p_wra_ip
add wave -noupdate /tb_button_messenger/av_wra_ip
add wave -noupdate /tb_button_messenger/data_wra_ip
add wave -noupdate /tb_button_messenger/comm_wra_ip
add wave -noupdate /tb_button_messenger/re_ip_wra
add wave -noupdate /tb_button_messenger/empty_wra_ip
add wave -noupdate /tb_button_messenger/one_d_wra_ip
add wave -noupdate /tb_button_messenger/av_wra_bus
add wave -noupdate /tb_button_messenger/data_wra_bus
add wave -noupdate /tb_button_messenger/comm_wra_bus
add wave -noupdate /tb_button_messenger/trnsp_data_out
add wave -noupdate /tb_button_messenger/trnsp_comm_out
add wave -noupdate /tb_button_messenger/full_wra_bus
add wave -noupdate /tb_button_messenger/lock_wra_bus
add wave -noupdate /tb_button_messenger/av_bus_wra
add wave -noupdate /tb_button_messenger/data_bus_wra
add wave -noupdate /tb_button_messenger/comm_bus_wra
add wave -noupdate /tb_button_messenger/full_bus_wra
add wave -noupdate /tb_button_messenger/lock_bus_wra
add wave -noupdate /tb_button_messenger/debug_tb_wra
add wave -noupdate /tb_button_messenger/counter_r
add wave -noupdate /tb_button_messenger/keys_tb_duv
add wave -noupdate -divider duv
add wave -noupdate /tb_button_messenger/DUV/clk
add wave -noupdate /tb_button_messenger/DUV/rst_n
add wave -noupdate /tb_button_messenger/DUV/tx_av_out
add wave -noupdate -radix hexadecimal /tb_button_messenger/DUV/tx_data_out
add wave -noupdate /tb_button_messenger/DUV/tx_we_out
add wave -noupdate /tb_button_messenger/DUV/tx_comm_out
add wave -noupdate /tb_button_messenger/DUV/tx_full_in
add wave -noupdate /tb_button_messenger/DUV/buttons_in
add wave -noupdate /tb_button_messenger/DUV/buttons_r
add wave -noupdate /tb_button_messenger/DUV/buttons2_r
add wave -noupdate /tb_button_messenger/DUV/buttons3_r
add wave -noupdate /tb_button_messenger/DUV/state_r
add wave -noupdate -divider Leds
add wave -noupdate /tb_button_messenger/leds
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {215 ns} 0}
configure wave -namecolwidth 366
configure wave -valuecolwidth 132
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
WaveRestoreZoom {0 ns} {572 ns}
