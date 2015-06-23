onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /test_prep_daa/low_sig
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /test_prep_daa/high_sig
add wave -noupdate /test_prep_daa/low_gt_9_sig
add wave -noupdate /test_prep_daa/high_gt_9_sig
add wave -noupdate /test_prep_daa/high_eq_9_sig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1400 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 138
configure wave -valuecolwidth 60
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
WaveRestoreZoom {0 ns} {4100 ns}
