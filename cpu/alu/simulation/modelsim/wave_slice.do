onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /test_slice/op1_sig
add wave -noupdate -radix hexadecimal /test_slice/op2_sig
add wave -noupdate /test_slice/cy_in_sig
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /test_slice/result_sig
add wave -noupdate -color Gold -format Literal -itemcolor Gold /test_slice/cy_out_sig
add wave -noupdate /test_slice/R_sig
add wave -noupdate /test_slice/S_sig
add wave -noupdate /test_slice/V_sig
add wave -noupdate /test_slice/cy_out_D_sig
add wave -noupdate /test_slice/cy_out_C_sig
add wave -noupdate /test_slice/cy_out_B_sig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2000 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 132
configure wave -valuecolwidth 57
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
