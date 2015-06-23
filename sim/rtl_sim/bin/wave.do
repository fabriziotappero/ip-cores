onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /lfsr_tb/DUT/clear
add wave -noupdate -format Logic /lfsr_tb/DUT/set
add wave -noupdate -format Logic /lfsr_tb/DUT/cke
add wave -noupdate -format Literal /lfsr_tb/DUT/q
add wave -noupdate -format Logic /lfsr_tb/DUT/rst
add wave -noupdate -format Logic /lfsr_tb/DUT/clk
add wave -noupdate -format Literal /lfsr_tb/DUT/qi
add wave -noupdate -format Logic /lfsr_tb/DUT/lfsr_fb
add wave -noupdate -format Logic /lfsr_tb/DUT/q_next
add wave -noupdate -format Logic /lfsr_tb/DUT/rew
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1005 ns} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {862 ns} {1552 ns}
