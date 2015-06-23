onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /led_hibi_example/rst_h_nRESETn
add wave -noupdate -divider switch
add wave -noupdate /led_hibi_example/clk_sCLK
add wave -noupdate /led_hibi_example/switch_0_in
add wave -noupdate /led_hibi_example/swi_hibiAV_FROM_IP
add wave -noupdate -radix hexadecimal /led_hibi_example/swi_hibiDATA_FROM_IP
add wave -noupdate /led_hibi_example/swi_hibiCOMM_FROM_IP
add wave -noupdate /led_hibi_example/swi_hibiWE_FROM_IP
add wave -noupdate /led_hibi_example/swi_hibiFULL_TO_IP
add wave -noupdate -divider bus
add wave -noupdate /led_hibi_example/clk_sCLK
add wave -noupdate /led_hibi_example/clk_sCLK
add wave -noupdate /led_hibi_example/hibi_segment_small_1/bus_av_in
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/bus_comm_in
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/bus_data_in
add wave -noupdate /led_hibi_example/hibi_segment_small_1/bus_full_in
add wave -noupdate /led_hibi_example/hibi_segment_small_1/bus_lock_in
add wave -noupdate -divider led
add wave -noupdate /led_hibi_example/clk_sCLK
add wave -noupdate /led_hibi_example/hibi_ledAV_TO_IP
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_ledDATA_TO_IP
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_ledCOMM_TO_IP
add wave -noupdate /led_hibi_example/hibi_ledEMPTY_TO_IP
add wave -noupdate /led_hibi_example/hibi_ledRE_FROM_IP
add wave -noupdate /led_hibi_example/led_0_out
add wave -noupdate -divider hibi
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/bus_clk
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_clk
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/bus_sync_clk
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_sync_clk
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/rst_n
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/bus_comm_in
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/bus_data_in
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/bus_full_in
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/bus_lock_in
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/bus_av_in
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_comm_in
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_data_in
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_av_in
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_we_in
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_re_in
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/bus_comm_out
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/bus_data_out
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/bus_full_out
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/bus_lock_out
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/bus_av_out
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_comm_out
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_data_out
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_av_out
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_full_out
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_one_p_out
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_empty_out
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/agent_one_d_out
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/debug_out
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/debug_in
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/data_dw_h
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/comm_dw_h
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/av_dw_h
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/we_0_dw_h
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/we_1_dw_h
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/full_0_h_dw
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/full_1_h_dw
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/one_p_0_h_dw
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/one_p_1_h_dw
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/data_0_h_mr
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/comm_0_h_mr
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/data_1_h_mr
add wave -noupdate -radix hexadecimal /led_hibi_example/hibi_segment_small_1/a1/agent_1/comm_1_h_mr
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/av_0_h_mr
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/av_1_h_mr
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/re_0_mr_h
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/re_1_mr_h
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/empty_0_h_mr
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/empty_1_h_mr
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/one_d_0_h_mr
add wave -noupdate /led_hibi_example/hibi_segment_small_1/a1/agent_1/one_d_1_h_mr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {67 ns} 0}
configure wave -namecolwidth 445
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
WaveRestoreZoom {3305 ns} {3406 ns}
