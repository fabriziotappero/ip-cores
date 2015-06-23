onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_pin_control/fFetch_sig
add wave -noupdate /test_pin_control/fMRead_sig
add wave -noupdate /test_pin_control/fMWrite_sig
add wave -noupdate /test_pin_control/fIORead_sig
add wave -noupdate /test_pin_control/fIOWrite_sig
add wave -noupdate /test_pin_control/T1_sig
add wave -noupdate /test_pin_control/T2_sig
add wave -noupdate /test_pin_control/T3_sig
add wave -noupdate /test_pin_control/T4_sig
add wave -noupdate -divider STATE
add wave -noupdate -color Pink /test_pin_control/bus_ab_pin_we_sig
add wave -noupdate -color Pink /test_pin_control/bus_db_pin_oe_sig
add wave -noupdate -color Pink /test_pin_control/bus_db_pin_re_sig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1400 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 240
configure wave -valuecolwidth 54
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 1
configure wave -timelineunits us
update
WaveRestoreZoom {0 ns} {4600 ns}
