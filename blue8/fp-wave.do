onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /t_fp/clockin
add wave -noupdate -format Logic /t_fp/pb0
add wave -noupdate -format Logic /t_fp/pb1
add wave -noupdate -format Literal /t_fp/sw
add wave -noupdate -format Literal /t_fp/led
add wave -noupdate -format Literal /t_fp/display
add wave -noupdate -format Logic /t_fp/dp
add wave -noupdate -format Literal /t_fp/digsel
add wave -noupdate -format Logic /t_fp/clkout
add wave -noupdate -format Literal /t_fp/swreg
add wave -noupdate -format Logic /t_fp/clear
add wave -noupdate -format Logic /t_fp/lpc
add wave -noupdate -format Logic /t_fp/exam
add wave -noupdate -format Logic /t_fp/dep
add wave -noupdate -format Logic /t_fp/xrun
add wave -noupdate -format Literal /t_fp/irin
add wave -noupdate -format Literal /t_fp/acin
add wave -noupdate -format Literal /t_fp/pcin
add wave -noupdate -format Logic /t_fp/UUT/select
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
update
WaveRestoreZoom {0 ps} {4096 ns}
