onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tx
add wave -noupdate /basic_tester_hibi_example/tx_wraAV_FROM_IP
add wave -noupdate -radix hexadecimal /basic_tester_hibi_example/tx_wraDATA_FROM_IP
add wave -noupdate -radix hexadecimal /basic_tester_hibi_example/tx_wraCOMM_FROM_IP
add wave -noupdate /basic_tester_hibi_example/tx_wraFULL_TO_IP
add wave -noupdate /basic_tester_hibi_example/tx_wraONE_P_TO_IP
add wave -noupdate /basic_tester_hibi_example/tx_wraWE_FROM_IP
add wave -noupdate -divider hibi
add wave -noupdate /basic_tester_hibi_example/hibi_segment_small_1/bus_av_in
add wave -noupdate -radix hexadecimal /basic_tester_hibi_example/hibi_segment_small_1/bus_data_in
add wave -noupdate -radix hexadecimal /basic_tester_hibi_example/hibi_segment_small_1/bus_comm_in
add wave -noupdate /basic_tester_hibi_example/hibi_segment_small_1/bus_full_in
add wave -noupdate /basic_tester_hibi_example/hibi_segment_small_1/bus_lock_in
add wave -noupdate -divider rx
add wave -noupdate /basic_tester_hibi_example/wra_rxAV_TO_IP
add wave -noupdate -radix hexadecimal /basic_tester_hibi_example/wra_rxDATA_TO_IP
add wave -noupdate -radix hexadecimal /basic_tester_hibi_example/wra_rxCOMM_TO_IP
add wave -noupdate /basic_tester_hibi_example/wra_rxEMPTY_TO_IP
add wave -noupdate /basic_tester_hibi_example/wra_rxONE_D_TO_IP
add wave -noupdate /basic_tester_hibi_example/wra_rxRE_FROM_IP
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 407
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
WaveRestoreZoom {0 ns} {931 ns}
