onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /uart_transactor/clk
add wave -noupdate -format Logic /uart_transactor/rst
add wave -noupdate -format Literal -radix hexadecimal /uart_transactor/uart_if
add wave -noupdate -format Literal -radix hexadecimal /uart_transactor/dout
add wave -noupdate -format Logic /uart_transactor/ddis
add wave -noupdate -format Logic /uart_transactor/int
add wave -noupdate -format Logic /uart_transactor/baudce
add wave -noupdate -format Logic /uart_transactor/rclk
add wave -noupdate -format Logic /uart_transactor/baudoutn
add wave -noupdate -format Logic /uart_transactor/out1n
add wave -noupdate -format Logic /uart_transactor/out2n
add wave -noupdate -format Logic /uart_transactor/rtsn
add wave -noupdate -format Logic /uart_transactor/dtrn
add wave -noupdate -format Logic /uart_transactor/ctsn
add wave -noupdate -format Logic /uart_transactor/dsrn
add wave -noupdate -format Logic /uart_transactor/dcdn
add wave -noupdate -format Logic /uart_transactor/rin
add wave -noupdate -format Logic /uart_transactor/sin
add wave -noupdate -format Logic /uart_transactor/sout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 292
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
WaveRestoreZoom {0 ns} {862 ns}
