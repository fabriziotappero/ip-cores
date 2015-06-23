onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /led_ase_mesh1_example/clk
add wave -noupdate /led_ase_mesh1_example/reset_n
add wave -noupdate /led_ase_mesh1_example/led_0_out
add wave -noupdate /led_ase_mesh1_example/led_1_out
add wave -noupdate /led_ase_mesh1_example/switch_0_in
add wave -noupdate /led_ase_mesh1_example/switch_1_in
add wave -noupdate -divider Noc
add wave -noupdate /led_ase_mesh1_example/led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0CMD_IN
add wave -noupdate /led_ase_mesh1_example/led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0CMD_OUT
add wave -noupdate /led_ase_mesh1_example/led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1CMD_IN
add wave -noupdate /led_ase_mesh1_example/led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1CMD_OUT
add wave -noupdate /led_ase_mesh1_example/switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2CMD_IN
add wave -noupdate /led_ase_mesh1_example/switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2CMD_OUT
add wave -noupdate /led_ase_mesh1_example/switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3CMD_IN
add wave -noupdate /led_ase_mesh1_example/switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3CMD_OUT
add wave -noupdate -radix hexadecimal /led_ase_mesh1_example/led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0DATA_IN
add wave -noupdate -radix hexadecimal /led_ase_mesh1_example/led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0DATA_OUT
add wave -noupdate -radix hexadecimal /led_ase_mesh1_example/led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1DATA_IN
add wave -noupdate -radix hexadecimal /led_ase_mesh1_example/led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1DATA_OUT
add wave -noupdate -radix hexadecimal /led_ase_mesh1_example/switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2DATA_IN
add wave -noupdate -radix hexadecimal /led_ase_mesh1_example/switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2DATA_OUT
add wave -noupdate -radix hexadecimal /led_ase_mesh1_example/switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3DATA_IN
add wave -noupdate -radix hexadecimal /led_ase_mesh1_example/switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3DATA_OUT
add wave -noupdate /led_ase_mesh1_example/led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0STALL_IN
add wave -noupdate /led_ase_mesh1_example/led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0STALL_OUT
add wave -noupdate /led_ase_mesh1_example/led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1STALL_IN
add wave -noupdate /led_ase_mesh1_example/led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1STALL_OUT
add wave -noupdate /led_ase_mesh1_example/switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2STALL_IN
add wave -noupdate /led_ase_mesh1_example/switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2STALL_OUT
add wave -noupdate /led_ase_mesh1_example/switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3STALL_IN
add wave -noupdate /led_ase_mesh1_example/switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3STALL_OUT
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 604
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ns} {4624 ns}
