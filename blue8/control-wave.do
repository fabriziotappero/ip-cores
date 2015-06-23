onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_control/extstart
add wave -noupdate -format Logic /tb_control/extstop
add wave -noupdate -format Logic /tb_control/extexam
add wave -noupdate -format Logic /tb_control/extdeposit
add wave -noupdate -format Logic /tb_control/ihlt
add wave -noupdate -format Logic /tb_control/aluov
add wave -noupdate -format Logic /tb_control/statee
add wave -noupdate -format Literal -radix hexadecimal /tb_control/cp
add wave -noupdate -format Literal -radix hexadecimal /tb_control/cpw
add wave -noupdate -format Logic /tb_control/F
add wave -noupdate -format Logic /tb_control/E
add wave -noupdate -format Logic /tb_control/extreset
add wave -noupdate -format Logic /tb_control/reset
add wave -noupdate -format Logic /tb_control/sw2bus
add wave -noupdate -format Logic /tb_control/loadpc1
add wave -noupdate -format Logic /tb_control/extloadpc
add wave -noupdate -format Logic /tb_control/exout
add wave -noupdate -format Logic /tb_control/depout
add wave -noupdate -format Logic /tb_control/running
add wave -noupdate -format Logic /tb_control/clk
add wave -noupdate -format Logic /tb_control/wclk
add wave -noupdate -format Literal /tb_control/TX_ERROR
add wave -noupdate -format Logic /tb_control/UUT/running
add wave -noupdate -format Logic /tb_control/UUT/pstop
add wave -noupdate -format Logic /tb_control/UUT/estate
add wave -noupdate -format Logic /tb_control/UUT/pende
add wave -noupdate -format Logic /tb_control/UUT/cycle
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 242
configure wave -valuecolwidth 42
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
WaveRestoreZoom {568705 ps} {731193 ps}
