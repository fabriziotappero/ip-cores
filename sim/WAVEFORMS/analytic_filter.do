onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /analytic_filter_tb/clk
add wave -noupdate -format Logic /analytic_filter_tb/rst
add wave -noupdate -divider int
add wave -noupdate -format Literal -radix decimal /analytic_filter_tb/x
add wave -noupdate -format Literal -radix decimal /analytic_filter_tb/i
add wave -noupdate -format Literal -radix decimal /analytic_filter_tb/q
add wave -noupdate -format Logic /analytic_filter_tb/analytic_filter_inst/data_str_i
add wave -noupdate -format Logic /analytic_filter_tb/analytic_filter_inst/data_str_o
add wave -noupdate -divider real
add wave -noupdate -format Literal /analytic_filter_tb/x_real
add wave -noupdate -format Literal /analytic_filter_tb/i_real
add wave -noupdate -format Literal /analytic_filter_tb/q_real
add wave -noupdate -divider analog
add wave -noupdate -format Analog-Step -height 120 -offset 1.0 -scale 50.0 /analytic_filter_tb/x_real
add wave -noupdate -format Analog-Step -height 120 -offset 1.0 -scale 50.0 /analytic_filter_tb/i_real
add wave -noupdate -format Analog-Step -height 120 -offset 1.0 -scale 50.0 /analytic_filter_tb/q_real
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {65000 ps} 0}
configure wave -namecolwidth 274
configure wave -valuecolwidth 39
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
WaveRestoreZoom {0 ps} {10500 ns}
