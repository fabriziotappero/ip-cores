onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -height 28 /sincos_tb/clk
add wave -noupdate -format Logic -height 28 /sincos_tb/rst
add wave -noupdate -format Logic -height 28 /sincos_tb/ce
add wave -noupdate -format Literal -height 28 -radix unsigned /sincos_tb/theta
add wave -noupdate -format Literal -height 28 -radix decimal /sincos_tb/y
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -height 28 -radix decimal /sincos_tb/del_theta
add wave -noupdate -format Logic -height 28 /sincos_tb/u_sin/piped_invert
add wave -noupdate -format Literal -height 28 -radix unsigned /sincos_tb/u_sin/rom_address
add wave -noupdate -format Literal -height 28 -radix unsigned /sincos_tb/u_sin/piped_abs_sin
add wave -noupdate -format Analog-Step -height 80 -max 256.0 -radix unsigned /sincos_tb/theta
add wave -noupdate -format Analog-Step -height 80 -max 128.0 -min -128.0 -radix decimal /sincos_tb/y
add wave -noupdate -format Analog-Step -height 80 -max 128.0 -min -128.0 -radix decimal /sincos_tb/o_sin
add wave -noupdate -format Analog-Step -height 80 -max 128.0 -min -128.0 -radix decimal /sincos_tb/o_cos
add wave -noupdate -format Literal /sincos_tb/worsterror
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
WaveRestoreCursors {{Cursor 1} {171548027 ps} 0} {{Cursor 2} {2577273 ps} 0} {{Cursor 3} {714545 ps} 0}
configure wave -namecolwidth 243
configure wave -valuecolwidth 139
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2940 ns}
