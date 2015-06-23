onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tbuart/clk
add wave -noupdate -format Logic /tbuart/UUT/u1/clke
add wave -noupdate -format Logic /tbuart/UUT/u1/clk16x
add wave -noupdate -format Logic /tbuart/rxd
add wave -noupdate -format Logic /tbuart/rst
add wave -noupdate -format Logic /tbuart/UUT/u1/clk1x_enable
add wave -noupdate -format Logic /tbuart/UUT/u1/clk1x
add wave -noupdate -format Logic /tbuart/UUT/u1/clk1xe
add wave -noupdate -format Literal /tbuart/UUT/u1/clkdiv
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
WaveRestoreZoom {568 ps} {629 ps}
