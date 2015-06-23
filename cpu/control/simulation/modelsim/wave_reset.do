onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_reset/clk
add wave -noupdate /test_reset/reset_in
add wave -noupdate /test_reset/fpga_reset
add wave -noupdate /test_reset/M1
add wave -noupdate /test_reset/T2
add wave -noupdate -color Gold /test_reset/clrpc
add wave -noupdate /test_reset/nreset
add wave -noupdate -color {Cadet Blue} /test_reset/reset_block/x1
add wave -noupdate -color {Cadet Blue} /test_reset/reset_block/x2
add wave -noupdate -color {Cadet Blue} /test_reset/reset_block/x3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2800 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 112
configure wave -valuecolwidth 73
configure wave -justifyvalue right
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ns} {13700 ns}
