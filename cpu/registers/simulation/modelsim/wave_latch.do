onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_latch/clk
add wave -noupdate -radix hexadecimal /test_latch/db
add wave -noupdate -radix hexadecimal /test_latch/db_sig
add wave -noupdate /test_latch/oe_sig
add wave -noupdate /test_latch/we_sig
add wave -noupdate -radix hexadecimal /test_latch/reg_latch_inst/latch
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2000 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 123
configure wave -valuecolwidth 72
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
WaveRestoreZoom {0 ns} {12600 ns}
