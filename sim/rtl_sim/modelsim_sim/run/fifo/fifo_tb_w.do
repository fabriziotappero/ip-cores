onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix hexadecimal /fifo_tb/prog_empty_thresh
add wave -noupdate -format Literal -radix hexadecimal /fifo_tb/prog_full_thresh
add wave -noupdate -divider {write port}
add wave -noupdate -format Logic /fifo_tb/wr_clk
add wave -noupdate -format Logic /fifo_tb/wr_en
add wave -noupdate -format Literal /fifo_tb/din
add wave -noupdate -divider read_port
add wave -noupdate -format Logic /fifo_tb/rd_clk
add wave -noupdate -format Logic /fifo_tb/rd_en
add wave -noupdate -format Literal /fifo_tb/dout
add wave -noupdate -divider flags
add wave -noupdate -format Logic /fifo_tb/prog_empty
add wave -noupdate -format Logic /fifo_tb/empty
add wave -noupdate -format Logic /fifo_tb/underflow
add wave -noupdate -format Logic /fifo_tb/prog_full
add wave -noupdate -format Logic /fifo_tb/full
add wave -noupdate -format Logic /fifo_tb/overflow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {387500 ps} 0}
configure wave -namecolwidth 192
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
WaveRestoreZoom {0 ps} {1160250 ps}
