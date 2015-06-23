onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /fuzzycore/clk
add wave -noupdate -format Logic /fuzzycore/rst
add wave -noupdate -format Literal -radix hexadecimal /fuzzycore/x
add wave -noupdate -format Literal -radix hexadecimal /fuzzycore/y
add wave -noupdate -format Logic /fuzzycore/model
add wave -noupdate -format Logic /fuzzycore/inference
add wave -noupdate -format Logic /fuzzycore/done
add wave -noupdate -format Literal -radix hexadecimal /fuzzycore/z
add wave -noupdate -format Logic /fuzzycore/start_count
add wave -noupdate -format Literal /fuzzycore/count
add wave -noupdate -format Literal -radix hexadecimal /fuzzycore/mux1_output
add wave -noupdate -format Literal -radix hexadecimal /fuzzycore/mux2_output
add wave -noupdate -format Literal -radix hexadecimal /fuzzycore/min_output
add wave -noupdate -format Literal -radix hexadecimal /fuzzycore/mux3_output
add wave -noupdate -format Literal -radix hexadecimal /fuzzycore/max_output
add wave -noupdate -format Literal -radix hexadecimal /fuzzycore/rule_output
add wave -noupdate -format Literal -radix hexadecimal /fuzzycore/zreg_output
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
WaveRestoreZoom {0 ps} {45760 ps}
configure wave -namecolwidth 150
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

do wave.tcl
