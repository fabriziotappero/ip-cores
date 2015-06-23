onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /dds_synthesizer_tb/clk
add wave -noupdate -format Logic /dds_synthesizer_tb/rst
add wave -noupdate -format Literal -radix decimal /dds_synthesizer_tb/ftw
add wave -noupdate -format Literal -radix decimal /dds_synthesizer_tb/init_phase
add wave -noupdate -format Literal -radix decimal /dds_synthesizer_tb/phase_out
add wave -noupdate -format Literal -radix decimal /dds_synthesizer_tb/ampl_out
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix unsigned /dds_synthesizer_tb/dds_synth/ftw_i
add wave -noupdate -format Literal -radix unsigned /dds_synthesizer_tb/dds_synth/phase_i
add wave -noupdate -format Literal -radix unsigned /dds_synthesizer_tb/dds_synth/phase_o
add wave -noupdate -format Literal -radix unsigned /dds_synthesizer_tb/dds_synth/ftw_accu
add wave -noupdate -format Literal -radix unsigned /dds_synthesizer_tb/dds_synth/phase
add wave -noupdate -format Literal -radix unsigned /dds_synthesizer_tb/dds_synth/lut_in
add wave -noupdate -format Literal -radix unsigned /dds_synthesizer_tb/dds_synth/lut_out
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /dds_synthesizer_tb/dds_synth/quadrant_2_or_4
add wave -noupdate -format Logic /dds_synthesizer_tb/dds_synth/quadrant_3_or_4
add wave -noupdate -format Analog-Step -height 100 -scale 0.0025940337224383916 /dds_synthesizer_tb/ampl_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5035 ns} 0} {{Cursor 2} {40035 ns} 0}
configure wave -namecolwidth 290
configure wave -valuecolwidth 135
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
update
WaveRestoreZoom {0 ns} {105472 ns}
