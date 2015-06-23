onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tlc_tb/uut/clk
add wave -noupdate -format Logic /tlc_tb/uut/rst
add wave -noupdate -format Logic /tlc_tb/uut/j_left
add wave -noupdate -format Logic /tlc_tb/uut/j_right
add wave -noupdate -format Literal /tlc_tb/uut/led
add wave -noupdate -format Literal /tlc_tb/uut/pr_state
add wave -noupdate -format Literal /tlc_tb/uut/nxt_state
add wave -noupdate -format Logic /tlc_tb/uut/pr_state_mode
add wave -noupdate -format Logic /tlc_tb/uut/nxt_state_mode
add wave -noupdate -format Literal /tlc_tb/uut/led_int
add wave -noupdate -format Logic /tlc_tb/uut/one_sec
add wave -noupdate -format Logic /tlc_tb/uut/go
add wave -noupdate -format Logic /tlc_tb/uut/mode
add wave -noupdate -format Logic /tlc_tb/uut/green_period
add wave -noupdate -format Logic /tlc_tb/uut/orange_period
add wave -noupdate -format Logic /tlc_tb/uut/red_period
add wave -noupdate -format Logic /tlc_tb/uut/red_orange_period
add wave -noupdate -format Logic /tlc_tb/uut/stb_period
add wave -noupdate -format Logic /tlc_tb/uut/rst_int
add wave -noupdate -format Literal /tlc_tb/uut/time_p/temp0
add wave -noupdate -format Literal /tlc_tb/uut/time_p/temp1
add wave -noupdate -format Literal /tlc_tb/uut/time_p/temp2
add wave -noupdate -format Literal /tlc_tb/uut/time_p/temp3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2053550 ns} 1}
configure wave -namecolwidth 208
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
WaveRestoreZoom {2202166 ns} {2234934 ns}
