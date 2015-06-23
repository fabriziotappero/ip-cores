onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_blue_exdep/clear
add wave -noupdate -format Logic /tb_blue_exdep/clk
add wave -noupdate -format Literal /tb_blue_exdep/accout
add wave -noupdate -format Logic /tb_blue_exdep/start
add wave -noupdate -format Logic /tb_blue_exdep/stop
add wave -noupdate -format Logic /tb_blue_exdep/exam
add wave -noupdate -format Logic /tb_blue_exdep/deposit
add wave -noupdate -format Literal /tb_blue_exdep/pcout
add wave -noupdate -format Literal /tb_blue_exdep/swreg
add wave -noupdate -format Logic /tb_blue_exdep/swloadpc
add wave -noupdate -format Literal /tb_blue_exdep/TX_ERROR
add wave -noupdate -format Literal /tb_blue_exdep/UUT/bus
add wave -noupdate -format Literal /tb_blue_exdep/UUT/cp
add wave -noupdate -format Literal /tb_blue_exdep/UUT/cpw
add wave -noupdate -format Logic /tb_blue_exdep/UUT/writepc
add wave -noupdate -format Logic /tb_blue_exdep/UUT/lwritepc
add wave -noupdate -format Logic /tb_blue_exdep/UUT/s2bus
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 213
configure wave -valuecolwidth 67
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
WaveRestoreZoom {0 ps} {15185171 ps}
