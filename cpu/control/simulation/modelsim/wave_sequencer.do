onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_sequencer/clk
add wave -noupdate /test_sequencer/nreset
add wave -noupdate /test_sequencer/nextM_sig
add wave -noupdate /test_sequencer/setM1_sig
add wave -noupdate /test_sequencer/hold_clk_iorq_sig
add wave -noupdate /test_sequencer/hold_clk_wait_sig
add wave -noupdate /test_sequencer/hold_clk_busrq_sig
add wave -noupdate -divider M-STATE
add wave -noupdate -color Aquamarine /test_sequencer/M1_sig
add wave -noupdate -color Aquamarine /test_sequencer/M2_sig
add wave -noupdate -color Aquamarine /test_sequencer/M3_sig
add wave -noupdate -color Aquamarine /test_sequencer/M4_sig
add wave -noupdate -color Aquamarine /test_sequencer/M5_sig
add wave -noupdate -color Aquamarine /test_sequencer/M6_sig
add wave -noupdate -divider T-STATE
add wave -noupdate -color Pink /test_sequencer/T1_sig
add wave -noupdate -color Pink /test_sequencer/T2_sig
add wave -noupdate -color Pink /test_sequencer/T3_sig
add wave -noupdate -color Pink /test_sequencer/T4_sig
add wave -noupdate -color Pink /test_sequencer/T5_sig
add wave -noupdate -color Pink /test_sequencer/T6_sig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6800 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 226
configure wave -valuecolwidth 78
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
WaveRestoreZoom {0 ns} {25 us}
