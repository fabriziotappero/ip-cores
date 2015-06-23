onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /stend_ambpex5_core_m2/amb/test_ctrl/test_gen/clk
add wave -noupdate /stend_ambpex5_core_m2/amb/test_ctrl/test_gen/di_clk
add wave -noupdate /stend_ambpex5_core_m2/amb/test_ctrl/test_gen/di_data
add wave -noupdate /stend_ambpex5_core_m2/amb/test_ctrl/test_gen/di_data_we
add wave -noupdate -divider {New Divider}
add wave -noupdate /stend_ambpex5_core_m2/amb/test_ctrl/test_check/clk
add wave -noupdate /stend_ambpex5_core_m2/amb/test_ctrl/test_check/do_clk
add wave -noupdate /stend_ambpex5_core_m2/amb/test_ctrl/test_check/do_data
add wave -noupdate /stend_ambpex5_core_m2/amb/test_ctrl/test_check/do_data_en
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 359
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {16540 ps}
